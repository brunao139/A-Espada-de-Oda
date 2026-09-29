extends Node2D
## Equipamentos e arquitetura em coordenadas do mundo. Decoração sem colisão.
var elapsed := 0.0
@onready var level: Node2D = get_parent()
const DISTRICTS := ["ACESSO / DISTRITO ODA","NEON / PASSARELAS","PORTO / TERMINAL 09"]
func _process(delta: float) -> void:
	elapsed += delta
	queue_redraw()
func district_at(x: float) -> int:
	return clampi(int(x/3000),0,2)
func _glow_line(a: Vector2,b: Vector2,color: Color,width: float = 2) -> void:
	draw_line(a,b,Color(color,0.08),width+10)
	draw_line(a,b,Color(color,0.17),width+4)
	draw_line(a,b,color,width)
func _sign(at: Vector2,words: String,color: Color,width: float = 160) -> void:
	draw_rect(Rect2(at-Vector2(4,4),Vector2(width+8,60)),Color(color,0.06))
	draw_rect(Rect2(at,Vector2(width,52)),Color("#08172b"))
	draw_rect(Rect2(at,Vector2(width,52)),Color(color,0.65),false,1)
	draw_string(ThemeDB.fallback_font,at+Vector2(12,33),words,HORIZONTAL_ALIGNMENT_LEFT,-1,19,color)
	var scan := fposmod(elapsed*15,48)
	draw_line(at+Vector2(4,scan),at+Vector2(width-4,scan),Color(color,0.15),1)
func _draw() -> void:
	if not is_instance_valid(level.camera): return
	var left: float = level.camera.position.x-790
	var right: float = left+1580
	# Fachadas com cabos, dutos e janelas; somente as próximas da câmera.
	var first := maxi(0,int(floor(left/440.0)))
	for block in range(first,mini(21,int(right/440.0)+1)):
		var x := block*440.0+40
		var district := district_at(x)
		var color := Color("#57dae1") if district == 0 else (Color("#eb68b7") if district == 1 else Color("#e8b86d"))
		var roof := 354.0+sin(block*2.1)*38
		draw_rect(Rect2(x,roof,270,580-roof),Color("#091b2c"))
		draw_rect(Rect2(x+9,roof+10,253,570-roof),Color("#0c2033"))
		draw_line(Vector2(x+15,roof),Vector2(x+250,roof),Color("#304b61"),3)
		_glow_line(Vector2(x+260,roof+15),Vector2(x+260,554),Color(color,0.42),1)
		for row in range(5):
			for col in range(6):
				var shade := 0.25+0.12*sin(block+row+elapsed*0.45)
				draw_rect(Rect2(x+22+col*35,roof+32+row*25,21,7),Color(color,shade))
		draw_rect(Rect2(x+23,roof-25,64,25),Color("#173347"))
		for vent in range(5):
			draw_line(Vector2(x+28+vent*11,roof-21),Vector2(x+28+vent*11,roof-5),Color("#456476"),2)
		draw_line(Vector2(x+210,roof),Vector2(x+210,roof-48),Color("#416c7d"),3)
		draw_arc(Vector2(x+210,roof-54),13,-0.6,2.5,12,Color("#7893a1"),3)
		var cable := PackedVector2Array()
		for point in range(13):
			var t := point/12.0
			cable.append(Vector2(x+230+t*210,roof-12+sin(t*PI)*24))
		draw_polyline(cable,Color("#203c52"),2,true)
		if block%2 == 0:
			_sign(Vector2(x+20,roof+85),["ODA TECH","NEXUS","DOCK 09"][district],color)
		else:
			draw_rect(Rect2(x+32,500,63,80),Color("#152b40"))
			draw_rect(Rect2(x+40,510,47,22),Color(color,0.32))
			_glow_line(Vector2(x+37,506),Vector2(x+89,506),color,1)
		# Corrimão recuado e luminária de rua.
		for post in range(5):
			draw_line(Vector2(x+post*58,543),Vector2(x+post*58,580),Color("#355469"),2)
		draw_line(Vector2(x,544),Vector2(x+255,544),Color("#466c7c"),2)
		draw_line(Vector2(x+315,580),Vector2(x+315,422),Color("#314d62"),5)
		draw_line(Vector2(x+315,422),Vector2(x+356,422),Color("#314d62"),5)
		_glow_line(Vector2(x+327,427),Vector2(x+354,427),Color("#87eaf0"),3)
		draw_colored_polygon(PackedVector2Array([Vector2(x+327,430),Vector2(x+354,430),Vector2(x+396,579),Vector2(x+297,579)]),Color(0.22,0.82,0.9,0.035))
	# Equipamentos sob a rota elevada: detalhes não invadem o topo sólido.
	for body in level.get_node("Geometry").get_children():
		if body.name in ["Floor","LeftWall","RightWall"]: continue
		var box: RectangleShape2D = body.get_node("Shape").shape
		var rect := Rect2(body.position-box.size/2,box.size)
		if rect.end.x < left or rect.position.x > right: continue
		for support in range(2):
			var sx := rect.position.x+28+support*(rect.size.x-56)
			draw_line(Vector2(sx,rect.end.y),Vector2(sx,580),Color("#18364a"),8)
			draw_line(Vector2(sx+3,rect.end.y),Vector2(sx+3,580),Color("#2d5366"),1)
	# Portais e orientação visível ao entrar em cada trecho.
	for district in range(3):
		var x := 420.0+district*3000
		if x < left-300 or x > right: continue
		var color: Color = [Color("#73e4e9"),Color("#ed86c8"),Color("#f0c379")][district]
		_sign(Vector2(x,226),DISTRICTS[district],color,290)
		draw_string(ThemeDB.fallback_font,Vector2(x+15,307),"ROTA ELEVADA  →",HORIZONTAL_ALIGNMENT_LEFT,-1,15,Color("#a3b4c6"))
	if right > 8250:
		# Guindaste do porto, além da área de circulação.
		draw_line(Vector2(8570,580),Vector2(8570,170),Color("#213b50"),18)
		draw_line(Vector2(8390,170),Vector2(8830,170),Color("#3c5364"),15)
		for i in range(8):
			var x := 8390+i*55
			draw_line(Vector2(x,163),Vector2(x+35,190),Color("#b79a62"),3)
		draw_line(Vector2(8770,177),Vector2(8770,315+sin(elapsed)*4),Color("#78909b"),2)
		_sign(Vector2(8580,400),"TERMINAL 09",Color("#f0c379"),185)
