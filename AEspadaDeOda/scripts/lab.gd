extends Node2D
## Primeiro trecho da cidade: passarelas sólidas e fundo com paralaxe.

@onready var youkai: CharacterBody2D = $Youkai
@onready var camera: Camera2D = $Camera2D

func _ready() -> void:
	$HUD/Interface.player = youkai
	camera.position = Vector2(640, 360)

func _process(delta: float) -> void:
	var target_x := clampf(youkai.position.x + youkai.facing * 90, 640, 2360)
	camera.position.x = lerpf(camera.position.x, target_x, 1.0 - exp(-5.0 * delta))
	$Backdrop/City.camera_offset = camera.position.x - 640.0
	if youkai.position.y > 900:
		get_tree().reload_current_scene()
	if Input.is_action_just_pressed("reset_lab"):
		get_tree().reload_current_scene()
	if Input.is_action_just_pressed("debug_hitbox"):
		youkai.debug_shapes = not youkai.debug_shapes

func _draw() -> void:
	for body in $Geometry.get_children():
		var collider: CollisionShape2D = body.get_node("Shape")
		var box := collider.shape as RectangleShape2D
		var rect := Rect2(body.position - box.size / 2, box.size)
		draw_rect(Rect2(rect.position + Vector2(0, 7), rect.size + Vector2(0, 9)), Color(0.015, 0.035, 0.075, 0.8))
		draw_rect(rect, Color("0b172b"))
		draw_line(rect.position, rect.position + Vector2(rect.size.x, 0), Color("84e7ee"), 3)
		draw_line(rect.position + Vector2(0, 4), rect.position + Vector2(rect.size.x, 4), Color("32657a"), 2)
		if body.name != "Floor" and body.name != "LeftWall" and body.name != "RightWall":
			draw_line(rect.position + Vector2(0, 12), rect.position + Vector2(rect.size.x, 12), Color("284455"), 1)
			for x in range(int(rect.position.x) + 16, int(rect.end.x) - 12, 32):
				draw_line(Vector2(x, rect.position.y + 17), Vector2(x + 7, rect.position.y + 24), Color("63878a"), 2)
	draw_string(ThemeDB.fallback_font, Vector2(2188, 373), "TESTE DE BEIRADA", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("ecc77c"))
	draw_string(ThemeDB.fallback_font, Vector2(2188, 400), "Pule em direção à quina", HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color("c2dce3"))
	for x in range(32, 3000, 40):
		draw_line(Vector2(x, 596), Vector2(x + 12, 596), Color("75969b"), 2)
	for x in range(0, 3000, 160):
		draw_rect(Rect2(x + 10, 609, 140, 50), Color("102339"))
		draw_line(Vector2(x + 12, 611), Vector2(x + 148, 611), Color("224054"), 1)
		draw_rect(Rect2(x + 30, 617, 40, 3), Color("31778c"))
