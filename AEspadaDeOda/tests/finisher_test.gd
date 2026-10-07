extends SceneTree
const Frames := preload("res://scripts/ajogun_frames.gd")
var checks := 0
var failures := 0
var scene: Node2D
var hero: CharacterBody2D
var started: Array[String] = []
func _initialize() -> void: call_deferred("run")
func step(n: int) -> void:
 for i in range(n): await physics_frame
func check(ok: bool, label: String) -> void:
 checks += 1
 print(("PASS " if ok else "FAIL ")+label)
 if not ok: failures += 1
func tap() -> void:
 Input.action_press("light_attack")
 await step(2)
 Input.action_release("light_attack")
func spawn(at: Vector2, hp: int = 6) -> CharacterBody2D:
 var enemy := CharacterBody2D.new()
 enemy.set_script(preload("res://scripts/ajogun.gd"))
 enemy.max_health = hp
 enemy.position = at
 enemy.ai_enabled = false
 enemy.player = hero
 scene.enemies.add_child(enemy)
 return enemy
func reset_hero(face: int = 1) -> void:
 hero.set_physics_process(true)
 hero.position = Vector2(700,580)
 hero.velocity = Vector2.ZERO
 hero.gravity = 1850
 hero.action = ""
 hero.queued_attack = ""
 hero.queued_time = 0
 hero.combo_left = 0
 hero.heavy_combo_left = 0
 hero.air_combo_left = 0
 hero.air_combo_step = 0
 hero.air_attacks_used = 0
 hero.ground_combo_step = 0
 hero.jump_buffer = 0
 hero.facing = face
 await step(5)
 started.clear()
func run() -> void:
 scene = load("res://scenes/movement_lab.tscn").instantiate()
 scene.spawn_enemies = false
 root.add_child(scene)
 hero = scene.youkai
 hero.attack_started.connect(func(kind: String): started.append(kind))
 await step(5)
 check(is_equal_approx(hero.attack_speed,0.8),"Velocidade padrao 20% menor")
 check(hero.sprite.sprite_frames.get_frame_count("gf5")==12,"12 poses novas para GF5")
 var source := Frames.source("gf5")
 var stable := true
 for index in range(12):
  var frame: Dictionary = source.frames[index]
  var height: float = frame.bounds[3]*hero.new_frame_scales.gf5[index].y
  stable = stable and absf(height-176)<0.5
 check(stable,"GF5 mantem 176 unidades de altura em todos os quadros")
 # Mede todas as durações reais com relógio padrão, incluindo golpes aéreos.
 for kind in hero.ATTACK_DURATION:
  await reset_hero()
  if String(kind).begins_with("gfa"):
   hero.position.y = -300
   hero.gravity = 0
   await step(2)
   hero.velocity = Vector2.ZERO
   hero.air_combo_step = int(String(kind).right(1))-1
   hero.air_attacks_used = hero.air_combo_step
   hero.air_combo_left = 2
  elif String(kind).begins_with("gf") and not String(kind).begins_with("gff"):
   hero.ground_combo_step = int(String(kind).right(1))-1
   hero.combo_left = 2
  else:
   hero.next_is_uppercut = kind=="gff2"
   hero.heavy_combo_left = 2
  hero._start_attack("heavy" if String(kind).begins_with("gff") else "light")
  var ticks := 0
  var synchronized := true
  while hero.action != "" and ticks<140:
   await step(1)
   ticks += 1
   if hero.attack_active:
    var inside := false
    for window in hero.attack_windows():
     inside = inside or (hero.action_time+0.00001>=window.x and hero.action_time<window.y)
    synchronized = synchronized and inside
  var expected: float = hero.ATTACK_DURATION[kind]/0.8
  check(absf(ticks/60.0-expected)<0.04 and synchronized,"Duracao e dano sincronizados a 0.8: "+kind)
 # Sequência completa com entradas reais, alvo vivo e espelhamento.
 for face in [1,-1]:
  await reset_hero(face)
  var enemy := spawn(Vector2(700+face*70,580))
  var defeats := [0]
  enemy.defeated.connect(func(): defeats[0]+=1)
  await step(4)
  var before_shakes: int = scene.shake_events
  await tap()
  var queued_for := ""
  var seen := {}
  var held_ticks := 0
  var flash_low := false
  var flash_white := false
  var lifted := false
  var thrown := false
  var last_hp := 6
  var damage_steps: Array[int] = []
  for tick in range(260):
   if hero.action != "" and hero.action != "gf5" and hero.action != queued_for and hero.action_time>hero.action_duration*0.55:
    queued_for = hero.action
    await tap()
   if hero.action=="gf5":
    seen[hero.sprite.frame] = true
    if hero.sprite.frame==11: held_ticks += 1
   if enemy.health!=last_hp:
    last_hp = enemy.health
    damage_steps.append(last_hp)
   flash_low = flash_low or enemy.art.modulate.a<0.5
   flash_white = flash_white or float(enemy.art.material.get_shader_parameter("flash"))>0.5
   lifted = lifted or (enemy.state=="hurt" and enemy.position.y<578)
   thrown = thrown or (enemy.state=="launch" and enemy.velocity.x*face>300)
   await step(1)
  check(started==["gf1","gf2","gf3","gf4","gf5"],"Cinco toques reais encadeiam GF1 a GF5 lado="+str(face)+str(started))
  check(seen.size()==12 and held_ticks>=17,"Todas as poses e braco estendido por pelo menos 0.28 s: "+str(face))
  check(flash_low and flash_white and lifted,"Impactos piscam e elevam suavemente: "+str(face))
  check(damage_steps==[5,4,3,2,1,0] and thrown,"Combo conectado causa seis impactos e arremessa: "+str(face)+str(damage_steps))
  check(defeats[0]==1 and enemy.health==0 and enemy.state=="dead","Morte conta uma vez e conclui queda: "+str(face))
  check(enemy.frame_kind=="landing" and enemy.frame_index==3 and enemy.is_on_floor(),"Arremesso fatal termina deitado e apoiado: "+str(face))
  var data := Frames.info(enemy.frame_kind,enemy.frame_index)
  var bottom: float = enemy.position.y+(data.frame.bounds[1]+data.frame.bounds[3]-data.frame.anchor[1])*data.sheet.scale
  check(absf(bottom-580)<0.5,"Corpo fatal alinhado ao chao: "+str(face))
  check(scene.shake_events==before_shakes+1 and scene.camera.offset==Vector2.ZERO,"Um tremor por GF5 sem deslocamento residual: "+str(face))
  enemy.queue_free()
  await step(2)
 # Encontro real, com a IA ativa, usando a mesma sequência de botões.
 await reset_hero()
 var live_enemy := spawn(Vector2(770,580))
 live_enemy.ai_enabled = true
 live_enemy.active = true
 await step(4)
 await tap()
 var queued_for := ""
 for tick in range(240):
  if hero.action!="" and hero.action!="gf5" and hero.action!=queued_for and hero.action_time>hero.action_duration*0.55:
   queued_for = hero.action
   await tap()
  await step(1)
 check(started==["gf1","gf2","gf3","gf4","gf5"] and live_enemy.health==0,"Combo completo funciona contra IA ativa")
 live_enemy.queue_free()
 await reset_hero()
 Input.action_press("light_attack")
 await step(180)
 Input.action_release("light_attack")
 check(started==["gf1"],"Segurar botao nao produz GF5 automaticamente")
 await reset_hero()
 hero.ground_combo_step = 4
 hero.combo_left = 1
 await tap()
 await step(20)
 hero.receive_hit(1,-1)
 await step(2)
 check(hero.action=="" and not hero.attack_active and hero.queued_attack=="","Receber dano cancela GF5 e a fila")
 hero.hurt_left = 0
 hero.invulnerable_left = 0
 await reset_hero()
 hero.ground_combo_step = 4
 hero.combo_left = 0.05
 await step(8)
 await tap()
 check(hero.action=="gf1","Pausa quebra combo antes do GF5")
 # Todo hit normal sobe um pouco, sem se transformar em lançamento.
 await reset_hero()
 hero.set_physics_process(false)
 for face in [1,-1]:
  var enemy := spawn(Vector2(2800,580),20)
  await step(4)
  for damage in [1,1,3]:
   enemy.receive_hit(damage,face)
   var min_y := enemy.position.y
   for tick in range(32):
    await step(1)
    min_y = minf(min_y,enemy.position.y)
   check(min_y>570 and min_y<577 and enemy.is_on_floor(),"Cada hit gera salto sutil e volta ao chao: "+str(damage)+"/"+str(face))
  check(enemy.art.modulate.a==1 and float(enemy.art.material.get_shader_parameter("flash"))==0,"Piscada termina e restaura arte: "+str(face))
  enemy.receive_combo_finisher(1,face)
  var start_x: float = enemy.position.x
  await step(90)
  check((enemy.position.x-start_x)*face>100 and enemy.state=="walk" and enemy.is_on_floor(),"Sobrevivente e arremessado, pousa e se levanta: "+str(face))
  enemy.queue_free()
  await step(2)
 var wall_enemy := spawn(Vector2(8950,580),20)
 await step(4)
 wall_enemy.receive_combo_finisher(1,1)
 await step(90)
 check(wall_enemy.position.x<9000 and wall_enemy.state=="walk" and wall_enemy.is_on_floor(),"Arremesso respeita parede e recupera no piso")
 wall_enemy.queue_free()
 # Tremor leve, limitado e zerado; não depende de acertar inimigo.
 scene._on_finisher()
 var max_offset := 0.0
 for tick in range(30):
  scene._process(1.0/60.0)
  max_offset = maxf(max_offset,scene.camera.offset.length())
 check(max_offset>1 and max_offset<=4.25 and scene.camera.offset==Vector2.ZERO,"Tremor leve menor que 4.25 px e dura 0.20 s")
 print("FINISHER RESULT: %d checks, %d failures" % [checks,failures])
 quit(1 if failures else 0)
