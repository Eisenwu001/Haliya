class_name GameSettings
extends RefCounted

## GameSettings
## Central persistent configuration for Audio, Video, Accessibility, and Controls.

const SETTINGS_FILE_PATH: String = "user://haliya_settings.cfg"

static var master_volume: float = 0.85
static var music_volume: float = 0.75
static var sfx_volume: float = 0.85
static var screen_shake_intensity: float = 1.0
static var fullscreen: bool = true
static var damage_numbers: bool = true
static var skip_intro: bool = false
static var reduce_motion: bool = false # Freezes background sway, mist drift, and light shafts
static var language: String = "en" # "en" (English), "tl" (Tagalog), "bcl" (Bikol)
static var custom_keybinds: Dictionary = {} # action -> {type: "key"|"joy", code: int}


static func load_settings() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SETTINGS_FILE_PATH) == OK:
		master_volume = float(cfg.get_value("audio", "master", 0.85))
		music_volume = float(cfg.get_value("audio", "music", 0.75))
		sfx_volume = float(cfg.get_value("audio", "sfx", 0.85))
		screen_shake_intensity = float(cfg.get_value("gameplay", "screen_shake", 1.0))
		fullscreen = bool(cfg.get_value("video", "fullscreen", true))
		damage_numbers = bool(cfg.get_value("gameplay", "damage_numbers", true))
		skip_intro = bool(cfg.get_value("gameplay", "skip_intro", false))
		reduce_motion = bool(cfg.get_value("accessibility", "reduce_motion", false))
		language = str(cfg.get_value("language", "lang", "en"))
		
		custom_keybinds.clear()
		if cfg.has_section("controls"):
			for action in cfg.get_section_keys("controls"):
				var raw = cfg.get_value("controls", action)
				if raw is Dictionary:
					custom_keybinds[action] = raw
	else:
		# If no saved config, default to current window state
		fullscreen = (DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN or DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	
	ensure_audio_buses()
	apply_settings()
	apply_keybinds()


static func save_settings() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("audio", "master", master_volume)
	cfg.set_value("audio", "music", music_volume)
	cfg.set_value("audio", "sfx", sfx_volume)
	cfg.set_value("gameplay", "screen_shake", screen_shake_intensity)
	cfg.set_value("video", "fullscreen", fullscreen)
	cfg.set_value("gameplay", "damage_numbers", damage_numbers)
	cfg.set_value("gameplay", "skip_intro", skip_intro)
	cfg.set_value("accessibility", "reduce_motion", reduce_motion)
	cfg.set_value("language", "lang", language)
	
	for action in custom_keybinds.keys():
		cfg.set_value("controls", action, custom_keybinds[action])
		
	cfg.save(SETTINGS_FILE_PATH)


static func apply_keybinds() -> void:
	for action in custom_keybinds.keys():
		if not InputMap.has_action(action):
			InputMap.add_action(action)
		var bind = custom_keybinds[action]
		if not (bind is Dictionary):
			continue
		var b_type = str(bind.get("type", "key"))
		var code = int(bind.get("code", 0))
		
		# Replace matching existing events for this action
		var events_to_remove: Array[InputEvent] = []
		for ev in InputMap.action_get_events(action):
			if b_type == "key" and ev is InputEventKey:
				events_to_remove.append(ev)
			elif b_type == "joy" and ev is InputEventJoypadButton:
				events_to_remove.append(ev)
		for ev in events_to_remove:
			InputMap.action_erase_event(action, ev)
			
		if b_type == "key" and code > 0:
			var new_ev := InputEventKey.new()
			new_ev.physical_keycode = code as Key
			InputMap.action_add_event(action, new_ev)
		elif b_type == "joy" and code >= 0:
			var new_joy := InputEventJoypadButton.new()
			new_joy.button_index = code as JoyButton
			InputMap.action_add_event(action, new_joy)


static func set_custom_bind(action: String, event: InputEvent) -> void:
	if event is InputEventKey:
		custom_keybinds[action] = {"type": "key", "code": int(event.physical_keycode if event.physical_keycode != 0 else event.keycode)}
	elif event is InputEventJoypadButton:
		custom_keybinds[action] = {"type": "joy", "code": int(event.button_index)}
	apply_keybinds()
	save_settings()


static func reset_default_keybinds() -> void:
	custom_keybinds.clear()
	save_settings()
	# Re-initialize player defaults if in tree
	var default_keys = {
		"move_left": [KEY_A, KEY_LEFT],
		"move_right": [KEY_D, KEY_RIGHT],
		"jump": [KEY_SPACE, KEY_W, KEY_UP],
		"run": [KEY_SHIFT],
		"crouch": [KEY_S, KEY_DOWN],
		"guard": [KEY_K],
		"attack": [KEY_J],
		"dodge": [KEY_ALT, KEY_C],
		"interact": [KEY_E]
	}
	var default_joy = {
		"jump": JOY_BUTTON_A,
		"attack": JOY_BUTTON_X,
		"guard": JOY_BUTTON_B,
		"dodge": JOY_BUTTON_Y,
		"run": JOY_BUTTON_LEFT_SHOULDER,
		"move_left": JOY_BUTTON_DPAD_LEFT,
		"move_right": JOY_BUTTON_DPAD_RIGHT,
		"crouch": JOY_BUTTON_DPAD_DOWN,
		"interact": JOY_BUTTON_Y
	}
	for act in default_keys.keys():
		if InputMap.has_action(act):
			InputMap.action_erase_events(act)
		else:
			InputMap.add_action(act)
		for k in default_keys[act]:
			var ev := InputEventKey.new()
			ev.physical_keycode = k as Key
			InputMap.action_add_event(act, ev)
		if default_joy.has(act):
			var jev := InputEventJoypadButton.new()
			jev.button_index = default_joy[act]
			InputMap.action_add_event(act, jev)


static func get_bound_display_text(action: String) -> String:
	if not InputMap.has_action(action):
		return "None"
	var events = InputMap.action_get_events(action)
	var key_labels: Array[String] = []
	var joy_labels: Array[String] = []
	var mouse_labels: Array[String] = []
	for ev in events:
		if ev is InputEventKey:
			var code = ev.physical_keycode if ev.physical_keycode != 0 else ev.keycode
			key_labels.append(OS.get_keycode_string(code))
		elif ev is InputEventJoypadButton:
			joy_labels.append(_get_joy_button_name(ev.button_index))
		elif ev is InputEventMouseButton:
			mouse_labels.append("LMB" if ev.button_index == MOUSE_BUTTON_LEFT else ("RMB" if ev.button_index == MOUSE_BUTTON_RIGHT else "MB"))
	var combined: Array[String] = []
	if not key_labels.is_empty():
		combined.append(key_labels[0])
	if not joy_labels.is_empty():
		combined.append(joy_labels[0])
	if combined.is_empty() and not mouse_labels.is_empty():
		combined.append(mouse_labels[0])
	if combined.is_empty():
		return "Unbound"
	return " / ".join(combined)


static func _get_joy_button_name(btn: JoyButton) -> String:
	match btn:
		JOY_BUTTON_A: return "Pad A"
		JOY_BUTTON_B: return "Pad B"
		JOY_BUTTON_X: return "Pad X"
		JOY_BUTTON_Y: return "Pad Y"
		JOY_BUTTON_LEFT_SHOULDER: return "LB/L1"
		JOY_BUTTON_RIGHT_SHOULDER: return "RB/R1"
		JOY_BUTTON_DPAD_UP: return "D-Up"
		JOY_BUTTON_DPAD_DOWN: return "D-Down"
		JOY_BUTTON_DPAD_LEFT: return "D-Left"
		JOY_BUTTON_DPAD_RIGHT: return "D-Right"
		_: return "Pad %d" % btn


static func ensure_audio_buses() -> void:
	if AudioServer.get_bus_index("Music") == -1:
		AudioServer.add_bus()
		var m_idx = AudioServer.bus_count - 1
		AudioServer.set_bus_name(m_idx, "Music")
		AudioServer.set_bus_send(m_idx, "Master")
	
	if AudioServer.get_bus_index("SFX") == -1:
		AudioServer.add_bus()
		var s_idx = AudioServer.bus_count - 1
		AudioServer.set_bus_name(s_idx, "SFX")
		AudioServer.set_bus_send(s_idx, "Master")


static func apply_settings() -> void:
	ensure_audio_buses()
	
	# 1. Master Volume
	var master_idx = AudioServer.get_bus_index("Master")
	if master_idx >= 0:
		AudioServer.set_bus_volume_db(master_idx, linear_to_db(clampf(master_volume, 0.001, 1.0)))
		AudioServer.set_bus_mute(master_idx, master_volume <= 0.01)
	
	# 2. Music Volume
	var music_idx = AudioServer.get_bus_index("Music")
	if music_idx >= 0:
		AudioServer.set_bus_volume_db(music_idx, linear_to_db(clampf(music_volume, 0.001, 1.0)))
		AudioServer.set_bus_mute(music_idx, music_volume <= 0.01)
	
	# 3. SFX Volume
	var sfx_idx = AudioServer.get_bus_index("SFX")
	if sfx_idx >= 0:
		AudioServer.set_bus_volume_db(sfx_idx, linear_to_db(clampf(sfx_volume, 0.001, 1.0)))
		AudioServer.set_bus_mute(sfx_idx, sfx_volume <= 0.01)
	
	# 4. Window title & Fullscreen
	DisplayServer.window_set_title("Haliya: Mask of Sorrows")
	var is_current_fs = (DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN or DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	if fullscreen and not is_current_fs:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	elif not fullscreen and is_current_fs:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
