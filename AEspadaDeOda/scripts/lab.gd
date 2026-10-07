extends Node2D
## Cidade contínua, plataformas e encontros com Ajoguns.
@export var spawn_enemies := true
@onready var youkai: CharacterBody2D = $Youkai
@onready var camera: Camera2D = $Camera2D
var world_width := 9000.0
var defeated_count := 0
var enemy_total := 0
var enemies: Node2D
var shake_left := 0.0
var shake_events := 0
const SHAKE_DURATION := 0.20
const SPAWNS := [Vector2(720,580),Vector2(1310,338),Vector2(1990,580),Vector2(2290,330),Vector2(2810,580),Vector2(3650,580),Vector2(4240,580),Vector2(4740,440),Vector2(5270,580),Vector2(5730,580),Vector2(6800,580),Vector2(7580,580),Vector2(8140,580),Vector2(8640,456)]
func _ready() -> void:
 $HUD/Interface.player = youkai
 world_width = $Geometry/Floor/Shape.shape.size.x
 camera.limit_right = int(world_width)
 camera.position = Vector2(640,360)
 youkai.finisher_executed.connect(_on_finisher)
 enemies = Node2D.new()
 enemies.name = "Enemies"
 add_child(enemies)
 if spawn_enemies:
  for point in SPAWNS:
   var enemy := CharacterBody2D.new()
   enemy.set_script(preload("res://scripts/ajogun.gd"))
   enemy.position = point
   enemy.player = youkai
   enemy.defeated.connect(_on_enemy_defeated)
   enemies.add_child(enemy)
   enemy_total += 1
func _on_enemy_defeated() -> void:
 defeated_count += 1
func _on_finisher() -> void:
 shake_left = SHAKE_DURATION
 shake_events += 1
func _process(delta: float) -> void:
 shake_left = maxf(0,shake_left-delta)
 var elapsed := SHAKE_DURATION-shake_left
 var amplitude := 3.0*shake_left/SHAKE_DURATION
 camera.offset = Vector2(sin(elapsed*117),cos(elapsed*93))*amplitude if shake_left>0 else Vector2.ZERO
 var target_x := clampf(youkai.position.x+youkai.facing*90,640,world_width-640)
 camera.position.x = lerpf(camera.position.x,target_x,1.0-exp(-5.0*delta))
 $Backdrop/City.camera_offset = camera.position.x-640.0
 if youkai.position.y > 900 or Input.is_action_just_pressed("reset_lab"):
  get_tree().reload_current_scene()
 if Input.is_action_just_pressed("debug_hitbox"):
  youkai.debug_shapes = not youkai.debug_shapes
  for enemy in enemies.get_children(): enemy.debug_shapes = youkai.debug_shapes
 queue_redraw()
func _draw() -> void:
 var left := camera.position.x-720 if is_instance_valid(camera) else 0.0
 var right := left+1440
 for body in $Geometry.get_children():
  var box: RectangleShape2D = body.get_node("Shape").shape
  var rect := Rect2(body.position-box.size/2,box.size)
  if rect.end.x < left or rect.position.x > right: continue
  draw_rect(Rect2(rect.position+Vector2(0,7),rect.size+Vector2(0,9)),Color(0.015,0.035,0.075,0.8))
  draw_rect(rect,Color("#0b172b"))
  if body.name in ["LeftWall","RightWall"]: continue
  var neon := Color("#84e7ee")
  if rect.position.x >= 3000: neon = Color("#eba1d2") if rect.position.x < 6000 else Color("#f0c684")
  draw_line(rect.position,rect.position+Vector2(rect.size.x,0),Color(neon,0.08),12)
  draw_line(rect.position,rect.position+Vector2(rect.size.x,0),neon,3)
  draw_line(rect.position+Vector2(0,4),rect.position+Vector2(rect.size.x,4),Color("#32657a"),2)
  if body.name != "Floor":
   for x in range(int(rect.position.x)+16,int(rect.end.x)-12,32):
    draw_line(Vector2(x,rect.position.y+17),Vector2(x+7,rect.position.y+24),Color("#63878a"),2)
 var start := maxi(0,int(floor(left/160.0))*160)
 for x in range(start,mini(int(world_width),int(right)+160),160):
  draw_rect(Rect2(x+10,609,140,50),Color("#102339"))
  draw_line(Vector2(x+12,611),Vector2(x+148,611),Color("#224054"),1)
  for stripe in range(4):
   draw_line(Vector2(x+22+stripe*32,596),Vector2(x+34+stripe*32,596),Color("#75969b"),2)
