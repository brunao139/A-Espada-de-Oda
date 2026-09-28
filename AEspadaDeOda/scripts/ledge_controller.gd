extends Node
## Controle de beirada para superfícies sólidas e estáticas.
## A colisão corporal permanece ativa durante toda a subida.
const HAND_HEIGHT := 176.0
const SIDE_GAP := 24.0
const REACH := 42.0
const CLIMB_DURATION := 0.64
const REGRAB_DELAY := 0.32
const SHEET := preload("res://assets/ledge/youkai_ledge.png")
const HAND_ANCHORS := [
	Vector2(0.72, 0.26), Vector2(0.72, 0.26), Vector2(0.72, 0.26),
	Vector2(0.71, 0.34), Vector2(0.72, 0.51), Vector2(0.72, 0.51)
]
var hero: CharacterBody2D
var body: CollisionShape2D
var state := ""
var point := Vector2.ZERO
var hang_position := Vector2.ZERO
var landing_position := Vector2.ZERO
var support: StaticBody2D
var support_transform := Transform2D.IDENTITY
var cooldown := 0.0
var elapsed := 0.0
var climb_armed := false
var direction := 1
var art_scale := 1.0
var cell := Vector2.ZERO
var feet: Array[Vector2] = []

func setup(player: CharacterBody2D) -> void:
	hero = player
	body = hero.get_node("Body")
	cell = Vector2(SHEET.get_width()/4.0, SHEET.get_height()/2.0)
	var frames: SpriteFrames = hero.sprite.sprite_frames
	frames.add_animation("ledge")
	frames.set_animation_loop("ledge", false)
	for i in range(8):
		var tex := AtlasTexture.new()
		tex.atlas = SHEET
		tex.region = Rect2(Vector2(i % 4, i / 4) * cell, cell)
		tex.filter_clip = true
		frames.add_frame("ledge", tex)
		var bounds: Rect2i = hero._visible_bounds(tex, 0.1)
		feet.append(Vector2(bounds.get_center().x, bounds.end.y))
		if i == 7:
			art_scale = 176.0 / float(bounds.size.y)

func _ray(from: Vector2, to: Vector2) -> Dictionary:
	var query := PhysicsRayQueryParameters2D.create(from, to, hero.collision_mask, [hero.get_rid()])
	return hero.get_world_2d().direct_space_state.intersect_ray(query)

func _shape_query(at: Vector2) -> PhysicsShapeQueryParameters2D:
	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = body.shape
	var pose := hero.global_transform
	pose.origin = at
	query.transform = pose * body.transform
	query.collision_mask = hero.collision_mask
	query.exclude = [hero.get_rid()]
	query.margin = 0.02
	return query

func _clear(at: Vector2) -> bool:
	return hero.get_world_2d().direct_space_state.intersect_shape(_shape_query(at), 1).is_empty()

func _path_clear(from: Vector2, to: Vector2) -> bool:
	if not _clear(from) or not _clear(to):
		return false
	var query := _shape_query(from)
	query.motion = to - from
	var fraction := hero.get_world_2d().direct_space_state.cast_motion(query)
	return fraction[0] >= 0.999

func _support_valid() -> bool:
	if not is_instance_valid(support) or support.global_transform != support_transform:
		return false
	var hit := _ray(point + Vector2(direction * 8, -4), point + Vector2(direction * 8, 8))
	return not hit.is_empty() and hit.collider == support and hit.normal.y < -0.95

func try_grab(previous_position: Vector2) -> bool:
	if state != "" or cooldown > 0 or hero.is_on_floor() or hero.action != "":
		return false
	if hero.velocity.y < 0 or Input.is_action_pressed("ledge_drop"):
		return false
	var forward: int = hero.facing
	var probe_x: float = hero.global_position.x + forward * REACH
	var hand_y: float = hero.global_position.y - HAND_HEIGHT
	# Varredura vertical inclui o deslocamento do quadro: não perde quinas finas em quedas rápidas.
	var from_y := minf(previous_position.y - HAND_HEIGHT, hand_y) - 18.0
	var hit := _ray(Vector2(probe_x, from_y), Vector2(probe_x, hand_y + 18.0))
	if hit.is_empty() or hit.normal.y > -0.95 or not hit.collider is StaticBody2D:
		return false
	var top: Vector2 = hit.position
	var side := _ray(Vector2(hero.global_position.x, top.y + 5), Vector2(probe_x, top.y + 5))
	if side.is_empty() or side.collider != hit.collider or side.normal.dot(Vector2(-forward,0)) < 0.95:
		return false
	var edge := Vector2(side.position.x, top.y)
	var hang := edge + Vector2(-forward * SIDE_GAP, HAND_HEIGHT)
	if not _path_clear(hero.global_position, hang):
		return false
	point = edge
	direction = forward
	support = hit.collider
	support_transform = support.global_transform
	hang_position = hang
	landing_position = point + Vector2(direction * SIDE_GAP, -1.0)
	state = "hang"
	elapsed = 0.0
	climb_armed = not Input.is_action_pressed("jump")
	hero.global_position = hang_position
	hero.velocity = Vector2.ZERO
	_reset_actions()
	update_visual()
	return true

func _reset_actions() -> void:
	hero.jump_spinning = false
	hero.jump_buffer = 0.0
	hero.coyote_left = 0.0
	hero.landing_left = 0.0
	hero.queued_attack = ""
	hero.queued_time = 0.0
	hero.combo_left = 0.0
	hero.heavy_combo_left = 0.0
	hero.next_is_spin = false
	hero.next_is_uppercut = false
	hero.held_finish = ""
	hero.attack_active = false
	hero.attack_shape.set_deferred("disabled", true)

func can_climb() -> bool:
	if not _support_valid():
		return false
	# Exige apoio também na parte interna; uma agulha estreita não é uma plataforma.
	var inner := point + Vector2(direction * (SIDE_GAP + 18), 0)
	var floor_hit := _ray(inner + Vector2(0,-4), inner + Vector2(0,8))
	if floor_hit.is_empty() or floor_hit.collider != support or floor_hit.normal.y > -0.95:
		return false
	var raised := Vector2(hang_position.x, landing_position.y)
	return _path_clear(hero.global_position, raised) and _path_clear(raised, landing_position)

func tick(delta: float) -> bool:
	cooldown = maxf(0.0, cooldown - delta)
	if state == "":
		return false
	elapsed += delta
	if not _support_valid():
		release()
		return true
	hero.facing = direction
	hero.visual.scale.x = direction
	hero.velocity = Vector2.ZERO
	if not Input.is_action_pressed("jump"):
		climb_armed = true
	if Input.is_action_just_pressed("ledge_drop"):
		release()
		return true
	if state == "hang":
		if not _clear(hang_position):
			release()
			return true
		if climb_armed and Input.is_action_just_pressed("jump") and can_climb():
			state = "climb"
			elapsed = 0.0
	else:
		var t := minf(elapsed / CLIMB_DURATION, 1.0)
		var raised := Vector2(hang_position.x, landing_position.y)
		var desired: Vector2
		if t < 0.68:
			desired = hang_position.lerp(raised, smoothstep(0.0,0.68,t))
		else:
			desired = raised.lerp(landing_position, smoothstep(0.68,1.0,t))
		# Revalida o volume a cada quadro: um obstáculo novo não pode ser atravessado.
		if not _path_clear(hero.global_position, desired):
			release()
			return true
		var collision := hero.move_and_collide(desired - hero.global_position)
		if collision != null:
			release()
			return true
		if t >= 1.0:
			state = ""
			cooldown = REGRAB_DELAY
			_reset_actions()
			hero.velocity = Vector2(0, 20)
			hero.move_and_slide()
			hero.landing_left = 0.09
			hero.landed.emit()
			hero._update_animation()
			return true
	update_visual()
	return true

func release() -> void:
	state = ""
	support = null
	cooldown = REGRAB_DELAY
	_reset_actions()
	hero.velocity = Vector2(-direction * 90, 80)
	hero._update_animation()

func update_visual() -> void:
	var sprite: AnimatedSprite2D = hero.sprite
	var index := 0 if int(elapsed * 3) % 2 == 0 else 1
	if state == "climb":
		var t := elapsed / CLIMB_DURATION
		index = 2 if t < 0.13 else (3 if t < 0.30 else (4 if t < 0.48 else (5 if t < 0.86 else (6 if t < 0.95 else 7))))
	sprite.play("ledge")
	sprite.pause()
	sprite.frame = index
	sprite.rotation = 0.0
	sprite.offset = Vector2.ZERO
	sprite.scale = Vector2.ONE * art_scale
	sprite.material = hero.new_attack_material
	if index < 6:
		# Pivô nas mãos, não nos pés: a quina não desliza durante a puxada.
		sprite.position = hero.visual.to_local(point) - (HAND_ANCHORS[index] * cell - cell * 0.5) * art_scale
	else:
		sprite.position = (cell * 0.5 - feet[index]) * art_scale
