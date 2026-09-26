extends SceneTree

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

func open_intro() -> Control:
	change_scene_to_file("res://scenes/intro.tscn")
	await frames()
	return current_scene as Control

func key(pressed: bool, echo: bool = false) -> InputEventKey:
	var event := InputEventKey.new()
	event.physical_keycode = KEY_J
	event.keycode = KEY_J
	event.pressed = pressed
	event.echo = echo
	return event

func capture(name: String) -> void:
	if capture_dir == "":
		return
	await RenderingServer.frame_post_draw
	check(root.get_texture().get_image().save_png(capture_dir.path_join(name + ".png")) == OK, "Captura " + name)

func run_tests() -> void:
	print("VIDEO TEST: exported template = ", OS.has_feature("template"))
	check(FileAccess.file_exists("res://assets/intro/intro.ogv"), "Video presente no pacote do jogo")
	var intro := await open_intro()
	check(intro.video.stream is VideoStreamTheora, "Abertura usa arquivo de video Theora")
	check(intro.get_node_or_null("Youkai") == null, "Sem animacao de personagem em tempo real na abertura")
	await create_timer(2.6).timeout
	check(intro.video.is_playing() and intro.video.stream_position > 1.0, "Reproducao real avanca automaticamente")
	var texture: Texture2D = intro.video.get_video_texture()
	check(texture != null and texture.get_width() == 1280 and texture.get_height() == 720, "Decodificacao em 1280x720")
	await capture("intro-video-in-game")
	var motion := InputEventMouseMotion.new()
	Input.parse_input_event(motion)
	var drift := InputEventJoypadMotion.new()
	drift.axis_value = 0.3
	Input.parse_input_event(drift)
	Input.parse_input_event(key(true, true))
	await frames()
	check(not intro.starting, "Mouse, analogico e repeticao nao iniciam")
	var deadline := Time.get_ticks_msec() + 15000
	while not intro.title_ready and Time.get_ticks_msec() < deadline:
		await process_frame
	check(intro.title_ready and intro.title_frame.visible and not intro.video.is_playing(), "Fim real do video mantem titulo sem repetir")
	await create_timer(0.4).timeout
	check(current_scene == intro and not intro.starting, "Tela final aguarda botao")
	await capture("intro-video-title")
	Input.parse_input_event(key(true))
	await create_timer(0.5).timeout
	check(current_scene == intro and intro.starting, "Tecla mantida nao vaza para combate")
	Input.parse_input_event(key(false))
	await create_timer(0.3).timeout
	check(current_scene.scene_file_path == "res://scenes/movement_lab.tscn", "Tecla inicia primeira fase")
	check(current_scene.get_node("Youkai").action == "", "Entrada nao dispara golpe")
	Input.action_press("reset_lab")
	await frames(3)
	Input.action_release("reset_lab")
	await frames(6)
	check(current_scene.scene_file_path == "res://scenes/movement_lab.tscn", "R reinicia fase sem repetir video")
	intro = await open_intro()
	var button := InputEventJoypadButton.new()
	button.button_index = JOY_BUTTON_A
	button.pressed = true
	Input.parse_input_event(button)
	await frames()
	button = button.duplicate()
	button.pressed = false
	Input.parse_input_event(button)
	await create_timer(0.6).timeout
	check(current_scene.scene_file_path == "res://scenes/movement_lab.tscn", "Botao de controle permite pular video")
	intro = await open_intro()
	var click := InputEventMouseButton.new()
	click.button_index = MOUSE_BUTTON_LEFT
	click.pressed = true
	Input.parse_input_event(click)
	await frames()
	click = click.duplicate()
	click.pressed = false
	Input.parse_input_event(click)
	await create_timer(0.6).timeout
	check(current_scene.scene_file_path == "res://scenes/movement_lab.tscn", "Clique tambem inicia")
	print("VIDEO RESULT: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
