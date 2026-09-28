extends Node
## Demonstração reproduzível por entradas reais, sem mover o personagem após o início.
var scene: Node2D
var hero: CharacterBody2D
var elapsed := 0.0
var stage := 0
func _ready() -> void:
	scene = preload("res://scenes/movement_lab.tscn").instantiate()
	add_child(scene)
	scene.set_process(false)
	scene.camera.position = Vector2(2300,360)
	scene.get_node("Backdrop/City").camera_offset = 1660
	hero = scene.get_node("Youkai")
	hero.position = Vector2(2060,580)
func _physics_process(delta: float) -> void:
	elapsed += delta
	if stage == 0 and elapsed >= 0.6:
		Input.action_press("move_right")
		Input.action_press("jump")
		stage = 1
	elif stage == 1 and hero.ledge.state == "hang":
		Input.action_release("move_right")
		Input.action_release("jump")
		stage = 2
	elif stage == 2 and elapsed >= 2.5:
		Input.action_press("jump")
		stage = 3
	elif stage == 3 and elapsed >= 3.5:
		Input.action_release("jump")
		Input.action_press("move_right")
		stage = 4
	elif stage == 4 and elapsed >= 3.8:
		Input.action_release("move_right")
		stage = 5
