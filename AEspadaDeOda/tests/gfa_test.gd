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

func _initialize() -> void:
	call_deferred("run_tests")

func step(count: int) -> void:
	for i in range(count): await physics_frame

func check(ok: bool, message: String) -> void:
	checks += 1
	print(("PASS " if ok else "FAIL ") + message)
	if not ok: failures += 1

func tap(key: String) -> void:
	Input.action_press(key)
	await step(2)
	Input.action_release(key)

func reset_hero() -> void:
	for key in ["jump", "light_attack", "heavy_attack"]: Input.action_release(key)
	hero.position = Vector2(600, 580)
	hero.velocity = Vector2.ZERO
	hero.action = ""
	hero.queued_attack = ""
	hero.queued_time = 0
	hero.next_is_spin = false
	hero.next_is_uppercut = false
	hero.jump_buffer = 0
	await step(5)
	started.clear()

func target_at(pos: Vector2) -> Target:
	var target := Target.new()
	target.position = pos
	target.collision_layer = 4
	target.collision_mask = 0
	var shape := CollisionShape2D.new()
	var box := RectangleShape2D.new()
	box.size = Vector2(12, 12)
	shape.shape = box
	target.add_child(shape)
	root.add_child(target)
	return target

func run_tests() -> void:
	var scene = load("res://scenes/movement_lab.tscn").instantiate()
	if scene.get_script() == preload("res://scripts/lab.gd"): scene.spawn_enemies = false
	root.add_child(scene)
	hero = scene.get_node("Youkai")
	hero.attack_speed = 1.0 # Baseline temporal histórico; finisher_test cobre a velocidade padrão 0.8.
	hero.attack_started.connect(func(kind: String): started.append(kind))
	await step(5)
	for face in [1, -1]:
		await reset_hero()
		hero.facing = face
		Input.action_press("jump")
		await step(10)
		await tap("light_attack")
		var minimum_y := hero.position.y
		for attack in ["gfa1", "gfa2", "gfa3", "gfa4"]:
			check(hero.action == attack and not hero.is_on_floor(), attack + " no ar: " + str(face))
			var queued := false
			for frame in range(24):
				minimum_y = minf(minimum_y, hero.position.y)
				if hero.action != attack: break
				if not queued and hero.action_time > hero.action_duration * 0.5:
					await tap("light_attack")
					queued = true
				await step(1)
		check(started == ["gfa1", "gfa2", "gfa3", "gfa4"], "Combo completo, quinto toque nao reinicia: " + str(face))
		check(minimum_y > 410 and minimum_y < 445, "Combo preserva altura do salto")
		check(hero.sprite.rotation == 0 and hero.visual.scale.x == face, "Orientacao e espelhamento preservados")
		await step(100)
		check(hero.is_on_floor() and not hero.attack_active, "Retorna ao chao sem flutuar")
		await tap("light_attack")
		check(hero.action == "gf1", "Pouso restaura GF-1")
	# Colisões reais em ambos os lados, em cada janela e fora dela.
	for face in [1, -1]:
		for number in range(1, 5):
			await reset_hero()
			hero.position = Vector2(600, 0)
			hero.gravity = 0
			hero.velocity = Vector2.ZERO
			hero.facing = face
			await step(2)
			hero.velocity = Vector2.ZERO
			hero.air_combo_step = number - 1
			hero.air_combo_left = 1
			var front := target_at(hero.position + Vector2(face * 85, -110))
			var behind := target_at(hero.position + Vector2(-face * 85, -110))
			var below := target_at(hero.position + Vector2(face * 85, -10))
			await tap("light_attack")
			await step(2)
			check(front.hits.is_empty(), "GFA%d sem dano no preparo" % number)
			await step(24)
			check(front.hits == [1] and front.directions == [face], "GFA%d um impacto e direcao correta: %d" % [number, face])
			check(behind.hits.is_empty() and below.hits.is_empty(), "GFA%d sem dano atras ou abaixo" % number)
			check(not hero.attack_active, "GFA%d encerra dano" % number)
			front.queue_free()
			behind.queue_free()
			below.queue_free()
			hero.gravity = 1850
	await reset_hero()
	Input.action_press("jump")
	await step(10)
	Input.action_press("light_attack")
	await step(45)
	check(started == ["gfa1"], "Segurar J nao repete golpes")
	await reset_hero()
	Input.action_press("jump")
	await step(10)
	await tap("light_attack")
	await step(7)
	await tap("light_attack")
	hero.position = Vector2(600, 578)
	hero.velocity.y = 300
	await step(3)
	check(hero.is_on_floor() and hero.action == "" and not hero.attack_active and hero.queued_attack == "", "Pouso cancela golpe e fila")
	await reset_hero()
	hero.position = Vector2(600, 0)
	hero.gravity = 0
	await step(2)
	hero.velocity = Vector2.ZERO
	await tap("light_attack")
	await step(35)
	await tap("light_attack")
	check(hero.action == "gfa1", "Pausa reinicia no GFA1 sem renovar limite por salto")
	check(hero.air_attacks_used == 2, "Pausa conserva orcamento de golpes")
	print("RESULT: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
