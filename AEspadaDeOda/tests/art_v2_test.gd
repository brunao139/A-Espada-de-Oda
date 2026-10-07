extends SceneTree
const Frames := preload("res://scripts/ajogun_frames.gd")
var checks := 0
var failures := 0
var scene: Node2D
var hero: CharacterBody2D
func _initialize() -> void: call_deferred("run")
func step(n: int) -> void:
 for i in range(n): await physics_frame
func check(ok: bool, label: String) -> void:
 checks += 1
 print(("PASS " if ok else "FAIL ")+label)
 if not ok: failures += 1
func spawn(at: Vector2) -> CharacterBody2D:
 var enemy := CharacterBody2D.new()
 enemy.set_script(preload("res://scripts/ajogun.gd"))
 enemy.position = at
 enemy.player = hero
 enemy.ai_enabled = false
 scene.enemies.add_child(enemy)
 return enemy
func run() -> void:
 scene = load("res://scenes/movement_lab.tscn").instantiate()
 scene.spawn_enemies = false
 root.add_child(scene)
 hero = scene.youkai
 await step(5)
 hero.set_physics_process(false)
 for at in [Vector2(700,580),Vector2(1310,342),Vector2(2290,330)]:
  for face in [1,-1]:
   var enemy := spawn(at)
   enemy.facing = face
   await step(5)
   enemy.receive_hit(6,face)
   enemy.velocity.x = 0
   var seen := {}
   var floor_ok := true
   for tick in range(78):
    await step(1)
    seen[enemy.frame_index] = true
    var info := Frames.info("death",enemy.frame_index)
    var frame: Dictionary = info.frame
    var visible_bottom: float = enemy.global_position.y+(frame.bounds[1]+frame.bounds[3]-frame.anchor[1])*info.sheet.scale
    floor_ok = floor_ok and absf(visible_bottom-enemy.global_position.y)<0.3 and enemy.global_position.y<=at.y+0.3
   check(floor_ok,"Corpo apoiado em todos os quadros; piso="+str(at.y)+" lado="+str(face))
   check(seen.size()==16 and enemy.frame_index==15,"16 poses de queda e pose final; lado="+str(face))
   var info := Frames.info("death",15)
   check(info.frame.bounds[2]>info.frame.bounds[3]*3,"Cadaver final horizontal, sem pose ajoelhada")
   enemy.queue_free()
   await step(1)
 for airborne in [false,true]:
  for face in [1,-1]:
   hero.position = Vector2(500,430 if airborne else 580)
   hero.velocity = Vector2.ZERO
   hero.health = hero.max_health
   hero.invulnerable_left = 0
   hero.hurt_left = 0
   hero.action = ""
   hero.facing = face
   hero.visual.scale.x = face
   hero.set_physics_process(true)
   await step(2)
   hero.receive_hit(1,-face)
   var seen := {}
   var name: String = "hurt_air" if airborne else "hurt_ground"
   var correct_sheet := true
   for tick in range(27):
    await step(1)
    if hero.sprite.animation.begins_with("hurt_"):
     seen[hero.sprite.frame] = true
     var texture: AtlasTexture = hero.sprite.sprite_frames.get_frame_texture(name,hero.sprite.frame)
     correct_sheet = correct_sheet and texture.atlas.resource_path.ends_with("air.png" if airborne else "ground.png") and hero.sprite.animation==name
   check(correct_sheet and seen.size()==12,"Dano usa as 12 poses corretas; ar="+str(airborne)+" lado="+str(face))
   check(hero.health==7 and not hero.attack_active,"Dano conserva vida e desativa ataque")
   check(hero.visual.scale.x==face and hero.sprite.rotation==0,"Reacao preserva espelhamento e orientacao")
   await step(50)
   check(hero.is_on_floor() and not hero.sprite.animation.begins_with("hurt_"),"Recupera controle e retorna ao piso")
   hero.set_physics_process(false)
 hero.position = Vector2(7000,580)
 var enemy := spawn(Vector2(2500,580))
 enemy.ai_enabled = true
 enemy.active = true
 enemy.facing = 1
 await step(25)
 check(enemy.frame_kind=="walk","Patrulha usa caminhada propria")
 hero.position = enemy.position+Vector2(400,0)
 await step(30)
 check(enemy.frame_kind=="run","Perseguicao usa corrida propria")
 hero.position = enemy.position+Vector2(85,0)
 enemy.cooldown = 10
 await step(20)
 check(enemy.frame_kind=="idle","Parada usa respiracao em vez de congelar caminhada")
 print("ART V2 RESULT: %d checks, %d failures" % [checks,failures])
 quit(1 if failures else 0)
