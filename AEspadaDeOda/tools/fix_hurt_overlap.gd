extends SceneTree
func _initialize() -> void:
 var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://assets/animation_manifest.json"))
 var image: Texture2D = load(data.idle_hurt.path)
 var img := image.get_image()
 for index in range(8,12):
  var frame: Dictionary = data.idle_hurt.frames[index]
  var r := Rect2i(frame.rect[0],frame.rect[1],frame.rect[2],frame.rect[3])
  var visited := {}
  var components := []
  for y in range(r.position.y,r.end.y):
   for x in range(r.position.x,r.end.x):
    var key := y*img.get_width()+x
    if visited.has(key) or img.get_pixel(x,y).a<0.15: continue
    var stack: Array[Vector2i] = [Vector2i(x,y)]
    var pixels: Array[Vector2i] = []
    visited[key] = true
    var minimum := Vector2i(x,y)
    var maximum := minimum
    while not stack.is_empty():
     var point: Vector2i = stack.pop_back()
     pixels.append(point)
     minimum = minimum.min(point)
     maximum = maximum.max(point)
     for delta in [Vector2i.LEFT,Vector2i.RIGHT,Vector2i.UP,Vector2i.DOWN]:
      var next: Vector2i = point+delta
      if not r.has_point(next): continue
      var nk := next.y*img.get_width()+next.x
      if not visited.has(nk) and img.get_pixelv(next).a>=0.15:
       visited[nk] = true
       stack.append(next)
    if pixels.size()>50: components.append({"pixels":pixels,"min":minimum,"max":maximum})
  components.sort_custom(func(a,b): return a.pixels.size()>b.pixels.size())
  if components.size()!=2:
   push_error("Esperados corpo e ponta de chifre vizinha: "+str(index))
   quit(1)
   return
  var main: Dictionary = components[0]
  var extra: Dictionary = components[1]
  var left: int = extra.min.x
  var right: int = extra.max.x+1
  var profile := {}
  for point in extra.pixels:
   profile[point.x] = mini(profile.get(point.x,r.end.y),point.y)
  for point in main.pixels:
   if profile.has(point.x) and point.y>=profile[point.x]:
    push_error("Contorno atingiria corpo: "+str(index))
    quit(1)
    return
  var polygon := [[r.position.x,r.position.y],[r.end.x,r.position.y],[r.end.x,r.end.y],[right,r.end.y]]
  for x in range(right-1,left-1,-1):
   var y: int = profile.get(x,r.end.y)
   for point in [[x+1,y],[x,y]]:
    if polygon[-1]!=point: polygon.append(point)
  polygon.append([left,r.end.y])
  polygon.append([r.position.x,r.end.y])
  frame.polygon = polygon
  frame.bounds = [main.min.x,main.min.y,main.max.x-main.min.x+1,main.max.y-main.min.y+1]
  frame.anchor[1] = main.max.y+1
  var next_frame: Dictionary = data.idle_hurt.frames[index+4]
  var next := Rect2i(next_frame.rect[0],next_frame.rect[1],next_frame.rect[2],next_frame.rect[3])
  var next_polygon := [[next.position.x,next.position.y],[left,next.position.y]]
  for x in range(left,right):
   var y: int = profile.get(x,r.end.y)
   for point in [[x,y],[x+1,y]]:
    if next_polygon[-1]!=point: next_polygon.append(point)
  next_polygon.append([right,next.position.y])
  next_polygon.append([next.end.x,next.position.y])
  next_polygon.append([next.end.x,next.end.y])
  next_polygon.append([next.position.x,next.end.y])
  next_frame.polygon = next_polygon
  var bottom: int = int(next_frame.bounds[1]+next_frame.bounds[3])
  next_frame.bounds[1] = extra.min.y
  next_frame.bounds[3] = bottom-extra.min.y
  print("PASS isolados os quadros ",index," e ",index+4," sem cortar pixels do corpo")
 var file := FileAccess.open("res://assets/animation_manifest.json",FileAccess.WRITE)
 file.store_string(JSON.stringify(data,"\t"))
 quit()
