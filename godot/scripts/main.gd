extends Node3D

const ISLAND_RADIUS := 42.0
const MOVE_SPEED := 6.0
const LOOK_SENSITIVITY := 0.006

var player: CharacterBody3D
var camera_pivot: Node3D
var camera: Camera3D
var status_label: Label
var joy_origin := Vector2.ZERO
var joy_vector := Vector2.ZERO
var look_finger := -1
var last_look := Vector2.ZERO
var touch_look := Vector2.ZERO

func _ready() -> void:
	_build_world()
	_build_player()
	_build_hud()

func _build_world() -> void:
	var world_env := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_SKY
	env.sky = Sky.new()
	env.sky.sky_material = ProceduralSkyMaterial.new()
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.72, 0.82, 0.95)
	env.ambient_light_energy = 0.7
	world_env.environment = env
	add_child(world_env)

	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-48, -30, 0)
	sun.light_energy = 1.25
	add_child(sun)

	_add_box("Ocean", Vector3(0, -1.4, 0), Vector3(180, 1, 180), Color(0.04, 0.34, 0.52))
	_add_cylinder("Island", Vector3(0, -0.1, 0), 43.0, 3.0, Color(0.72, 0.58, 0.34))
	_add_cylinder("Grass", Vector3(0, 1.25, 0), 38.0, 1.0, Color(0.22, 0.43, 0.19))

	for i in range(26):
		var angle := TAU * float(i) / 26.0
		var radius := 12.0 + float((i * 17) % 22)
		var x := cos(angle) * radius
		var z := sin(angle) * radius
		_add_tree(Vector3(x, 1.8, z), 0.8 + float(i % 4) * 0.18)

	_add_box("Runway", Vector3(4, 1.82, -8), Vector3(18, 0.12, 3), Color(0.31, 0.31, 0.29))
	_add_box("Wreckage", Vector3(10, 2.5, -8), Vector3(2.2, 1.1, 2.0), Color(0.37, 0.39, 0.40))
	_add_box("Supply crate", Vector3(-7, 2.2, 5), Vector3(1.5, 1.4, 1.5), Color(0.42, 0.25, 0.12))

func _add_box(label: String, pos: Vector3, size: Vector3, color: Color) -> void:
	var body := StaticBody3D.new()
	body.name = label
	body.position = pos
	var mesh := BoxMesh.new()
	mesh.size = size
	var visual := MeshInstance3D.new()
	visual.mesh = mesh
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	visual.material_override = mat
	body.add_child(visual)
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = size
	shape.shape = box
	body.add_child(shape)
	add_child(body)

func _add_cylinder(label: String, pos: Vector3, radius: float, height: float, color: Color) -> void:
	var body := StaticBody3D.new()
	body.name = label
	body.position = pos
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	var visual := MeshInstance3D.new()
	visual.mesh = mesh
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	visual.material_override = mat
	body.add_child(visual)
	var shape := CollisionShape3D.new()
	var cylinder := CylinderShape3D.new()
	cylinder.radius = radius
	cylinder.height = height
	shape.shape = cylinder
	body.add_child(shape)
	add_child(body)

func _add_tree(pos: Vector3, scale_factor: float) -> void:
	var tree := Node3D.new()
	tree.position = pos
	tree.scale = Vector3.ONE * scale_factor
	var trunk := MeshInstance3D.new()
	var trunk_mesh := CylinderMesh.new()
	trunk_mesh.top_radius = 0.18
	trunk_mesh.bottom_radius = 0.28
	trunk_mesh.height = 2.5
	trunk.mesh = trunk_mesh
	var trunk_mat := StandardMaterial3D.new()
	trunk_mat.albedo_color = Color(0.30, 0.17, 0.09)
	trunk.material_override = trunk_mat
	trunk.position.y = 1.25
	tree.add_child(trunk)
	var leaves := MeshInstance3D.new()
	var leaf_mesh := SphereMesh.new()
	leaf_mesh.radius = 1.35
	leaf_mesh.height = 2.7
	leaves.mesh = leaf_mesh
	var leaf_mat := StandardMaterial3D.new()
	leaf_mat.albedo_color = Color(0.10, 0.34, 0.14)
	leaves.material_override = leaf_mat
	leaves.position.y = 2.7
	tree.add_child(leaves)
	add_child(tree)

func _build_player() -> void:
	player = CharacterBody3D.new()
	player.name = "Player"
	player.position = Vector3(0, 3, 14)
	var collision := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.42
	capsule.height = 1.8
	collision.shape = capsule
	player.add_child(collision)
	var body_mesh := MeshInstance3D.new()
	var capsule_mesh := CapsuleMesh.new()
	capsule_mesh.radius = 0.42
	capsule_mesh.height = 1.8
	body_mesh.mesh = capsule_mesh
	var body_mat := StandardMaterial3D.new()
	body_mat.albedo_color = Color(0.78, 0.68, 0.48)
	body_mesh.material_override = body_mat
	player.add_child(body_mesh)
	camera_pivot = Node3D.new()
	camera_pivot.position.y = 0.65
	player.add_child(camera_pivot)
	camera = Camera3D.new()
	camera.position = Vector3(0, 1.2, 4.5)
	camera.rotation_degrees.x = -12
	camera.current = true
	camera_pivot.add_child(camera)
	add_child(player)

func _build_hud() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	var panel := PanelContainer.new()
	panel.position = Vector2(18, 18)
	panel.custom_minimum_size = Vector2(310, 74)
	layer.add_child(panel)
	status_label = Label.new()
	status_label.text = "RELANDED  |  DIA 1\nExplore a ilha e encontre suprimentos."
	status_label.add_theme_font_size_override("font_size", 18)
	panel.add_child(status_label)
	var help := Label.new()
	help.text = "Toque esquerdo: mover   •   Arraste à direita: olhar"
	help.position = Vector2(18, -48)
	help.add_theme_font_size_override("font_size", 15)
	panel.add_child(help)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed and event.position.x > get_viewport().get_visible_rect().size.x * 0.48:
			look_finger = event.index
			last_look = event.position
		elif not event.pressed and event.index == look_finger:
			look_finger = -1
	elif event is InputEventScreenDrag:
		if event.index == look_finger:
			camera_pivot.rotate_y(-event.relative.x * LOOK_SENSITIVITY)
			camera.rotate_x(-event.relative.y * LOOK_SENSITIVITY)
			camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-65), deg_to_rad(35))
		elif event.position.x < get_viewport().get_visible_rect().size.x * 0.48:
			joy_vector = (event.position - Vector2(110, get_viewport().get_visible_rect().size.y - 110)).limit_length(72.0) / 72.0
	elif event is InputEventScreenTouch and not event.pressed:
		joy_vector = Vector2.ZERO
	elif event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		get_tree().quit()

func _physics_process(delta: float) -> void:
	var input_vector := Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	if joy_vector.length() > 0.08:
		input_vector = joy_vector
	var direction := (player.transform.basis * Vector3(input_vector.x, 0, input_vector.y)).normalized()
	if direction.length() > 0.01:
		player.velocity.x = direction.x * MOVE_SPEED
		player.velocity.z = direction.z * MOVE_SPEED
	else:
		player.velocity.x = move_toward(player.velocity.x, 0.0, MOVE_SPEED * 5.0 * delta)
		player.velocity.z = move_toward(player.velocity.z, 0.0, MOVE_SPEED * 5.0 * delta)
	player.velocity.y -= 9.8 * delta
	player.move_and_slide()
	if player.global_position.y < -5:
		player.global_position = Vector3(0, 4, 14)
		player.velocity = Vector3.ZERO
