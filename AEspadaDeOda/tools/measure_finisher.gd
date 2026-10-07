extends SceneTree
# Medição somente: gera metadados de recorte; não modifica a arte original.
const SPECS := {
 "gf5": ["res://assets/gf5/right_punch.png",3,176.0],
 "launch": ["res://assets/ajogun_launch/launch.png",3,176.0],
 "landing": ["res://assets/ajogun_launch/landing.png",3,176.0]
}
func cuts(counts: Array[int], parts: int) -> Array[int]:
 var result: Array[int] = [0]
 var stride := float(counts.size())/parts
 for cut in range(1,parts):
  var ideal := stride*cut
  var best := int(ideal)
  var cost := INF
  for at in range(maxi(result[-1]+30,int(ideal-stride*0.43)),mini(counts.size()-2,int(ideal+stride*0.43))):
   var score := 0.0
   for offset in range(-2,3): score += counts[clampi(at+offset,0,counts.size()-1)]
   score = score*1000.0+absf(at-ideal)
   if score<cost:
    cost = score
    best = at
  result.append(best)
 result.append(counts.size())
 return result
func _initialize() -> void:
 var manifest: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://assets/animation_manifest.json"))
 for kind in SPECS:
  var spec: Array = SPECS[kind]
  if not FileAccess.file_exists(spec[0]): continue
  var img := Image.load_from_file(spec[0])
  var width := img.get_width()
  var height := img.get_height()
  var rows: Array[int] = []
  rows.resize(height)
  rows.fill(0)
  for y in range(height):
   for x in range(width):
    if img.get_pixel(x,y).a>0.15: rows[y]+=1
  var row_cuts := cuts(rows,int(spec[1]))
  if kind == "death": row_cuts = [0,380,690,930,height]
  var frames := []
  for row in range(int(spec[1])):
   var columns: Array[int] = []
   columns.resize(width)
   columns.fill(0)
   for x in range(width):
    for y in range(row_cuts[row],row_cuts[row+1]):
     if img.get_pixel(x,y).a>0.15: columns[x]+=1
   var col_cuts := cuts(columns,4)
   for col in range(4):
    var left := col_cuts[col]
    var right := col_cuts[col+1]
    var top := row_cuts[row]
    var bottom := row_cuts[row+1]
    var min_x := right
    var max_x := left
    var min_y := bottom
    var max_y := top
    for y in range(top,bottom):
     for x in range(left,right):
      if img.get_pixel(x,y).a>0.15:
       min_x = mini(min_x,x)
       max_x = maxi(max_x,x)
       min_y = mini(min_y,y)
       max_y = maxi(max_y,y)
    var foot_left := max_x
    var foot_right := min_x
    for y in range(maxi(min_y,max_y-12),max_y+1):
     for x in range(min_x,max_x+1):
      if img.get_pixel(x,y).a>0.15:
       foot_left = mini(foot_left,x)
       foot_right = maxi(foot_right,x)
    var anchor_x := (foot_left+foot_right)*0.5
    if kind in ["launch","landing"]: anchor_x = (min_x+max_x)*0.5
    frames.append({"rect":[left,top,right-left,bottom-top],"bounds":[min_x,min_y,max_x-min_x+1,max_y-min_y+1],"anchor":[anchor_x,max_y+1]})
  var scale := float(spec[2])/float(frames[11 if kind=="landing" else 0].bounds[3])
  for index in range(frames.size()):
   var frame: Dictionary = frames[index]
   if kind=="gf5": frame.scale = 176.0/float(frame.bounds[3])
   if kind=="launch":
    frame.anchor[1] += (80.0/scale-frame.bounds[3]*0.5)*(1.0-float(index)/11.0)
  manifest[kind] = {"path":spec[0],"scale":scale,"frames":frames,"size":[width,height]}
  print(kind," ",width,"x",height," cuts=",row_cuts," scale=",scale)
 var file := FileAccess.open("res://assets/animation_manifest.json",FileAccess.WRITE)
 file.store_string(JSON.stringify(manifest,"\t"))
 quit()
