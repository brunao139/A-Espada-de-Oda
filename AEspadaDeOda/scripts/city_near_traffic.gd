extends Node2D
## Tráfego próximo passa à frente das fachadas, atrás das plataformas e do Youkai.
@onready var level: Node2D = get_parent()
@onready var city: Node2D = level.get_node("Backdrop/City")
func _process(_delta: float) -> void:
	position = Vector2(level.camera.position.x-640,0)
	queue_redraw()
func _draw() -> void:
	if is_instance_valid(city):
		city.draw_traffic(self,true)
