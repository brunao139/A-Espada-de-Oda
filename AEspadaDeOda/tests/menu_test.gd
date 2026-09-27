extends SceneTree

var failures := 0
var checks := 0
var capture_dir := ""
var original_settings: PackedByteArray
var had_settings := false

func _initialize() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--capture-dir="):
			capture_dir = arg.trim_prefix("--capture-dir=")
	call_deferred("run_tests")

func check(ok: bool, description: String) -> void:
	checks += 1
	print(("PASS " if ok else "FAIL ") + description)
	if not ok:
		failures += 1

func frames(count: int = 3) -> void:
	for i in range(count):
		await process_frame

func press(code: Key) -> void:
	var event := InputEventKey.new()
	event.keycode = code
	event.physical_keycode = code
	event.pressed = true
	Input.parse_input_event(event)
	await frames()
	event = event.duplicate()
	event.pressed = false
	Input.parse_input_event(event)
	await frames()

func capture(name: String) -> void:
	if capture_dir != "":
		await RenderingServer.frame_post_draw
		check(root.get_texture().get_image().save_png(capture_dir.path_join(name + ".png")) == OK, "Captura " + name)

func run_tests() -> void:
	had_settings = FileAccess.file_exists("user://settings.cfg")
	if had_settings:
		original_settings = FileAccess.get_file_as_bytes("user://settings.cfg")
	change_scene_to_file("res://scenes/main_menu.tscn")
	await frames(5)
	var menu := current_scene
	check(menu.start_button.has_focus(), "START recebe foco inicial")
	check(menu.start_button.text == "START" and menu.options_button.text == "OPTIONS" and menu.exit_button.text == "EXIT", "Tres botoes reais")
	await capture("menu-principal")
	await press(KEY_DOWN)
	check(menu.options_button.has_focus(), "Navegacao por teclado")
	await press(KEY_ENTER)
	check(menu.options_panel.visible and not menu.actions.visible, "OPTIONS abre painel")
	await capture("menu-options")
	menu.volume_slider.value = 0
	check(AudioServer.is_bus_mute(0), "Volume zero silencia audio")
	menu.volume_slider.value = 35
	check(not AudioServer.is_bus_mute(0) and is_equal_approx(db_to_linear(AudioServer.get_bus_volume_db(0)), 0.35), "Slider altera volume real")
	await press(KEY_ESCAPE)
	check(not menu.options_panel.visible and menu.options_button.has_focus(), "Escape fecha opcoes e devolve foco")
	change_scene_to_file("res://scenes/main_menu.tscn")
	await frames(5)
	menu = current_scene
	check(is_equal_approx(menu.volume_slider.value, 35), "Opcoes persistem ao reabrir")
	await press(KEY_ENTER)
	await create_timer(0.5).timeout
	check(current_scene.scene_file_path == "res://scenes/movement_lab.tscn", "START abre primeira fase")
	if had_settings:
		var file := FileAccess.open("user://settings.cfg", FileAccess.WRITE)
		file.store_buffer(original_settings)
		file.close()
	else:
		DirAccess.remove_absolute("user://settings.cfg")
	change_scene_to_file("res://scenes/main_menu.tscn")
	await frames(5)
	print("MENU RESULT: %d checks, %d failures" % [checks, failures])
	if failures:
		quit(1)
		return
	current_scene.exit_button.grab_focus()
	print("VERIFY EXIT: ativando botao EXIT; processo deve encerrar com codigo zero")
	await press(KEY_ENTER)
	quit(1)
