extends SceneTree
func _initialize() -> void:
	call_deferred("capture")
func capture() -> void:
	var shot = load("res://tools/anime_source.tscn").instantiate()
	root.add_child(shot)
	shot.manual = true
	var out := OS.get_cmdline_user_args()[0]
	DirAccess.make_dir_recursive_absolute(out)
	for t in [2.8,5.1,7.6,10.2,12.1,14.1,16.5,19.5,22.3,23.3,27.8]:
		shot.elapsed = t
		shot.queue_redraw()
		await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(out.path_join("shot-%04.1f.png" % t))
	quit()
