extends Node2D
## Abertura independente: nenhum comando ou ajuste de física é enviado ao jogador.

const LEVEL := "res://scenes/movement_lab.tscn"
const HERO := preload("res://scenes/youkai.tscn")
const JAPAN := preload("res://assets/intro/japan.png")
const FUTURE := preload("res://assets/intro/future.png")
const PIXEL_FONT := preload("res://assets/intro/PressStart2P-Regular.ttf")
const FLASH_START := 4.2
const TIME_SHIFT := 4.7
const FLASH_END := 5.35
const LEAP := 8.6
const TITLE := 10.8
const READY := 11.8
const FLOOR_Y := 560.0

var elapsed := 0.0
var starting := false
var fade_time := 0.0
var start_released := false
var start_event: InputEvent
var changing_scene := false
var hero: CharacterBody2D
var title_group: Control
var prompt: Label
var effects: Node2D

class ScreenEffects extends Node2D:

	var intro: Node2D

	func _draw() -> void:
		# Linhas discretas de CRT, sem tremulação ou distorção dos sprites.
		for y in range(0, 720, 4):
			draw_line(Vector2(0, y), Vector2(1280, y), Color(0, 0, 0, 0.10))
		var flash: float = intro.flash_amount()
		if flash > 0:
			draw_rect(Rect2(0, 0, 1280, 720), Color(0.72, 0.97, 1.0, flash))
			for i in range(14):
				var y := fmod(i * 61.0 + intro.elapsed * 190.0, 720.0)
				draw_line(Vector2(0, y), Vector2(1280, y - 72), Color(1, 1, 1, flash * 0.35), 3)
		if intro.starting:
			draw_rect(Rect2(0, 0, 1280, 720), Color(0.02, 0.025, 0.06, minf(intro.fade_time / 0.4, 1.0)))

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	hero = HERO.instantiate()
	add_child(hero)
	hero.set_physics_process(false)
	hero.collision_layer = 0
	hero.collision_mask = 0
	hero.get_node("Body").set_deferred("disabled", true)
	hero.attack_area.set_deferred("monitoring", false)
	hero.facing = -1
	hero.visual.scale.x = -1
	hero.z_index = 2
	_build_title()
	effects = ScreenEffects.new()
	effects.intro = self
	effects.z_index = 10
	add_child(effects)
	_update_visuals()

func _build_title() -> void:
	title_group = Control.new()
	title_group.name = "Title"
	title_group.mouse_filter = Control.MOUSE_FILTER_IGNORE
	title_group.z_index = 5
	title_group.pivot_offset = Vector2(640, 330)
	add_child(title_group)
	var title := _label("A Espada de Oda", 52, Rect2(80, 265, 1120, 90), Color("ffe4a0"))
	title.name = "GameTitle"
	title.add_theme_color_override("font_shadow_color", Color("521c46"))
	title.add_theme_constant_override("shadow_offset_x", 5)
	title.add_theme_constant_override("shadow_offset_y", 7)
	title.add_theme_color_override("font_outline_color", Color("100f29"))
	title.add_theme_constant_override("outline_size", 12)
	title_group.add_child(title)
	prompt = _label("Aperte qualquer botão para iniciar", 18, Rect2(80, 415, 1120, 50), Color("d6f8ff"))
	prompt.name = "StartPrompt"
	title_group.add_child(prompt)

func _label(value: String, font_size: int, rect: Rect2, color: Color) -> Label:
	var label := Label.new()
	label.text = value
	label.position = rect.position
	label.size = rect.size
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_font_override("font", PIXEL_FONT)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	return label

func _process(delta: float) -> void:
	if starting:
		fade_time += delta
		# A tecla de início deve ser solta antes de entregar os controles à fase.
		if fade_time >= 0.4 and start_released and not changing_scene:
			changing_scene = true
			call_deferred("_enter_level")
	else:
		elapsed += delta
	_update_visuals()
	queue_redraw()
	effects.queue_redraw()

func _input(event: InputEvent) -> void:
	if OS.get_cmdline_args().has("--write-movie"):
		return
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

func flash_amount() -> float:
	if elapsed < FLASH_START or elapsed > FLASH_END:
		return 0.0
	if elapsed <= TIME_SHIFT:
		return smoothstep(FLASH_START, TIME_SHIFT, elapsed)
	return 1.0 - smoothstep(TIME_SHIFT, FLASH_END, elapsed)

func _update_visuals() -> void:
	var run_progress := smoothstep(0.0, 3.8, elapsed)
	hero.position = Vector2(lerpf(1140, 470, run_progress), FLOOR_Y)
	if elapsed >= FLASH_END:
		hero.position.x = lerpf(470, 360, clampf((elapsed - FLASH_END) / (LEAP - FLASH_END), 0, 1))
	hero.visible = elapsed < TITLE
	if elapsed < LEAP:
		hero.sprite.play("run")
	else:
		var air := elapsed - LEAP
		hero.position = Vector2(360 - air * 300, FLOOR_Y - 650 * air + 420 * air * air)
		if air < 0.12:
			hero.sprite.play("rise")
		elif air < 1.02:
			hero.sprite.play("somersault")
			hero.roll_duration = 0.9
			hero.roll_elapsed = air - 0.12 + 0.04
		else:
			hero.sprite.play("fall")
	hero._align_sprite()
	var reveal := smoothstep(TITLE, READY, elapsed)
	title_group.visible = elapsed >= TITLE
	title_group.modulate.a = reveal
	title_group.scale = Vector2.ONE * lerpf(1.10, 1.0, reveal)
	prompt.modulate.a = 0.70 + 0.30 * sin(maxf(elapsed - READY, 0.0) * 2.6)

func _draw() -> void:
	var future := elapsed >= TIME_SHIFT
	var pan := minf(elapsed, TITLE) * 13.0
	var texture: Texture2D = FUTURE if future else JAPAN
	# Um panorama maior que a tela permite movimento sem emendas visíveis.
	draw_texture_rect(texture, Rect2(-200 + pan, -20, 1500, 844), false)
	draw_rect(Rect2(0, 0, 1280, 720), Color(0.02, 0.02, 0.08, 0.12))
	_draw_parallax(future)
	var edge := -40.0
	if future:
		edge = lerpf(-420, 360, clampf((elapsed - FLASH_END) / (LEAP - FLASH_END), 0.0, 1.0))
		if elapsed > LEAP:
			edge += minf(elapsed - LEAP, 2.2) * 270
	_draw_roof(edge, future)
	# Letterbox da sequência, com posição fixa para evitar mudanças de enquadramento.
	draw_rect(Rect2(0, 0, 1280, 44), Color("080c1b"))
	draw_rect(Rect2(0, 676, 1280, 44), Color("080c1b"))
	if elapsed < LEAP:
		for i in range(5):
			var phase := fmod(elapsed * 2.8 + i * 0.2, 1.0)
			var origin := hero.position + Vector2(20 + phase * 75, -6 - phase * 14)
			draw_rect(Rect2(origin, Vector2(9, 4) * (1.0 - phase)), Color(0.85, 0.8, 0.6, (1.0 - phase) * 0.5))
	if elapsed >= TITLE:
		var reveal := smoothstep(TITLE, READY, elapsed)
		draw_rect(Rect2(0, 44, 1280, 632), Color(0.025, 0.03, 0.10, reveal * 0.65))
		draw_line(Vector2(290, 235), Vector2(990, 235), Color(0.95, 0.74, 0.38, reveal), 2)
		draw_line(Vector2(420, 385), Vector2(860, 385), Color(0.95, 0.74, 0.38, reveal), 2)

func _draw_parallax(future: bool) -> void:
	var travel := fmod(minf(elapsed, TITLE) * 75.0, 410.0)
	for i in range(-2, 4):
		var x := i * 410.0 + travel
		if future:
			var height := 100.0 + posmod(i, 3) * 42.0
			draw_rect(Rect2(x, FLOOR_Y - height, 125, height + 160), Color("171a34"))
			draw_rect(Rect2(x + 8, FLOOR_Y - height - 7, 109, 7), Color("29304a"))
			draw_line(Vector2(x + 97, FLOOR_Y - height - 7), Vector2(x + 97, FLOOR_Y - height - 42), Color("23263c"), 3)
			for row in range(7):
				for col in range(4):
					if posmod(row * 3 + col + i, 5) == 0:
						continue
					draw_rect(Rect2(x + 15 + col * 25, FLOOR_Y - height + 20 + row * 25, 6, 9), Color("537d92") if col % 2 == 0 else Color("775d77"))
			draw_line(Vector2(x - 70, 190), Vector2(x + 360, 255), Color("17162a"), 3)
		else:
			draw_rect(Rect2(x + 15, 446, 108, 125), Color("302b35"))
			for tier in range(2):
				var y := 450.0 + tier * 67.0
				var roof := PackedVector2Array([Vector2(x - 12, y - 10), Vector2(x + 12, y - 7), Vector2(x + 70, y - 40), Vector2(x + 128, y - 7), Vector2(x + 155, y - 10), Vector2(x + 135, y + 6), Vector2(x + 5, y + 6)])
				draw_colored_polygon(roof, Color("242b35"))
				draw_line(Vector2(x - 12, y - 10), Vector2(x + 12, y - 7), Color("a37655"), 2)
				draw_line(Vector2(x + 12, y - 7), Vector2(x + 70, y - 40), Color("a37655"), 2)
				draw_rect(Rect2(x + 19, y + 7, 100, 4), Color("775343"))
				for col in range(4):
					draw_rect(Rect2(x + 25 + col * 23, y + 17, 12, 24), Color("93694c"))
					draw_line(Vector2(x + 31 + col * 23, y + 17), Vector2(x + 31 + col * 23, y + 41), Color("49353a"), 2)
				for post in [19, 65, 115]:
					draw_rect(Rect2(x + post, y + 12, 4, 48), Color("67453e"))

func _draw_roof(edge: float, future: bool) -> void:
	var top := Color("77d8e5") if future else Color("e2a95f")
	draw_rect(Rect2(edge, FLOOR_Y, 1600, 170), Color("151b30") if future else Color("282630"))
	draw_rect(Rect2(edge - 12, FLOOR_Y, 1612, 10), top)
	draw_rect(Rect2(edge, FLOOR_Y + 10, 1600, 16), Color("26394b") if future else Color("5b4340"))
	var travel := fmod(minf(elapsed, LEAP) * 250.0, 64.0)
	for i in range(-2, 23):
		var x := i * 64.0 + travel
		if x < edge + 8:
			continue
		if future:
			draw_rect(Rect2(x, FLOOR_Y + 39, 42, 5), Color("395569"))
			draw_rect(Rect2(x, FLOOR_Y + 51, 23, 3), Color("294154"))
		else:
			draw_line(Vector2(x, FLOOR_Y + 13), Vector2(x + 15, FLOOR_Y + 26), Color("b27e55"), 2)
			draw_line(Vector2(x, FLOOR_Y + 35), Vector2(x, 676), Color("47373c"), 3)
