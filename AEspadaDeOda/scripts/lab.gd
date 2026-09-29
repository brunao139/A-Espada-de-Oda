extends Node2D
## Cidade contínua: piso seguro, rotas elevadas e limites derivados da geometria.
@onready var youkai: CharacterBody2D = $Youkai
@onready var camera: Camera2D = $Camera2D
var world_width := 9000.0
func _ready() -> void:
	$HUD/Interface.player = youkai
	world_width = $Geometry/Floor/Shape.shape.size.x
	camera.limit_right = int(world_width)
	camera.position = Vector2(640,360)
func _process(delta: float) -> void:
	var target_x := clampf(youkai.position.x+youkai.facing*90,640,world_width-640)
	camera.position.x = lerpf(camera.position.x,target_x,1.0-exp(-5.0*delta))
	$Backdrop/City.camera_offset = camera.position.x-640.0
	if youkai.position.y > 900 or Input.is_action_just_pressed("reset_lab"):
		get_tree().reload_current_scene()
	if Input.is_action_just_pressed("debug_hitbox"):
		youkai.debug_shapes = not youkai.debug_shapes
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
			if rect.size.y > 80:
				# Painéis, dutos e ventilação distinguem a torre sólida do fundo.
				var panel := rect.grow(-12)
				panel.position.y += 18
				panel.size.y -= 18
				draw_rect(panel,Color("#10243a"))
				draw_rect(panel,Color("#294355"),false,1)
				for seam in range(1,3):
					var seam_x := panel.position.x+panel.size.x*seam/3
					draw_line(Vector2(seam_x,panel.position.y),Vector2(seam_x,panel.end.y),Color("#1d374c"),2)
				var center := rect.position+Vector2(rect.size.x*0.5,80)
				draw_circle(center,29,Color("#071423"))
				draw_arc(center,29,0,TAU,32,Color("#3d6476"),2)
				var time: float = $CityDetails.elapsed
				for blade in range(4):
					var angle := time*2.6+blade*PI/2
					draw_line(center+Vector2.from_angle(angle)*7,center+Vector2.from_angle(angle+0.4)*24,Color("#416f7c"),6)
				draw_circle(center,5,neon)
				draw_line(panel.position+Vector2(7,5),Vector2(panel.position.x+7,panel.end.y-10),Color(neon,0.3),2)
				for x in range(int(rect.position.x)+16,int(rect.end.x)-12,48):
					draw_rect(Rect2(x,rect.end.y-24,24,3),Color(neon,0.55))
	draw_string(ThemeDB.fallback_font,Vector2(2188,373),"TESTE DE BEIRADA",HORIZONTAL_ALIGNMENT_LEFT,-1,18,Color("#ecc77c"))
	draw_string(ThemeDB.fallback_font,Vector2(2188,400),"Pule em direção à quina",HORIZONTAL_ALIGNMENT_LEFT,-1,15,Color("#c2dce3"))
	var start := maxi(0,int(floor(left/160.0))*160)
	for x in range(start,mini(int(world_width),int(right)+160),160):
		draw_rect(Rect2(x+10,609,140,50),Color("#102339"))
		draw_line(Vector2(x+12,611),Vector2(x+148,611),Color("#224054"),1)
		draw_rect(Rect2(x+30,617,40,3),Color("#31778c"))
		for stripe in range(4):
			draw_line(Vector2(x+22+stripe*32,596),Vector2(x+34+stripe*32,596),Color("#75969b"),2)
