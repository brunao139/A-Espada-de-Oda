extends SceneTree
func _initialize() -> void:
	call_deferred("capture")
func capture() -> void:
	root.size = Vector2i(1536,1100)
	root.content_scale_size = root.size
	var bg := ColorRect.new()
	bg.color = Color("192633")
	bg.size = root.size
	root.add_child(bg)
	var hero = load("res://scenes/youkai.tscn").instantiate()
	root.add_child(hero)
	hero.set_physics_process(false)
	hero.hide()
	for i in range(24):
		var pose := Node2D.new()
		pose.position = Vector2(125+(i%6)*256,235+(i/6)*270)
		root.add_child(pose)
		hero.sprite.animation = "gf4"
		hero.sprite.frame = i
		hero._align_sprite()
		var sprite := Sprite2D.new()
		sprite.texture = hero.sprite.sprite_frames.get_frame_texture("gf4",i)
		sprite.position = hero.sprite.position
		sprite.scale = hero.sprite.scale
		sprite.material = hero.sprite.material
		pose.add_child(sprite)
		var line := Line2D.new()
		line.points = PackedVector2Array([Vector2(-110,0),Vector2(120,0)])
		line.width = 1
		line.default_color = Color("55727b")
		pose.add_child(line)
		var label := Label.new()
		label.text = "GF4  /  %02d" % (i+1)
		label.position = Vector2(-105,7)
		pose.add_child(label)
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(OS.get_cmdline_user_args()[0])
	quit()
