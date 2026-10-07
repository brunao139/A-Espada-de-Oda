extends RefCounted
## Recortes medidos; escala pela altura anatômica, nunca pela largura do soco.
static func build(frames: SpriteFrames) -> Dictionary:
 var source: Dictionary = preload("res://scripts/ajogun_frames.gd").source("gf5")
 var sheet: Texture2D = load(source.path)
 var positions: Array[Vector2] = []
 var scales: Array[Vector2] = []
 frames.add_animation("gf5")
 frames.set_animation_loop("gf5",false)
 for frame in source.frames:
  var r := Rect2(frame.rect[0],frame.rect[1],frame.rect[2],frame.rect[3])
  var anchor := Vector2(frame.anchor[0],frame.anchor[1])
  var factor: float = frame.get("scale", source.scale)
  var texture := AtlasTexture.new()
  texture.atlas = sheet
  texture.region = r
  texture.filter_clip = true
  frames.add_frame("gf5",texture)
  positions.append((r.get_center()-anchor)*factor)
  scales.append(Vector2.ONE*factor)
 return {"positions":{"gf5":positions},"scales":{"gf5":scales}}
