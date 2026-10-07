extends RefCounted
## Correção de proporção do corpo em relação à guarda, sem medir pela espada.
const BODY_SCALE: float = 0.80
const FRONT_FOOT := Vector2(70, 0)

static func normalize_point(point: Vector2) -> Vector2:
 return FRONT_FOOT + (point - Vector2(54, 0)) * BODY_SCALE

## Recortes medidos: divisão deslocada da grade para manter a ponta da espada.
## O pivô usa a bota da frente; não usa o centro do desenho ou o brilho da lâmina.
const POSES := [
	{"sheet": "a", "rect": [0, 0, 474, 443], "anchor": [275.5, 379], "scale": [0.7016129, 0.6595161], "tip": [406, 357.9]},
	{"sheet": "a", "rect": [474, 0, 413, 443], "anchor": [248.0, 379], "scale": [0.7016129, 0.6735484], "tip": [368, 319.12]},
	{"sheet": "a", "rect": [0, 443, 474, 444], "anchor": [294.5, 377], "scale": [0.7016129, 0.7016129], "tip": [408, 260.57]},
	{"sheet": "a", "rect": [474, 443, 413, 444], "anchor": [239.5, 376], "scale": [0.7016129, 0.7016129], "tip": [361, 256.38]},
	{"sheet": "a", "rect": [0, 887, 474, 443], "anchor": [289.0, 360], "scale": [0.7016129, 0.7016129], "tip": [409, 219.61]},
	{"sheet": "a", "rect": [474, 887, 413, 443], "anchor": [227.5, 360], "scale": [0.7016129, 0.7016129], "tip": [376, 215.4]},
	{"sheet": "a", "rect": [0, 1330, 474, 444], "anchor": [280.0, 345], "scale": [0.7016129, 0.7016129], "tip": [438, 192.16]},
	{"sheet": "a", "rect": [474, 1330, 413, 444], "anchor": [239.5, 345], "scale": [0.7016129, 0.7016129], "tip": [399, 189.38]},
	{"sheet": "b", "rect": [0, 0, 530, 396], "anchor": [322.5, 319], "scale": [0.6516854, 0.6516854], "tip": [489, 178.35]},
	{"sheet": "b", "rect": [530, 0, 462, 396], "anchor": [279.5, 319], "scale": [0.6516854, 0.6516854], "tip": [430, 183.29]},
	{"sheet": "b", "rect": [0, 396, 530, 397], "anchor": [326.5, 313], "scale": [0.6516854, 0.6516854], "tip": [462, 179.32]},
	{"sheet": "b", "rect": [530, 396, 462, 397], "anchor": [276.5, 315], "scale": [0.6516854, 0.6516854], "tip": [378, 179.67]},
	{"sheet": "b", "rect": [0, 793, 530, 396], "anchor": [323.5, 307], "scale": [0.6516854, 0.6516854], "tip": [428, 208.0]},
	{"sheet": "b", "rect": [530, 793, 462, 396], "anchor": [265.5, 309], "scale": [0.6516854, 0.6516854], "tip": [371, 228.46]},
	{"sheet": "b", "rect": [0, 1189, 530, 397], "anchor": [325.5, 308], "scale": [0.6516854, 0.6516854], "tip": [421, 238.14]},
	{"sheet": "b", "rect": [530, 1189, 462, 397], "anchor": [270.5, 309], "scale": [0.6516854, 0.6516854], "tip": [364, 241.47]}
]

static func build(frames: SpriteFrames, entry_pose: Texture2D) -> Dictionary:
 var sheets := {
  "a": preload("res://assets/gff/gff2_forward_a.png"),
  "b": preload("res://assets/gff/gff2_forward_b.png")
 }
 frames.add_animation("gff2")
 frames.set_animation_loop("gff2", false)
 frames.set_animation_speed("gff2", 25.0)
 frames.add_frame("gff2", entry_pose)
 var positions: Array[Vector2] = [Vector2(26, -92)]
 var scales: Array[Vector2] = [Vector2.ONE]
 var tips: Array[Vector2] = [Vector2.ZERO]
 for pose in POSES:
  var texture := AtlasTexture.new()
  texture.atlas = sheets[pose.sheet]
  var r: Array = pose.rect
  texture.region = Rect2(r[0],r[1],r[2],r[3])
  texture.filter_clip = true
  frames.add_frame("gff2", texture)
  var factor := Vector2(pose.scale[0],pose.scale[1]) * BODY_SCALE
  var anchor := Vector2(pose.anchor[0],pose.anchor[1])
  positions.append(FRONT_FOOT+(texture.region.size/2.0-anchor)*factor)
  scales.append(factor)
  tips.append(FRONT_FOOT+(Vector2(pose.tip[0],pose.tip[1])-anchor)*factor)
 return {"positions":positions,"scales":scales,"tips":tips}
