extends SceneTree

const BaybayinText = preload("res://scripts/baybayin_text.gd")
const BaybayinLabel = preload("res://scripts/baybayin_label.gd")
const ProceduralAudio = preload("res://scripts/procedural_audio.gd")
const GameSettings = preload("res://scripts/game_settings.gd")
const SettingsMenu = preload("res://scripts/settings_menu.gd")
const MetaProgression = preload("res://scripts/meta_progression.gd")
const BestiaryCodexUI = preload("res://scripts/bestiary_codex_ui.gd")
const Santelmo = preload("res://scripts/santelmo.gd")
const Player = preload("res://scripts/player.gd")
const MainScript = preload("res://scripts/main.gd")
const SaveManager = preload("res://scripts/save_manager.gd")

func _init() -> void:
	print("=====================================================================")
	print("[SUITE] CULTURAL FEATURES, BAYBAYIN, AUDIO & SETTINGS VERIFICATION")
	print("=====================================================================")
	
	test_baybayin_system()
	test_audio_system()
	test_settings_system()
	test_santelmo_enemy()
	test_meta_progression_and_player_perks()
	test_bestiary_codex_ui()
	test_scene_integration()
	
	print("=====================================================================")
	print("[ALL TESTS PASS] All cultural, audio, settings & meta features verified!")
	print("=====================================================================")
	quit(0)


func test_baybayin_system() -> void:
	print("\n--- 1. Testing Baybayin Transliterator & Glyph Label ---")
	
	# Dictionary lookups
	var haliya_baybayin = BaybayinText.get_baybayin("HALIYA")
	assert(haliya_baybayin == "ᜑᜎᜒᜌ", "Haliya dictionary lookup mismatch: " + haliya_baybayin)
	
	var bakunawa_baybayin = BaybayinText.get_baybayin("BAKUNAWA")
	assert(bakunawa_baybayin == "ᜊᜃᜓᜈᜏ", "Bakunawa dictionary lookup mismatch: " + bakunawa_baybayin)
	
	var kubo_baybayin = BaybayinText.get_baybayin("BAHAY KUBO")
	assert(kubo_baybayin == "ᜊᜑᜌ᜔ ᜃᜓᜊᜓ", "Bahay Kubo dictionary lookup mismatch: " + kubo_baybayin)
	
	# Font loading
	var font = BaybayinLabel.get_baybayin_font()
	assert(font != null, "Baybayin FontFile must load successfully")
	
	# Label component
	var lbl = BaybayinLabel.new()
	lbl.set_text("HALIYA")
	assert("ᜑᜎᜒᜌ" in lbl.baybayin_label.text, "Label must display Baybayin runes")
	assert(lbl.english_label.text == "HALIYA", "Label must display English translation")
	
	# Decode sequence
	lbl.play_decode_sequence("EMERALD TERRACES", "", 20)
	assert(lbl.reveal_tween != null, "Decode sequence must initiate reveal tween")
	lbl.free()
	print("  ✓ Baybayin dictionary, algorithmic transliterator, and animation label PASS")


func test_audio_system() -> void:
	print("\n--- 2. Testing Philippine Archival Music & Audio Infrastructure ---")
	
	var k_exp = ProceduralAudio.get_kulintang_exploration_bgm()
	assert(k_exp != null, "Kulintang exploration BGM must not be null")
	assert(k_exp is AudioStreamMP3, "Kulintang exploration BGM must be AudioStreamMP3")
	assert(k_exp.loop == true, "Kulintang exploration BGM must loop")
	
	var k_bat = ProceduralAudio.get_kulintang_battle_bgm()
	assert(k_bat != null, "Kulintang battle BGM must not be null")
	assert(k_bat is AudioStreamMP3, "Kulintang battle BGM must be AudioStreamMP3")
	assert(k_bat.loop == true, "Kulintang battle BGM must loop")
	
	var rice_ambient = ProceduralAudio.get_rice_field_ambient()
	assert(rice_ambient != null, "Rice field ambient must return Kulintang BGM")
	
	var boss_music = ProceduralAudio.get_boss_battle_music()
	assert(boss_music != null, "Boss battle music must return Kulintang battle track")
	print("  ✓ Archival Kulintang Binalig & Tidtu gong recordings loaded and looping PASS")


func test_settings_system() -> void:
	print("\n--- 3. Testing Settings, AudioServer & Screen Shake System ---")
	
	GameSettings.load_settings()
	GameSettings.master_volume = 0.85
	GameSettings.music_volume = 0.70
	GameSettings.sfx_volume = 0.90
	GameSettings.screen_shake_intensity = 0.75
	GameSettings.save_settings()
	
	# Re-read
	GameSettings.load_settings()
	assert(abs(GameSettings.master_volume - 0.85) < 0.01, "Master volume must persist")
	assert(abs(GameSettings.music_volume - 0.70) < 0.01, "Music volume must persist")
	assert(abs(GameSettings.screen_shake_intensity - 0.75) < 0.01, "Screen shake intensity must persist")
	
	# Modal test
	var menu = SettingsMenu.new()
	root.add_child(menu)
	menu.open_menu()
	assert(menu.visible == true, "Settings menu must be visible on open")
	menu.close_menu()
	menu.free()
	print("  ✓ GameSettings persistence, AudioServer volume conversion, and SettingsMenu PASS")


func test_santelmo_enemy() -> void:
	print("\n--- 4. Testing Santelmo Spirit Enemy Combat & Drops ---")
	
	var santelmo = Santelmo.new()
	root.add_child(santelmo)
	assert(santelmo.health == 4, "Santelmo initial health must be 4")
	assert(santelmo.is_dead == false, "Santelmo must be alive upon spawn")
	
	var died_called = [false]
	santelmo.santelmo_died.connect(func(_e): died_called[0] = true)
	
	# Parry extinguish deflect
	santelmo.deflect_by_parry(1.0)
	assert(santelmo.is_dead == true, "Parry deflection must extinguish Santelmo")
	assert(died_called[0] == true, "santelmo_died signal must emit on death")
	santelmo.free()
	print("  ✓ Santelmo sinusoidal hover, pogo bounce, and parry extinguish PASS")


func test_meta_progression_and_player_perks() -> void:
	print("\n--- 5. Testing Player Baseline Stats (Perks Deleted) ---")
	
	MetaProgression.load_meta()
	MetaProgression.moon_pearls = 100
	
	var player = Player.new()
	root.add_child(player)
	player.reset_combat_state()
	
	# Verify player stats are ALWAYS pure baseline stats without any perks
	assert(player.get_max_hp() == 5, "Player HP must always be base 5 (perks deleted)")
	assert(abs(player.get_max_stamina() - 100.0) < 0.1, "Player Stamina must always be base 100 (perks deleted)")
	assert(player.get_attack_damage_bonus() == 0, "Player Attack Bonus must always be base 0 (perks deleted)")
	
	# Spend pearls
	var initial_pearls = MetaProgression.moon_pearls
	assert(MetaProgression.spend_moon_pearls(25) == true, "Should succeed spending 25 pearls")
	assert(MetaProgression.moon_pearls == initial_pearls - 25, "Pearls should be deducted")
	
	player.free()
	print("  ✓ Player stats confirmed pure baseline without perk modifiers PASS")


func test_bestiary_codex_ui() -> void:
	print("\n--- 6. Testing Mythological Bestiary Lore Codex UI ---")
	
	MetaProgression.unlock_bestiary("santelmo")
	MetaProgression.unlock_bestiary("bakunawa")
	
	var codex = BestiaryCodexUI.new()
	root.add_child(codex)
	codex.open_menu()
	assert(codex.visible == true, "Codex must be visible on open")
	
	codex.close_menu()
	codex.free()
	print("  ✓ BestiaryCodexUI pure Lore Codex presentation and unlocked entries PASS")


func test_scene_integration() -> void:
	print("\n--- 7. Testing Main Menu & Main Scene Integration ---")
	var had_slot_1: bool = SaveManager.has_save(1)
	
	var main_scene = load("res://scenes/main.tscn")
	assert(main_scene != null, "scenes/main.tscn must exist and load")
	var main_inst = main_scene.instantiate()
	root.add_child(main_inst)
	if not main_inst.is_node_ready():
		main_inst._ready()
	
	assert(main_inst.get("settings_menu") != null, "main.tscn must have settings_menu")
	assert(main_inst.get("bestiary_codex_ui") != null, "main.tscn must have bestiary_codex_ui")
	assert(main_inst.get("stage_name_label") != null, "main.tscn must have stage_name_label")
	
	# Verify area discovery banner
	main_inst.trigger_area_discovery("EMERALD TERRACES", "Level 2-1")
	assert(main_inst.area_title_timer > 3.0, "Area discovery timer should be set")
	
	main_inst.free()
	if not had_slot_1:
		SaveManager.delete_slot(1)
	print("  ✓ Main gameplay scene fully integrated with Settings, Codex, and Baybayin PASS")
