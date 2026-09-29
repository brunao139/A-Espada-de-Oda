extends SceneTree
func _initialize() -> void:
	call_deferred("run")
func run() -> void:
	var scene = load("res://scenes/movement_lab.tscn").instantiate()
	root.add_child(scene)
	for i in range(5): await physics_frame
	scene.set_process(false)
	var hero = scene.get_node("Youkai")
	hero.set_physics_process(false)
	var positions := [Vector2(600,580),Vector2(4380,330),Vector2(8640,456)]
	var cameras := [640.0,4420.0,8360.0]
	var output := OS.get_cmdline_user_args()[0]
	for i in range(3):
		hero.position = positions[i]
		hero.action = ""
		hero.sprite.play("idle")
		hero._align_sprite()
		scene.camera.position.x = cameras[i]
		scene.get_node("Backdrop/City").camera_offset = cameras[i]-640
		scene.get_node("Backdrop/City").elapsed = 3.0+i*3.0
		scene.queue_redraw()
		await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(output.path_join("cidade-%d.png" % (i+1)))
	quit()
