extends SceneTree
const Frames := preload("res://scripts/ajogun_frames.gd")
func _initialize() -> void: call_deferred("run")
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
 hero.position = Vector2(460,580)
 hero._update_animation()
 enemy.position = Vector2(680,580)
 enemy.facing = -1
 enemy.state = "walk"
 enemy.velocity.x = -70
 enemy._update_visual()
 await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png(out.path_join("v015-gameplay.png"))
 for face in [1,-1]:
  enemy.facing = face
  enemy.state = "dead"
  enemy.state_time = 1.2
  enemy.velocity = Vector2.ZERO
  enemy._update_visual()
  await process_frame
  await RenderingServer.frame_post_draw
  root.get_texture().get_image().save_png(out.path_join("v015-death-"+str(face)+".png"))
 hero.hurt_animation = "hurt_ground"
 hero.hurt_elapsed = 0.08
 hero.hurt_left = 0.3
 hero._tick_damage(0.0)
 await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png(out.path_join("v015-youkai-hurt.png"))
 scene.visible = false
 scene.get_node("HUD").visible = false
 scene.get_node("Backdrop").visible = false
 for kind in ["idle","walk","run","hurt","attack","death","hero_ground","hero_air"]:
  var grid := Node2D.new()
  root.add_child(grid)
  var bg := Polygon2D.new()
  bg.polygon = PackedVector2Array([Vector2.ZERO,Vector2(1280,0),Vector2(1280,720),Vector2(0,720)])
  bg.color = Color("263649")
  grid.add_child(bg)
  var count: int = 12 if kind.begins_with("hero") else Frames.count(kind)
  for index in range(count):
   var at := Vector2(155+(index%4)*320,158+(index/4)*178)
   var line := Line2D.new()
   line.points = PackedVector2Array([at+Vector2(-145,0),at+Vector2(145,0)])
   line.width = 1
   line.default_color = Color("6fb0a0")
   grid.add_child(line)
   var label := Label.new()
   label.text = str(index)
   label.position = at+Vector2(-142,-150)
   grid.add_child(label)
   if kind.begins_with("hero"):
    var name: String = "hurt_"+kind.trim_prefix("hero_")
    var sprite := Sprite2D.new()
    sprite.texture = hero.sprite.sprite_frames.get_frame_texture(name,index)
    sprite.position = at+hero.new_frame_positions[name][index]*0.7
    sprite.scale = hero.new_frame_scales[name][index]*0.7
    grid.add_child(sprite)
   else:
    var art := Polygon2D.new()
    Frames.apply(art,kind,index)
    art.position = at
    art.scale = Vector2.ONE*0.7
    grid.add_child(art)
  await process_frame
  await RenderingServer.frame_post_draw
  root.get_texture().get_image().save_png(out.path_join("v015-frames-"+kind+".png"))
  grid.queue_free()
  await process_frame
 quit()
