extends CharacterBody2D
## Movimento lateral, animação e janelas de ataque do Youkai.
## Origem do personagem = ponto dos pés. Mundo: camada 1, jogador: 2, alvos futuros: 3.

signal attack_started(kind: String)
signal landed
signal health_changed(value: int)
signal finisher_executed

@export var max_health := 8
var health := 8
var dead := false
var hurt_left := 0.0
var invulnerable_left := 0.0
const HURT_DURATION := 0.40
var hurt_elapsed := 0.0
var hurt_animation := "hurt_ground"

@export var run_speed: float = 420.0
@export var acceleration: float = 2800.0
@export var braking: float = 3600.0
@export var jump_speed: float = 740.0
@export var gravity: float = 1850.0
@export var max_fall_speed: float = 1050.0
@export var coyote_time: float = 0.10
@export var jump_buffer_time: float = 0.13
@export var heavy_combo_window: float = 0.50
@export_range(0.1, 2.0) var attack_speed: float = 0.8
var finisher_fired := false

var facing: int = 1
var action: String = ""
var action_time: float = 0.0
var action_duration: float = 0.0
var attack_active: bool = false
var debug_shapes: bool = false
var coyote_left: float = 0.0
var jump_buffer: float = 0.0
var combo_left: float = 0.0
var next_is_spin: bool = false
var ground_combo_step: int = 0
var gf4_launched: bool = false
var next_is_uppercut: bool = false
var heavy_combo_left: float = 0.0
var jump_spinning: bool = false
var roll_elapsed: float = 0.0
var roll_duration: float = 0.46
var jump_start_y: float = 0.0
var roll_center_offset := Vector2.ZERO
var queued_attack: String = ""
var queued_time: float = 0.0
var landing_left: float = 0.0
var animation_clock: float = 0.0
var hit_targets: Array[int] = []
var normal_sprite_scale := Vector2.ONE
var sword_sprite_scale := Vector2.ONE
var sword_material: ShaderMaterial
var new_attack_material: ShaderMaterial
var new_frame_positions: Dictionary = {}
var new_frame_scales: Dictionary = {}
var forward_blade_tips: Array[Vector2] = []
var hit_phase: int = -1
var held_finish: String = ""
const GFF1_SPEED: float = 1.2
const GFF1_BODY_SCALE: float = 0.86
const ATTACK_DURATION := {"gf1": 0.55, "gf2": 0.58, "gf3": 0.24, "gf4": 0.80, "gf5": 0.64, "gff1": 0.56 / GFF1_SPEED, "gff2": 0.68,
	"gfa1": 0.18, "gfa2": 0.24, "gfa3": 0.18, "gfa4": 0.32}
var air_combo_step: int = 0
var air_attacks_used: int = 0
var air_combo_left: float = 0.0

@onready var ledge: Node = $Ledge
@onready var sprite: AnimatedSprite2D = $Visual/Sprite
@onready var visual: Node2D = $Visual
@onready var attack_area: Area2D = $AttackArea
@onready var attack_shape: CollisionShape2D = $AttackArea/Shape

func _ready() -> void:
	health = max_health
	_install_controls()
	_build_animations()
	ledge.setup(self)
	attack_area.area_entered.connect(_try_hit)
	attack_area.body_entered.connect(_try_hit)

func _install_controls() -> void:
	var bindings := {
		"move_left": [KEY_A, KEY_LEFT], "move_right": [KEY_D, KEY_RIGHT],
		"jump": [KEY_SPACE, KEY_W, KEY_UP], "ledge_drop": [KEY_S, KEY_DOWN], "light_attack": [KEY_J, KEY_Z],
		"heavy_attack": [KEY_K, KEY_X], "reset_lab": [KEY_R], "debug_hitbox": [KEY_F1]
	}
	for name in bindings:
		if not InputMap.has_action(name):
			InputMap.add_action(name)
		for key in bindings[name]:
			var event := InputEventKey.new()
			event.physical_keycode = key
			if not InputMap.action_has_event(name, event):
				InputMap.action_add_event(name, event)

func _build_animations() -> void:
	var sheet: Texture2D = load("res://assets/youkai_atlas.png")
	if sheet == null:
		push_error("Atlas do Youkai não encontrado")
		return
	var frames := SpriteFrames.new()
	frames.remove_animation("default")
	var cell := Vector2(sheet.get_width() / 6.0, sheet.get_height() / 5.0)
	_add_animation(frames, sheet, cell, "idle", 0, [0, 1, 2, 3, 4, 5], 7, true)
	_add_animation(frames, sheet, cell, "run", 1, [0, 1, 2, 3, 4, 5], 13, true)
	_add_animation(frames, sheet, cell, "rise", 2, [1, 2], 8, false)
	_add_animation(frames, sheet, cell, "apex", 2, [3], 1, false)
	_add_animation(frames, sheet, cell, "fall", 2, [4], 1, false)
	_add_animation(frames, sheet, cell, "land", 2, [5], 1, false)
	_add_animation(frames, sheet, cell, "gf1", 3, [0, 1, 2, 3, 4, 5], 11, false)
	# A pose compacta gira pelo centro do corpo, sem girar a colisão.
	frames.add_animation("somersault")
	frames.set_animation_loop("somersault", false)
	var tuck_texture := frames.get_frame_texture("apex", 0) as AtlasTexture
	frames.add_frame("somersault", tuck_texture)
	var tuck_bounds := sheet.get_image().get_region(Rect2i(tuck_texture.region)).get_used_rect()
	roll_center_offset = cell / 2.0 - Vector2(tuck_bounds.get_center())
	# A espada usa uma folha própria, com espaço para a lâmina inteira.
	var sword_sheet: Texture2D = load("res://assets/youkai_sword_v2.png")
	var sword_cell := Vector2(sword_sheet.get_width() / 3.0, sword_sheet.get_height() / 2.0)
	frames.add_animation("gff1")
	frames.set_animation_speed("gff1", 11 * GFF1_SPEED)
	frames.set_animation_loop("gff1", false)
	for index in range(6):
		var texture := AtlasTexture.new()
		texture.atlas = sword_sheet
		texture.region = Rect2(Vector2(index % 3, index / 3) * sword_cell, sword_cell)
		# A lâmina ultrapassa o bloco nominal; a faixa adicional contém só
		# transparência e a própria lâmina, sem alcançar o próximo personagem.
		var extra_width := sword_cell.x * 48.0 / 512.0
		if index % 3 < 2:
			texture.region.size.x += extra_width
		else:
			texture.margin.size.x = extra_width
		# O início das duas últimas células inclui a ponta da lâmina anterior.
		# Retira essa faixa, preservando o pivô com a margem virtual.
		if index >= 4:
			var trim := sword_cell.x * 48.0 / 512.0
			texture.region.position.x += trim
			texture.region.size.x -= trim
			texture.margin.position.x += trim
			texture.margin.size.x += trim
		texture.filter_clip = true
		frames.add_frame("gff1", texture)
	# GFF-1 termina baixo: GFF-2 começa exatamente com a mesma textura e pivô.
	frames.set_frame("gff1", 5, frames.get_frame_texture("gff1", 4))
	_add_new_attack(frames, "gf2", "res://assets/gf/gf2_spin_kick.png", 0, 176.0)
	var forward: Dictionary = preload("res://scripts/gff2_frames.gd").build(frames, frames.get_frame_texture("gff1", 5))
	new_frame_positions["gff2"] = forward.positions
	new_frame_scales["gff2"] = forward.scales
	forward_blade_tips = forward.tips
	var air_sheet: Texture2D = load("res://assets/gfa/gfa_combo.png")
	for row in range(4):
		_add_animation(frames, air_sheet, Vector2(384, 256), "gfa" + str(row + 1), row, [0, 1, 2, 3], 16, false)
	# GF3 é uma ligação curta com as poses de soco já aprovadas.
	_add_animation(frames, sheet, cell, "gf3", 3, [0, 1, 2], 12.5, false)
	var spin: Dictionary = preload("res://scripts/spin_kick_frames.gd").build(frames)
	new_frame_positions.merge(spin.positions)
	new_frame_scales.merge(spin.scales)
	var damage_frames: Dictionary = preload("res://scripts/youkai_hurt_frames.gd").build(frames)
	new_frame_positions.merge(damage_frames.positions)
	new_frame_scales.merge(damage_frames.scales)
	var finish_frames: Dictionary = preload("res://scripts/gf5_frames.gd").build(frames)
	new_frame_positions.merge(finish_frames.positions)
	new_frame_scales.merge(finish_frames.scales)
	sprite.sprite_frames = frames
	# Quadros de 192 unidades: o desenho tem cerca de 176 unidades de altura.
	normal_sprite_scale = Vector2(192.0 / cell.x, 192.0 / cell.y)
	sword_sprite_scale = Vector2(292.0 / sword_cell.x, 292.0 / sword_cell.y) * GFF1_BODY_SCALE
	sword_material = ShaderMaterial.new()
	sword_material.shader = load("res://scripts/sword_sprite.gdshader")
	sword_material.set_shader_parameter("alpha_cutoff", 0.80)
	new_attack_material = ShaderMaterial.new()
	new_attack_material.shader = sword_material.shader
	new_attack_material.set_shader_parameter("alpha_cutoff", 0.10)
	sprite.scale = normal_sprite_scale
	sprite.play("idle")

func _visible_bounds(texture: AtlasTexture, cutoff: float = 0.98) -> Rect2i:
	var image := texture.atlas.get_image().get_region(Rect2i(texture.region))
	for y in range(image.get_height()):
		for x in range(image.get_width()):
			if image.get_pixel(x, y).a < cutoff:
				image.set_pixel(x, y, Color.TRANSPARENT)
	return image.get_used_rect()

func _add_new_attack(frames: SpriteFrames, name: String, path: String, reference: int, target_height: float, entry_pose: Texture2D = null) -> void:
	var sheet: Texture2D = load(path)
	var cell := Vector2(sheet.get_width() / 4.0, sheet.get_height() / 2.0)
	var gutter := floorf(cell.x * 0.12)
	var textures: Array[AtlasTexture] = []
	var bounds: Array[Rect2i] = []
	for index in range(8):
		var column := index % 4
		var texture := AtlasTexture.new()
		texture.atlas = sheet
		texture.region = Rect2(Vector2(column, index / 4) * cell, cell)
		if column < 3:
			texture.region.size.x += gutter
		else:
			texture.margin.size.x = gutter
		if column > 0:
			texture.region.position.x += gutter
			texture.region.size.x -= gutter
			texture.margin.position.x = gutter
			texture.margin.size.x += gutter
		if name == "gff2":
			if index < 4:
				texture.region.size.y -= 18
				texture.margin.size.y = 18
			else:
				texture.region.position.y -= 12
				texture.region.size.y += 12
		texture.filter_clip = true
		textures.append(texture)
		bounds.append(_visible_bounds(texture))
	var scale_factor := target_height / float(bounds[reference].size.y)
	var positions: Array[Vector2] = []
	var scales: Array[Vector2] = []
	frames.add_animation(name)
	frames.set_animation_loop(name, false)
	frames.set_animation_speed(name, 14)
	if entry_pose != null:
		frames.add_frame(name, entry_pose)
		positions.append(Vector2(26, -92))
		scales.append(Vector2.ONE) # O primeiro quadro usa a escala da folha GFF-1.
	var anchor_x := cell.x * 0.52
	for index in range(8):
		frames.add_frame(name, textures[index])
		var scale_y := scale_factor
		if name == "gff2" and index < 3:
			scale_y *= [0.87, 0.92, 0.97][index]
		var feet := float(bounds[index].end.y) + textures[index].margin.position.y
		positions.append(Vector2(((cell.x + gutter) / 2.0 - anchor_x) * scale_factor, (textures[index].get_height() / 2.0 - feet) * scale_y))
		scales.append(Vector2(scale_factor, scale_y))
	new_frame_positions[name] = positions
	new_frame_scales[name] = scales

func _add_animation(frames: SpriteFrames, sheet: Texture2D, cell: Vector2, name: String, row: int, columns: Array, fps: float, looped: bool) -> void:
	frames.add_animation(name)
	frames.set_animation_speed(name, fps)
	frames.set_animation_loop(name, looped)
	for column in columns:
		var texture := AtlasTexture.new()
		texture.atlas = sheet
		texture.region = Rect2(Vector2(column, row) * cell, cell)
		# A arte de salto toca a linha seguinte do atlas. Exclui essa borda
		# mantendo o tamanho virtual do quadro e o pivô de animação.
		if row == 2 and not name.begins_with("gfa"):
			texture.region.size.y -= 11
			texture.margin = Rect2(0, 0, 0, 11)
		frames.add_frame(name, texture)

func _physics_process(delta: float) -> void:
	animation_clock += delta
	invulnerable_left = maxf(0.0, invulnerable_left - delta)
	visual.modulate = Color(1, 0.6, 0.6, 0.45 if int(animation_clock * 18) % 2 == 0 else 1.0) if invulnerable_left > 0 else Color.WHITE
	if dead or hurt_left > 0:
		_tick_damage(delta)
		return
	if ledge.tick(delta):
		queue_redraw()
		return
	var grounded := is_on_floor()
	coyote_left = coyote_time if grounded else maxf(0.0, coyote_left - delta)
	jump_buffer = maxf(0.0, jump_buffer - delta)
	combo_left = maxf(0.0, combo_left - delta)
	heavy_combo_left = maxf(0.0, heavy_combo_left - delta)
	queued_time = maxf(0.0, queued_time - delta)
	landing_left = maxf(0.0, landing_left - delta)
	air_combo_left = maxf(0.0, air_combo_left - delta)
	if grounded:
		air_attacks_used = 0
		air_combo_step = 0
	elif air_combo_left <= 0.0 and not is_air_attack():
		air_combo_step = 0
	if combo_left <= 0.0:
		next_is_spin = false
		ground_combo_step = 0
	if heavy_combo_left <= 0.0:
		next_is_uppercut = false
		held_finish = ""
	if queued_time <= 0.0:
		queued_attack = ""
	if Input.is_action_just_pressed("jump"):
		jump_buffer = jump_buffer_time
	if Input.is_action_just_pressed("heavy_attack"):
		_request_attack("heavy")
	elif Input.is_action_just_pressed("light_attack"):
		_request_attack("light")
	_update_attack(delta)
	var axis := Input.get_axis("move_left", "move_right")
	if action == "":
		if axis != 0:
			facing = 1 if axis > 0 else -1
			held_finish = ""
		velocity.x = move_toward(velocity.x, axis * run_speed, (acceleration if axis != 0 else braking) * delta)
	elif grounded:
		velocity.x = move_toward(velocity.x, 0, braking * delta)
	# Golpes leves permitem pular; a espada compromete o personagem até terminar.
	if jump_buffer > 0 and coyote_left > 0 and not is_heavy_attack() and action not in ["gf4", "gf5"]:
		velocity.y = -jump_speed
		jump_buffer = 0
		coyote_left = 0
		landing_left = 0
		jump_spinning = action == ""
		roll_elapsed = 0.0
		roll_duration = 0.46
		jump_start_y = position.y
		held_finish = ""
	if Input.is_action_just_released("jump") and velocity.y < -260 and action != "gf4":
		velocity.y *= 0.48
		# O salto curto também completa a cambalhota antes de abrir para o pouso.
		var height_above_start := maxf(0.0, jump_start_y - position.y)
		var time_to_floor := (velocity.y + sqrt(velocity.y * velocity.y + 2.0 * gravity * height_above_start)) / gravity
		roll_duration = minf(roll_duration, maxf(0.12, roll_elapsed + time_to_floor - 0.10))
	if jump_spinning:
		roll_elapsed += delta
	if not grounded or velocity.y < 0:
		# Suspensão limitada às quatro ações; nunca aplica impulso para cima.
		var gravity_scale := 0.35 if is_air_attack() and velocity.y >= 0.0 else 1.0
		velocity.y = minf(velocity.y + gravity * gravity_scale * delta, max_fall_speed)
	visual.scale.x = facing
	var previous_position := global_position
	move_and_slide()
	if ledge.try_grab(previous_position):
		queue_redraw()
		return
	if is_on_floor() and not grounded:
		if is_air_attack():
			action = ""
			attack_active = false
			attack_shape.set_deferred("disabled", true)
			queued_attack = ""
			queued_time = 0.0
		if action == "gf4" and gf4_launched:
			# Teto/plataforma podem antecipar o pouso: recolher sem golpe fantasma.
			if action_time < 16.0/30.0:
				action_time = maxf(action_time, 20.0/30.0)
			attack_active = false
			attack_shape.set_deferred("disabled", true)
		if action != "gf4":
			ground_combo_step = 0
			next_is_spin = false
			combo_left = 0.0
		air_combo_step = 0
		air_attacks_used = 0
		air_combo_left = 0.0
		landing_left = 0.09
		jump_spinning = false
		landed.emit()
	_update_animation()
	queue_redraw()

func _request_attack(kind: String) -> void:
	if dead or hurt_left > 0: return
	if ledge.state != "":
		return
	if action == "":
		_start_attack(kind)
	elif action_time > action_duration * 0.45:
		# O quinto toque pode ficar na fila durante o giro; GF5 começa após GF4.
		queued_attack = kind
		queued_time = (action_duration - action_time) / attack_speed + 0.12

func _start_attack(kind: String) -> void:
	if kind == "light" and not is_on_floor():
		if air_attacks_used >= 4:
			return
		air_combo_step += 1
		air_attacks_used += 1
		action = "gfa" + str(air_combo_step)
		air_combo_left = ATTACK_DURATION[action] / attack_speed + 0.22
	elif kind == "light":
		if combo_left <= 0.0 or ground_combo_step >= 5:
			ground_combo_step = 0
		ground_combo_step += 1
		action = "gf" + str(ground_combo_step)
	else:
		action = "gff2" if next_is_uppercut else "gff1"
		air_combo_step = 0
		air_combo_left = 0.0
	action_duration = ATTACK_DURATION[action]
	action_time = 0
	finisher_fired = false
	gf4_launched = false
	hit_phase = -1
	held_finish = ""
	jump_spinning = false
	hit_targets.clear()
	if is_air_attack():
		ground_combo_step = 0
		next_is_spin = false
		next_is_uppercut = false
		combo_left = 0.0
		heavy_combo_left = 0.0
	elif not is_heavy_attack():
		next_is_spin = action == "gf1"
		combo_left = action_duration / attack_speed + 0.45
		next_is_uppercut = false
		heavy_combo_left = 0.0
	else:
		ground_combo_step = 0
		combo_left = 0.0
		next_is_spin = false
		next_is_uppercut = action == "gff1"
		heavy_combo_left = action_duration / attack_speed + heavy_combo_window
	attack_started.emit(action)

func is_heavy_attack() -> bool:
	return action == "gff1" or action == "gff2"

func is_air_attack() -> bool:
	return action.begins_with("gfa")

func attack_windows() -> Array[Vector2]:
	match action:
		"gf1": return [Vector2(0.07, 0.17), Vector2(0.33, 0.47)]
		"gf2": return [Vector2(0.28, 0.44)]
		"gf3": return [Vector2(0.08, 0.16)]
		"gf4": return [Vector2(13.0/30.0, 16.0/30.0)]
		"gf5": return [Vector2(0.24, 0.36)]
		"gff1": return [Vector2(0.18, 0.39) / GFF1_SPEED]
		"gff2": return [Vector2(0.24, 0.44)]
		"gfa1", "gfa3": return [Vector2(0.09, 0.135)]
		"gfa2": return [Vector2(0.12, 0.18)]
		"gfa4": return [Vector2(9.0/50.0, 12.0/50.0)]
	return []

func _update_attack(delta: float) -> void:
	attack_active = false
	if action != "":
		action_time += delta * attack_speed
		if action == "gf5" and not finisher_fired and action_time >= 0.24:
			finisher_fired = true
			finisher_executed.emit()
		if action == "gf4" and not gf4_launched and action_time >= 0.10:
			gf4_launched = true
			if is_on_floor():
				velocity.y = -545.0
				coyote_left = 0.0
				jump_buffer = 0.0
				landing_left = 0.0
		var windows := attack_windows()
		for index in range(windows.size()):
			# Vector2 armazena tempos em float32: tolerância evita dano no quadro de recuperação.
			if action_time + 0.000001 >= windows[index].x and action_time < windows[index].y - 0.000001:
				attack_active = true
				if hit_phase != index:
					hit_targets.clear()
					hit_phase = index
		if action_time >= action_duration:
			attack_active = false
			held_finish = "gff1" if action == "gff1" else ""
			action = ""
			if queued_attack != "":
				var pending := queued_attack
				queued_attack = ""
				_start_attack(pending)
	var box := attack_shape.shape as RectangleShape2D
	if action == "gf5":
		box.size = Vector2(92, 52)
		attack_area.position = Vector2(facing * 82, -108)
	elif action == "gf4" or action == "gfa4":
		box.size = Vector2(98, 48)
		attack_area.position = Vector2(facing * 74, -106)
	elif is_air_attack():
		var kick := action == "gfa2" or action == "gfa4"
		box.size = Vector2(90, 46) if kick else Vector2(60, 38)
		attack_area.position = Vector2(facing * (73 if kick else 64), -101 if kick else -117)
	elif action == "gff2":
		box.size = Vector2(144, 64) * preload("res://scripts/gff2_frames.gd").BODY_SCALE
		var center: Vector2 = preload("res://scripts/gff2_frames.gd").normalize_point(Vector2(106, -98))
		attack_area.position = Vector2(facing * center.x, center.y)
	elif action == "gf2":
		box.size = Vector2(120, 68)
		attack_area.position = Vector2(facing * 61, -96)
	else:
		box.size = Vector2(146, 126) if action == "gff1" else Vector2(88 if hit_phase == 1 else 68, 56)
		attack_area.position = Vector2(facing * (83 if action == "gff1" else 49), -78)
		if action == "gff1":
			box.size *= GFF1_BODY_SCALE
			attack_area.position *= GFF1_BODY_SCALE
	attack_shape.set_deferred("disabled", not attack_active)
	if attack_active:
		for target in attack_area.get_overlapping_areas():
			_try_hit(target)
		for target in attack_area.get_overlapping_bodies():
			_try_hit(target)

func _try_hit(target: Node) -> void:
	if not attack_active or not target.has_method("receive_hit") or target.get_instance_id() in hit_targets:
		return
	hit_targets.append(target.get_instance_id())
	if action == "gf5" and target.has_method("receive_combo_finisher"):
		target.receive_combo_finisher(1, facing)
	else:
		target.receive_hit(3 if is_heavy_attack() else 1, facing)

func _update_animation() -> void:
	if ledge.state != "":
		ledge.update_visual()
		return
	if sprite.sprite_frames == null:
		return
	if action != "":
		sprite.play(action)
		sprite.pause()
		var count := sprite.sprite_frames.get_frame_count(action)
		if action == "gf5":
			# Três poses de preparo; a extensão começa junto da janela de dano.
			# Depois da transferência de peso, mantém o braço esticado.
			sprite.frame = mini(2, int(action_time / 0.08)) if action_time < 0.24 else mini(11, 3 + int((action_time - 0.24) / 0.16 * 9))
		else:
			sprite.frame = mini(count - 1, int(action_time / action_duration * count))
	elif not is_on_floor():
		if jump_spinning and roll_elapsed >= 0.04 and roll_elapsed < 0.04 + roll_duration:
			sprite.play("somersault")
		else:
			sprite.play("rise" if velocity.y < -100 else ("fall" if velocity.y > 100 else "apex"))
	elif landing_left > 0 and absf(velocity.x) < 30:
		sprite.play("land")
	elif held_finish == "gff1" and heavy_combo_left > 0 and absf(velocity.x) < 25:
		sprite.play("gff1")
		sprite.pause()
		sprite.frame = 5
	elif absf(velocity.x) > 25:
		sprite.play("run")
	else:
		sprite.play("idle")
	_align_sprite()

func _align_sprite() -> void:
	sprite.rotation = 0.0
	sprite.offset = Vector2.ZERO
	if String(sprite.animation).begins_with("hurt_"):
		sprite.scale = new_frame_scales[String(sprite.animation)][sprite.frame]
		sprite.position = new_frame_positions[String(sprite.animation)][sprite.frame]
		sprite.material = null
	elif sprite.animation in ["gf4", "gfa4", "gf5"]:
		sprite.scale = new_frame_scales[String(sprite.animation)][sprite.frame]
		sprite.position = new_frame_positions[String(sprite.animation)][sprite.frame]
		sprite.material = new_attack_material
	elif String(sprite.animation).begins_with("gfa"):
		# Pivô no tronco, sem alinhar pelos pés recolhidos de cada pose.
		sprite.scale = Vector2(0.65, 0.65)
		sprite.position = Vector2(10, -93)
		sprite.material = new_attack_material
	elif sprite.animation == "gff1" or (sprite.animation == "gff2" and sprite.frame == 0):
		sprite.scale = sword_sprite_scale
		sprite.material = sword_material
		var source_frame: int = 4 if sprite.animation == "gff2" else sprite.frame
		sprite.position = Vector2(26, -132 if source_frame < 3 else -92) * GFF1_BODY_SCALE
	elif sprite.animation == "gf2" or sprite.animation == "gff2":
		sprite.scale = new_frame_scales[String(sprite.animation)][sprite.frame]
		sprite.position = new_frame_positions[String(sprite.animation)][sprite.frame]
		sprite.material = new_attack_material
	elif sprite.animation == "somersault":
		sprite.scale = normal_sprite_scale
		sprite.material = null
		sprite.position = Vector2(0, -85)
		sprite.offset = roll_center_offset
		var turn := clampf((roll_elapsed - 0.04) / roll_duration, 0.0, 1.0)
		sprite.rotation = turn * TAU * 2.0
	else:
		var offsets := {"run": 7.0, "gf1": 16.0, "gf3": 16.0}
		sprite.scale = normal_sprite_scale
		sprite.material = null
		sprite.position = Vector2(0, -92.0 + float(offsets.get(String(sprite.animation), 0.0)))

func state_label() -> String:
	if dead: return "YOUKAI CAIU / R PARA REINICIAR"
	if hurt_left > 0: return "ATINGIDO"
	if ledge.state == "hang": return "BEIRADA / PENDURADO"
	if ledge.state == "climb": return "BEIRADA / SUBINDO"
	if action == "gf1": return "GF-1 / SOCO + CHUTE"
	if action == "gf2": return "GF-2 / CHUTE GIRATÓRIO"
	if action == "gf3": return "GF-3 / SOCO DE LIGAÇÃO"
	if action == "gf4": return "GF-4 / GIRO COM SALTO"
	if action == "gf5": return "GF-5 / DIRETO FINAL"
	if action == "gff1": return "GFF-1 / DESCENDENTE"
	if action == "gff2": return "GFF-2 / FRONTAL"
	if action == "gfa1": return "GFA1 / SOCO DIRETO"
	if action == "gfa2": return "GFA2 / CHUTE GIRATÓRIO"
	if action == "gfa3": return "GFA3 / SOCO CRUZADO"
	if action == "gfa4": return "GFA4 / GIRO FINAL"
	if sprite.animation == "somersault": return "SALTO / GIRO DUPLO"
	if not is_on_floor(): return "SALTO / SUBINDO" if velocity.y < 0 else "SALTO / DESCENDO"
	return "CORRIDA" if absf(velocity.x) > 25 else "EM GUARDA"

func _draw() -> void:
	if is_on_floor() and absf(velocity.x) > 100:
		for i in range(3):
			var phase := fmod(animation_clock * 4 + i * 0.33, 1.0)
			draw_circle(Vector2(-facing * (15 + phase * 48), -3 - phase * 12), 3 * (1 - phase), Color(0.85, 0.68, 0.35, (1 - phase) * 0.4))
	if debug_shapes:
		draw_rect(Rect2(-18, -166, 36, 166), Color(0.3, 0.9, 0.95, 0.65), false, 1)
		if attack_active:
			var box := attack_shape.shape as RectangleShape2D
			draw_rect(Rect2(attack_area.position - box.size / 2, box.size), Color(1, 0.7, 0.2, 0.25))
			draw_rect(Rect2(attack_area.position - box.size / 2, box.size), Color(1, 0.7, 0.2), false, 2)

func receive_hit(damage: int, direction: int) -> void:
	if dead or invulnerable_left > 0 or damage <= 0: return
	hurt_animation = "hurt_ground" if is_on_floor() else "hurt_air"
	hurt_elapsed = 0.0
	health = maxi(0, health - damage)
	health_changed.emit(health)
	if ledge.state != "": ledge.release()
	ledge._reset_actions()
	ledge.cooldown = 0.5
	action = ""
	ground_combo_step = 0
	air_combo_step = 0
	air_combo_left = 0
	gf4_launched = false
	hit_targets.clear()
	velocity = Vector2(direction * 220, -130)
	hurt_left = HURT_DURATION
	invulnerable_left = 0.95
	dead = health == 0
	_update_animation()

func _tick_damage(delta: float) -> void:
	hurt_elapsed += delta
	hurt_left = maxf(0, hurt_left - delta)
	attack_active = false
	attack_shape.set_deferred("disabled", true)
	velocity.x = move_toward(velocity.x, 0, braking * 0.3 * delta)
	velocity.y = minf(max_fall_speed, velocity.y + gravity * delta)
	move_and_slide()
	sprite.play("land" if dead else hurt_animation)
	sprite.pause()
	if not dead: sprite.frame = mini(11,int(hurt_elapsed/HURT_DURATION*12))
	_align_sprite()
	if dead:
		visual.rotation = lerp_angle(visual.rotation, facing * PI * 0.5, minf(1, delta * 8))
		visual.position.y = -24
		visual.modulate = Color(0.6, 0.6, 0.7)
	queue_redraw()
