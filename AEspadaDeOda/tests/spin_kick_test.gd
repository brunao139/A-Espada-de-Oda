extends SceneTree
var hero: CharacterBody2D
var checks := 0
var failures := 0
var started: Array[String] = []

class Target extends Area2D:
	var hits: Array[int] = []
	var directions: Array[int] = []
	func receive_hit(damage: int, direction: int) -> void:
		hits.append(damage)
		directions.append(direction)

func _initialize() -> void: call_deferred("run_tests")
func step(count: int) -> void:
	for i in range(count): await physics_frame
func check(ok: bool, message: String) -> void:
	checks += 1
	print(("PASS " if ok else "FAIL ")+message)
	if not ok: failures += 1
func tap(key: String) -> void:
	Input.action_press(key)
	await step(1)
	Input.action_release(key)
	await step(1)
func reset_hero() -> void:
	for key in ["jump","light_attack","heavy_attack","move_left","move_right"]: Input.action_release(key)
	hero.position = Vector2(600,580)
	hero.velocity = Vector2.ZERO
	hero.gravity = 1850
	hero.action = ""
	hero.queued_attack = ""
	hero.queued_time = 0
	hero.combo_left = 0
	hero.ground_combo_step = 0
	hero.next_is_spin = false
	hero.next_is_uppercut = false
	hero.jump_buffer = 0
	hero.air_attacks_used = 0
	hero.air_combo_step = 0
	hero.air_combo_left = 0
	await step(5)
	started.clear()
func target_at(pos: Vector2) -> Target:
	var target := Target.new()
	target.position = pos
	target.collision_layer = 4
	var shape := CollisionShape2D.new()
	var box := RectangleShape2D.new()
	box.size = Vector2(12,12)
	shape.shape = box
	target.add_child(shape)
	root.add_child(target)
	return target
func begin_gf4() -> void:
	hero.ground_combo_step = 3
	hero.combo_left = 1
	await tap("light_attack")
func run_tests() -> void:
	var scene = load("res://scenes/movement_lab.tscn").instantiate()
	if scene.get_script() == preload("res://scripts/lab.gd"): scene.spawn_enemies = false
	root.add_child(scene)
	hero = scene.get_node("Youkai")
	hero.attack_speed = 1.0 # Baseline temporal histórico; finisher_test cobre a velocidade padrão 0.8.
	hero.attack_started.connect(func(kind: String): started.append(kind))
	await step(5)
	var frames: SpriteFrames = hero.sprite.sprite_frames
	check(frames.get_frame_count("gf4") == 24, "GF4 tem 24 desenhos distintos")
	check(frames.get_frame_count("gfa4") == 16, "GFA4 tem 16 poses aereas")
	for face in [1,-1]:
		await reset_hero()
		hero.facing = face
		await tap("light_attack")
		var queued_for := ""
		var seen: Array[int] = []
		var minimum_y := 580.0
		var safe := true
		for tick in range(170):
			if hero.action == "gf4":
				minimum_y = minf(minimum_y,hero.position.y)
				if not hero.sprite.frame in seen: seen.append(hero.sprite.frame)
				if hero.attack_active and (hero.is_on_floor() or hero.sprite.frame < 13 or hero.sprite.frame > 15):
					safe = false
					print('BAD FRAME ',hero.sprite.frame,' t=',hero.action_time,' floor=',hero.is_on_floor())
				if hero.sprite.rotation != 0 or hero.visual.scale.x != face: safe = false
			elif hero.action != "" and hero.action != queued_for and hero.action_time > hero.action_duration*0.5:
				queued_for = hero.action
				await tap("light_attack")
			await step(1)
		check(started == ["gf1","gf2","gf3","gf4"], "Quatro toques encadeiam GF1 a GF4: "+str(face))
		check(seen.size() == 24,"Todos os 24 quadros aparecem no salto real: "+str(seen))
		check(minimum_y > 485 and minimum_y < 515,"GF4 salta de verdade, altura controlada: "+str(minimum_y))
		check(safe,"Impacto apenas na extensao aerea; corpo vertical e espelhamento: "+str(face))
		check(hero.is_on_floor() and hero.action == "" and not hero.attack_active,"GF4 pousa e encerra: "+str(face))
		await tap("light_attack")
		check(hero.action == "gf1","Apos GF4 a sequencia recomeca em GF1")
		await reset_hero()
		hero.facing = face
		var front := target_at(Vector2(600+face*94,408))
		var back := target_at(Vector2(600-face*94,408))
		var low := target_at(Vector2(600+face*94,564))
		await begin_gf4()
		await step(15)
		check(front.hits.is_empty(),"GF4 sem dano no preparo")
		await step(45)
		check(front.hits == [1] and front.directions == [face],"GF4 acerta alvo real uma unica vez: "+str(face))
		check(back.hits.is_empty() and low.hits.is_empty(),"GF4 sem dano atras ou no piso")
		front.queue_free(); back.queue_free(); low.queue_free()
		await reset_hero()
		hero.position = Vector2(600,0)
		hero.gravity = 0
		hero.facing = face
		await step(2)
		hero.velocity = Vector2.ZERO
		hero.air_combo_step = 3
		hero.air_combo_left = 1
		hero.air_attacks_used = 3
		front = target_at(hero.position+Vector2(face*94,-106))
		back = target_at(hero.position+Vector2(-face*94,-106))
		await tap("light_attack")
		seen.clear()
		safe = true
		for tick in range(30):
			if hero.action == "gfa4":
				if not hero.sprite.frame in seen: seen.append(hero.sprite.frame)
				if hero.attack_active and (hero.sprite.frame < 9 or hero.sprite.frame > 11): safe = false
			await step(1)
		check(seen.size() == 16 and safe,"GFA4 exibe 16 poses com impacto sincronizado: "+str(seen))
		check(front.hits == [1] and back.hits.is_empty(),"GFA4 um impacto frontal real: "+str(face))
		await tap("light_attack")
		check(hero.action == "" and hero.air_attacks_used == 4,"GFA4 nao permite quinto ataque no mesmo voo")
		front.queue_free(); back.queue_free()
	# Liberação do botão de salto não corta o impulso automático do GF4.
	await reset_hero()
	await begin_gf4()
	await step(8)
	var before: float = hero.velocity.y
	await tap("jump")
	check(hero.action == "gf4" and hero.velocity.y < before+100,"Pulo e soltura nao cortam nem duplicam impulso do GF4")
	await step(65)
	check(hero.is_on_floor(),"Nao ha salto extra depois do finalizador")
	# Teto baixo deve encerrar o golpe no pouso sem atravessar a colisão.
	await reset_hero()
	var ceiling := StaticBody2D.new()
	ceiling.position = Vector2(600,375)
	var shape := CollisionShape2D.new()
	var box := RectangleShape2D.new()
	box.size = Vector2(250,20)
	shape.shape = box
	ceiling.add_child(shape)
	root.add_child(ceiling)
	await step(2)
	await begin_gf4()
	var min_y := 580.0
	var active_after_landing := false
	for tick in range(65):
		min_y = minf(min_y,hero.position.y)
		if hero.gf4_launched and hero.is_on_floor() and hero.attack_active: active_after_landing = true
		await step(1)
	check(min_y >= 550,"GF4 respeita teto baixo: "+str(min_y))
	check(hero.is_on_floor() and hero.action == "" and not active_after_landing,"Pouso antecipado cancela impacto e recupera")
	ceiling.queue_free()
	# Pausa e troca para espada quebram a cadeia terrestre.
	await reset_hero()
	await tap("light_attack")
	await step(80)
	await tap("light_attack")
	check(hero.action == "gf1","Pausa reinicia combo terrestre")
	await step(20)
	await tap("heavy_attack")
	await step(45)
	await tap("light_attack")
	check(hero.action == "gf1","Troca de tipo reinicia combo terrestre")
	await reset_hero()
	Input.action_press("light_attack")
	await step(160)
	Input.action_release("light_attack")
	check(started == ["gf1"],"Segurar ataque nao executa combo automaticamente")
	print("SPIN RESULT: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)
