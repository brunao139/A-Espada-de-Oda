extends SceneTree
var failures := 0
var checks := 0
func _initialize() -> void:
	call_deferred("run_tests")
func check(ok: bool, message: String) -> void:
	checks += 1
	print(("PASS " if ok else "FAIL ") + message)
	if not ok: failures += 1
func frames(count: int = 3) -> void:
	for i in range(count): await process_frame
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
func run_tests() -> void:
	check(FileAccess.file_exists("res://assets/intro_anime/opening.ogv"), "Video anime presente no pacote")
	var intro := await open_intro()
	check(intro.video.stream is VideoStreamTheora, "Reproducao Theora embutida")
	check(intro.get_node_or_null("Youkai") == null, "Cinema pre-renderizado independente do jogador")
	await create_timer(2.6).timeout
	check(intro.video.is_playing() and intro.video.stream_position > 1.0, "Decodificacao avanca automaticamente")
	var texture: Texture2D = intro.video.get_video_texture()
	check(texture != null and texture.get_width() == 1280 and texture.get_height() == 720, "Quadros HD 1280x720")
	Input.parse_input_event(InputEventMouseMotion.new())
	var drift := InputEventJoypadMotion.new()
	drift.axis_value = 0.3
	Input.parse_input_event(drift)
	Input.parse_input_event(key(true,true))
	await frames()
	check(not intro.starting, "Mouse, analogico e repeticao nao pulam video")
	var began := Time.get_ticks_msec()
	var deadline := began + 35000
	while is_instance_valid(intro) and current_scene == intro and Time.get_ticks_msec() < deadline:
		await process_frame
	check(current_scene.scene_file_path == "res://scenes/main_menu.tscn", "Fim real do video abre menu automaticamente")
	check(Time.get_ticks_msec()-began > 24000, "Video completo dura aproximadamente 30 segundos")
	if current_scene.scene_file_path != "res://scenes/main_menu.tscn":
		quit(1)
		return
	await create_timer(0.4).timeout
	check(current_scene.start_button.has_focus() and not current_scene.starting, "Menu aguarda START")
	current_scene.start_button.pressed.emit()
	await create_timer(0.5).timeout
	check(current_scene.scene_file_path == "res://scenes/movement_lab.tscn", "START abre fase")
	check(current_scene.get_node("Youkai").action == "", "Nenhum golpe involuntario")
	Input.action_press("reset_lab")
	await frames()
	Input.action_release("reset_lab")
	await frames(6)
	check(current_scene.scene_file_path == "res://scenes/movement_lab.tscn", "R nao repete a abertura")
	intro = await open_intro()
	Input.parse_input_event(key(true))
	await create_timer(0.5).timeout
	check(current_scene == intro and intro.starting, "Pular aguarda soltura da tecla")
	Input.parse_input_event(key(false))
	await create_timer(0.4).timeout
	check(current_scene.scene_file_path == "res://scenes/main_menu.tscn" and not current_scene.starting, "Tecla pula ao menu sem ativar START")
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
	check(current_scene.scene_file_path == "res://scenes/main_menu.tscn" and not current_scene.starting, "Controle pula ao menu sem ativar START")
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
	check(current_scene.scene_file_path == "res://scenes/main_menu.tscn", "Clique pula ao menu")
	print("VIDEO RESULT: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)
