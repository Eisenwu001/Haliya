class_name SaveManager
extends RefCounted

## SaveManager
## Manages robust, multi-slot JSON game saves (Slots 1, 2, 3), run state preservation,
## and version migration according to Godot standards.

const SAVE_VERSION: int = 1
const DEFAULT_SLOT_COUNT: int = 3
const SAVE_FILE_TEMPLATE: String = "user://haliya_save_slot_%d.json"

static var active_slot: int = 1
static var active_run_play_time: float = 0.0

signal save_started
signal save_completed(success: bool)

static func get_save_path(slot: int = -1) -> String:
	var s = active_slot if slot <= 0 else slot
	return SAVE_FILE_TEMPLATE % clampi(s, 1, DEFAULT_SLOT_COUNT)

static func has_save(slot: int = -1) -> bool:
	var path = get_save_path(slot)
	return FileAccess.file_exists(path)

static func get_slot_metadata(slot: int) -> Dictionary:
	var path = get_save_path(slot)
	if not FileAccess.file_exists(path):
		return {"exists": false, "slot": slot}

	var file = FileAccess.open(path, FileAccess.READ)
	if not file:
		return {"exists": false, "slot": slot}

	var json_str = file.get_as_text()
	file.close()

	var parsed = JSON.parse_string(json_str)
	if typeof(parsed) != TYPE_DICTIONARY:
		return {"exists": false, "slot": slot}

	var data: Dictionary = parsed
	return {
		"exists": true,
		"slot": slot,
		"version": data.get("version", 1),
		"level_idx": data.get("level_idx", 0),
		"highest_level_idx": data.get("highest_level_idx", 0),
		"stage_title": data.get("stage_title", "Forest Outskirts"),
		"date_string": data.get("date_string", ""),
		"play_time_seconds": data.get("play_time_seconds", 0.0),
		"moon_pearls": data.get("progression", {}).get("moon_pearls", 0),
		"upgrades_count": data.get("progression", {}).get("active_upgrades", {}).size(),
		"current_hp": data.get("player", {}).get("hp", 5),
		"current_armor": data.get("player", {}).get("armor", 3)
	}

static func save_game(slot: int = -1, main_node: Node = null) -> bool:
	var target_slot = active_slot if slot <= 0 else slot
	var path = get_save_path(target_slot)

	var dir_path = "user://"
	if not DirAccess.dir_exists_absolute(dir_path):
		DirAccess.make_dir_recursive_absolute(dir_path)

	var time_dict = Time.get_datetime_dict_from_system()
	var date_str = "%04d-%02d-%02d %02d:%02d" % [
		time_dict.year, time_dict.month, time_dict.day,
		time_dict.hour, time_dict.minute
	]

	var lvl_idx: int = 0
	var highest_lvl: int = 0
	var stage_name: String = "Level 1-1: Forest Canopy"
	var player_hp: int = 5
	var player_armor: int = 3
	var has_checkpoint: bool = false
	var a_kills_val: int = 0
	var s_kills_val: int = 0
	var score: int = 0

	if is_instance_valid(main_node):
		lvl_idx = int(main_node.get("current_level_idx")) if main_node.get("current_level_idx") != null else 0
		has_checkpoint = true if main_node.get("has_activated_boss_checkpoint") else false
		var a_kills = main_node.get("aswang_kills")
		var s_kills = main_node.get("skeleton_kills")
		a_kills_val = int(a_kills) if a_kills != null else 0
		s_kills_val = int(s_kills) if s_kills != null else 0
		score = a_kills_val + s_kills_val
		var player = main_node.get("player")
		if is_instance_valid(player):
			player_hp = player.current_hp
			player_armor = player.current_armor
		
		# Pull stage name from MainScript LEVELS_DATA if available
		var levels_data = main_node.get("LEVELS_DATA")
		if levels_data is Array and lvl_idx < levels_data.size():
			stage_name = levels_data[lvl_idx].get("full_title", stage_name)

	# Read existing highest level from meta or previous save
	var existing = get_slot_metadata(target_slot)
	if existing.get("exists", false):
		highest_lvl = maxi(int(existing.get("highest_level_idx", 0)), lvl_idx)
	else:
		highest_lvl = lvl_idx

	var save_dict: Dictionary = {
		"version": SAVE_VERSION,
		"slot": target_slot,
		"timestamp": Time.get_unix_time_from_system(),
		"date_string": date_str,
		"play_time_seconds": active_run_play_time,
		"level_idx": lvl_idx,
		"highest_level_idx": highest_lvl,
		"stage_title": stage_name,
		"player": {
			"hp": player_hp,
			"armor": player_armor,
			"has_boss_checkpoint": has_checkpoint
		},
		"progression": {
			"active_upgrades": UpgradeManager.active_upgrades.duplicate(true),
			"current_tier": UpgradeManager.current_tier,
			"loop_count": UpgradeManager.loop_count,
			"total_kills": UpgradeManager.total_kills_this_run,
			"levels_cleared": UpgradeManager.levels_cleared_this_run,
			"aswang_kills": a_kills_val,
			"skeleton_kills": s_kills_val,
			"score": score,
			"moon_pearls": MetaProgression.moon_pearls
		}
	}

	var json_str = JSON.stringify(save_dict, "\t")
	var file = FileAccess.open(path, FileAccess.WRITE)
	if not file:
		printerr("[SaveManager] Error opening save file for write: %s (Error: %d)" % [path, FileAccess.get_open_error()])
		return false

	file.store_string(json_str)
	file.close()
	print("[SaveManager] Successfully saved game to slot %d at %s" % [target_slot, path])
	return true

static func load_game(slot: int = -1) -> Dictionary:
	var target_slot = active_slot if slot <= 0 else slot
	var path = get_save_path(target_slot)

	if not FileAccess.file_exists(path):
		printerr("[SaveManager] Save file does not exist: %s" % path)
		return {}

	var file = FileAccess.open(path, FileAccess.READ)
	if not file:
		printerr("[SaveManager] Error opening save file for read: %s" % path)
		return {}

	var json_str = file.get_as_text()
	file.close()

	var parsed = JSON.parse_string(json_str)
	if typeof(parsed) != TYPE_DICTIONARY:
		printerr("[SaveManager] Failed to parse JSON save file: %s" % path)
		return {}

	var data: Dictionary = parsed
	data = _migrate_save_if_needed(data)
	return data

static func apply_loaded_game_to_run(data: Dictionary, main_node: Node) -> bool:
	if data.is_empty() or not is_instance_valid(main_node):
		return false

	active_run_play_time = float(data.get("play_time_seconds", 0.0))
	var lvl_idx = int(data.get("level_idx", 0))
	main_node.set("current_level_idx", lvl_idx)

	var prog = data.get("progression", {})
	if prog is Dictionary:
		UpgradeManager.active_upgrades = prog.get("active_upgrades", {}).duplicate(true)
		UpgradeManager.current_tier = int(prog.get("current_tier", 1))
		UpgradeManager.loop_count = int(prog.get("loop_count", 1))
		UpgradeManager.total_kills_this_run = int(prog.get("total_kills", 0))
		UpgradeManager.levels_cleared_this_run = int(prog.get("levels_cleared", 0))
		var saved_a_kills = int(prog.get("aswang_kills", prog.get("score", 0)))
		var saved_s_kills = int(prog.get("skeleton_kills", 0))
		main_node.set("aswang_kills", saved_a_kills)
		main_node.set("skeleton_kills", saved_s_kills)
		MetaProgression.moon_pearls = int(prog.get("moon_pearls", MetaProgression.moon_pearls))
		if main_node.has_method("update_score_hud"):
			main_node.update_score_hud()

	var player_data = data.get("player", {})
	if player_data is Dictionary:
		main_node.set("has_activated_boss_checkpoint", true if player_data.get("has_boss_checkpoint", false) else false)
		var player = main_node.get("player")
		if is_instance_valid(player):
			UpgradeManager.sync_player_stats(player)
			player.current_hp = clampi(int(player_data.get("hp", player.get_max_hp())), 1, player.get_max_hp())
			player.current_armor = clampi(int(player_data.get("armor", player.get_max_armor())), 0, player.get_max_armor())
			player.hp_changed.emit(player.current_hp, player.get_max_hp())
			player.armor_changed.emit(player.current_armor, player.get_max_armor())

	print("[SaveManager] Restored run: Stage %d, HP %d, Upgrades %d" % [
		lvl_idx,
		player_data.get("hp", 5) if player_data is Dictionary else 5,
		UpgradeManager.active_upgrades.size()
	])
	return true

static func delete_slot(slot: int) -> bool:
	var path = get_save_path(slot)
	if FileAccess.file_exists(path):
		var err = DirAccess.remove_absolute(path)
		return err == OK
	return false

static func _migrate_save_if_needed(data: Dictionary) -> Dictionary:
	var ver = int(data.get("version", 0))
	if ver < 1:
		# Migration from version 0
		data["version"] = 1
	return data
