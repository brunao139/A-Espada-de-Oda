extends Control
## Reproduz o vídeo pré-renderizado incluído no pacote do jogo.
## A montagem editável em tools/intro_source.tscn não roda na abertura.

const LEVEL := "res://scenes/movement_lab.tscn"
var starting := false
var fade_time := 0.0
var start_released := false
var start_event: InputEvent
var changing_scene := false
var title_ready := false

@onready var video: VideoStreamPlayer = $Video
@onready var title_frame: TextureRect = $TitleFrame
@onready var fade: ColorRect = $Fade

func _ready() -> void:
	video.finished.connect(_show_title)
	video.play()

func _show_title() -> void:
	# Mantém o último quadro até iniciar, sem repetir o filme.
	title_ready = true
	title_frame.show()
	video.hide()
	video.stop()

func _process(delta: float) -> void:
	if not starting:
		return
	fade_time += delta
	fade.color.a = minf(fade_time / 0.4, 1.0)
	if fade_time >= 0.4 and start_released and not changing_scene:
		changing_scene = true
		call_deferred("_enter_level")

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

func _enter_level() -> void:
	var result := get_tree().change_scene_to_file(LEVEL)
	if result != OK:
		push_error("Não foi possível abrir a primeira fase: %s" % error_string(result))
		starting = false
		changing_scene = false
		fade_time = 0.0
		fade.color.a = 0.0
		_show_title()
