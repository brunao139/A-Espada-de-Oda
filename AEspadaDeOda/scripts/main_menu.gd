extends Control
## Menu funcional preparado para a nova abertura anime.

const LEVEL := "res://scenes/movement_lab.tscn"
const BACKGROUND := preload("res://assets/intro_anime/menu_background.png")
const TITLE_FONT := preload("res://assets/intro_anime/Cinzel.ttf")
const SETTINGS := "user://settings.cfg"

var options_panel: PanelContainer
var actions: VBoxContainer
var start_button: Button
var options_button: Button
var exit_button: Button
var back_button: Button
var volume_slider: HSlider
var fullscreen_button: CheckButton
var starting := false
var fade: ColorRect
var volume_value := 0.8
var fullscreen_value := false

func _ready() -> void:
	_load_settings()
	_build_ui()
	_apply_settings()
	start_button.grab_focus()

func _build_ui() -> void:
	var background := TextureRect.new()
	background.texture = BACKGROUND
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var shade := ColorRect.new()
	shade.color = Color(0.01, 0.025, 0.065, 0.35)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(shade)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var title := Label.new()
	title.name = "ProvisionalTitle"
	title.text = "A ESPADA DE ODA"
	title.position = Vector2(100, 166)
	title.size = Vector2(1080, 96)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_override("font", TITLE_FONT)
	title.add_theme_font_size_override("font_size", 66)
	title.add_theme_color_override("font_color", Color("ffe5a4"))
	title.add_theme_color_override("font_outline_color", Color("071325"))
	title.add_theme_constant_override("outline_size", 8)
	title.add_theme_color_override("font_shadow_color", Color("060c1d"))
	title.add_theme_constant_override("shadow_offset_y", 5)
	add_child(title)
	var rule := ColorRect.new()
	rule.color = Color(0.85, 0.71, 0.43, 0.7)
	rule.position = Vector2(450, 274)
	rule.size = Vector2(380, 2)
	rule.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(rule)
	actions = VBoxContainer.new()
	actions.position = Vector2(470, 349)
	actions.size = Vector2(340, 210)
	actions.add_theme_constant_override("separation", 14)
	add_child(actions)
	start_button = _button("START", actions)
	options_button = _button("OPTIONS", actions)
	exit_button = _button("EXIT", actions)
	start_button.pressed.connect(_start_game)
	options_button.pressed.connect(_open_options)
	exit_button.pressed.connect(_exit_game)
	_build_options()
	fade = ColorRect.new()
	fade.color = Color(0.01, 0.02, 0.05, 0)
	fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(fade)
	fade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

func _button(value: String, parent: Node) -> Button:
	var button := Button.new()
	button.text = value
	button.custom_minimum_size = Vector2(300, 56)
	button.add_theme_font_size_override("font_size", 24)
	button.add_theme_color_override("font_color", Color("e8edf4"))
	button.add_theme_color_override("font_focus_color", Color("fff0bf"))
	button.add_theme_color_override("font_hover_color", Color("fff0bf"))
	for state in ["normal", "hover", "pressed", "focus"]:
		var style := StyleBoxFlat.new()
		style.bg_color = Color(0.02, 0.045, 0.09, 0.90) if state == "normal" else Color(0.055, 0.11, 0.17, 0.97)
		style.border_color = Color("587b86") if state == "normal" else Color("efce83")
		style.set_border_width_all(1 if state == "normal" else 2)
		style.set_corner_radius_all(3)
		if state == "focus":
			style.bg_color = Color.TRANSPARENT
		button.add_theme_stylebox_override(state, style)
	parent.add_child(button)
	return button

func _build_options() -> void:
	options_panel = PanelContainer.new()
	options_panel.name = "Options"
	options_panel.position = Vector2(410, 306)
	options_panel.size = Vector2(460, 310)
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.02, 0.04, 0.085, 0.97)
	style.border_color = Color("c4a675")
	style.set_border_width_all(1)
	style.content_margin_left = 28
	style.content_margin_right = 28
	style.content_margin_top = 24
	style.content_margin_bottom = 24
	options_panel.add_theme_stylebox_override("panel", style)
	add_child(options_panel)
	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation", 18)
	options_panel.add_child(layout)
	var heading := Label.new()
	heading.text = "OPTIONS"
	heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	heading.add_theme_font_size_override("font_size", 24)
	heading.add_theme_color_override("font_color", Color("ffe5a4"))
	layout.add_child(heading)
	var caption := Label.new()
	caption.text = "Volume geral"
	caption.add_theme_font_size_override("font_size", 18)
	layout.add_child(caption)
	volume_slider = HSlider.new()
	volume_slider.min_value = 0
	volume_slider.max_value = 100
	volume_slider.step = 1
	volume_slider.value = volume_value * 100
	volume_slider.custom_minimum_size.y = 28
	layout.add_child(volume_slider)
	volume_slider.value_changed.connect(_set_volume)
	fullscreen_button = CheckButton.new()
	fullscreen_button.text = "Tela cheia"
	fullscreen_button.button_pressed = fullscreen_value
	fullscreen_button.add_theme_font_size_override("font_size", 18)
	layout.add_child(fullscreen_button)
	fullscreen_button.toggled.connect(_set_fullscreen)
	back_button = _button("VOLTAR", layout)
	back_button.pressed.connect(_close_options)
	options_panel.hide()

func _open_options() -> void:
	actions.hide()
	options_panel.show()
	volume_slider.grab_focus()

func _close_options() -> void:
	options_panel.hide()
	actions.show()
	options_button.grab_focus()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and options_panel.visible:
		_close_options()
		get_viewport().set_input_as_handled()

func _set_volume(value: float) -> void:
	volume_value = value / 100.0
	_apply_audio()
	_save_settings()

func _set_fullscreen(value: bool) -> void:
	fullscreen_value = value
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if value else DisplayServer.WINDOW_MODE_WINDOWED)
	_save_settings()

func _apply_audio() -> void:
	var bus := AudioServer.get_bus_index("Master")
	AudioServer.set_bus_mute(bus, volume_value <= 0.0)
	AudioServer.set_bus_volume_db(bus, linear_to_db(maxf(volume_value, 0.001)))

func _apply_settings() -> void:
	_apply_audio()
	if DisplayServer.get_name() != "headless":
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if fullscreen_value else DisplayServer.WINDOW_MODE_WINDOWED)

func _load_settings() -> void:
	var config := ConfigFile.new()
	if config.load(SETTINGS) == OK:
		volume_value = clampf(float(config.get_value("audio", "volume", 0.8)), 0.0, 1.0)
		fullscreen_value = bool(config.get_value("display", "fullscreen", false))

func _save_settings() -> void:
	var config := ConfigFile.new()
	config.set_value("audio", "volume", volume_value)
	config.set_value("display", "fullscreen", fullscreen_value)
	var result := config.save(SETTINGS)
	if result != OK:
		push_warning("Não foi possível salvar as opções: %s" % error_string(result))

func _start_game() -> void:
	if starting:
		return
	starting = true
	for button in [start_button, options_button, exit_button]:
		button.disabled = true
	fade.mouse_filter = Control.MOUSE_FILTER_STOP
	var tween := create_tween()
	tween.tween_property(fade, "color:a", 1.0, 0.3)
	tween.tween_callback(_enter_level)

func _enter_level() -> void:
	var result := get_tree().change_scene_to_file(LEVEL)
	if result != OK:
		push_error("Não foi possível abrir a fase: %s" % error_string(result))
		starting = false
		fade.color.a = 0.0
		fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
		for button in [start_button, options_button, exit_button]:
			button.disabled = false
		start_button.grab_focus()

func _exit_game() -> void:
	get_tree().quit()
