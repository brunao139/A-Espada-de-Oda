extends Node2D
## Três planos de cidade, tráfego aéreo e linha de transporte; sem colisão.
var camera_offset := 0.0
var elapsed := 0.0
var city: Texture2D = preload("res://assets/cidade_futurista.png")
var vehicle_sheet: Texture2D = preload("res://assets/city/hover_traffic.png")
var vehicles: Array[AtlasTexture] = []
const TRAFFIC_COUNT := 10
func _ready() -> void:
	var image := vehicle_sheet.get_image()
	var cell := Vector2i(image.get_width()/2,image.get_height()/2)
	for i in range(4):
		var origin := Vector2i(i%2,i/2)*cell
		var bounds := image.get_region(Rect2i(origin,cell)).get_used_rect()
		var texture := AtlasTexture.new()
		texture.atlas = vehicle_sheet
		texture.region = Rect2(Vector2(origin+bounds.position),Vector2(bounds.size))
		texture.filter_clip = true
		vehicles.append(texture)
func _process(delta: float) -> void:
	elapsed += delta
	queue_redraw()
func traffic_position(index: int) -> Vector2:
	var speed := 58.0+index*8.0
	var direction := 1.0 if index%2 == 0 else -1.0
	var x := fposmod(index*227.0 + elapsed*speed*direction-camera_offset*0.20,1880.0)-300.0
	var y := 205.0+(index%5)*45.0+sin(elapsed*0.7+index)*9.0
	return Vector2(x,y)
func draw_traffic() -> void:
	if vehicles.is_empty(): return
	for i in range(TRAFFIC_COUNT):
		var texture := vehicles[i%4]
		var width := 48.0+(i%5)*11
		var height := width*texture.get_height()/texture.get_width()
		var position := traffic_position(i)
		var direction := 1.0 if i%2 == 0 else -1.0
		var bank := sin(elapsed+i)*0.055 if i%4 >= 2 else 0.0
		draw_set_transform(position,bank,Vector2(direction,1))
		var tint := Color(0.47,0.70,0.90,0.72)
		draw_texture_rect(texture,Rect2(-width/2,-height/2,width,height),false,tint)
		draw_line(Vector2(-width*0.44,0),Vector2(-width*0.68,0),Color(0.3,0.85,1,0.12),4)
	draw_set_transform(Vector2.ZERO)
func _draw() -> void:
	draw_rect(Rect2(0,0,1280,720),Color("#081626"))
	var size := Vector2(1740,1740.0*city.get_height()/city.get_width())
	var shift := fposmod(camera_offset*0.10,size.x)
	for tile in range(2):
		draw_texture_rect(city,Rect2(Vector2(tile*size.x-shift,-110),size),false,Color(0.66,0.72,0.90))
	draw_rect(Rect2(0,0,1280,720),Color(0.025,0.03,0.09,0.16))
	draw_traffic()
	var first := int(floor(camera_offset*0.32/210.0))-1
	for i in range(first,first+9):
		var x := i*210.0-camera_offset*0.32
		var top := 280.0+sin(i*3.71)*80
		var width := 95.0+fposmod(i*37.0,80)
		draw_rect(Rect2(x,top,width,460),Color("#0c263c"))
		draw_rect(Rect2(x+8,top+6,width-16,460),Color("#103047"))
		draw_line(Vector2(x+width-6,top),Vector2(x+width-6,670),Color("#286378"),2)
		draw_rect(Rect2(x+15,top-17,width-30,17),Color("#123049"))
		draw_line(Vector2(x+width*0.5,top-17),Vector2(x+width*0.5,top-53),Color("#244960"),3)
		draw_circle(Vector2(x+width*0.5,top-54),2,Color(1,0.32,0.48,0.55+sin(elapsed*2+i)*0.25))
		for row in range(9):
			for col in range(4):
				if posmod(i+row*3+col,5) == 0: continue
				var lit := 0.4+0.16*sin(elapsed*0.6+i+row)
				draw_rect(Rect2(x+16+col*22,top+25+row*29,12,4),Color(0.23,0.78,0.91,lit))
		if posmod(i,3) == 0:
			draw_rect(Rect2(x+21,top+87,width-43,43),Color("#102137"))
			draw_line(Vector2(x+21,top+88),Vector2(x+width-22,top+88),Color("#ed639e"),2)
			draw_string(ThemeDB.fallback_font,Vector2(x+28,top+115),"NEON",HORIZONTAL_ALIGNMENT_LEFT,-1,18,Color("#c78ce1"))
	_draw_train()
	# Chuva fina e pontos de luz ficam no fundo, sem cobrir a silhueta do herói.
	for i in range(48):
		var x := fposmod(i*163.0-camera_offset*0.15-elapsed*32,1320)-20
		var y := fposmod(i*79.0+elapsed*185,640)+70
		draw_line(Vector2(x,y),Vector2(x-4,y+12),Color(0.61,0.82,0.94,0.14),1)
	for i in range(14):
		var x := fposmod(i*137.0-camera_offset*0.25+elapsed*7,1280)
		var y := 180+fposmod(i*83.0-elapsed*9,420)
		draw_circle(Vector2(x,y),1.2,Color(0.4,1,1,0.25))
func _draw_train() -> void:
	var y := 408.0
	draw_line(Vector2(0,y+27),Vector2(1280,y+27),Color("#26455a"),5)
	draw_line(Vector2(0,y+23),Vector2(1280,y+23),Color(0.32,0.9,1,0.28),1)
	var start := fposmod(elapsed*105-camera_offset*0.27+210,2500)-700
	for carriage in range(4):
		var x := start+carriage*138
		draw_style_box(_train_style(),Rect2(x,y-12,130,30))
		for window in range(5):
			draw_rect(Rect2(x+12+window*22,y-5,14,10),Color("#6baabd"))
		draw_line(Vector2(x+8,y+13),Vector2(x+122,y+13),Color("#d873a5"),2)
		if carriage == 3: draw_rect(Rect2(x+124,y-1,6,5),Color("#e6f7da"))
func _train_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color("#15344a")
	style.border_color = Color("#3a7185")
	style.set_border_width_all(1)
	style.set_corner_radius_all(7)
	return style
