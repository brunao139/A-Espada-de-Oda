extends Node2D
## Efeito independente da textura do personagem: não é recortado pelo atlas.

@onready var hero: CharacterBody2D = get_parent().get_parent()

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	if not hero.is_heavy_attack():
		return
	var ascending: bool = hero.action == "gff2"
	var windows: Array[Vector2] = hero.attack_windows()
	var progress: float = (hero.action_time - windows[0].x) / (windows[0].y - windows[0].x)
	if progress <= 0.0 or progress >= 1.0:
		return
	var strength := sin(progress * PI)
	if strength < 0.04:
		return
	var angle := lerpf(1.12, -1.55, progress) if ascending else lerpf(-1.55, 1.12, progress)
	var center := Vector2(16, -91)
	var outer := PackedVector2Array()
	var inner := PackedVector2Array()
	for index in range(25):
		var fraction := index / 24.0
		var trail_angle := angle + (1.0 - fraction) * 1.35 if ascending else angle - (1.0 - fraction) * 1.35
		var direction := Vector2.from_angle(trail_angle)
		var width := sin(fraction * PI) * 19.0 * strength
		outer.append(center + direction * 130.0)
		# As pontas já estão na borda externa: duplicá-las pode gerar
		# um polígono degenerado durante o início/fim do efeito.
		if index > 0 and index < 24:
			inner.append(center + direction * (130.0 - width))
	var polygon := PackedVector2Array(outer)
	inner.reverse()
	polygon.append_array(inner)
	draw_polyline(outer, Color(0.1, 0.8, 1.0, 0.10 * strength), 15, true)
	draw_colored_polygon(polygon, Color(0.22, 0.95, 1.0, 0.78 * strength))
	draw_polyline(outer, Color(0.83, 1.0, 1.0, 0.95 * strength), 2.5, true)
