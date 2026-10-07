extends CharacterBody2D
## Ajogun: patrulha, perseguição, garras, reação e morte.
signal defeated
const Frames := preload("res://scripts/ajogun_frames.gd")
const ATTACK_DURATION := 0.92
const HIT_START := 0.345
const HIT_END := 0.575
const HURT_DURATION := 0.42
const DEATH_DURATION := 1.12
@export var max_health := 6
@export var patrol_radius := 180.0
@export var walk_speed := 72.0
@export var chase_speed := 115.0
var health := 6
var state := "walk"
var state_time := 0.0
var facing := -1
var home_x := 0.0
var cooldown := 0.8
var hit_landed := false
var hit_flash := 0.0
var attack_active := false
var active := false
var ai_enabled := true
var debug_shapes := false
var frame_kind := "walk"
var frame_index := 0
var player: CharacterBody2D
var art: Polygon2D
var claw_shape: RectangleShape2D
var attack_attempts := 0
var locomotion_phase := 0.0
const FLASH_DURATION := 0.24
const LANDING_DURATION := 0.85
var thrown_death := false

func _ready() -> void:
 health = max_health
 home_x = position.x
 collision_layer = 4
 collision_mask = 1
 floor_snap_length = 6
 add_to_group("ajoguns")
 var capsule := CapsuleShape2D.new()
 capsule.radius = 24
 capsule.height = 158
 var body := CollisionShape2D.new()
 body.name = "Body"
 body.shape = capsule
 body.position = Vector2(0,-79)
 add_child(body)
 claw_shape = RectangleShape2D.new()
 claw_shape.size = Vector2(146,60)
 art = Polygon2D.new()
 art.name = "Art"
 art.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
 var flash_material := ShaderMaterial.new()
 flash_material.shader = preload("res://scripts/hit_flash.gdshader")
 art.material = flash_material
 add_child(art)
 _update_visual()

func _physics_process(delta: float) -> void:
 state_time += delta
 cooldown = maxf(0,cooldown-delta)
 hit_flash = maxf(0,hit_flash-delta)
 attack_active = false
 if state == "launch":
  velocity.x = move_toward(velocity.x,0,90*delta)
 elif state == "landing":
  velocity.x = move_toward(velocity.x,0,1500*delta)
  if state_time >= LANDING_DURATION:
   cooldown = 0.65
   _set_state("walk")
 elif state == "dead":
  velocity.x = move_toward(velocity.x,0,650*delta)
 elif state == "hurt":
  velocity.x = move_toward(velocity.x,0,700*delta)
  if state_time >= HURT_DURATION: _set_state("walk")
 elif state == "attack":
  velocity.x = move_toward(velocity.x,0,1000*delta)
  attack_active = state_time >= HIT_START and state_time < HIT_END
  if attack_active and not hit_landed: _strike()
  if state_time >= ATTACK_DURATION:
   cooldown = 0.65
   _set_state("walk")
 elif ai_enabled:
  _think(delta)
 else:
  velocity.x = 0
 velocity.y = minf(1050,velocity.y+1850*delta)
 move_and_slide()
 if state == "launch" and is_on_floor() and velocity.y >= 0:
  _set_state("dead" if health == 0 else "landing")
 locomotion_phase += absf(velocity.x)*delta/(86.0 if absf(velocity.x)>90 else 64.0)
 _update_visual()
 queue_redraw()

func _think(delta: float) -> void:
 var tracking: bool = is_instance_valid(player) and not player.dead
 if not active:
  active = tracking and absf(player.global_position.x-global_position.x)<760
  if not active:
   velocity.x = 0
   return
 var desired := facing*walk_speed
 if tracking:
  var distance := player.global_position-global_position
  if absf(distance.x)<520 and absf(distance.y)<220 and _line_clear(player.global_position+Vector2(0,-90)):
   if absf(distance.x)>8: facing = 1 if distance.x>0 else -1
   desired = facing*chase_speed
   if absf(distance.x)<108 and absf(distance.y)<65 and is_on_floor():
    desired = 0
    if cooldown<=0:
     _set_state("attack")
     hit_landed = false
     attack_attempts += 1
     return
  elif absf(position.x-home_x)>patrol_radius:
   facing = 1 if position.x<home_x else -1
   desired = facing*walk_speed
 if is_on_floor() and (is_on_wall() or not _floor_ahead()):
  facing *= -1
  desired = 0
 velocity.x = move_toward(velocity.x,desired,650*delta)

func _floor_ahead() -> bool:
 var start := global_position+Vector2(facing*40,-12)
 var query := PhysicsRayQueryParameters2D.create(start,start+Vector2(0,42),1,[get_rid()])
 return not get_world_2d().direct_space_state.intersect_ray(query).is_empty()

func _line_clear(to: Vector2) -> bool:
 var query := PhysicsRayQueryParameters2D.create(global_position+Vector2(0,-100),to,1,[get_rid()])
 return get_world_2d().direct_space_state.intersect_ray(query).is_empty()

func _strike() -> void:
 var query := PhysicsShapeQueryParameters2D.new()
 query.shape = claw_shape
 query.transform = Transform2D(0,global_position+Vector2(facing*82,-110))
 query.collision_mask = 2
 query.exclude = [get_rid()]
 for result in get_world_2d().direct_space_state.intersect_shape(query):
  var victim: Node2D = result.collider
  if victim.has_method("receive_hit") and _line_clear(victim.global_position+Vector2(0,-90)):
   victim.receive_hit(1,facing)
   hit_landed = true
   break

func receive_hit(damage: int, direction: int) -> void:
 if health <= 0 or damage<=0: return
 health = maxi(0,health-damage)
 active = true
 hit_flash = FLASH_DURATION
 velocity.x = direction*(155 if damage>=3 else 70)
 velocity.y = -170.0
 attack_active = false
 cooldown = 0.5
 if health == 0:
  _set_state("dead")
  set_deferred("collision_layer",0)
  defeated.emit()
 else:
  _set_state("hurt")
 _update_visual()

func receive_combo_finisher(damage: int, direction: int) -> void:
 if health <= 0 or damage <= 0: return
 receive_hit(damage,direction)
 thrown_death = health == 0
 facing = -direction
 velocity = Vector2(direction*440,-350)
 _set_state("launch")
 _update_visual()

func _set_state(value: String) -> void:
 state = value
 state_time = 0

func _update_visual() -> void:
 if state == "launch":
  frame_kind = "launch"
  # Progressão balística: a pose acompanha subida, ápice e descida.
  frame_index = clampi(int((velocity.y+350.0)/700.0*12.0),0,11)
 elif state == "landing" or (state == "dead" and thrown_death):
  frame_kind = "landing"
  frame_index = mini(3,int(state_time/0.28*4)) if health == 0 else mini(11,int(state_time/LANDING_DURATION*12))
 elif state == "dead":
  frame_kind = "death"
  frame_index = mini(15,int(state_time/DEATH_DURATION*16))
 elif state == "hurt":
  frame_kind = "hurt"
  frame_index = mini(11,int(state_time/HURT_DURATION*12))
 elif state == "attack":
  frame_kind = "attack"
  # Seis quadros de preparo, quatro de impacto e seis de recuperação.
  if state_time<HIT_START:
   frame_index = mini(5,int(state_time/HIT_START*6))
  elif state_time<HIT_END:
   frame_index = 6+mini(3,int((state_time-HIT_START)/(HIT_END-HIT_START)*4))
  else:
   frame_index = 10+mini(5,int((state_time-HIT_END)/(ATTACK_DURATION-HIT_END)*6))
 elif absf(velocity.x)>5:
  frame_kind = "run" if absf(velocity.x)>90 else "walk"
  frame_index = int(locomotion_phase*12)%12
 else:
  frame_kind = "idle"
  frame_index = int(state_time*4)%4
 Frames.apply(art,frame_kind,frame_index)
 art.scale.x = facing
 var bright := hit_flash > 0 and int((FLASH_DURATION-hit_flash)/0.04)%2 == 0
 art.material.set_shader_parameter("flash",0.9 if bright else 0.0)
 art.color = Color.WHITE
 art.modulate.a = 0.38 if hit_flash > 0 and not bright else 1.0
 if state == "dead":
  art.modulate.a *= clampf(1.0-(state_time-4.0)/1.5,0,1)
  if state_time>5.5: queue_free()
func _draw() -> void:
 if health>0 and health<max_health:
  draw_rect(Rect2(-25,-194,50,4),Color("1d2430"))
  draw_rect(Rect2(-25,-194,50*float(health)/max_health,4),Color("d58f96"))
 if debug_shapes:
  draw_rect(Rect2(-24,-158,48,158),Color(0.8,0.3,0.7),false,1)
  if attack_active:
   draw_rect(Rect2(Vector2(facing*82,-110)-claw_shape.size/2,claw_shape.size),Color(1,0.25,0.3,0.3))
