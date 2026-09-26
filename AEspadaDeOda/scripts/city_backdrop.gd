extends Node2D
## Fundo distante em tela e silhuetas intermediárias, com velocidades de paralaxe distintas.

var camera_offset: float = 0.0
var elapsed: float = 0.0
var city: Texture2D = preload("res://assets/cidade_futurista.png")

func _process(delta: float) -> void:
	elapsed += delta
	queue_redraw()

func _draw() -> void:
	var size := Vector2(1480, 1480.0 * city.get_height() / city.get_width())
	draw_texture_rect(city, Rect2(Vector2(-camera_offset * 0.10, 45), size), false)
	draw_rect(Rect2(0, 0, 1280, 720), Color(0.01, 0.025, 0.06, 0.12))
	# Estruturas mais próximas deslizam mais rápido que a cidade distante.
	for i in range(-2, 13):
		var x := i * 240.0 - camera_offset * 0.38
		var top := 470.0 + sin(i * 4.3) * 55
		draw_rect(Rect2(x, top, 92, 250), Color("08253b"))
		draw_rect(Rect2(x + 12, top - 19, 60, 19), Color("08253b"))
		draw_line(Vector2(x + 27, top - 19), Vector2(x + 27, top - 65), Color("08253b"), 3)
		for j in range(3):
			draw_rect(Rect2(x + 15, top + 22 + j * 27, 22 + (j % 2) * 18, 3), Color(0.14, 0.72, 0.8, 0.55))
	for i in range(16):
		var x := fposmod(i * 137.0 - camera_offset * 0.25 + elapsed * 7, 1280)
		var y := 180 + fposmod(i * 83.0 - elapsed * 9, 420)
		draw_circle(Vector2(x, y), 1.2, Color(0.4, 1, 1, 0.20))
