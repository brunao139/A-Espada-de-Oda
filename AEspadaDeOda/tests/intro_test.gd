extends SceneTree
## Fluxo real de cena e entrada; opcionalmente salva quadros com -- --capture-dir=...

var failures := 0
var checks := 0
var capture_dir := ""

func _initialize() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--capture-dir="):
			capture_dir = arg.trim_prefix("--capture-dir=")
	call_deferred("run_tests")

func check(ok: bool, message: String) -> void:
	checks += 1
	print(("PASS " if ok else "FAIL ") + message)
	if not ok:
		failures += 1

func frames(count: int = 3) -> void:
	for i in range(count):
		await process_frame

func open_intro() -> Node2D:
	change_scene_to_file("res://scenes/intro.tscn")
	await frames()
	var intro := current_scene as Node2D
	intro.set_process(false)
	return intro

func show_at(intro: Node2D, time: float, filename: String) -> void:
	intro.elapsed = time
	intro._update_visuals()
	intro.queue_redraw()
	intro.effects.queue_redraw()
	await frames()
	if capture_dir != "":
		await RenderingServer.frame_post_draw
		var result := root.get_texture().get_image().save_png(capture_dir.path_join(filename + ".png"))
		check(result == OK, "Captura " + filename)

func key(code: Key, pressed: bool, echo: bool = false) -> InputEventKey:
	var event := InputEventKey.new()
	event.physical_keycode = code
	event.keycode = code
	event.pressed = pressed
	event.echo = echo
	return event

func run_tests() -> void:
	check(ProjectSettings.get_setting("application/run/main_scene") == "res://scenes/intro.tscn", "F5 abre introducao")
	var intro := await open_intro()
	await show_at(intro, 0.3, "intro-01-japao")
	var initial_x: float = intro.hero.position.x
	await show_at(intro, 3.0, "intro-02-corrida")
	check(intro.hero.position.x < initial_x and intro.hero.visual.scale.x == -1, "Corrida direita para esquerda")
	check(not intro.hero.is_physics_processing() and intro.hero.collision_layer == 0, "Ator cinematografico isolado da fisica")
	await show_at(intro, 4.7, "intro-03-viagem")
	check(is_equal_approx(intro.flash_amount(), 1.0), "Mudanca de epoca coberta pela luz")
	await show_at(intro, 6.8, "intro-04-futuro")
	check(intro.flash_amount() == 0 and intro.hero.sprite.animation == "run" and intro.hero.visual.scale.x == -1, "Corrida continua no futuro no mesmo sentido")
	await show_at(intro, 8.8, "intro-05-salto")
	check(intro.hero.position.x < 360 and intro.hero.position.y < 560, "Salto sai da borda esquerda do predio")
	await show_at(intro, 12.0, "intro-06-titulo")
	check(intro.title_group.visible and not intro.hero.visible, "Titulo surge apos salto")
	check(intro.title_group.get_node("GameTitle").text == "A Espada de Oda" and intro.prompt.text == "Aperte qualquer botão para iniciar", "Textos solicitados")
	intro._process(10.0)
	check(not intro.starting and current_scene == intro, "Titulo aguarda comando sem entrar sozinho")
	var motion := InputEventMouseMotion.new()
	Input.parse_input_event(motion)
	var drift := InputEventJoypadMotion.new()
	drift.axis_value = 0.3
	Input.parse_input_event(drift)
	Input.parse_input_event(key(KEY_J, true, true))
	await frames()
	check(not intro.starting, "Mouse, deriva do analogico e repeticao nao iniciam")
	Input.parse_input_event(key(KEY_J, true))
	await frames()
	intro._process(0.5)
	await frames()
	check(current_scene == intro and intro.starting, "Tecla mantida nao vaza para combate")
	Input.parse_input_event(key(KEY_J, false))
	await frames()
	intro._process(0.01)
	await frames(8)
	check(current_scene.scene_file_path == "res://scenes/movement_lab.tscn", "Qualquer tecla abre fase existente")
	check(current_scene.get_node("Youkai").action == "", "Entrada nao dispara GF-1")
	Input.parse_input_event(key(KEY_R, true))
	await frames(6)
	Input.parse_input_event(key(KEY_R, false))
	await frames(6)
	check(current_scene.scene_file_path == "res://scenes/movement_lab.tscn", "R reinicia fase sem repetir introducao")
	intro = await open_intro()
	var button := InputEventJoypadButton.new()
	button.button_index = JOY_BUTTON_A
	button.pressed = true
	Input.parse_input_event(button)
	await frames()
	button = button.duplicate()
	button.pressed = false
	Input.parse_input_event(button)
	await frames()
	intro._process(0.5)
	await frames(8)
	check(current_scene.scene_file_path == "res://scenes/movement_lab.tscn", "Botao de controle permite iniciar durante abertura")
	intro = await open_intro()
	var click := InputEventMouseButton.new()
	click.button_index = MOUSE_BUTTON_LEFT
	click.pressed = true
	Input.parse_input_event(click)
	await frames()
	click = click.duplicate()
	click.pressed = false
	Input.parse_input_event(click)
	await frames()
	intro._process(0.5)
	await frames(8)
	check(current_scene.scene_file_path == "res://scenes/movement_lab.tscn", "Clique tambem inicia")
	print("INTRO RESULT: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
