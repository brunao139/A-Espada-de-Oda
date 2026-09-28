extends Control

var player: CharacterBody2D
var gold := Color("ecc77c")
var muted := Color("8596a4")
var paper := Color("e9eee9")

func _process(_delta: float) -> void:
	queue_redraw()

func text(at: Vector2, value: String, size: int, color: Color) -> void:
	draw_string(ThemeDB.fallback_font, at, value, HORIZONTAL_ALIGNMENT_LEFT, -1, size, color)

func _draw() -> void:
	draw_rect(Rect2(0, 0, 1280, 110), Color("0b111b"))
	draw_rect(Rect2(36, 25, 4, 59), gold)
	text(Vector2(54, 53), "A ESPADA DE ODA", 30, paper)
	text(Vector2(55, 80), "YOUKAI     /     CIDADE FUTURISTA", 13, gold)
	text(Vector2(1045, 43), "PROTÓTIPO  /  01", 15, gold)
	text(Vector2(1045, 68), "R  Reiniciar", 14, muted)
	text(Vector2(1045, 89), "F1  Ver alcance", 14, muted)
	draw_line(Vector2(36, 109), Vector2(1244, 109), Color("28333b"), 1)
	draw_rect(Rect2(0, 628, 1280, 92), Color("0b111b"))
	draw_line(Vector2(36, 628), Vector2(1244, 628), Color("28333b"), 1)
	_control(42, "A  D", "CORRER", "ou setas", "move_left", "move_right")
	_control(264, "ESPAÇO", "PULAR", "segure para ir mais alto", "jump")
	_control(567, "J / Z", "GF-1 → GF-2", "kung-fu + giro esquerdo", "light_attack")
	_control(858, "K / X", "GFF-1 → GFF-2", "descendente + frontal", "heavy_attack")
	if is_instance_valid(player):
		draw_style_box(_status_style(), Rect2(36, 121, 280, 79))
		text(Vector2(54, 145), player.state_label(), 16, gold)
		if player.ledge.state != "":
			text(Vector2(54, 169), "Espaço / W / ↑: subir", 12, paper)
			text(Vector2(54, 188), "S / ↓: soltar", 12, muted)
		else:
			text(Vector2(54, 169), "No ar: aproxime-se da quina", 12, muted)
		if player.action != "":
			draw_rect(Rect2(54, 184, 180, 3), Color("263742"))
			draw_rect(Rect2(54, 184, 180 * minf(1, player.action_time / player.action_duration), 3), gold)
		if player.debug_shapes:
			text(Vector2(800, 145), "CIANO: CORPO    /    DOURADO: GOLPE ATIVO", 13, gold)

func _control(x: float, keys: String, name: String, hint: String, action: String, other: String = "") -> void:
	var held := Input.is_action_pressed(action) or (other != "" and Input.is_action_pressed(other))
	var width := 86.0 if keys == "ESPAÇO" else 67.0
	draw_style_box(_key_style(held), Rect2(x, 651, width, 36))
	text(Vector2(x + 9, 675), keys, 14, Color("0b111b") if held else gold)
	text(Vector2(x + width + 15, 666), name, 14, paper)
	text(Vector2(x + width + 15, 687), hint, 12, muted)

func _key_style(held: bool) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = gold if held else Color("1b2630")
	style.border_color = Color("514b39")
	style.set_border_width_all(1)
	style.set_corner_radius_all(5)
	return style

func _status_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.025, 0.04, 0.075, 0.88)
	style.set_corner_radius_all(4)
	return style
