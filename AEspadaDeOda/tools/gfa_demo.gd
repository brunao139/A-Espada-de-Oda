extends SceneTree
## Demonstração com entradas reais. -- --capture-dir=CAMINHO salva os quatro impactos.
var hero: CharacterBody2D
var captured: Array[String] = []
var queued_for := ""
var elapsed := 0
var capture_dir := ""

func _initialize() -> void:
	call_deferred("run_demo")

func run_demo() -> void:
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--capture-dir="):
			capture_dir = argument.trim_prefix("--capture-dir=")
	var scene = load("res://scenes/movement_lab.tscn").instantiate()
	root.add_child(scene)
	hero = scene.get_node("Youkai")
	Engine.time_scale = 0.35
	for i in range(8): await physics_frame
	Input.action_press("jump")
	for i in range(10): await physics_frame
	Input.action_press("light_attack")
	for i in range(2): await physics_frame
	Input.action_release("light_attack")
	while elapsed < 160:
		await physics_frame
		elapsed += 1
		if hero.is_air_attack():
			if hero.attack_active and not hero.action in captured:
				var name: String = hero.action
				captured.append(name)
				if capture_dir != "":
					await RenderingServer.frame_post_draw
					var error := root.get_texture().get_image().save_png(capture_dir.path_join(name + ".png"))
					if error != OK:
						push_error("Falha ao salvar captura: " + str(error))
						quit(1)
						return
			if hero.action != queued_for and hero.action_time > hero.action_duration * 0.5:
				queued_for = hero.action
				Input.action_press("light_attack")
				await physics_frame
				await physics_frame
				Input.action_release("light_attack")
	Input.action_release("jump")
	print("GFA DEMO: ", captured, " captures: ", capture_dir)
	quit(0 if captured.size() == 4 else 1)
