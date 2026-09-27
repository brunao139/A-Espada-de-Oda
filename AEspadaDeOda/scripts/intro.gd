extends Control
## Reproduz o vídeo pré-renderizado incluído no pacote do jogo.
## A montagem editável em tools/anime_source.tscn não roda na abertura.

const MENU := "res://scenes/main_menu.tscn"
var starting := false
var fade_time := 0.0
var start_released := false
var start_event: InputEvent
var changing_scene := false


@onready var video: VideoStreamPlayer = $Video

@onready var fade: ColorRect = $Fade

func _ready() -> void:
	# Respeita as opções salvas já na reprodução da abertura.
	var config := ConfigFile.new()
	var volume := 0.8
	if config.load("user://settings.cfg") == OK:
		volume = clampf(float(config.get_value("audio", "volume", 0.8)), 0.0, 1.0)
		if DisplayServer.get_name() != "headless":
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if bool(config.get_value("display", "fullscreen", false)) else DisplayServer.WINDOW_MODE_WINDOWED)
	AudioServer.set_bus_mute(0, volume <= 0.0)
	AudioServer.set_bus_volume_db(0, linear_to_db(maxf(volume, 0.001)))
	video.finished.connect(_video_finished)
	video.play()

func _video_finished() -> void:
	if changing_scene or starting:
		return
	changing_scene = true
	call_deferred("_enter_menu")

func _process(delta: float) -> void:
	if not starting:
		return
	fade_time += delta
	fade.color.a = minf(fade_time / 0.4, 1.0)
	if fade_time >= 0.4 and start_released and not changing_scene:
		changing_scene = true
		call_deferred("_enter_menu")

func _input(event: InputEvent) -> void:
	if starting:
		if _releases_start(event):
			start_released = true
		get_viewport().set_input_as_handled()
		return
	var pressed := false
	if event is InputEventKey:
		pressed = event.pressed and not event.echo
	elif event is InputEventJoypadButton:
		pressed = event.pressed
	elif event is InputEventMouseButton:
		pressed = event.pressed and event.button_index in [MOUSE_BUTTON_LEFT, MOUSE_BUTTON_RIGHT, MOUSE_BUTTON_MIDDLE]
	elif event is InputEventScreenTouch:
		pressed = event.pressed
	if pressed:
		start_event = event
		starting = true
		video.paused = true
		get_viewport().set_input_as_handled()

func _releases_start(event: InputEvent) -> bool:
	if start_event is InputEventKey and event is InputEventKey:
		return not event.pressed and event.physical_keycode == start_event.physical_keycode and event.keycode == start_event.keycode
	if start_event is InputEventJoypadButton and event is InputEventJoypadButton:
		return not event.pressed and event.device == start_event.device and event.button_index == start_event.button_index
	if start_event is InputEventMouseButton and event is InputEventMouseButton:
		return not event.pressed and event.button_index == start_event.button_index
	if start_event is InputEventScreenTouch and event is InputEventScreenTouch:
		return not event.pressed and event.index == start_event.index
	return false

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT and starting:
		start_released = true

func _enter_menu() -> void:
	var result := get_tree().change_scene_to_file(MENU)
	if result != OK:
		push_error("Não foi possível abrir o menu: %s" % error_string(result))
		starting = false
		changing_scene = false
		fade_time = 0.0
		fade.color.a = 0.0
		video.play()
