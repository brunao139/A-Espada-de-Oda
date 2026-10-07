extends SceneTree
## Demonstração determinística com comandos reais. Pode ser gravada com --write-movie.
var hero: CharacterBody2D
var capture_dir := ""
var phase_label: Label
func _initialize() -> void: call_deferred("run_demo")
func step(count: int) -> void:
	for i in range(count): await physics_frame
func tap(action: String) -> void:
	Input.action_press(action)
	await step(2)
	Input.action_release(action)
func run_demo() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--capture-dir="): capture_dir = arg.trim_prefix("--capture-dir=")
	var scene = load("res://scenes/movement_lab.tscn").instantiate()
	root.add_child(scene)
	hero = scene.get_node("Youkai")
	phase_label = Label.new()
	phase_label.position = Vector2(390,125)
	phase_label.add_theme_font_size_override("font_size",24)
	scene.get_node("HUD").add_child(phase_label)
	await step(8)
	for mode in ["ground", "air", "slow_ground", "slow_air"]:
		hero.position = Vector2(600,580)
		hero.velocity = Vector2.ZERO
		hero.combo_left = 0
		hero.air_combo_left = 0
		Engine.time_scale = 0.45 if mode.begins_with("slow") else 1.0
		var airborne: bool = mode.ends_with("air")
		phase_label.text = ("GFA4 · 16 poses no ar" if airborne else "GF4 · 24 poses + salto") + ("  /  CÂMERA LENTA" if mode.begins_with("slow") else "")
		await step(30)
		if airborne:
			Input.action_press("jump")
			await step(3)
		await tap("light_attack")
		var queued_for := ""
		var captured := false
		var seen: Array[int] = []
		for tick in range(400 if mode.begins_with("slow") else 180):
			if hero.action in ["gf4","gfa4"]:
				if not hero.sprite.frame in seen: seen.append(hero.sprite.frame)
				if not captured and hero.attack_active and capture_dir != "":
					captured = true
					await RenderingServer.frame_post_draw
					root.get_texture().get_image().save_png(capture_dir.path_join(mode+".png"))
			elif hero.action != "" and hero.action != queued_for and hero.action_time > hero.action_duration*0.5:
				queued_for = hero.action
				await tap("light_attack")
			await step(1)
		Input.action_release("jump")
		print(mode," FRAMES ",seen)
	Engine.time_scale = 1
	quit()
