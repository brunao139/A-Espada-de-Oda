extends SceneTree
var checks := 0
var failures := 0
var scene: Node2D
var hero: CharacterBody2D
func _initialize() -> void: call_deferred("run")
func step(n: int) -> void:
	for i in range(n):
		await physics_frame
		await process_frame
func check(ok: bool, message: String) -> void:
	checks += 1
	print(("PASS " if ok else "FAIL ")+message)
	if not ok: failures += 1
func place(pos: Vector2) -> void:
	Input.action_release("jump")
	Input.action_release("move_right")
	hero.position = pos
	hero.velocity = Vector2.ZERO
	hero.ledge.state = ""
	hero.ledge.cooldown = 0.4
	hero.action = ""
	hero.jump_buffer = 0
	hero.coyote_left = 0
	hero.jump_spinning = false
func run() -> void:
	scene = load("res://scenes/movement_lab.tscn").instantiate()
	root.add_child(scene)
	hero = scene.get_node("Youkai")
	await step(4)
	check(scene.world_width == 9000 and scene.camera.limit_right == 9000,"Cenario e camera ampliados para 9000")
	check(scene.get_node("Geometry/RightWall").position.x == 9030,"Parede final transferida")
	check(scene.get_node("Geometry/StepOne").position == Vector2(970,466) and scene.get_node("Geometry/LedgePractice").position == Vector2(2290,455),"Plataformas originais preservadas")
	var city = scene.get_node("Backdrop/City")
	check(city.vehicles.size() == 4,"Dois carros e duas motos com sprites proprios")
	var initial: Vector2 = city.traffic_position(10)
	city.elapsed += 1
	check(city.traffic_position(10).distance_to(initial)>100,"Trafego realmente animado")
	check(scene.get_node("NearTraffic").z_index > scene.get_node("CityDetails").z_index,"Veiculos proximos visiveis a frente das fachadas")
	for offset in [0,3000,7720]:
		city.camera_offset = offset
		var safe := true
		for i in range(city.TRAFFIC_COUNT):
			var pos: Vector2 = city.traffic_position(i)
			safe = safe and is_finite(pos.x) and pos.x >= -300 and pos.x < 1580
		check(safe,"Trafego circular valido no offset "+str(offset))
	for body in scene.get_node("Geometry").get_children():
		if not (String(body.name).begins_with("Neon") or String(body.name).begins_with("Port") or body.name == "TerminalPad"): continue
		var shape: RectangleShape2D = body.get_node("Shape").shape
		var top: float = body.position.y-shape.size.y/2
		place(Vector2(body.position.x,top-25))
		await step(18)
		check(hero.is_on_floor() and absf(hero.position.y-top)<1,"Colisao no topo: "+str(body.name))
	# Percurso completo da expansão com entrada de corrida e saltos por aproximação.
	place(Vector2(2860,580))
	await step(4)
	var crossed := false
	var grabs := 0
	var was_hanging := false
	for frame in range(2600):
		Input.action_press("move_right")
		if hero.ledge.state == "hang":
			if not was_hanging:
				Input.action_release("jump")
				grabs += 1
			elif hero.ledge.climb_armed:
				Input.action_press("jump")
			was_hanging = true
		else:
			was_hanging = false
			if hero.is_on_floor() and not Input.is_action_pressed("jump"):
				var obstacle := false
				for body in scene.get_node("Geometry").get_children():
					if body.name in ["Floor","LeftWall","RightWall"]: continue
					var shape: RectangleShape2D = body.get_node("Shape").shape
					var edge: float = body.position.x-shape.size.x/2
					var top: float = body.position.y-shape.size.y/2
					if edge > hero.position.x+6 and edge < hero.position.x+140 and top < hero.position.y-5:
						obstacle = true
				if obstacle or hero.is_on_wall(): Input.action_press("jump")
			elif hero.is_on_floor():
				Input.action_release("jump")
		await step(1)
		if hero.position.x >= 8900:
			crossed = true
			break
	check(crossed,"Percurso da expansao por corrida, saltos e beiradas; x="+str(round(hero.position.x)))
	print("TRAVERSAL ledge grabs: ",grabs)
	Input.action_release("jump")
	Input.action_release("move_right")
	place(Vector2(8970,580))
	Input.action_press("move_right")
	await step(30)
	check(hero.position.x <= 8982.1,"Limite direito impede sair do mundo")
	check(scene.camera.position.x <= 8360.1,"Camera nao mostra alem do fim")
	Input.action_release("move_right")
	print("CITY RESULT: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)
