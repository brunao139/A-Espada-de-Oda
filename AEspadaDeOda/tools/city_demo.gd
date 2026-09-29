extends Node
## Mostra os três distritos em cortes de câmera; não faz parte do jogo.
var scene: Node2D
var elapsed := 0.0
var district := -1
func _ready() -> void:
	scene = preload("res://scenes/movement_lab.tscn").instantiate()
	add_child(scene)
	scene.set_process(false)
func _process(delta: float) -> void:
	elapsed += delta
	var next := mini(2,int(elapsed/4.0))
	if next != district:
		district = next
		var positions := [Vector2(600,580),Vector2(4380,330),Vector2(8640,456)]
		var cameras := [640.0,4420.0,8360.0]
		scene.youkai.position = positions[district]
		scene.youkai.velocity = Vector2.ZERO
		scene.camera.position.x = cameras[district]
		scene.get_node("Backdrop/City").camera_offset = cameras[district]-640
	scene.queue_redraw()
