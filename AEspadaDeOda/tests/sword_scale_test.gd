extends SceneTree
var failures := 0
var checks := 0

func _initialize() -> void:
	call_deferred("run_tests")

func check(ok: bool, message: String) -> void:
	checks += 1
	print(("PASS " if ok else "FAIL ") + message)
	if not ok: failures += 1

func run_tests() -> void:
	var hero = load("res://scenes/youkai.tscn").instantiate()
	root.add_child(hero)
	hero.set_physics_process(false)
	var collider: CollisionShape2D = hero.get_node("Body")
	var body_scale: Vector2 = collider.scale
	var idle_scale: Vector2 = hero.normal_sprite_scale
	hero.sprite.animation = "gff1"
	hero.sprite.frame = 5
	hero._align_sprite()
	var last_scale: Vector2 = hero.sprite.scale
	var last_position: Vector2 = hero.sprite.position
	hero.sprite.animation = "gff2"
	hero.sprite.frame = 0
	hero._align_sprite()
	check(hero.sprite.scale == last_scale and hero.sprite.position == last_position, "Ligacao GFF1/GFF2 preserva escala e pivo exatos")
	# A proporção artística é conferida na prancha; aqui verificamos a geometria.
	for index in range(1, 17):
		hero.sprite.frame = index
		hero._align_sprite()
		var definition: Dictionary = preload("res://scripts/gff2_frames.gd").POSES[index - 1]
		var texture := hero.sprite.sprite_frames.get_frame_texture("gff2", index) as AtlasTexture
		var foot: Vector2 = hero.sprite.position + (Vector2(definition.anchor[0], definition.anchor[1]) - texture.region.size / 2) * hero.sprite.scale
		check(absf(foot.y) < 0.01, "GFF2 quadro %d mantem bota no piso" % index)
		var tip: Vector2 = hero.sprite.position + (Vector2(definition.tip[0], definition.tip[1]) - texture.region.size / 2) * hero.sprite.scale
		check(tip.distance_to(hero.forward_blade_tips[index]) < 0.01, "Rastro segue ponta da espada no quadro %d" % index)
	hero.sprite.animation = "idle"
	hero.sprite.frame = 0
	hero._align_sprite()
	check(hero.sprite.scale == idle_scale and collider.scale == body_scale, "Retorno a guarda e colisao do corpo preservados")
	print("RESULT: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
