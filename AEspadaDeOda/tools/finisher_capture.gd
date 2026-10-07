extends SceneTree
const Frames := preload("res://scripts/ajogun_frames.gd")
func _initialize() -> void: call_deferred("run")
func capture(out: String, name: String) -> void:
 await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png(out.path_join(name+".png"))
func run() -> void:
 var out := OS.get_cmdline_user_args()[0]
 var scene = load("res://scenes/movement_lab.tscn").instantiate()
 root.add_child(scene)
 for i in range(5): await physics_frame
 scene.set_process(false)
 var hero = scene.youkai
 hero.set_physics_process(false)
 for enemy in scene.enemies.get_children(): enemy.set_physics_process(false)
 var enemy = scene.enemies.get_child(0)
 hero.position = Vector2(470,580)
 hero.action = "gf5"
 hero.action_duration = 0.64
 hero.action_time = 0.46
 hero._update_animation()
 enemy.position = Vector2(690,550)
 enemy.facing = -1
 enemy.state = "launch"
 enemy.velocity = Vector2(300,100)
 enemy._update_visual()
 await capture(out,"v016-gf5-launch")
 enemy.position = Vector2(760,580)
 enemy.state = "dead"
 enemy.health = 0
 enemy.thrown_death = true
 enemy.state_time = 1
 enemy._update_visual()
 await capture(out,"v016-gf5-landed")
 scene.visible = false
 scene.get_node("HUD").visible = false
 scene.get_node("Backdrop").visible = false
 for kind in ["gf5","launch","landing"]:
  var grid := Node2D.new()
  root.add_child(grid)
  var bg := Polygon2D.new()
  bg.polygon = PackedVector2Array([Vector2.ZERO,Vector2(1280,0),Vector2(1280,720),Vector2(0,720)])
  bg.color = Color("263649")
  grid.add_child(bg)
  for index in range(12):
   var at := Vector2(155+(index%4)*320,215+(index/4)*230)
   var line := Line2D.new()
   line.points = PackedVector2Array([at+Vector2(-145,0),at+Vector2(145,0)])
   line.width = 1
   line.default_color = Color("6fb0a0")
   grid.add_child(line)
   var label := Label.new()
   label.text = str(index)
   label.position = at+Vector2(-142,-205)
   grid.add_child(label)
   if kind=="gf5":
    var sprite := Sprite2D.new()
    sprite.texture = hero.sprite.sprite_frames.get_frame_texture(kind,index)
    sprite.position = at+hero.new_frame_positions[kind][index]
    sprite.scale = hero.new_frame_scales[kind][index]
    grid.add_child(sprite)
   else:
    var art := Polygon2D.new()
    Frames.apply(art,kind,index)
    art.position = at
    grid.add_child(art)
  await capture(out,"v016-frames-"+kind)
  grid.queue_free()
  await process_frame
 quit()
