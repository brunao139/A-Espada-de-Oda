extends SceneTree

var failures := 0
var checks := 0
var hero: CharacterBody2D

class HitProbe extends Node2D:
	var hits: Array[int] = []
	func receive_hit(damage: int, _direction: int) -> void:
		hits.append(damage)

func _initialize() -> void:
	call_deferred("run_tests")

func step(count: int) -> void:
	for i in range(count): await physics_frame

func check(ok: bool, message: String) -> void:
	checks += 1
	print(("PASS " if ok else "FAIL ") + message)
	if not ok: failures += 1

func reset_hero() -> void:
	for key in ["move_left", "move_right", "jump", "light_attack", "heavy_attack"]:
		Input.action_release(key)
	hero.position = Vector2(340, 580)
	hero.velocity = Vector2.ZERO
	hero.action = ""
	hero.next_is_spin = false
	hero.next_is_uppercut = false
	hero.combo_left = 0
	hero.heavy_combo_left = 0
	hero.jump_spinning = false
	hero.held_finish = ""
	hero.queued_attack = ""
	hero.jump_buffer = 0
	await step(5)

func run_tests() -> void:
	var scene = load("res://scenes/movement_lab.tscn").instantiate()
	root.add_child(scene)
	hero = scene.get_node("Youkai")
	await step(5)
	check(hero.is_on_floor(), "Colisao com piso")
	check(hero.sprite.sprite_frames.has_animation("gf1") and hero.sprite.sprite_frames.has_animation("gf2") and hero.sprite.sprite_frames.has_animation("gff1") and hero.sprite.sprite_frames.has_animation("gff2"), "Quatro secoes GF-1 GF-2 GFF-1 GFF-2")
	for name in ["gf2", "gff1", "gff2"]:
		var safe := true
		for i in range(hero.sprite.sprite_frames.get_frame_count(name)):
			var tex := hero.sprite.sprite_frames.get_frame_texture(name, i) as AtlasTexture
			var cutoff := 0.8 if name == "gff1" or (name == "gff2" and i == 0) else 0.1
			var bounds: Rect2i = hero._visible_bounds(tex, cutoff)
			if bounds.position.x < 4 or bounds.position.y < 4 or bounds.end.x > tex.region.size.x - 4 or bounds.end.y > tex.region.size.y - 4:
				safe = false
				print("BORDER ", name, " ", i, " ", bounds, " ", tex.region)
		check(safe, name + ": corpo e lamina inteiros, bordas livres")
	check(hero.sprite.sprite_frames.get_frame_count("gf2") == 8 and hero.sprite.sprite_frames.get_frame_count("gff2") == 9, "Oito poses novas por sequencia e pose de ligacao GFF")
	check(hero.sprite.sprite_frames.get_frame_texture("gff2", 1).atlas.resource_path.ends_with("gff2_rising_cut.png"), "GFF-2 usa arte propria, sem inverter GFF-1")
	Input.action_press("move_right")
	await step(30)
	check(hero.position.x > 490 and hero.velocity.x == hero.run_speed, "Corrida e aceleracao preservadas")
	Input.action_release("move_right")
	await step(10)
	check(absf(hero.velocity.x) < 1, "Frenagem preservada")
	await reset_hero()
	Input.action_press("jump")
	var minimum_y := hero.position.y
	var max_rotation := 0.0
	var air_frames := 0
	for i in range(55):
		await step(1)
		minimum_y = minf(minimum_y, hero.position.y)
		max_rotation = maxf(max_rotation, hero.sprite.rotation)
		if not hero.is_on_floor(): air_frames += 1
	Input.action_release("jump")
	check(max_rotation > TAU * 1.9, "Dois giros completos no salto")
	check(minimum_y > 410 and minimum_y < 445 and air_frames >= 44 and air_frames <= 50, "Altura e tempo no ar preservados (cerca de 0.8 s)")
	check(hero.is_on_floor() and hero.sprite.rotation == 0, "Pouso na orientacao correta")
	await reset_hero()
	Input.action_press("jump")
	await step(3)
	Input.action_release("jump")
	max_rotation = 0
	minimum_y = hero.position.y
	for i in range(35):
		await step(1)
		max_rotation = maxf(max_rotation, hero.sprite.rotation)
		minimum_y = minf(minimum_y, hero.position.y)
	check(max_rotation > TAU * 1.8 and minimum_y > 485, "Dois giros adaptados ao salto curto")
	await reset_hero()
	Input.action_press("light_attack")
	await step(7)
	Input.action_release("light_attack")
	check(hero.action == "gf1" and hero.attack_active and hero.hit_phase == 0, "GF-1 inicia com soco")
	var probe := HitProbe.new()
	root.add_child(probe)
	hero._try_hit(probe)
	hero._try_hit(probe)
	check(probe.hits == [1], "Soco acerta cada alvo uma vez")
	await step(15)
	check(hero.action == "gf1" and hero.attack_active and hero.hit_phase == 1, "GF-1 continua com chute")
	hero._try_hit(probe)
	hero._try_hit(probe)
	check(probe.hits == [1, 1], "Chute tem impacto proprio sem dano repetido")
	Input.action_press("light_attack")
	await step(1)
	Input.action_release("light_attack")
	await step(15)
	check(hero.action == "gf2", "GF-2 emendado depois do GF-1")
	await step(17)
	check(hero.attack_active and hero.hit_phase == 0, "Chute giratorio atinge apenas na extensao da perna")
	await step(30)
	check(hero.action == "" and hero.sprite.rotation == 0 and not hero.attack_active, "GF-2 recolhe a perna e volta a guarda")
	await reset_hero()
	Input.action_press("heavy_attack")
	await step(5)
	Input.action_release("heavy_attack")
	check(hero.action == "gff1" and is_equal_approx(hero.action_duration, 0.56 / 1.2), "GFF-1 acelerado exatamente 1.2x")
	check(not hero.attack_active, "GFF-1 conserva preparo")
	await step(7)
	check(hero.attack_active, "Janela de impacto GFF-1 acompanha a aceleracao")
	await step(5)
	Input.action_press("heavy_attack")
	await step(1)
	Input.action_release("heavy_attack")
	await step(12)
	check(hero.action == "gff2", "Combo GFF-1 para GFF-2 sem voltar a guarda")
	check(hero.sprite.sprite_frames.get_frame_texture("gff1", 5) == hero.sprite.sprite_frames.get_frame_texture("gff2", 0), "Mesma pose exata na ligacao dos dois cortes")
	await step(15)
	check(hero.attack_active and hero.attack_shape.shape.size.y > 150, "GFF-2 tem impacto ascendente")
	Input.action_press("jump")
	await step(2)
	Input.action_release("jump")
	check(hero.is_on_floor(), "Espada mantem compromisso ate terminar")
	await step(65)
	Input.action_press("heavy_attack")
	await step(3)
	Input.action_release("heavy_attack")
	check(hero.action == "gff1", "Pausa reinicia sequencia pelo GFF-1")
	await step(27)
	check(hero.action == "" and hero.sprite.animation == "gff1" and hero.sprite.frame == 5, "Sem comando seguinte segura final baixo durante janela de combo")
	await step(40)
	check(hero.sprite.animation == "idle" and hero.sprite.material == null, "Depois da janela volta a guarda normal")
	await reset_hero()
	Input.action_press("move_left")
	Input.action_press("jump")
	await step(10)
	check(hero.sprite.animation == "somersault" and hero.visual.scale.x == -1, "Giro duplo acompanha direcao esquerda")
	Input.action_release("jump")
	Input.action_release("move_left")
	Input.action_press("light_attack")
	await step(2)
	Input.action_release("light_attack")
	check(hero.action == "gf1" and hero.sprite.rotation == 0 and not hero.is_on_floor(), "GF-1 aereo interrompe giro corretamente")
	await reset_hero()
	hero.position = Vector2(70, 580)
	Input.action_press("move_left")
	await step(35)
	Input.action_release("move_left")
	check(hero.position.x >= 17.9, "Parede limita movimento")
	await reset_hero()
	hero.position = Vector2(970, 200)
	await step(50)
	check(hero.is_on_floor() and absf(hero.position.y - 452) < 1, "Plataformas preservadas")
	print("RESULT: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
