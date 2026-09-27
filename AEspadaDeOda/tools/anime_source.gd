extends Node2D
## Fonte de montagem offline. O jogo reproduz apenas o OGV renderizado.
const FEUDAL = preload("res://assets/intro_anime/feudal_night.png")
const CITY = preload("res://assets/intro_anime/cyberpunk_night.png")
const RUN = preload("res://assets/intro_anime/run_cycle.png")
const LEAP = preload("res://assets/intro_anime/youkai_leap.png")
const PREP = preload("res://assets/intro_anime/youkai_preparation.png")
const STRIKE = preload("res://assets/intro_anime/youkai_strike.png")
const MENU = preload("res://assets/intro_anime/menu_background.png")
const FONT = preload("res://assets/intro_anime/Cinzel.ttf")
const DURATION := 30.0
var elapsed := 0.0
var manual := false

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	queue_redraw()

func _process(delta: float) -> void:
	if not manual:
		elapsed += delta
	queue_redraw()

func plate(tex: Texture2D, zoom: float = 1.0, offset: Vector2 = Vector2.ZERO, tint: Color = Color.WHITE) -> void:
	var sz := Vector2(1280, 720) * zoom
	draw_texture_rect(tex, Rect2((Vector2(1280,720)-sz)*0.5+offset,sz), false, tint)

func runner(pos: Vector2, height: float, time: float, tint: Color = Color.WHITE) -> void:
	# Somente a linha voltada para a esquerda; evita trocar o lado da bainha.
	var frame := int(time * 14.0) % 4
	var cell := Vector2(RUN.get_width()/4.0, RUN.get_height()/2.0)
	var scale_factor := height / cell.y
	var sz := cell * scale_factor
	draw_texture_rect_region(RUN,Rect2(pos-Vector2(sz.x*0.5,sz.y*0.93),sz),Rect2(Vector2(frame*cell.x,0),cell),tint)

func streaks(time: float, strength: float, radial: bool = false) -> void:
	for i in range(42):
		var seedv := float(i)
		var y := fmod(seedv*83.0+17.0,720.0)
		var x := fposmod(seedv*191.0+time*2100.0,1700.0)-220.0
		var length := 70.0+fmod(seedv*29.0,170.0)
		var color := Color(0.66,0.85,1.0,strength*(0.08+fmod(seedv*0.03,0.2)))
		if radial:
			var angle := seedv/42.0*TAU+time*0.05
			var v := Vector2(cos(angle),sin(angle))
			draw_line(Vector2(640,340)+v*430,Vector2(640,340)+v*900,color,2.0,true)
		else:
			draw_line(Vector2(x,y),Vector2(x+length,y-8),color,1.5,true)

func rain(time: float, strength: float = 1.0) -> void:
	for i in range(135):
		var x := fposmod(i*103.7-time*165.0,1360.0)-30.0
		var y := fposmod(i*59.1+time*(580.0+float(i%4)*70.0),800.0)-40.0
		draw_line(Vector2(x,y),Vector2(x-9,y+29),Color(0.66,0.83,1.0,0.16*strength),1.0,true)

func roof(time: float, future: bool, floor_y: float = 540.0) -> void:
	draw_rect(Rect2(0,floor_y,1280,180),Color("08111f"))
	draw_line(Vector2(0,floor_y),Vector2(1280,floor_y),Color("3f6a81"),5)
	for i in range(-1,19):
		var x := fposmod(i*86.0+time*480.0,1500.0)-120.0
		if future:
			draw_line(Vector2(x,floor_y+18),Vector2(x+54,floor_y+18),Color("49c8e6"),2)
			draw_line(Vector2(x,floor_y+70),Vector2(x+70,floor_y+70),Color("162d42"),2)
		else:
			draw_line(Vector2(x,floor_y),Vector2(x-40,floor_y+84),Color("284056"),7,true)
			draw_line(Vector2(x+3,floor_y),Vector2(x-37,floor_y+84),Color("416079"),1,true)
	draw_rect(Rect2(0,floor_y+86,1280,7),Color("030914"))

func aura(time: float, intensity: float) -> void:
	for j in range(5):
		var pts := PackedVector2Array()
		for i in range(65):
			var x := float(i)*21.0-30.0
			var y := 470.0+sin(x*0.007+time*2.3+j*0.9)*(60.0+j*17.0)-j*42.0
			pts.append(Vector2(x,y))
		draw_polyline(pts,Color(1.0,0.63,0.09,0.11*intensity),18.0,true)
		draw_polyline(pts,Color(1.0,0.85,0.35,0.42*intensity),2.0,true)
	for i in range(65):
		var x := fposmod(i*131.1+sin(time+i)*16.0,1280)
		var y := fposmod(i*61.9-time*(35.0+float(i%5)*12.0),720)
		draw_circle(Vector2(x,y),1.2+float(i%3),Color(1,0.8,0.26,0.45*intensity))

func portal(time: float, progress: float) -> void:
	var center := Vector2(lerpf(100.0,1280.0,progress),330)
	for r in range(4):
		var pts := PackedVector2Array()
		for i in range(97):
			var a := float(i)/96.0*TAU
			var jitter := sin(a*17.0+time*23.0)*8.0
			pts.append(center+Vector2(cos(a)*(85+r*13+jitter),sin(a)*(320+r*14+jitter)))
		draw_polyline(pts,Color(0.2,0.85,1.0,0.12),23.0,true)
		draw_polyline(pts,Color(0.63,0.96,1,0.72),2.0,true)
	for i in range(22):
		var y := fposmod(i*47.0+time*210,700)
		var x := center.x+sin(i*9.0+time*3.0)*160
		draw_line(Vector2(x,y),Vector2(x+55,y),Color(0.2,0.8,1,0.65),2,true)

func leap_shot(time: float) -> void:
	var p := clampf((time-11.4)/5.4,0,1)
	# Tempo retido no ápice; acelera na saída e na chegada.
	var u := 0.5+4.0*pow(p-0.5,3)
	plate(CITY,1.14,Vector2(25*sin(p*PI),24*p))
	rain(time,0.75)
	for rect in [Rect2(0,566,405,154),Rect2(864,536,416,184)]:
		draw_rect(rect,Color("081221"))
		draw_line(rect.position,rect.position+Vector2(rect.size.x,0),Color("52d9ef"),5)
		draw_line(rect.position+Vector2(0,17),rect.position+Vector2(rect.size.x,17),Color("6f386d"),3)
	var center := Vector2(lerpf(1030,270,u),540-210*sin(u*PI))
	var width := 330.0+190.0*sin(u*PI)
	var sz := Vector2(width,width*LEAP.get_height()/float(LEAP.get_width()))
	draw_set_transform(center,lerpf(-0.13,0.14,u),Vector2.ONE)
	draw_texture_rect(LEAP,Rect2(-sz*Vector2(0.5,0.8),sz),false)
	draw_set_transform(Vector2.ZERO)
	streaks(time,0.35,true)
	if p > 0.94:
		var land := (p-0.94)/0.06
		draw_arc(Vector2(270,562),90*land,PI,TAU,30,Color(0.45,0.9,1,1-land),5,true)

func _draw() -> void:
	var t := elapsed
	draw_rect(Rect2(0,0,1280,720),Color("050b18"))
	if t < 4.4:
		plate(FEUDAL,1.12,Vector2(-65+t*24,0))
		roof(t,false)
		if t > 0.7:
			var x := lerpf(1420.0,435.0,clampf((t-0.7)/3.7,0,1))
			runner(Vector2(x+55,540),326,t-0.08,Color(0.4,0.65,0.95,0.18))
			runner(Vector2(x,540),326,t)
			streaks(t,0.8)
		draw_rect(Rect2(0,0,1280,720),Color(0,0,0,1.0-smoothstep(0.0,0.7,t)))
	elif t < 6.2:
		plate(FEUDAL,1.5,Vector2(90,-120),Color(0.6,0.7,0.9))
		roof(t*1.5,false,575)
		runner(Vector2(650,580),980,t)
		streaks(t,1.0)
		for i in range(20):
			var a := fposmod(t*7.0+i*0.117,1.0)
			draw_line(Vector2(430+i*13+a*110,570-a*70),Vector2(442+i*13+a*110,566-a*70),Color(1,0.78,0.4,(1-a)*0.7),2,true)
	elif t < 9.4:
		var p := (t-6.2)/3.2
		plate(FEUDAL,1.1,Vector2(p*65,0))
		# Faixas de arquitetura se recompõem, avançando da esquerda para a direita.
		for i in range(24):
			var y := i*30.0
			var width := clampf((p*1.6-0.2+sin(i*7.0)*0.11)*1280.0,0,1280)
			if width > 0:
				draw_texture_rect_region(CITY,Rect2(0,y,width,30),Rect2(0,y/720*CITY.get_height(),width/1280*CITY.get_width(),30.0/720*CITY.get_height()))
		roof(t,p>0.5)
		runner(Vector2(625-p*200,540),326,t)
		portal(t,p)
		streaks(t,1.2)
		draw_rect(Rect2(0,0,1280,720),Color(0.65,0.95,1,pow(maxf(0.0,1.0-absf(p-0.52)*5.0),3)*0.8))
	elif t < 11.4:
		plate(CITY,1.15,Vector2((t-9.4)*30-50,0))
		roof(t,true)
		runner(Vector2(970-(t-9.4)*240,540),326,t)
		rain(t)
		streaks(t,1.0)
	elif t < 16.8:
		leap_shot(t)
	elif t < 21.8:
		var p := (t-16.8)/5.0
		plate(PREP,1.0+p*0.12,Vector2(-p*20,p*22))
		rain(t,0.5)
		aura(t,0.3+p*0.7)
		if t < 17.0:
			draw_rect(Rect2(0,0,1280,720),Color(0.65,0.9,1,(17.0-t)*1.3))
	elif t < 22.8:
		var p := t-21.8
		draw_texture_rect_region(PREP,Rect2(0,0,1280,720),Rect2(750+p*15,130+p*10,410-p*30,231-p*17))
		aura(t,0.6)
		var glow := p*p
		draw_line(Vector2(245,396),Vector2(1040,325),Color(0.4,0.95,1,glow*0.24),23,true)
	elif t < 24.8:
		var p := (t-22.8)/2.0
		plate(STRIKE,1.0+pow(p,3)*0.7,Vector2(sin(t*72)*p*6,cos(t*65)*p*6))
		streaks(t,1.5,true)
		aura(t,0.8)
		var slash := smoothstep(0.25,0.7,p)
		if slash > 0:
			draw_line(Vector2(-200,850),Vector2(1450,-200),Color(1,0.72,0.2,slash*0.65),60+slash*160,true)
			draw_line(Vector2(-200,850),Vector2(1450,-200),Color(1,1,0.92,slash),12+slash*90,true)
		draw_rect(Rect2(0,0,1280,720),Color(1,1,1,smoothstep(0.6,0.92,p)))
	else:
		plate(MENU)
		draw_rect(Rect2(0,0,1280,720),Color(0.01,0.025,0.065,0.35))
		var a := smoothstep(25.8,27.3,t)
		var title := "A ESPADA DE ODA"
		var size := FONT.get_string_size(title,HORIZONTAL_ALIGNMENT_LEFT,-1,66)
		var pos := Vector2((1280-size.x)*0.5,231)
		draw_string_outline(FONT,pos,title,HORIZONTAL_ALIGNMENT_LEFT,-1,66,8,Color(0.027,0.075,0.145,a))
		draw_string(FONT,pos,title,HORIZONTAL_ALIGNMENT_LEFT,-1,66,Color(1,0.9,0.64,a))
		draw_line(Vector2(450,274),Vector2(830,274),Color(0.85,0.71,0.43,a*0.7),2)
		draw_rect(Rect2(0,0,1280,720),Color(1,1,1,1.0-smoothstep(24.9,26.5,t)))
	# Letterbox abre suavemente para o menu final em 16:9.
	var bars := 34.0*(1.0-smoothstep(25.6,27.0,t))
	draw_rect(Rect2(0,0,1280,bars),Color.BLACK)
	draw_rect(Rect2(0,720-bars,1280,bars),Color.BLACK)
