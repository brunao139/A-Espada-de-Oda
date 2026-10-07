extends RefCounted
const Data := preload("res://scripts/ajogun_frames.gd")
static func build(frames: SpriteFrames) -> Dictionary:
 var positions := {}
 var scales := {}
 for kind in ["ground","air"]:
  var source := Data.source("hero_"+kind)
  var name: String = "hurt_"+kind
  var sheet: Texture2D = load(source.path)
  frames.add_animation(name)
  frames.set_animation_loop(name,false)
  frames.set_animation_speed(name,30)
  var points: Array[Vector2] = []
  var sizes: Array[Vector2] = []
  for index in range(source.frames.size()):
   var frame: Dictionary = source.frames[index]
   var r := Rect2(frame.rect[0],frame.rect[1],frame.rect[2],frame.rect[3])
   var anchor := Vector2(frame.anchor[0],frame.anchor[1])
   var factor: float = source.scale
   var texture := AtlasTexture.new()
   texture.atlas = sheet
   texture.region = r
   texture.filter_clip = true
   frames.add_frame(name,texture)
   var at := (r.position+r.size*0.5-anchor)*factor
   if kind=="air":
    # Pivô central no ar, sem fazer os pés recolhidos simularem um chão.
    var bounds := Rect2(frame.bounds[0],frame.bounds[1],frame.bounds[2],frame.bounds[3])
    at = (r.position+r.size*0.5-bounds.get_center())*factor+Vector2(0,-90)
   points.append(at)
   sizes.append(Vector2.ONE*factor)
  positions[name] = points
  scales[name] = sizes
 return {"positions":positions,"scales":scales}
