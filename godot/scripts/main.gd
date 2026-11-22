extends Node3D

const MOVE_SPEED := 5.2
const SWIM_SPEED := 2.8
const LOOK_SENSITIVITY := 0.0045
const WORLD_RADIUS := 29.0
const ASSET := "res://models/"

var ui_layer: CanvasLayer
var ui_root: Control
var player: CharacterBody3D
var player_visual: Node3D
var camera_pivot: Node3D
var camera: Camera3D
var hud_label: Label
var interaction_button: Button
var message_label: Label
var inventory_panel: PanelContainer
var inventory_label: Label
var craft_panel: PanelContainer
var craft_label: Label
var menu_panel: PanelContainer
var multiplayer_status: Label
var ip_input: LineEdit
var joy_vector := Vector2.ZERO
var joy_origin := Vector2.ZERO
var look_finger := -1
var move_finger := -1
var nearest_interactable: Node3D
var interactables: Array[Node3D] = []
var inventory := {"Coco": 0, "Madeira": 0, "Fibra": 0, "Ervas": 0, "Água": 0, "Concha": 0}
var inventory_capacity := 12
var health := 100.0
var hunger := 100.0
var thirst := 100.0
var stamina := 100.0
var body_temperature := 37.0
var oxygen := 100.0
var day_number := 1
var day_time := 9.0
var weather := "Ensolarado"
var is_swimming := false
var is_diving := false
var has_shelter := false
var has_campfire := false
var cold_clothes := false
var graphics_quality := 2
var game_active := false
var notification_time := 0.0
var survival_tick := 0.0
var sky_light: DirectionalLight3D
var world_environment: WorldEnvironment
var island_root: Node3D

func _ready() -> void:
	_build_ui()
	_show_main_menu()

func _build_ui() -> void:
	ui_layer = CanvasLayer.new()
	ui_layer.layer = 10
	add_child(ui_layer)
	ui_root = Control.new()
	ui_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	ui_layer.add_child(ui_root)

func _clear_ui() -> void:
	for child in ui_root.get_children():
		child.queue_free()

func _panel(parent: Control, min_size: Vector2 = Vector2.ZERO) -> PanelContainer:
	var p := PanelContainer.new()
	p.custom_minimum_size = min_size
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.035, 0.065, 0.075, 0.94)
	style.border_color = Color(0.30, 0.62, 0.52, 0.9)
	style.set_border_width_all(2)
	style.set_corner_radius_all(14)
	style.content_margin_left = 18
	style.content_margin_right = 18
	style.content_margin_top = 14
	style.content_margin_bottom = 14
	p.add_theme_stylebox_override("panel", style)
	parent.add_child(p)
	return p

func _make_button(parent: Control, text_value: String, callback: Callable, min_size := Vector2(220, 54)) -> Button:
	var b := Button.new()
	b.text = text_value
	b.custom_minimum_size = min_size
	b.add_theme_font_size_override("font_size", 19)
	b.pressed.connect(callback)
	parent.add_child(b)
	return b

func _show_main_menu() -> void:
	game_active = false
	_clear_ui()
	var bg := ColorRect.new()
	bg.color = Color(0.025, 0.075, 0.09, 1)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	ui_root.add_child(bg)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	ui_root.add_child(center)
	menu_panel = _panel(center, Vector2(390, 0))
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 12)
	menu_panel.add_child(col)
	var title := Label.new()
	title.text = "RELANDED"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 42)
	title.add_theme_color_override("font_color", Color(0.48, 0.86, 0.72))
	col.add_child(title)
	var subtitle := Label.new()
	subtitle.text = "SOBREVIVA • EXPLORE • RECOMECE"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_font_size_override("font_size", 13)
	col.add_child(subtitle)
	_make_button(col, "JOGAR SOLO", Callable(self, "_start_solo"))
	_make_button(col, "MULTIPLAYER • WI-FI", Callable(self, "_show_multiplayer"))
	_make_button(col, "CONFIGURAÇÕES", Callable(self, "_show_settings"))
	_make_button(col, "SAIR", Callable(self, "_exit_game"))
	var note := Label.new()
	note.text = "A ilha não vai esperar por você."
	note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	note.add_theme_font_size_override("font_size", 12)
	col.add_child(note)

func _show_multiplayer() -> void:
	_clear_ui()
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	ui_root.add_child(center)
	var panel := _panel(center, Vector2(390, 0))
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 12)
	panel.add_child(col)
	var title := Label.new()
	title.text = "MULTIPLAYER • REDE LOCAL"
	title.add_theme_font_size_override("font_size", 25)
	col.add_child(title)
	var info := Label.new()
	info.text = "Crie uma sala ou conecte-se pelo IP do anfitrião na mesma rede Wi-Fi. A sincronização de jogadores ainda será finalizada numa etapa própria."
	info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	col.add_child(info)
	ip_input = LineEdit.new()
	ip_input.placeholder_text = "IP do anfitrião (ex.: 192.168.0.10)"
	ip_input.custom_minimum_size.y = 48
	col.add_child(ip_input)
	_make_button(col, "CRIAR SALA", Callable(self, "_host_lan"))
	_make_button(col, "CONECTAR", Callable(self, "_join_lan"))
	multiplayer_status = Label.new()
	multiplayer_status.text = "Modo de rede local em preparação."
	multiplayer_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	col.add_child(multiplayer_status)
	_make_button(col, "VOLTAR", Callable(self, "_show_main_menu"))

func _host_lan() -> void:
	var peer := ENetMultiplayerPeer.new()
	var result := peer.create_server(2456, 4)
	if result == OK:
		multiplayer.multiplayer_peer = peer
		multiplayer_status.text = "Sala criada na porta 2456. A sincronização de jogadores ainda não está ativa."
	else:
		multiplayer_status.text = "Não foi possível criar a sala. Código: " + str(result)

func _join_lan() -> void:
	var address := ip_input.text.strip_edges()
	if address.is_empty():
		multiplayer_status.text = "Digite o IP do anfitrião."
		return
	var peer := ENetMultiplayerPeer.new()
	var result := peer.create_client(address, 2456)
	if result == OK:
		multiplayer.multiplayer_peer = peer
		multiplayer_status.text = "Tentando conectar. A sincronização de jogadores ainda não está ativa."
	else:
		multiplayer_status.text = "Não foi possível conectar. Código: " + str(result)

func _show_settings() -> void:
	_clear_ui()
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	ui_root.add_child(center)
	var panel := _panel(center, Vector2(410, 0))
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 10)
	panel.add_child(col)
	var title := Label.new()
	title.text = "CONFIGURAÇÕES"
	title.add_theme_font_size_override("font_size", 28)
	col.add_child(title)
	var quality := OptionButton.new()
	quality.add_item("Baixa • melhor desempenho", 0)
	quality.add_item("Média", 1)
	quality.add_item("Alta", 2)
	quality.add_item("Muito alta", 3)
	quality.select(graphics_quality)
	quality.item_selected.connect(_set_quality)
	col.add_child(quality)
	var scale_label := Label.new()
	scale_label.text = "Escala de renderização: " + str(int(get_viewport().scaling_3d_scale * 100.0)) + "%"
	col.add_child(scale_label)
	var scale_slider := HSlider.new()
	scale_slider.min_value = 0.65
	scale_slider.max_value = 1.0
	scale_slider.step = 0.05
	scale_slider.value = get_viewport().scaling_3d_scale
	scale_slider.value_changed.connect(func(v: float) -> void:
		get_viewport().scaling_3d_scale = v
		scale_label.text = "Escala de renderização: " + str(int(v * 100.0)) + "%"
	)
	col.add_child(scale_slider)
	var unsupported := Label.new()
	unsupported.text = "Ray tracing e geração de quadros não são suportados por esta configuração Android. Não vou mostrar esses recursos como se estivessem funcionando."
	unsupported.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	unsupported.add_theme_color_override("font_color", Color(0.95, 0.78, 0.42))
	col.add_child(unsupported)
	_make_button(col, "VOLTAR", Callable(self, "_show_main_menu"))

func _set_quality(index: int) -> void:
	graphics_quality = index
	var vp := get_viewport()
	vp.msaa_3d = Viewport.MSAA_2X if index >= 2 else Viewport.MSAA_DISABLED
	vp.screen_space_aa = Viewport.SCREEN_SPACE_AA_FXAA if index >= 1 else Viewport.SCREEN_SPACE_AA_DISABLED
	if sky_light:
		sky_light.shadow_enabled = index >= 2

func _exit_game() -> void:
	get_tree().quit()

func _start_solo() -> void:
	_clear_ui()
	_build_world()
	_build_player()
	_build_hud()
	game_active = true
	_show_message("Você acordou após o acidente. Encontre água, comida e abrigo.")

func _build_world() -> void:
	for child in get_children():
		if child != ui_layer:
			child.queue_free()
	interactables.clear()
	world_environment = WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_SKY
	env.sky = Sky.new()
	env.sky.sky_material = ProceduralSkyMaterial.new()
	env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	env.ambient_light_energy = 0.8
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	world_environment.environment = env
	add_child(world_environment)
	sky_light = DirectionalLight3D.new()
	sky_light.rotation_degrees = Vector3(-42, -28, 0)
	sky_light.light_energy = 1.15
	sky_light.shadow_enabled = true
	add_child(sky_light)
	_add_ocean()
	island_root = Node3D.new()
	island_root.name = "DownloadedIslandEnvironment"
	add_child(island_root)
	_spawn_model("island_lagoon.glb", Vector3.ZERO, Vector3(5.0, 5.0, 5.0), island_root)
	_spawn_model("palm_tall.glb", Vector3(-13, 0, -8), Vector3(1.8, 1.8, 1.8), island_root)
	_spawn_model("palm_tall.glb", Vector3(15, 0, -10), Vector3(1.5, 1.5, 1.5), island_root)
	_spawn_model("palm_leaning.glb", Vector3(-17, 0, 9), Vector3(1.5, 1.5, 1.5), island_root)
	_spawn_model("palm_leaning.glb", Vector3(18, 0, 8), Vector3(1.4, 1.4, 1.4), island_root)
	_spawn_model("shells.glb", Vector3(-9, 0.2, 16), Vector3(2.0, 2.0, 2.0), island_root)
	_spawn_model("driftwood.glb", Vector3(9, 0.2, 16), Vector3(2.0, 2.0, 2.0), island_root)
	_spawn_model("spring.glb", Vector3(-11, 0.1, -13), Vector3(1.7, 1.7, 1.7), island_root)
	_spawn_model("lean_to.glb", Vector3(13, 0, 12), Vector3(1.8, 1.8, 1.8), island_root)
	_add_ground_collision()
	_add_interactable("spring", "Fonte de água", Vector3(-11, 1.0, -13))
	_add_interactable("coconut", "Coqueiro", Vector3(-13, 1.0, -8))
	_add_interactable("wood", "Madeira à deriva", Vector3(9, 1.0, 16))
	_add_interactable("fiber", "Folhas e fibras", Vector3(15, 1.0, -10))
	_add_interactable("herb", "Plantas medicinais", Vector3(-17, 1.0, 9))
	_add_interactable("shell", "Conchas", Vector3(-9, 1.0, 16))
	_add_interactable("shelter", "Abrigo natural", Vector3(13, 1.0, 12))
	_set_quality(graphics_quality)

func _add_ocean() -> void:
	var ocean := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(240, 240)
	ocean.mesh = plane
	ocean.position.y = -2.3
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.025, 0.24, 0.36, 0.92)
	mat.metallic = 0.18
	mat.roughness = 0.22
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	ocean.material_override = mat
	add_child(ocean)

func _add_ground_collision() -> void:
	var ground := StaticBody3D.new()
	ground.name = "IslandWalkableCollision"
	var shape_node := CollisionShape3D.new()
	var shape := CylinderShape3D.new()
	shape.radius = WORLD_RADIUS
	shape.height = 1.0
	shape_node.shape = shape
	shape_node.position.y = -0.45
	ground.add_child(shape_node)
	add_child(ground)

func _spawn_model(file_name: String, pos: Vector3, scale_value: Vector3, parent: Node3D) -> Node3D:
	var packed := load(ASSET + file_name) as PackedScene
	if packed == null:
		push_warning("Asset ausente: " + file_name)
		return null
	var instance := packed.instantiate() as Node3D
	if instance == null:
		return null
	instance.position = pos
	instance.scale = scale_value
	parent.add_child(instance)
	return instance

func _add_interactable(kind: String, label_text: String, pos: Vector3) -> void:
	var marker := Node3D.new()
	marker.name = "Interact_" + kind
	marker.position = pos
	marker.set_meta("kind", kind)
	marker.set_meta("label", label_text)
	add_child(marker)
	interactables.append(marker)

func _build_player() -> void:
	player = CharacterBody3D.new()
	player.name = "Player"
	player.position = Vector3(0, 1.2, 9)
	player.floor_snap_length = 0.35
	var collision := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.34
	capsule.height = 1.7
	collision.shape = capsule
	collision.position.y = 0.85
	player.add_child(collision)
	player_visual = _spawn_model("hiker.glb", Vector3.ZERO, Vector3(1, 1, 1), player)
	if player_visual:
		player_visual.rotation.y = PI
		var anim_players := player_visual.find_children("*", "AnimationPlayer", true, false)
		if anim_players.size() > 0:
			var anim := anim_players[0] as AnimationPlayer
			if anim.has_animation("idle"):
				anim.play("idle")
	camera_pivot = Node3D.new()
	camera_pivot.position.y = 1.4
	player.add_child(camera_pivot)
	camera = Camera3D.new()
	camera.position = Vector3(0, 2.1, 5.4)
	camera.rotation_degrees.x = -12
	camera.current = true
	camera_pivot.add_child(camera)
	add_child(player)

func _build_hud() -> void:
	var top := _panel(ui_root, Vector2(360, 0))
	top.position = Vector2(14, 14)
	top.size = Vector2(420, 112)
	hud_label = Label.new()
	hud_label.add_theme_font_size_override("font_size", 16)
	top.add_child(hud_label)
	var controls := HBoxContainer.new()
	controls.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
	controls.position = Vector2(-420, -82)
	controls.size = Vector2(410, 64)
	ui_root.add_child(controls)
	_make_button(controls, "MOCHILA", Callable(self, "_toggle_inventory"), Vector2(112, 54))
	_make_button(controls, "CRIAR", Callable(self, "_toggle_crafting"), Vector2(100, 54))
	_make_button(controls, "MERGULHAR", Callable(self, "_toggle_dive"), Vector2(112, 54))
	interaction_button = _make_button(ui_root, "INTERAGIR", Callable(self, "_interact"), Vector2(150, 58))
	interaction_button.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
	interaction_button.position = Vector2(-180, -160)
	interaction_button.visible = false
	message_label = Label.new()
	message_label.position = Vector2(16, 140)
	message_label.add_theme_font_size_override("font_size", 17)
	message_label.add_theme_color_override("font_color", Color(0.95, 0.88, 0.62))
	ui_root.add_child(message_label)
	var back := Button.new()
	back.text = "MENU"
	back.custom_minimum_size = Vector2(82, 42)
	back.position = Vector2(14, 132)
	back.pressed.connect(_pause_to_menu)
	ui_root.add_child(back)
	_update_hud()

func _toggle_inventory() -> void:
	if inventory_panel and is_instance_valid(inventory_panel):
		inventory_panel.queue_free()
		inventory_panel = null
		return
	inventory_panel = _panel(ui_root, Vector2(300, 0))
	inventory_panel.position = Vector2(14, 190)
	var col := VBoxContainer.new()
	inventory_panel.add_child(col)
	var title := Label.new()
	title.text = "MOCHILA  •  " + str(_inventory_count()) + "/" + str(inventory_capacity)
	title.add_theme_font_size_override("font_size", 22)
	col.add_child(title)
	inventory_label = Label.new()
	inventory_label.text = _inventory_text()
	inventory_label.add_theme_font_size_override("font_size", 16)
	col.add_child(inventory_label)
	_make_button(col, "COMER COCO", Callable(self, "_consume_coconut"), Vector2(240, 46))
	_make_button(col, "BEBER ÁGUA", Callable(self, "_drink_water"), Vector2(240, 46))
	_make_button(col, "FECHAR", Callable(self, "_toggle_inventory"), Vector2(240, 46))

func _toggle_crafting() -> void:
	if craft_panel and is_instance_valid(craft_panel):
		craft_panel.queue_free()
		craft_panel = null
		return
	craft_panel = _panel(ui_root, Vector2(330, 0))
	craft_panel.position = Vector2(340, 190)
	var col := VBoxContainer.new()
	craft_panel.add_child(col)
	var title := Label.new()
	title.text = "FABRICAÇÃO"
	title.add_theme_font_size_override("font_size", 22)
	col.add_child(title)
	craft_label = Label.new()
	craft_label.text = "Receitas de sobrevivência"
	col.add_child(craft_label)
	_make_button(col, "ABRIGO  •  5 madeira + 4 fibra", Callable(self, "_craft_shelter"), Vector2(300, 48))
	_make_button(col, "ROUPA TÉRMICA  •  4 fibra + 2 ervas", Callable(self, "_craft_clothes"), Vector2(300, 48))
	_make_button(col, "ATADURA  •  2 fibra + 1 erva", Callable(self, "_craft_bandage"), Vector2(300, 48))
	_make_button(col, "FOGUEIRA  •  3 madeira + 2 fibra", Callable(self, "_craft_fire"), Vector2(300, 48))
	_make_button(col, "MOCHILA MAIOR  •  4 madeira + 5 fibra", Callable(self, "_craft_backpack"), Vector2(300, 48))
	_make_button(col, "FECHAR", Callable(self, "_toggle_crafting"), Vector2(300, 46))

func _inventory_count() -> int:
	var total := 0
	for amount in inventory.values():
		total += int(amount)
	return total

func _inventory_text() -> String:
	var lines := PackedStringArray()
	for item in inventory.keys():
		if int(inventory[item]) > 0:
			lines.append(str(item) + ": " + str(inventory[item]))
	if lines.is_empty():
		return "Mochila vazia. Explore a ilha e colete recursos."
	return "\n".join(lines)

func _add_item(item: String, amount: int = 1) -> void:
	if _inventory_count() >= inventory_capacity:
		_show_message("Mochila cheia. Melhore sua capacidade.")
		return
	inventory[item] = int(inventory.get(item, 0)) + amount
	_refresh_panels()

func _has_items(cost: Dictionary) -> bool:
	for item in cost.keys():
		if int(inventory.get(item, 0)) < int(cost[item]):
			return false
	return true

func _pay_items(cost: Dictionary) -> void:
	for item in cost.keys():
		inventory[item] = int(inventory.get(item, 0)) - int(cost[item])
	_refresh_panels()

func _refresh_panels() -> void:
	if inventory_label and is_instance_valid(inventory_label):
		inventory_label.text = _inventory_text()
	if craft_label and is_instance_valid(craft_label):
		craft_label.text = "Itens: " + str(_inventory_count()) + "/" + str(inventory_capacity)

func _craft_shelter() -> void:
	var cost := {"Madeira": 5, "Fibra": 4}
	if not _has_items(cost):
		_show_message("Faltam materiais para o abrigo.")
		return
	_pay_items(cost)
	has_shelter = true
	_show_message("Abrigo fabricado. Você fica mais protegido durante a noite.")
	if island_root:
		_spawn_model("lean_to.glb", Vector3(3, 0, 4), Vector3(1.8, 1.8, 1.8), island_root)

func _craft_clothes() -> void:
	var cost := {"Fibra": 4, "Ervas": 2}
	if not _has_items(cost):
		_show_message("Faltam materiais para a roupa térmica.")
		return
	_pay_items(cost)
	cold_clothes = true
	_show_message("Roupa térmica equipada. Sua temperatura fica mais estável.")

func _craft_bandage() -> void:
	var cost := {"Fibra": 2, "Ervas": 1}
	if not _has_items(cost):
		_show_message("Faltam materiais para a atadura.")
		return
	_pay_items(cost)
	health = minf(100.0, health + 28.0)
	_show_message("Você tratou seus ferimentos.")

func _craft_fire() -> void:
	var cost := {"Madeira": 3, "Fibra": 2}
	if not _has_items(cost):
		_show_message("Faltam materiais para a fogueira.")
		return
	_pay_items(cost)
	has_campfire = true
	_show_message("Fogueira montada. O frio da noite será menos intenso.")

func _craft_backpack() -> void:
	if inventory_capacity > 12:
		_show_message("Sua mochila já foi melhorada.")
		return
	var cost := {"Madeira": 4, "Fibra": 5}
	if not _has_items(cost):
		_show_message("Faltam materiais para ampliar a mochila.")
		return
	_pay_items(cost)
	inventory_capacity = 20
	_show_message("Mochila ampliada para 20 espaços.")

func _consume_coconut() -> void:
	if int(inventory.get("Coco", 0)) <= 0:
		_show_message("Você não tem coco.")
		return
	inventory["Coco"] -= 1
	hunger = minf(100.0, hunger + 22.0)
	thirst = minf(100.0, thirst + 12.0)
	_refresh_panels()
	_update_hud()

func _drink_water() -> void:
	if int(inventory.get("Água", 0)) <= 0:
		_show_message("Você não tem água coletada.")
		return
	inventory["Água"] -= 1
	thirst = minf(100.0, thirst + 35.0)
	_refresh_panels()
	_update_hud()

func _toggle_dive() -> void:
	if not is_swimming:
		_show_message("Entre no mar para nadar.")
		return
	is_diving = not is_diving
	_show_message("Mergulho ativado." if is_diving else "Você voltou à superfície.")

func _interact() -> void:
	if nearest_interactable == null or not is_instance_valid(nearest_interactable):
		return
	var kind := str(nearest_interactable.get_meta("kind", ""))
	match kind:
		"spring":
			_add_item("Água", 2)
			_show_message("Você coletou água da fonte.")
		"coconut":
			_add_item("Coco", 1)
			_add_item("Fibra", 1)
			_show_message("Você coletou cocos e fibras.")
		"wood":
			_add_item("Madeira", 2)
			_show_message("Você recolheu madeira à deriva.")
		"fiber":
			_add_item("Fibra", 2)
			_show_message("Você coletou folhas e fibras.")
		"herb":
			_add_item("Ervas", 1)
			_show_message("Você coletou plantas úteis.")
		"shell":
			_add_item("Concha", 1)
			_show_message("Você guardou uma concha.")
		"shelter":
			_add_item("Fibra", 1)
			_show_message("Você encontrou fibras no abrigo.")
	nearest_interactable.queue_free()
	interactables.erase(nearest_interactable)
	nearest_interactable = null
	interaction_button.visible = false
	_refresh_panels()

func _update_interaction() -> void:
	var best: Node3D = null
	var best_distance := 4.0
	for node in interactables:
		if not is_instance_valid(node):
			continue
		var d := player.global_position.distance_to(node.global_position)
		if d < best_distance:
			best = node
			best_distance = d
	nearest_interactable = best
	interaction_button.visible = best != null
	if best != null:
		interaction_button.text = "COLETAR"

func _show_message(text_value: String) -> void:
	if message_label:
		message_label.text = text_value
		notification_time = 3.0

func _pause_to_menu() -> void:
	game_active = false
	if multiplayer.multiplayer_peer:
		multiplayer.multiplayer_peer = null
	_show_main_menu()

func _unhandled_input(event: InputEvent) -> void:
	if not game_active:
		return
	if event is InputEventScreenTouch:
		if event.pressed:
			if event.position.x < get_viewport().get_visible_rect().size.x * 0.48:
				move_finger = event.index
				joy_origin = event.position
				joy_vector = Vector2.ZERO
			else:
				look_finger = event.index
				last_look = event.position
		else:
			if event.index == move_finger:
				move_finger = -1
				joy_vector = Vector2.ZERO
			if event.index == look_finger:
				look_finger = -1
	elif event is InputEventScreenDrag:
		if event.index == move_finger:
			joy_vector = ((event.position - joy_origin) / 70.0).limit_length(1.0)
		elif event.index == look_finger:
			camera_pivot.rotate_y(-event.relative.x * LOOK_SENSITIVITY)
			camera.rotate_x(-event.relative.y * LOOK_SENSITIVITY)
			camera.rotation.x = clampf(camera.rotation.x, deg_to_rad(-65), deg_to_rad(30))
	elif event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		_pause_to_menu()

func _process(delta: float) -> void:
	if not game_active:
		return
	day_time += delta * 0.035
	if day_time >= 24.0:
		day_time = 0.0
		day_number += 1
		weather = "Chuva" if day_number % 3 == 0 else "Ensolarado"
	survival_tick += delta
	if survival_tick >= 1.0:
		survival_tick = 0.0
		_update_survival()
	_update_interaction()
	_update_hud()
	if notification_time > 0.0:
		notification_time -= delta
		if notification_time <= 0.0 and message_label:
			message_label.text = ""

func _physics_process(delta: float) -> void:
	if not game_active or player == null:
		return
	var input_vector := Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	if joy_vector.length() > 0.08:
		input_vector = joy_vector
	var direction := (camera_pivot.global_basis * Vector3(input_vector.x, 0, input_vector.y)).normalized()
	if direction.length() > 0.01:
		var speed := SWIM_SPEED if is_swimming else MOVE_SPEED
		player.velocity.x = direction.x * speed
		player.velocity.z = direction.z * speed
		if player_visual:
			player_visual.rotation.y = atan2(-direction.x, -direction.z)
	else:
		player.velocity.x = move_toward(player.velocity.x, 0.0, MOVE_SPEED * 5.0 * delta)
		player.velocity.z = move_toward(player.velocity.z, 0.0, MOVE_SPEED * 5.0 * delta)
	var distance_from_center := Vector2(player.global_position.x, player.global_position.z).length()
	is_swimming = distance_from_center > WORLD_RADIUS - 1.0
	if is_swimming:
		player.velocity.y = -0.5 if is_diving else 0.0
		player.position.y = move_toward(player.position.y, -0.2 if is_diving else 0.65, delta * 2.0)
	else:
		is_diving = false
		player.velocity.y -= 9.8 * delta
	player.move_and_slide()
	if player.global_position.y < -8:
		player.global_position = Vector3(0, 1.5, 9)
		player.velocity = Vector3.ZERO
		_show_message("Você voltou à costa.")

func _update_survival() -> void:
	hunger = maxf(0.0, hunger - 0.035)
	thirst = maxf(0.0, thirst - 0.06)
	stamina = minf(100.0, stamina + 0.35)
	var hour := int(day_time)
	var night := hour < 6 or hour >= 19
	var target_temp := 36.8
	if night:
		target_temp -= 2.0
	if weather == "Chuva":
		target_temp -= 1.8
	if hour >= 11 and hour <= 15:
		target_temp += 1.0
	if has_shelter and night:
		target_temp += 0.8
	if has_campfire and night:
		target_temp += 1.2
	if cold_clothes:
		target_temp = lerpf(target_temp, 36.8, 0.7)
	body_temperature = move_toward(body_temperature, target_temp, 0.08)
	if is_swimming and is_diving:
		oxygen = maxf(0.0, oxygen - 2.0)
	else:
		oxygen = minf(100.0, oxygen + 4.0)
	if hunger <= 0.0 or thirst <= 0.0 or body_temperature < 34.0 or body_temperature > 39.0 or oxygen <= 0.0:
		health = maxf(0.0, health - 0.5)
	if health <= 0.0:
		_show_message("Você desmaiou. Recomeçando no acampamento.")
		health = 65.0
		hunger = 45.0
		thirst = 45.0
		player.global_position = Vector3(0, 1.5, 9)
		is_diving = false

func _update_hud() -> void:
	if hud_label == null:
		return
	var hour := int(day_time)
	var minute := int((day_time - float(hour)) * 60.0)
	var temp_text := str(snappedf(body_temperature, 0.1)) + "°C"
	var swim_text := "NADANDO" if is_swimming else "EM TERRA"
	if is_diving:
		swim_text = "MERGULHANDO • O2 " + str(int(oxygen)) + "%"
	hud_label.text = "DIA %d  •  %02d:%02d  •  %s\nVIDA %d  FOME %d  SEDE %d  FÔLEGO %d\nTEMPERATURA %s  •  %s  •  %s" % [
		day_number, hour, minute, weather, int(health), int(hunger), int(thirst), int(stamina), temp_text, swim_text,
		("ABRIGADO" if has_shelter else "SEM ABRIGO")
	]
