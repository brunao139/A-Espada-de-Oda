extends Node
## Demonstração por comandos reais: combo à direita, à esquerda e repetição lenta.
var scene: Node2D
var hero: CharacterBody2D
var elapsed := 0.0
var next_event := 0
var events := [
	[0.5,"heavy_attack",true], [0.6,"heavy_attack",false],
	[0.8,"heavy_attack",true], [0.9,"heavy_attack",false],
	[2.6,"move_left",true], [2.7,"move_left",false],
	[3.0,"heavy_attack",true], [3.1,"heavy_attack",false],
	[3.3,"heavy_attack",true], [3.4,"heavy_attack",false],
	[4.7,"move_right",true], [4.8,"move_right",false],
	[5.0,"slow",true],
	[5.2,"heavy_attack",true], [5.3,"heavy_attack",false],
	[5.5,"heavy_attack",true], [5.6,"heavy_attack",false]
]
func _ready() -> void:
	scene = preload("res://scenes/movement_lab.tscn").instantiate()
	add_child(scene)
	scene.set_process(false)
	scene.camera.position = Vector2(640,360)
	scene.get_node("Backdrop/City").camera_offset = 0
	hero = scene.get_node("Youkai")
	hero.position = Vector2(610,580)
func _physics_process(delta: float) -> void:
	elapsed += delta
	while next_event < events.size() and elapsed >= events[next_event][0]:
		var event: Array = events[next_event]
		if event[1] == "slow":
			Engine.time_scale = 0.4
		elif event[2]:
			Input.action_press(event[1])
		else:
			Input.action_release(event[1])
		next_event += 1
func _exit_tree() -> void:
	Engine.time_scale = 1.0
