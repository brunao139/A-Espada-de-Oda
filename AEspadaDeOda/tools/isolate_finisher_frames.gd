extends SceneTree
## Mede componentes conectados e guarda contornos; não altera os PNGs gerados.
func _initialize() -> void:
 var manifest: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://assets/animation_manifest.json"))
 for kind in ["launch","landing"]:
  var source: Dictionary = manifest[kind]
  var img := Image.load_from_file(source.path)
  var width := img.get_width()
  var height := img.get_height()
  var visited := PackedByteArray()
  visited.resize(width*height)
  var components := []
  for y in range(height):
   for x in range(width):
    var key := y*width+x
    if visited[key] or img.get_pixel(x,y).a<0.15: continue
    var stack: Array[Vector2i] = [Vector2i(x,y)]
    var pixels: Array[Vector2i] = []
    var lo := Vector2i(x,y)
    var hi := lo
    visited[key] = 1
    while not stack.is_empty():
     var point: Vector2i = stack.pop_back()
     pixels.append(point)
     lo = lo.min(point)
     hi = hi.max(point)
     for offset in [Vector2i.LEFT,Vector2i.RIGHT,Vector2i.UP,Vector2i.DOWN]:
      var next: Vector2i = point+offset
      if next.x<0 or next.x>=width or next.y<0 or next.y>=height: continue
      var nk := next.y*width+next.x
      if not visited[nk] and img.get_pixelv(next).a>=0.15:
       visited[nk] = 1
       stack.append(next)
    if pixels.size()>1000: components.append({"pixels":pixels,"lo":lo,"hi":hi})
  if components.size()!=12:
   push_error(kind+" precisa 12 componentes, encontrou "+str(components.size()))
   quit(1)
   return
  # Agrupar pela base evita confundir mãos altas e corpos deitados entre linhas.
  components.sort_custom(func(a,b): return a.hi.y<b.hi.y)
  var ordered := []
  for row in range(3):
   var group: Array = components.slice(row*4,row*4+4)
   group.sort_custom(func(a,b): return a.lo.x<b.lo.x)
   ordered.append_array(group)
  var factor: float = 176.0/(ordered[11 if kind=="landing" else 0].hi.y-ordered[11 if kind=="landing" else 0].lo.y+1)
  source.scale = factor
  for index in range(12):
   var part: Dictionary = ordered[index]
   var origin: Vector2i = part.lo-Vector2i(3,3)
   var size: Vector2i = part.hi-part.lo+Vector2i(7,7)
   var crop := Rect2i(origin,size).intersection(Rect2i(0,0,width,height))
   for other in range(12):
    if other==index: continue
    var other_part: Dictionary = ordered[other]
    if crop.intersects(Rect2i(other_part.lo,other_part.hi-other_part.lo+Vector2i.ONE)):
     push_error("Recorte alcanca corpo vizinho: "+kind+"/"+str(index))
     quit(1)
     return
   var frame: Dictionary = source.frames[index]
   frame.erase("polygon")
   frame.rect = [crop.position.x,crop.position.y,crop.size.x,crop.size.y]
   frame.bounds = [part.lo.x,part.lo.y,part.hi.x-part.lo.x+1,part.hi.y-part.lo.y+1]
   frame.anchor = [(part.lo.x+part.hi.x)*0.5,part.hi.y+1]
   if kind=="launch": frame.anchor[1] += (80.0/factor-frame.bounds[3]*0.5)*(1.0-float(index)/11.0)
   print(kind," ",index," corpo isolado=",frame.bounds)
 var file := FileAccess.open("res://assets/animation_manifest.json",FileAccess.WRITE)
 file.store_string(JSON.stringify(manifest,"\t"))
 quit()
