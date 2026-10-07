extends SceneTree
func _initialize() -> void:
 var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://assets/animation_manifest.json"))
 var img := Image.load_from_file(data.idle_hurt.path)
 for index in range(8,12):
  var fr: Dictionary = data.idle_hurt.frames[index]
  var x0 := int(fr.rect[0])
  var x1 := x0+int(fr.rect[2])
  var y0 := int(fr.rect[1])
  var y1 := y0+int(fr.rect[3])
  var visited := {}
  var components := []
  for y in range(y0,y1):
   for x in range(x0,x1):
    var key := y*img.get_width()+x
    if visited.has(key) or img.get_pixel(x,y).a<0.15: continue
    var stack: Array[Vector2i] = [Vector2i(x,y)]
    visited[key] = true
    var bounds := Rect2i(x,y,1,1)
    var pixels := 0
    while not stack.is_empty():
     var point: Vector2i = stack.pop_back()
     pixels += 1
     bounds = bounds.expand(point)
     for delta in [Vector2i.LEFT,Vector2i.RIGHT,Vector2i.UP,Vector2i.DOWN]:
      var next: Vector2i = point+delta
      if next.x<x0 or next.x>=x1 or next.y<y0 or next.y>=y1: continue
      var nk := next.y*img.get_width()+next.x
      if not visited.has(nk) and img.get_pixelv(next).a>=0.15:
       visited[nk] = true
       stack.append(next)
    if pixels>8: components.append([pixels,str(bounds)])
  print(index," ",components)
 quit()
