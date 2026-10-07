extends SceneTree
var hero: CharacterBody2D
var scene: Node2D
var failures := 0
var checks := 0
var capture_dir := ""
func _initialize() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--capture-dir="): capture_dir = arg.trim_prefix("--capture-dir=")
	call_deferred("run_tests")
func step(n: int) -> void:
	for i in range(n): await physics_frame
func check(ok: bool, message: String) -> void:
	checks += 1
	print(("PASS " if ok else "FAIL ") + message)
	if not ok: failures += 1
func release_inputs() -> void:
	for a in ["move_left","move_right","jump","ledge_drop","light_attack","heavy_attack"]:
		Input.action_release(a)
func place(pos: Vector2, face: int = 1, speed: float = 120) -> void:
	release_inputs()
	hero.ledge.state = ""
	hero.ledge.support = null
	hero.ledge.cooldown = 0
	hero.action = ""
	hero.ledge._reset_actions()
	hero.velocity = Vector2(0,speed)
	hero.global_position = pos
	hero.facing = face
	hero.jump_buffer = 0
	hero.coyote_left = 0
	hero.queued_attack = ""
	hero.jump_spinning = false
	hero.held_finish = ""
func grab(face: int = 1) -> void:
	place(Vector2(2138 if face == 1 else 2442, 500),face)
	Input.action_press("move_right" if face == 1 else "move_left")
	await step(3)
	release_inputs()
func capture(name: String) -> void:
	if capture_dir.is_empty(): return
	scene.camera.position = Vector2(2300,360)
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(capture_dir.path_join(name+".png"))
func box(at: Vector2, size: Vector2) -> StaticBody2D:
	var solid := StaticBody2D.new()
	solid.position = at
	solid.collision_layer = 1
	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = size
	collision.shape = shape
	solid.add_child(collision)
	scene.add_child(solid)
	return solid
func run_tests() -> void:
	scene = load("res://scenes/movement_lab.tscn").instantiate()
	if scene.get_script() == preload("res://scripts/lab.gd"): scene.spawn_enemies = false
	root.add_child(scene)
	hero = scene.get_node("Youkai")
	hero.attack_speed = 1.0 # Baseline temporal histórico; finisher_test cobre a velocidade padrão 0.8.
	await step(5)
	check(hero.sprite.sprite_frames.get_frame_count("ledge") == 8,"Oito poses dedicadas")
	await grab()
	check(hero.ledge.state == "hang" and hero.ledge.point.is_equal_approx(Vector2(2170,330)),"Agarra quina esquerda real durante queda")
	check(hero.sprite.animation == "ledge" and hero.sprite.rotation == 0 and not hero.jump_spinning,"Pendurar interrompe giro e alinha pose")
	var hold: Vector2 = hero.global_position
	await step(25)
	check(hero.global_position.is_equal_approx(hold) and hero.velocity == Vector2.ZERO,"Sustenta o corpo sem escorregar")
	await capture("01-pendurado")
	Input.action_press("heavy_attack")
	await step(3)
	Input.action_release("heavy_attack")
	Input.action_press("light_attack")
	await step(3)
	Input.action_release("light_attack")
	check(hero.action == "" and not hero.attack_active and hero.queued_attack == "","Ataques nao ativam nem ficam na fila ao pendurar")
	Input.action_press("jump")
	await step(2)
	check(hero.ledge.state == "climb","Novo toque de pulo inicia subida")
	var safe := true
	for i in range(46):
		await step(1)
		safe = safe and not hero.get_node("Body").disabled
		if hero.ledge.state == "climb":
			safe = safe and hero.ledge._clear(hero.global_position)
		if i in [6,18,29]: await capture("02-subida-%02d" % i)
	check(safe,"Colisao ativa e corpo livre durante toda a subida")
	check(hero.ledge.state == "" and hero.is_on_floor() and absf(hero.global_position.y-330)<1 and hero.global_position.x>2187,"Termina apoiado sobre plataforma")
	await step(20)
	check(hero.is_on_floor() and hero.jump_buffer == 0,"Segurar pulo da subida nao dispara salto no topo")
	await capture("03-no-topo")
	Input.action_release("jump")
	Input.action_press("heavy_attack")
	await step(3)
	check(hero.action == "gff1","Combate volta a funcionar apos subir")
	await grab(-1)
	check(hero.ledge.state == "hang" and hero.facing == -1 and hero.visual.scale.x == -1,"Agarra quina direita com espelhamento")
	await capture("04-pendurado-esquerda")
	Input.action_press("jump")
	await step(45)
	check(hero.ledge.state == "" and hero.is_on_floor() and hero.global_position.x<2393,"Sobe tambem pela direita")
	await grab()
	Input.action_press("ledge_drop")
	await step(2)
	check(hero.ledge.state == "" and hero.velocity.y>0 and hero.ledge.cooldown>0,"S solta com queda e intervalo para reagarrar")
	await step(30)
	check(hero.ledge.state == "" and hero.is_on_floor(),"Soltar nao prende novamente na mesma quina")
	place(Vector2(2138,500))
	Input.action_press("jump")
	await step(4)
	check(hero.ledge.state == "hang","Agarrar funciona com pulo mantido")
	await step(18)
	check(hero.ledge.state == "hang","Pulo ja mantido nao sobe automaticamente")
	Input.action_release("jump")
	await step(2)
	Input.action_press("jump")
	await step(2)
	check(hero.ledge.state == "climb","Soltar e apertar novamente permite subir")
	await grab()
	var ceiling := box(Vector2(2210,245),Vector2(76,20))
	await step(3)
	Input.action_press("jump")
	await step(3)
	check(hero.ledge.state == "hang" and not hero.ledge.can_climb(),"Teto bloqueia subida sem atravessar ou perder apoio")
	ceiling.queue_free()
	await step(3)
	Input.action_release("jump")
	await step(2)
	Input.action_press("jump")
	await step(5)
	check(hero.ledge.state == "climb","Subida liberada quando teto sai")
	var obstacle := box(Vector2(2146,290),Vector2(40,20))
	await step(15)
	check(hero.ledge.state == "" and not hero.get_node("Body").disabled,"Obstaculo surgindo durante subida interrompe sem desativar colisao")
	obstacle.queue_free()
	await step(3)
	place(Vector2(2138,554))
	await step(3)
	check(hero.ledge.state == "","Parede sem quina na altura da mao nao agarra")
	place(Vector2(2000,400))
	await step(3)
	check(hero.ledge.state == "","Nao agarra no vazio")
	place(Vector2(2138,500),1,-180)
	await step(3)
	check(hero.ledge.state == "","Nao interrompe subida natural do salto")
	place(Vector2(2138,480))
	Input.action_press("heavy_attack")
	await step(3)
	hero.global_position = Vector2(2138,500)
	hero.velocity.y = 120
	await step(3)
	check(hero.ledge.state == "" and hero.action == "gff1","Nao cancela espada ativa para agarrar")
	place(Vector2(1188,501),1,1000)
	await step(3)
	check(hero.ledge.state == "hang" and hero.ledge.support.name == "StepTwo","Varredura captura plataforma fina em queda rapida")
	await capture("05-plataforma-fina")
	var narrow := box(Vector2(1970,315),Vector2(24,30))
	await step(3)
	place(Vector2(1926,476))
	await step(3)
	check(hero.ledge.state == "hang" and not hero.ledge.can_climb(),"Apoio estreito nao permite subir sem espaco para os pes")
	narrow.queue_free()
	await step(3)
	check(hero.ledge.state == "" and hero.velocity.y>0,"Remocao do apoio solta o personagem com seguranca")
	place(Vector2(2060,580))
	await step(5)
	Input.action_press("move_right")
	Input.action_press("jump")
	await step(55)
	check(hero.ledge.state == "hang", "Corrida e salto reais desde o chao alcancam a beirada")
	release_inputs()
	await step(3)
	Input.action_press("jump")
	await step(45)
	check(hero.is_on_floor() and absf(hero.position.y-330)<1, "Fluxo completo chao, salto, agarrar e subir")
	release_inputs()
	print("LEDGE RESULT: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)
