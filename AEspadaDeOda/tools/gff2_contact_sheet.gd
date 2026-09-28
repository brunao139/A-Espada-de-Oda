extends SceneTree
func _initialize() -> void:
	call_deferred("capture")
func capture() -> void:
	root.size = Vector2i(1600,960)
	root.content_scale_size = Vector2i(1600,960)
	var bg := ColorRect.new()
	bg.color = Color("#192633")
	bg.size = Vector2(1600,960)
	root.add_child(bg)
	var hero = load("res://scenes/youkai.tscn").instantiate()
	root.add_child(hero)
	hero.set_physics_process(false)
	hero.hide()
	for index in range(19):
		var pose := Node2D.new()
		pose.position = Vector2(110+(index%5)*320,207+(index/5)*240)
		root.add_child(pose)
		var anim := "gff2"
		var frame := index-1
		if index == 0:
			anim = "gff1"
			frame = 5
		elif index == 18:
			anim = "idle"
			frame = 0
		hero.sprite.animation = anim
		hero.sprite.frame = frame
		hero._align_sprite()
		var sprite := Sprite2D.new()
		sprite.texture = hero.sprite.sprite_frames.get_frame_texture(anim,frame)
		sprite.position = hero.sprite.position
		sprite.scale = hero.sprite.scale
		sprite.material = hero.sprite.material
		pose.add_child(sprite)
		var floor_line := Line2D.new()
		floor_line.points = PackedVector2Array([Vector2(-75,0),Vector2(215,0)])
		floor_line.width = 1
		floor_line.default_color = Color("#55727b")
		pose.add_child(floor_line)
		var label := Label.new()
		label.text = "GFF-1 / final" if index == 0 else ("Guarda" if index == 18 else "GFF-2 / %02d" % frame)
		label.position = Vector2(-72,-197)
		label.add_theme_font_size_override("font_size",18)
		pose.add_child(label)
	await process_frame
	await RenderingServer.frame_post_draw
	var dest := OS.get_cmdline_user_args()[0]
	root.get_texture().get_image().save_png(dest)
	quit()
