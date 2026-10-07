extends Node2D
## Primeiro plano limpo: apenas as grades da ponte, sem letreiros ou fachadas.
var elapsed := 0.0
@onready var level: Node2D = get_parent()
func _process(delta: float) -> void:
 elapsed += delta
 queue_redraw()
func district_at(x: float) -> int:
 return clampi(int(x/3000),0,2)
func _draw() -> void:
 if not is_instance_valid(level.camera): return
 var left := maxf(0,level.camera.position.x-740)
 var right := minf(level.world_width,level.camera.position.x+740)
 draw_line(Vector2(left,545),Vector2(right,545),Color("456476"),3)
 draw_line(Vector2(left,565),Vector2(right,565),Color("233f52"),2)
 for x in range(int(floor(left/58.0))*58,int(right)+58,58):
  draw_line(Vector2(x,545),Vector2(x,580),Color("355469"),2)
  draw_line(Vector2(x+3,547),Vector2(x+3,580),Color("152b40"),1)
