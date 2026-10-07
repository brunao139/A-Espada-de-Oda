extends RefCounted
## Arte v2: folhas próprias, recortes medidos e apoio opaco por quadro.
static var manifest: Dictionary = {}
static var textures: Dictionary = {}
const COUNTS := {"idle":4,"walk":12,"run":12,"hurt":12,"attack":16,"death":16,"launch":12,"landing":12}
static func source(kind: String) -> Dictionary:
 if manifest.is_empty():
  manifest = JSON.parse_string(FileAccess.get_file_as_string("res://assets/animation_manifest.json"))
 return manifest[kind]
static func count(kind: String) -> int:
 return COUNTS[kind]
static func info(kind: String, index: int) -> Dictionary:
 var sheet_kind := "idle_hurt" if kind in ["idle","hurt"] else kind
 var sheet := source(sheet_kind)
 var frame: Dictionary = sheet.frames[index+4 if kind=="hurt" else index]
 return {"sheet":sheet,"frame":frame}
static func apply(target: Polygon2D, kind: String, index: int) -> void:
 var data := info(kind,index)
 var frame: Dictionary = data.frame
 var sheet: Dictionary = data.sheet
 var path: String = sheet.path
 if not textures.has(path): textures[path] = load(path)
 var r := Rect2(frame.rect[0],frame.rect[1],frame.rect[2],frame.rect[3])
 var anchor := Vector2(frame.anchor[0],frame.anchor[1])
 var uv := PackedVector2Array([r.position,Vector2(r.end.x,r.position.y),r.end,Vector2(r.position.x,r.end.y)])
 if frame.has("polygon"):
  uv = PackedVector2Array()
  for point in frame.polygon: uv.append(Vector2(point[0],point[1]))
 var points := PackedVector2Array()
 for point in uv: points.append((point-anchor)*float(sheet.scale))
 target.texture = textures[path]
 target.uv = uv
 target.polygon = points
