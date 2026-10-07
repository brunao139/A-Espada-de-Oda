extends SceneTree
var checks := 0
var failures := 0
var scene: Node2D
var hero: CharacterBody2D
var enemy: CharacterBody2D
var deaths := 0
func _initialize() -> void: call_deferred("run")
func step(count: int) -> void:
 for i in range(count): await physics_frame
func check(ok: bool, note: String) -> void:
 checks += 1
 print(("PASS " if ok else "FAIL ")+note)
 if not ok: failures += 1
func spawn(at: Vector2) -> CharacterBody2D:
 var foe := CharacterBody2D.new()
 foe.set_script(preload("res://scripts/ajogun.gd"))
 foe.position = at
 foe.player = hero
 foe.ai_enabled = false
 scene.enemies.add_child(foe)
 return foe
func reset() -> void:
 for action in ["light_attack","heavy_attack","jump","move_left","move_right"]: Input.action_release(action)
 for foe in scene.enemies.get_children(): foe.queue_free()
 hero.set_physics_process(true)
 hero.dead = false
 hero.health = hero.max_health
 hero.invulnerable_left = 0
 hero.hurt_left = 0
 hero.ledge.state = ""
 hero.ledge._reset_actions()
 hero.action = ""
 hero.ground_combo_step = 0
 hero.air_combo_step = 0
 hero.air_attacks_used = 0
 hero.air_combo_left = 0
 hero.velocity = Vector2.ZERO
 hero.position = Vector2(500,580)
 hero.facing = 1
 hero.visual.rotation = 0
 hero.visual.position = Vector2.ZERO
 await step(5)
func tap(action: String) -> void:
 Input.action_press(action)
 await step(2)
 Input.action_release(action)
func run() -> void:
 scene = load("res://scenes/movement_lab.tscn").instantiate()
 scene.spawn_enemies = false
 root.add_child(scene)
 hero = scene.youkai
 await reset()
 enemy = spawn(Vector2(570,580))
 await step(4)
 check(enemy.is_on_floor(),"Ajogun pousa no piso")
 check(enemy.collision_layer == 4 and enemy.collision_mask == 1,"Camadas de alvo e mundo corretas")
 var frames = preload("res://scripts/ajogun_frames.gd")
 var valid := true
 for kind in frames.COUNTS:
  for index in range(frames.count(kind)):
   frames.apply(enemy.art,kind,index)
   valid = valid and Geometry2D.triangulate_polygon(enemy.art.polygon).size()>0
   for point in enemy.art.uv:
    valid = valid and point.x>=0 and point.y>=0 and point.x<=enemy.art.texture.get_width() and point.y<=enemy.art.texture.get_height()
 check(valid,"72 recortes validos dentro das novas folhas")
 check(frames.count("walk")==12 and frames.count("run")==12 and frames.count("hurt")==12 and frames.count("death")==16 and frames.count("attack")==16,"Novas sequencias completas")
 await tap("light_attack")
 await step(38)
 check(enemy.health==4,"GF1 aplica dois impactos reais, uma vez por janela")
 check(enemy.state=="hurt" or enemy.state=="walk","Reacao a dano e recuperacao")
 for face in [1,-1]:
  await reset()
  hero.facing = face
  enemy = spawn(Vector2(500+face*82,580))
  await step(3)
  await tap("heavy_attack")
  await step(36)
  check(enemy.health==3,"Espada causa 3 uma vez, lado "+str(face))
 await reset()
 hero.position = Vector2(500,530)
 hero.gravity = 0
 await step(2)
 hero.velocity = Vector2.ZERO
 enemy = spawn(Vector2(570,580))
 await step(3)
 await tap("light_attack")
 await step(16)
 check(hero.air_attacks_used==1 and enemy.health==5,"Golpe aereo acerta Ajogun real")
 hero.gravity = 1850
 for face in [1,-1]:
  await reset()
  hero.set_physics_process(false)
  enemy = spawn(Vector2(500-face*90,580))
  enemy.facing = face
  await step(4)
  enemy._set_state("attack")
  enemy.hit_landed = false
  await step(17)
  check(hero.health==8,"Garras sem dano na antecipacao "+str(face))
  await step(23)
  check(hero.health==7,"Garras atingem uma vez pela frente "+str(face))
  await step(24)
  check(hero.health==7 and not enemy.attack_active,"Recuperacao das garras sem dano extra "+str(face))
 await reset()
 hero.set_physics_process(false)
 enemy = spawn(Vector2(590,580))
 enemy.facing = 1
 await step(3)
 enemy._set_state("attack")
 await step(58)
 check(hero.health==8,"Garras nao acertam atras")
 await reset()
 hero.set_physics_process(false)
 enemy = spawn(Vector2(1500,580))
 enemy.facing = 1
 hero.position = Vector2(1570,580)
 await step(3)
 enemy._set_state("attack")
 await step(10)
 enemy.receive_hit(1,-1)
 await step(25)
 check(hero.health==8,"Receber dano interrompe ataque de garras")
 await reset()
 hero.set_physics_process(false)
 enemy = spawn(Vector2(410,580))
 enemy.facing = 1
 var wall := StaticBody2D.new()
 wall.position = Vector2(455,490)
 var collider := CollisionShape2D.new()
 var box := RectangleShape2D.new()
 box.size = Vector2(8,180)
 collider.shape = box
 wall.add_child(collider)
 scene.add_child(wall)
 await step(4)
 enemy._set_state("attack")
 await step(58)
 check(hero.health==8,"Garras nao atravessam parede")
 wall.queue_free()
 await reset()
 hero.receive_hit(1,1)
 hero.receive_hit(1,1)
 check(hero.health==7,"Invulnerabilidade evita dano consecutivo")
 check(hero.action=="" and not hero.attack_active,"Dano cancela acao ofensiva")
 await step(65)
 hero.receive_hit(1,-1)
 check(hero.health==6,"Dano volta apos protecao temporaria")
 await reset()
 enemy = spawn(Vector2(700,580))
 enemy.defeated.connect(func(): deaths += 1)
 await step(3)
 enemy.receive_hit(6,1)
 enemy.receive_hit(3,1)
 await step(74)
 check(enemy.state=="dead" and enemy.frame_index==15,"Morte cai e mantem pose final")
 check(enemy.collision_layer==0 and deaths==1,"Cadaver deixa de ser alvo e conta uma unica morte")
 await step(265)
 check(not is_instance_valid(enemy),"Cadaver desaparece apos animacao e espera")
 await reset()
 hero.receive_hit(8,1)
 await tap("heavy_attack")
 await step(10)
 check(hero.dead and hero.health==0 and hero.action=="" and not hero.attack_active,"Youkai derrotado nao ataca")
 await reset()
 hero.position = Vector2(1310,338)
 hero.set_physics_process(false)
 enemy = spawn(Vector2(1350,338))
 enemy.ai_enabled = true
 enemy.active = true
 enemy.player = null
 enemy.facing = 1
 await step(170)
 check(absf(enemy.position.y-342)<1 and enemy.position.x>1220 and enemy.position.x<1400,"Patrulha nao cai da plataforma")
 await reset()
 enemy = spawn(Vector2(800,580))
 enemy.ai_enabled = true
 enemy.player = hero
 await step(60)
 check(enemy.position.x<760,"Ajogun persegue Youkai ao detectar")
 check(scene.get_node("Geometry").get_child_count()==11,"Piso, limites e oito plataformas preservados")
 var source := FileAccess.get_file_as_string("res://scripts/city_environment.gd")
 var backdrop := FileAccess.get_file_as_string("res://scripts/city_backdrop.gd")
 check(not source.contains("draw_string") and not backdrop.contains("draw_string"),"Cenario sem escritos desenhados")
 scene.queue_free()
 await step(2)
 change_scene_to_file("res://scenes/movement_lab.tscn")
 await step(12)
 scene = current_scene
 hero = scene.youkai
 check(scene.enemy_total==14 and scene.enemies.get_child_count()==14,"Fase normal cria 14 Ajoguns")
 var supported := true
 for foe in scene.enemies.get_children():
  foe.ai_enabled = false
  supported = supported and foe.is_on_floor()
 check(supported,"Todos os encontros nascem sobre piso ou plataforma")
 for foe in scene.enemies.get_children(): foe.receive_hit(99,1)
 await step(2)
 check(scene.defeated_count==14,"Contador registra todos os Ajoguns derrotados")
 hero.invulnerable_left = 0
 hero.receive_hit(99,1)
 Input.action_press("reset_lab")
 await step(3)
 Input.action_release("reset_lab")
 await step(6)
 scene = current_scene
 check(not scene.youkai.dead and scene.youkai.health==8,"R restaura Youkai depois da derrota")
 check(scene.defeated_count==0 and scene.enemies.get_child_count()==14,"R restaura inimigos e contador")
 print("AJOGUN RESULT: %d checks, %d failures" % [checks,failures])
 quit(1 if failures else 0)
