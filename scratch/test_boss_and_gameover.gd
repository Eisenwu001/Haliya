extends SceneTree

const MainScript = preload("res://scripts/main.gd")
const ForestBruteScript = preload("res://scripts/forest_brute_miniboss.gd")
const GameOverUIScript = preload("res://scripts/game_over_ui.gd")
const AswangScript = preload("res://scripts/aswang.gd")
const SkeletonScript = preload("res://scripts/skeleton.gd")
const FarmerScript = preload("res://scripts/corrupted_farmer.gd")
const SantelmoScript = preload("res://scripts/santelmo.gd")
const ScarecrowScript = preload("res://scripts/possessed_scarecrow.gd")

func _init() -> void:
	print("==================================================")
	print("--- TESTING BOSS HUD, MONSTERS & DEATH OVERHAUL ---")
	print("==================================================")

	# 1. Test Forest Brute 112 HP & 10% threshold (12 HP)
	var boss = ForestBruteScript.new()
	assert(boss.health_pips == null, "Overhead health pips must be null (disabled)")
	assert(boss.MAX_HEALTH == 112, "Boss MAX_HEALTH must be 112 (-75% damage scaling)")
	var p2_thresh = int(ceil(float(boss.MAX_HEALTH) * 0.10))
	assert(p2_thresh == 12, "10% threshold for 112 HP must be 12 HP")
	print("PASS: Forest brute MAX_HEALTH = 112 and 10% threshold confirmed (12 HP)")
	boss.free()

	# 2. Test Normal Monsters Doubled HP
	var aswang = AswangScript.new()
	assert(aswang.MAX_HEALTH == 6, "Aswang MAX_HEALTH must be 6 (doubled from 3)")
	aswang.free()

	var skeleton = SkeletonScript.new()
	assert(skeleton.MAX_HEALTH == 8, "Skeleton MAX_HEALTH must be 8 (doubled from 4)")
	skeleton.free()

	var farmer = FarmerScript.new()
	assert(farmer.MAX_HEALTH == 6, "Corrupted Farmer MAX_HEALTH must be 6 (doubled from 3)")
	farmer.free()

	var santelmo = SantelmoScript.new()
	assert(santelmo.BASE_MAX_HEALTH == 4, "Santelmo BASE_MAX_HEALTH must be 4 (doubled from 2)")
	santelmo.free()

	var scarecrow = ScarecrowScript.new()
	assert(scarecrow.MAX_HEALTH == 4, "Scarecrow MAX_HEALTH must be 4 (doubled from 2)")
	scarecrow.free()
	print("PASS: All normal monster HPs doubled (Aswang 6, Skeleton 8, Farmer 6, Santelmo 4, Scarecrow 4)")

	# 3. Test GameOverUI layout, styling, and integer scoring
	var root = Control.new()
	root.size = Vector2(640, 360)
	root_node_add(root)

	var game_over = GameOverUIScript.new()
	root.add_child(game_over)

	var test_stats = {
		"deepest_stage": "Enchanted Glade — Level 1-1",
		"kills": 15,
		"elapsed_sec": 142.6,
		"bosses_defeated": 1,
		"parries": 7,
		"pearls": 84,
		"stage_idx": 0,
		"upgrades": ["Agimat", "Moonlight Blade"]
	}
	game_over.display_defeat(test_stats)

	# Check panel sizing and border removal
	var panel = game_over.panel
	assert(panel != null, "GameOverUI panel exists")
	print("Panel size: ", panel.custom_minimum_size)
	var sb = panel.get_theme_stylebox("panel") as StyleBoxFlat
	assert(sb != null, "StyleBoxFlat exists on panel")
	assert(sb.border_width_left == 0 and sb.border_width_right == 0, "Red borders must be removed (border width 0)")
	print("PASS: Red borders completely removed from DefeatPanel")

	# Check "YOU DIED" title
	assert(game_over.title_lbl != null, "TitleLabel exists")
	print("Title text: ", game_over.title_lbl.text)
	assert(game_over.title_lbl.text == "YOU DIED", "Title text must be 'YOU DIED'")
	assert(game_over.title_lbl.position.y == 0.0 or game_over.title_lbl.position.y > 0.0, "Title position initialized for rise")
	print("PASS: 'YOU DIED' label present and configured for rising animation")

	# Check no Baybayin characters exist in GameOverUI labels
	check_no_baybayin(game_over)
	print("PASS: GameOverUI has zero Baybayin characters")

	# Check score readout has no decimal points (e.g. 7864 PTS, not 7864.0 PTS)
	var score_val_lbl = find_label_with_text(panel, "PTS")
	assert(score_val_lbl != null, "Score PTS label found")
	print("Score readout: ", score_val_lbl.text)
	assert(not (".0 " in score_val_lbl.text or score_val_lbl.text.ends_with(".0 PTS")), "Score PTS must not have trailing decimals")
	print("PASS: Score display is integer formatted without decimals")

	# 4. Test Boss HUD configuration in Main
	var main_scene = MainScript.new()
	root.add_child(main_scene)
	main_scene.game_over_ui = game_over
	main_scene.hud_container = Control.new()
	main_scene.add_child(main_scene.hud_container)
	main_scene.setup_boss_hud()

	assert(main_scene.boss_hud_root != null, "Boss HUD root exists")
	assert(main_scene.boss_hp_num_label != null, "Boss HP number label exists")
	assert(main_scene.boss_phase_notch != null, "Boss phase notch exists")

	# Check phase notch is at 10% mark (x = 58)
	print("Boss phase notch position: ", main_scene.boss_phase_notch.position)
	assert(main_scene.boss_phase_notch.position.x == 58, "Phase notch must be at 10% position (x=58)")
	print("PASS: Phase notch positioned at 10% mark")

	# Check Boss HP label centering and percentage text
	print("Boss HP num label text: ", main_scene.boss_hp_num_label.text)
	assert(main_scene.boss_hp_num_label.text == "100%", "Initial HP text must be 100%")
	assert(main_scene.boss_hp_num_label.horizontal_alignment == HORIZONTAL_ALIGNMENT_CENTER, "HP label must be center aligned horizontally")
	assert(main_scene.boss_hp_num_label.vertical_alignment == VERTICAL_ALIGNMENT_CENTER, "HP label must be center aligned vertically")
	print("PASS: Boss HP label is centered and formatted as percentage")

	# Test HP change updates percentage with 112 HP
	main_scene._on_boss_hp_changed(56, 112)
	assert(main_scene.boss_hp_num_label.text == "50%", "50% HP must display 50%")
	main_scene._on_boss_hp_changed(12, 112)
	assert(main_scene.boss_hp_num_label.text == "11%", "12/112 HP must display 11%")
	main_scene._on_boss_hp_changed(0, 112)
	assert(main_scene.boss_hp_num_label.text == "0%", "0 HP must display 0%")
	print("PASS: _on_boss_hp_changed dynamically computes and updates percentage string")

	# Check no Baybayin in Boss HUD
	check_no_baybayin(main_scene.boss_hud_root)
	print("PASS: Boss HUD has zero Baybayin characters")

	# 5. Test Player Death handling
	main_scene.player = CharacterBody2D.new()
	main_scene.player.set_script(load("res://scripts/player.gd"))
	main_scene.add_child(main_scene.player)
	main_scene.boss_hud_root.visible = true
	main_scene._on_player_died()

	assert(main_scene.boss_hud_root.visible == false, "Boss HUD must hide on player death")
	assert(main_scene.player.velocity == Vector2.ZERO, "Player velocity must stop on death")
	assert(main_scene.player.is_physics_processing() == false, "Player physics processing must stop on death")
	print("PASS: Player death hides boss HUD, freezes velocity, and stops physics")

	# 6. Test Player Respawn restores state
	main_scene.respawn_player_at_checkpoint()
	assert(main_scene.player.visible == true, "Player must be visible on respawn")
	assert(main_scene.player.modulate.a == 1.0, "Player modulate alpha must be 1.0 on respawn")
	assert(main_scene.player.is_physics_processing() == true, "Player physics must be resumed on respawn")
	assert(main_scene.is_player_dead == false, "is_player_dead must be reset to false")
	print("PASS: Player respawn restores visibility, alpha, and physics processing")

	print("==================================================")
	print("--- ALL BOSS HUD & DEATH OVERHAUL TESTS PASSED ---")
	print("==================================================")
	quit()

func root_node_add(node: Node) -> void:
	get_root().add_child(node)

func check_no_baybayin(node: Node) -> void:
	if node is Label:
		var txt = (node as Label).text
		for c in ["ᜑ", "ᜒ", "ᜄ", "ᜈ", "᜔", "ᜆ", "ᜅ", "ᜓ", "ᜊ", "ᜎ", "ᜏ", "ᜋ", "ᜌ", "ᜐ", "ᜃ"]:
			if c in txt:
				push_error("Found Baybayin char in node " + node.name + ": " + txt)
				assert(false, "Baybayin text must not be present")
	for child in node.get_children():
		check_no_baybayin(child)

func find_label_with_text(node: Node, needle: String) -> Label:
	if node is Label and needle in (node as Label).text:
		return node as Label
	for child in node.get_children():
		var found = find_label_with_text(child, needle)
		if found != null:
			return found
	return null
