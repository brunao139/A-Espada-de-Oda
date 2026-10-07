extends RefCounted
## Recortes medidos no atlas; a grade nominal corta pés e a perna estendida.
const SHEET := preload("res://assets/gf/gf4_jump_spin.png")
const BODY_SCALE := 0.78
const RECTS := [
	Rect2(50,50,171,222), Rect2(318,83,129,188), Rect2(528,107,201,164),
	Rect2(802,36,177,241), Rect2(1072,36,147,167), Rect2(1324,47,161,196),
	Rect2(61,292,150,190), Rect2(302,294,153,196), Rect2(527,308,236,171),
	Rect2(800,305,224,170), Rect2(1066,302,174,177), Rect2(1324,296,161,178),
	Rect2(46,525,194,191), Rect2(265,538,259,183), Rect2(526,536,254,168),
	Rect2(799,537,274,173), Rect2(1092,543,159,178), Rect2(1341,527,136,217),
	Rect2(61,760,141,196), Rect2(302,748,159,240), Rect2(572,766,135,224),
	Rect2(802,814,211,176), Rect2(1067,760,167,230), Rect2(1319,768,175,223)
]
const HIPS := [
	Vector2(141,177), Vector2(388,211), Vector2(639,211), Vector2(910,163),
	Vector2(1160,146), Vector2(1415,163), Vector2(151,413), Vector2(385,416),
	Vector2(626,409), Vector2(928,416), Vector2(1165,415), Vector2(1417,417),
	Vector2(148,639), Vector2(365,659), Vector2(632,643), Vector2(919,644),
	Vector2(1180,658), Vector2(1417,665), Vector2(145,885), Vector2(389,861),
	Vector2(642,894), Vector2(920,935), Vector2(1162,890), Vector2(1407,893)
]

static func build(frames: SpriteFrames) -> Dictionary:
	var positions := {}
	var scales := {}
	for name in ["gf4", "gfa4"]:
		if frames.has_animation(name): frames.remove_animation(name)
		frames.add_animation(name)
		frames.set_animation_loop(name, false)
		frames.set_animation_speed(name, 30 if name == "gf4" else 50)
		var offsets: Array[Vector2] = []
		var sizes: Array[Vector2] = []
		var indices := range(24) if name == "gf4" else range(4,20)
		for i in indices:
			var texture := AtlasTexture.new()
			texture.atlas = SHEET
			texture.region = RECTS[i]
			texture.margin = Rect2(8,8,16,16)
			texture.filter_clip = true
			frames.add_frame(name,texture)
			# Centro do quadril fixo durante o voo: pés recolhidos não movem o pivô.
			var anchor: Vector2 = HIPS[i]
			var hip_y := -74.0
			if name == "gf4" and (i < 4 or i >= 19):
				hip_y = -(RECTS[i].end.y - 1 - anchor.y) * BODY_SCALE
			offsets.append((RECTS[i].get_center()-anchor)*BODY_SCALE + Vector2(0,hip_y))
			sizes.append(Vector2.ONE*BODY_SCALE)
		positions[name] = offsets
		scales[name] = sizes
	return {"positions":positions, "scales":scales}
