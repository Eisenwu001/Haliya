with open("scripts/procedural_audio.gd", "r", encoding="utf-8") as f:
    code = f.read()

nl = "\r\n" if "\r\n" in code else "\n"
code = code.replace("\r\n", "\n")

# Add static streams at top
target_vars = "static var _forest_music: AudioStream = null\n"
repl_vars = """static var _forest_music: AudioStream = null
static var _kulintang_stream: AudioStreamMP3 = null
static var _battle_stream: AudioStreamMP3 = null

static func get_kulintang_exploration_bgm() -> AudioStream:
	if _kulintang_stream != null:
		return _kulintang_stream
	if FileAccess.file_exists("res://assets/audio/music/kulintang_exploration.mp3"):
		var bytes = FileAccess.get_file_as_bytes("res://assets/audio/music/kulintang_exploration.mp3")
		if bytes.size() > 0:
			_kulintang_stream = AudioStreamMP3.new()
			_kulintang_stream.data = bytes
			_kulintang_stream.loop = true
			return _kulintang_stream
	return get_forest_ambient()

static func get_kulintang_battle_bgm() -> AudioStream:
	if _battle_stream != null:
		return _battle_stream
	if FileAccess.file_exists("res://assets/audio/music/kulintang_battle.mp3"):
		var bytes = FileAccess.get_file_as_bytes("res://assets/audio/music/kulintang_battle.mp3")
		if bytes.size() > 0:
			_battle_stream = AudioStreamMP3.new()
			_battle_stream.data = bytes
			_battle_stream.loop = true
			return _battle_stream
	return get_kulintang_exploration_bgm()
"""
assert target_vars in code, "target_vars not found"
code = code.replace(target_vars, repl_vars, 1)

# Hook into get_rice_field_ambient
target_rf = """static func get_rice_field_ambient() -> AudioStream:
	if _rice_field_music != null:
		return _rice_field_music"""

repl_rf = """static func get_rice_field_ambient() -> AudioStream:
	var k_bgm = get_kulintang_exploration_bgm()
	if k_bgm != null:
		return k_bgm
	if _rice_field_music != null:
		return _rice_field_music"""

assert target_rf in code, "target_rf not found"
code = code.replace(target_rf, repl_rf, 1)

# Hook into get_boss_battle_music
target_boss = """static func get_boss_battle_music() -> AudioStream:
	if _boss_music != null:
		return _boss_music"""

repl_boss = """static func get_boss_battle_music() -> AudioStream:
	var b_bgm = get_kulintang_battle_bgm()
	if b_bgm != null:
		return b_bgm
	if _boss_music != null:
		return _boss_music"""

assert target_boss in code, "target_boss not found"
code = code.replace(target_boss, repl_boss, 1)

# Hook into get_bakunawa_theme
target_baku = """static func get_bakunawa_theme() -> AudioStream:
	if _bakunawa_music != null:
		return _bakunawa_music"""

repl_baku = """static func get_bakunawa_theme() -> AudioStream:
	var b_bgm = get_kulintang_battle_bgm()
	if b_bgm != null:
		return b_bgm
	if _bakunawa_music != null:
		return _bakunawa_music"""

assert target_baku in code, "target_baku not found"
code = code.replace(target_baku, repl_baku, 1)

code = code.replace("\n", nl)
with open("scripts/procedural_audio.gd", "w", encoding="utf-8") as f:
    f.write(code)

print("procedural_audio.gd patched successfully!")
