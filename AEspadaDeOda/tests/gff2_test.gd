extends SceneTree
var hero: CharacterBody2D
var checks := 0
var failures := 0
class Target extends Area2D:
	var hits: Array[int] = []
	func receive_hit(damage: int, _direction: int) -> void:
		hits.append(damage)
func _initialize() -> void:
	call_deferred("run_tests")
func step(count: int) -> void:
	for i in range(count): await physics_frame
func check(ok: bool, message: String) -> void:
	checks += 1
	print(("PASS " if ok else "FAIL ")+message)
	if not ok: failures += 1
func target_at(pos: Vector2) -> Target:
	var target := Target.new()
	target.position = pos
	target.collision_layer = 4
	target.collision_mask = 0
	var shape := CollisionShape2D.new()
	var rectangle := RectangleShape2D.new()
	rectangle.size = Vector2(10,10)
	shape.shape = rectangle
	target.add_child(shape)
	root.add_child(target)
	return target
func run_tests() -> void:
	var scene = load("res://scenes/movement_lab.tscn").instantiate()
	if scene.get_script() == preload("res://scripts/lab.gd"): scene.spawn_enemies = false
	root.add_child(scene)
	hero = scene.get_node("Youkai")
	hero.attack_speed = 1.0 # Baseline temporal histórico; finisher_test cobre a velocidade padrão 0.8.
	await step(5)
	for face in [1,-1]:
		hero.position = Vector2(600,580)
		hero.facing = face
		hero.velocity = Vector2.ZERO
		hero.action = ""
		hero.next_is_uppercut = true
		var front := target_at(hero.position+Vector2(face*140,-70))
		var back := target_at(hero.position+Vector2(-face*110,-98))
		var above := target_at(hero.position+Vector2(face*110,-190))
		var beyond := target_at(hero.position+Vector2(face*175,-70))
		await step(3)
		hero.next_is_uppercut = true
		hero._start_attack("heavy")
		var seen: Array[int] = []
		var phase_safe := true
		var mirrored := true
		for i in range(43):
			await step(1)
			if hero.action == "gff2":
				var frame: int = hero.sprite.frame
				if not frame in seen: seen.append(frame)
				if hero.attack_active and (frame < 6 or frame > 11): phase_safe = false
				if hero.visual.scale.x != face or signf(hero.attack_area.position.x) != face: mirrored = false
		check(front.hits == [3], "Alvo frontal recebe um unico impacto de 3: "+str(face))
		check(back.hits.is_empty(), "Sem dano atras do personagem: "+str(face))
		check(above.hits.is_empty(), "Sem antiga caixa ascendente acima da espada: "+str(face))
		check(beyond.hits.is_empty(), "Sem dano no alcance antigo apos reduzir espada: "+str(face))
		check(seen.size() == 17, "Todos os 17 quadros sao exibidos na fisica real: "+str(face))
		check(phase_safe and mirrored, "Dano acompanha extensao e espelhamento: "+str(face))
		check(hero.action == "" and not hero.attack_active, "Recuperacao encerra dano e acao: "+str(face))
		front.queue_free()
		back.queue_free()
		above.queue_free()
		beyond.queue_free()
		await step(2)
	print("RESULT: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
