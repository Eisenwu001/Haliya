class_name ProceduralAudio
extends RefCounted

## Audio Manager & Dynamic Sfx Engine
## Loads studio WAV samples from res://assets/audio/sfx/ with procedural fallbacks

const PATH_SFX_GRASS_1 = "res://assets/audio/sfx/grass_step_1.wav"
const PATH_SFX_GRASS_2 = "res://assets/audio/sfx/grass_step_2.wav"
const PATH_SFX_GRASS_3 = "res://assets/audio/sfx/grass_step_3.wav"
const PATH_SFX_GRASS_4 = "res://assets/audio/sfx/grass_step_4.wav"

const PATH_SFX_WOOD_1 = "res://assets/audio/sfx/wood_step_1.wav"
const PATH_SFX_WOOD_2 = "res://assets/audio/sfx/wood_step_2.wav"
const PATH_SFX_LAND_SOIL = "res://assets/audio/sfx/land_soil.wav"

const PATH_SFX_SWING_LIGHT_1 = "res://assets/audio/sfx/swing_light_1.wav"
const PATH_SFX_SWING_LIGHT_2 = "res://assets/audio/sfx/swing_light_2.wav"
const PATH_SFX_SWING_HEAVY = "res://assets/audio/sfx/swing_heavy.wav"

const PATH_SFX_HIT_SLASH_1 = "res://assets/audio/sfx/hit_slash_1.wav"
const PATH_SFX_HIT_SLASH_2 = "res://assets/audio/sfx/hit_slash_2.wav"
const PATH_SFX_HIT_CRITICAL = "res://assets/audio/sfx/hit_critical.wav"
const PATH_SFX_KICK_LAUNCH = "res://assets/audio/sfx/kick_launch.wav"
const PATH_SFX_KICK_HIT = "res://assets/audio/sfx/kick_hit.wav"
const PATH_SFX_POT_SMASH = "res://assets/audio/sfx/pot_smash.wav"

const PATH_AMBIENT_FOREST_WIND = "res://assets/audio/ambient/forest_canopy_wind_loop.wav"
const PATH_SFX_BIRD_1 = "res://assets/audio/sfx/bird_robin_chirp_1.wav"
const PATH_SFX_BIRD_2 = "res://assets/audio/sfx/bird_robin_chirp_2.wav"
const PATH_SFX_BIRD_3 = "res://assets/audio/sfx/bird_songbird_trill.wav"
const PATH_SFX_BIRD_4 = "res://assets/audio/sfx/bird_distant_flute.wav"

static var _grass_steps: Array[AudioStream] = []
static var _wood_steps: Array[AudioStream] = []
static var _land_soil: AudioStream = null

static var _swing_lights: Array[AudioStream] = []
static var _swing_heavy: AudioStream = null

static var _hit_slashes: Array[AudioStream] = []
static var _hit_critical: AudioStream = null
static var _kick_launch: AudioStream = null
static var _kick_hit: AudioStream = null
static var _pot_smash: AudioStream = null
static var _bird_chirps: Array[AudioStream] = []

# Background music & specialty procedural sound caches
static var _menu_music: AudioStream = null
static var _forest_music: AudioStream = null
static var _rice_field_music: AudioStream = null
static var _tempest_music: AudioStream = null
static var _boss_music: AudioStream = null
static var _dodge_whoosh: AudioStream = null
static var _boss_roar: AudioStream = null

static func _ensure_loaded() -> void:
	if _grass_steps.is_empty():
		for p in [PATH_SFX_GRASS_1, PATH_SFX_GRASS_2, PATH_SFX_GRASS_3, PATH_SFX_GRASS_4]:
			var s = load(p) as AudioStream
			if s: _grass_steps.append(s)
	if _wood_steps.is_empty():
		for p in [PATH_SFX_WOOD_1, PATH_SFX_WOOD_2]:
			var s = load(p) as AudioStream
			if s: _wood_steps.append(s)
	if _land_soil == null:
		_land_soil = load(PATH_SFX_LAND_SOIL) as AudioStream
	if _swing_lights.is_empty():
		for p in [PATH_SFX_SWING_LIGHT_1, PATH_SFX_SWING_LIGHT_2]:
			var s = load(p) as AudioStream
			if s: _swing_lights.append(s)
	if _swing_heavy == null:
		_swing_heavy = load(PATH_SFX_SWING_HEAVY) as AudioStream
	if _hit_slashes.is_empty():
		for p in [PATH_SFX_HIT_SLASH_1, PATH_SFX_HIT_SLASH_2]:
			var s = load(p) as AudioStream
			if s: _hit_slashes.append(s)
	if _hit_critical == null:
		_hit_critical = load(PATH_SFX_HIT_CRITICAL) as AudioStream
	if _kick_launch == null:
		_kick_launch = load(PATH_SFX_KICK_LAUNCH) as AudioStream
	if _kick_hit == null:
		_kick_hit = load(PATH_SFX_KICK_HIT) as AudioStream
	if _pot_smash == null:
		_pot_smash = load(PATH_SFX_POT_SMASH) as AudioStream
	if _bird_chirps.is_empty():
		for p in [PATH_SFX_BIRD_1, PATH_SFX_BIRD_2, PATH_SFX_BIRD_3, PATH_SFX_BIRD_4]:
			if ResourceLoader.exists(p):
				var s = load(p) as AudioStream
				if s: _bird_chirps.append(s)

static func get_grass_footstep(is_running: bool = false, step_index: int = 0) -> AudioStream:
	_ensure_loaded()
	if not _grass_steps.is_empty():
		var idx = abs(step_index) % _grass_steps.size()
		return _grass_steps[idx]
	return _synthesize_organic_grass_step(1429 + step_index * 100, is_running)

static func get_dirt_footstep() -> AudioStream:
	return get_grass_footstep(false, 0)

static func get_wood_footstep(step_index: int = 0) -> AudioStream:
	_ensure_loaded()
	if not _wood_steps.is_empty():
		var idx = abs(step_index) % _wood_steps.size()
		return _wood_steps[idx]
	return _synthesize_wood_step()

static func get_landing_thud() -> AudioStream:
	_ensure_loaded()
	if _land_soil != null:
		return _land_soil
	return _synthesize_land_thud()

static func get_swing_whoosh(is_heavy: bool = false, step_index: int = 0) -> AudioStream:
	_ensure_loaded()
	if is_heavy:
		if _swing_heavy != null:
			return _swing_heavy
	else:
		if not _swing_lights.is_empty():
			var idx = abs(step_index) % _swing_lights.size()
			return _swing_lights[idx]
	return null

static func get_hit_slash(is_critical: bool = false, step_index: int = 0) -> AudioStream:
	_ensure_loaded()
	if is_critical:
		if _hit_critical != null:
			return _hit_critical
	else:
		if not _hit_slashes.is_empty():
			var idx = abs(step_index) % _hit_slashes.size()
			return _hit_slashes[idx]
	return null

static func get_pot_smash() -> AudioStream:
	_ensure_loaded()
	return _pot_smash

static func get_kick_launch() -> AudioStream:
	_ensure_loaded()
	return _kick_launch

static func get_kick_hit() -> AudioStream:
	_ensure_loaded()
	return _kick_hit

## Synthesize a 100% organic acoustic grass footstep (no musical sine beeps)
static func _synthesize_organic_grass_step(seed_val: int, is_run: bool) -> AudioStreamWAV:
	var rate: int = 22050
	var duration: float = 0.11 if is_run else 0.16
	var num_samples: int = int(rate * duration)
	var byte_array = PackedByteArray()
	byte_array.resize(num_samples * 2)

	var rng = RandomNumberGenerator.new()
	rng.seed = seed_val

	# Pre-generate 3-5 micro-twig snap timestamps
	var snap_offsets: Array[int] = []
	var num_snaps = rng.randi_range(3, 5)
	for s in range(num_snaps):
		snap_offsets.append(rng.randi_range(int(num_samples * 0.05), int(num_samples * 0.50)))

	# 2-pole low-pass and band-pass filter state
	var lp_soil_1: float = 0.0
	var lp_soil_2: float = 0.0
	var bp_grass_1: float = 0.0
	var bp_grass_2: float = 0.0
	var brown_noise: float = 0.0

	for i in range(num_samples):
		var t: float = float(i) / float(rate)

		# 1. White noise generator
		var white: float = rng.randf_range(-1.0, 1.0)

		# 2. Brown noise accumulator (soft low-end ground mass)
		brown_noise = (brown_noise + (0.08 * white)) / 1.05

		# 3. Layer A: Soil Compression (2-pole low-pass brown noise around 120-140Hz)
		var soil_cutoff: float = 0.045 if not is_run else 0.065
		lp_soil_1 += soil_cutoff * (brown_noise - lp_soil_1)
		lp_soil_2 += soil_cutoff * (lp_soil_1 - lp_soil_2)
		var soil_layer: float = lp_soil_2 * 3.4

		# 4. Layer B: Grass Blades Crushed (Band-pass filtered noise around 1.5kHz - 3.5kHz)
		var grass_delta: float = (white - bp_grass_1) * 0.35
		bp_grass_1 += grass_delta
		bp_grass_2 = bp_grass_2 * 0.60 + grass_delta * 0.40
		var grass_layer: float = bp_grass_2 * 1.85

		# 5. Layer C: Micro-snaps (tiny dry blade/twig crackles under foot)
		var snap_layer: float = 0.0
		for snap_idx in snap_offsets:
			var diff = i - snap_idx
			if diff >= 0 and diff < 30:
				var snap_env = exp(-float(diff) * 0.20)
				snap_layer += rng.randf_range(-0.7, 0.7) * snap_env * (1.2 if is_run else 0.7)

		# 6. Natural amplitude envelope: Gentle attack (4-8ms) -> Organic decay
		var attack_time: float = 0.005 if is_run else 0.008
		var attack_mult: float = clampf(t / attack_time, 0.0, 1.0)
		var decay_rate: float = 26.0 if is_run else 19.5
		var main_env: float = attack_mult * exp(-t * decay_rate)

		# Combine acoustic layers (zero electronic sine tones!)
		var combined: float = (soil_layer * 0.52 + grass_layer * 0.36 + snap_layer * 0.22) * main_env

		_write_sample(byte_array, i, combined)

	return _build_wav(byte_array, rate)

static func _synthesize_wood_step() -> AudioStreamWAV:
	var rate: int = 22050
	var duration: float = 0.075
	var num_samples: int = int(rate * duration)
	var byte_array = PackedByteArray()
	byte_array.resize(num_samples * 2)

	var rng = RandomNumberGenerator.new()
	rng.seed = 9812

	for i in range(num_samples):
		var t: float = float(i) / float(rate)
		
		# Dual harmonic resonance: 330 Hz + 495 Hz (hollow wooden plank resonance)
		var tone1: float = sin(t * TAU * 330.0)
		var tone2: float = sin(t * TAU * 495.0) * 0.40
		var tap: float = rng.randf_range(-0.6, 0.6) if i < 44 else 0.0
		
		var env: float = exp(-t * 62.0)
		var sample: float = ((tone1 + tone2) * 0.68 + tap * 0.32) * env

		_write_sample(byte_array, i, sample)

	return _build_wav(byte_array, rate)

static func _synthesize_land_thud() -> AudioStreamWAV:
	var rate: int = 22050
	var duration: float = 0.22
	var num_samples: int = int(rate * duration)
	var byte_array = PackedByteArray()
	byte_array.resize(num_samples * 2)

	var rng = RandomNumberGenerator.new()
	rng.seed = 4455

	var brown_noise: float = 0.0
	var lp1: float = 0.0
	var lp2: float = 0.0
	var bp1: float = 0.0

	for i in range(num_samples):
		var t: float = float(i) / float(rate)
		var white = rng.randf_range(-1.0, 1.0)
		brown_noise = (brown_noise + (0.10 * white)) / 1.04

		# Heavy soil displacement low-pass
		lp1 += 0.05 * (brown_noise - lp1)
		lp2 += 0.05 * (lp1 - lp2)
		var heavy_soil = lp2 * 4.2

		# Wide grass blade rustle
		bp1 += 0.25 * (white - bp1)
		var grass_rustle = bp1 * 1.5

		var attack_mult = clampf(t / 0.006, 0.0, 1.0)
		var env = attack_mult * exp(-t * 14.0)
		var combined = (heavy_soil * 0.70 + grass_rustle * 0.30) * env

		_write_sample(byte_array, i, combined)

	return _build_wav(byte_array, rate)

static func _write_sample(bytes: PackedByteArray, idx: int, sample: float) -> void:
	sample = clampf(sample, -1.0, 1.0)
	var val16: int = int(round(sample * 32767.0))
	if val16 < 0:
		val16 += 65536
	bytes[idx * 2] = val16 & 0xFF
	bytes[idx * 2 + 1] = (val16 >> 8) & 0xFF

static func _build_wav(data: PackedByteArray, mix_rate: int, is_loop: bool = false) -> AudioStreamWAV:
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = mix_rate
	wav.stereo = false
	wav.data = data
	if is_loop:
		wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
		wav.loop_begin = 0
		wav.loop_end = data.size() / 2
	return wav

# ── Dynamic Procedural Soundtracks & Themes ───────────────────────────────────

static func get_menu_ambient() -> AudioStream:
	if _menu_music != null:
		return _menu_music
	
	var rate: int = 22050
	var dur: float = 4.0
	var num_samples: int = int(rate * dur)
	var bytes := PackedByteArray()
	bytes.resize(num_samples * 2)
	var rng := RandomNumberGenerator.new()
	rng.seed = 1012
	
	for i in range(num_samples):
		var t: float = float(i) / float(rate)
		# Low atmospheric drone in A (55 Hz + 110 Hz with gentle phase sweep)
		var drone = sin(t * TAU * 55.0) * 0.35 + sin(t * TAU * 110.0 + sin(t * TAU * 0.25)) * 0.20
		
		# Gentle wind whisper (filtered noise)
		var wind = rng.randf_range(-0.15, 0.15) * (0.6 + 0.4 * sin(t * TAU * 0.5))
		
		# Ethereal singing bell strikes at t=0.4s (A4 440Hz), t=1.8s (E4 330Hz), t=2.9s (D4 293.6Hz)
		var bell = 0.0
		var bell_points = [{"t": 0.4, "f": 440.0}, {"t": 1.8, "f": 330.0}, {"t": 2.9, "f": 293.6}]
		for bp in bell_points:
			var dt = t - bp["t"]
			if dt >= 0.0:
				var env = exp(-dt * 3.2)
				bell += (sin(dt * TAU * bp["f"]) + 0.4 * sin(dt * TAU * bp["f"] * 2.0)) * env * 0.25
				
		var sample = clampf(drone + wind + bell, -1.0, 1.0)
		_write_sample(bytes, i, sample)
		
	_menu_music = _build_wav(bytes, rate, true)
	return _menu_music

static func get_forest_ambient() -> AudioStream:
	if _forest_music != null:
		return _forest_music

	if ResourceLoader.exists(PATH_AMBIENT_FOREST_WIND):
		var s = load(PATH_AMBIENT_FOREST_WIND) as AudioStream
		if s:
			if s is AudioStreamWAV:
				(s as AudioStreamWAV).loop_mode = AudioStreamWAV.LOOP_FORWARD
				(s as AudioStreamWAV).loop_begin = 0
				(s as AudioStreamWAV).loop_end = -1
			_forest_music = s
			return _forest_music

	# High-fidelity procedural broadleaf canopy wind loop fallback
	var rate: int = 22050
	var dur: float = 6.0
	var num_samples: int = int(rate * dur)
	var bytes := PackedByteArray()
	bytes.resize(num_samples * 2)
	var rng := RandomNumberGenerator.new()
	rng.seed = 2044

	var lp1: float = 0.0
	var lp2: float = 0.0
	var bp1: float = 0.0
	var bp2: float = 0.0
	var hp1: float = 0.0
	var hp2: float = 0.0

	for i in range(num_samples):
		var t: float = float(i) / float(rate)
		var w: float = rng.randf_range(-1.0, 1.0)

		# Lowpass body (~220Hz)
		lp1 += 0.035 * (w - lp1)
		lp2 += 0.035 * (lp1 - lp2)

		# Bandpass broadleaf rustle (~1400Hz)
		bp1 += 0.16 * (w - bp1)
		bp2 = bp2 * 0.75 + (w - bp1) * 0.25

		# High airy whisper (~3500Hz)
		hp1 += 0.35 * (w - hp1)
		hp2 = hp2 * 0.55 + (w - hp1) * 0.45

		# Natural canopy undulating swells and leaf flutter
		var gust = 0.55 + 0.28 * sin(t * TAU / 6.0) + 0.15 * sin(t * TAU / 3.0 + 0.9)
		var leaf_flutter = 0.70 + 0.18 * sin(t * TAU * 3.5) + 0.12 * sin(t * TAU * 7.0 + 1.1)

		var body = lp2 * 3.4 * gust
		var leaves = bp2 * 1.6 * gust * leaf_flutter
		var whisper = hp2 * 0.65 * (gust * 0.7 + 0.3)

		var sample = clampf((body * 0.52 + leaves * 0.36 + whisper * 0.12) * 0.85, -1.0, 1.0)
		_write_sample(bytes, i, sample)

	_forest_music = _build_wav(bytes, rate, true)
	return _forest_music

static func get_random_bird_chirp() -> AudioStream:
	_ensure_loaded()
	if not _bird_chirps.is_empty():
		return _bird_chirps.pick_random()

	# Procedural bird chirp fallback (4 musical robin/songbird styles)
	return _synthesize_procedural_bird_chirp(randi() % 4)

static func _synthesize_procedural_bird_chirp(style: int) -> AudioStreamWAV:
	var rate: int = 22050
	var dur: float = 0.32
	var num_samples: int = int(rate * dur)
	var bytes := PackedByteArray()
	bytes.resize(num_samples * 2)
	var phase: float = 0.0

	for i in range(num_samples):
		var t: float = float(i) / float(rate)
		var freq: float = 3200.0
		var env: float = 0.0

		match style:
			0: # Robin ascending sweet whistle
				if t < 0.16:
					freq = 2800.0 + (4300.0 - 2800.0) * (t / 0.16)
				else:
					freq = 4300.0 - (4300.0 - 3400.0) * ((t - 0.16) / 0.16)
				env = sin(clampf(t / 0.32, 0.0, 1.0) * PI)
			1: # Double pip
				if t < 0.12:
					var pt = t / 0.12
					freq = 3100.0 + 1200.0 * pt
					env = sin(pt * PI)
				elif t > 0.18:
					var pt2 = (t - 0.18) / 0.14
					freq = 3400.0 + 1400.0 * pt2
					env = sin(pt2 * PI)
			2: # High rapid trill
				freq = 3900.0 + 320.0 * sin(t * TAU * 28.0) - (t * 400.0)
				env = sin(clampf(t / 0.32, 0.0, 1.0) * PI)
			_: # Flute-like two-tone
				freq = 4200.0 if t < 0.14 else 3500.0
				env = sin(clampf(t / 0.32, 0.0, 1.0) * PI)

		phase += TAU * freq / float(rate)
		var s: float = (sin(phase) + 0.06 * sin(phase * 2.0)) * env * 0.70
		_write_sample(bytes, i, s)

	return _build_wav(bytes, rate, false)

static func get_rice_field_ambient() -> AudioStream:
	if _rice_field_music != null:
		return _rice_field_music
		
	var rate: int = 22050
	var dur: float = 4.0
	var num_samples: int = int(rate * dur)
	var bytes := PackedByteArray()
	bytes.resize(num_samples * 2)
	var rng := RandomNumberGenerator.new()
	rng.seed = 3320
	
	for i in range(num_samples):
		var t: float = float(i) / float(rate)
		# Golden evening open G-chord drone (98 Hz + 196 Hz + 293.6 Hz)
		var drone = sin(t * TAU * 98.0) * 0.25 + sin(t * TAU * 196.0) * 0.18 + sin(t * TAU * 293.6) * 0.12
		
		# Kulintang metallic bell strikes (G4 392Hz, D5 587Hz, E5 659Hz)
		var chime = 0.0
		var chime_points = [{"t": 0.2, "f": 392.0}, {"t": 1.2, "f": 493.8}, {"t": 2.2, "f": 587.3}, {"t": 3.2, "f": 659.2}]
		for cp in chime_points:
			var dt = t - cp["t"]
			if dt >= 0.0 and dt < 1.0:
				var env = exp(-dt * 4.5)
				chime += (sin(dt * TAU * cp["f"]) + 0.5 * sin(dt * TAU * cp["f"] * 2.76)) * env * 0.24
				
		var breeze = rng.randf_range(-0.1, 0.1) * (0.4 + 0.3 * sin(t * TAU * 0.5))
		var sample = clampf(drone + chime + breeze, -1.0, 1.0)
		_write_sample(bytes, i, sample)
		
	_rice_field_music = _build_wav(bytes, rate, true)
	return _rice_field_music

static func get_tempest_ambient() -> AudioStream:
	if _tempest_music != null:
		return _tempest_music
		
	var rate: int = 22050
	var dur: float = 4.0
	var num_samples: int = int(rate * dur)
	var bytes := PackedByteArray()
	bytes.resize(num_samples * 2)
	var rng := RandomNumberGenerator.new()
	rng.seed = 4480
	
	for i in range(num_samples):
		var t: float = float(i) / float(rate)
		# Heavy low sub-bass drone (45 Hz + 90 Hz with slow pulse)
		var sub = sin(t * TAU * 45.0) * 0.40 + sin(t * TAU * 90.0) * 0.25
		
		# Dark bowed string dissonance (C#2 69.3 Hz + F#2 92.5 Hz)
		var bowed = (sin(t * TAU * 69.3) + sin(t * TAU * 92.5)) * 0.15 * (0.7 + 0.3 * sin(t * TAU * 0.25))
		
		# Deep thunder roll swell at t=2.0s
		var dt_thunder = t - 2.0
		var thunder = 0.0
		if dt_thunder >= 0.0 and dt_thunder < 1.4:
			thunder = rng.randf_range(-0.35, 0.35) * exp(-dt_thunder * 2.5) * (1.0 + sin(dt_thunder * TAU * 28.0))
			
		var rain_hiss = rng.randf_range(-0.12, 0.12)
		var sample = clampf(sub + bowed + thunder + rain_hiss, -1.0, 1.0)
		_write_sample(bytes, i, sample)
		
	_tempest_music = _build_wav(bytes, rate, true)
	return _tempest_music

static func get_boss_battle_music() -> AudioStream:
	if _boss_music != null:
		return _boss_music
		
	var rate: int = 22050
	var dur: float = 4.0 # 8 beats at 120 BPM
	var num_samples: int = int(rate * dur)
	var bytes := PackedByteArray()
	bytes.resize(num_samples * 2)
	var rng := RandomNumberGenerator.new()
	rng.seed = 5510
	
	for i in range(num_samples):
		var t: float = float(i) / float(rate)
		var sixteenth = fmod(t, 0.125)
		
		# 1. Driving Kick on beats 0.0, 1.0, 2.0, 3.0
		var kick_time = fmod(t, 1.0)
		var kick = 0.0
		if kick_time < 0.18:
			var k_freq = 72.0 * exp(-kick_time * 24.0)
			kick = sin(kick_time * TAU * k_freq) * exp(-kick_time * 16.0) * 0.65
			
		# 2. Snare / Tribal Rim crack on beats 0.5, 1.5, 2.5, 3.5
		var snare_time = fmod(t + 0.5, 1.0)
		var snare = 0.0
		if snare_time < 0.15:
			var s_noise = rng.randf_range(-1.0, 1.0)
			var s_tone = sin(snare_time * TAU * 196.0) * 0.4
			snare = (s_noise * 0.75 + s_tone) * exp(-snare_time * 26.0) * 0.40
			
		# 3. Continuous 16th-note tribal shaker
		var shaker = 0.0
		if sixteenth < 0.045:
			shaker = rng.randf_range(-0.25, 0.25) * exp(-sixteenth * 70.0)
			
		# 4. Galloping Bassline Ostinato (E2 -> G2 -> A2 -> B2)
		var beat_idx = int(floor(t / 0.5)) % 4
		var bass_freq = 82.4 # E2
		if beat_idx == 1: bass_freq = 98.0 # G2
		elif beat_idx == 2: bass_freq = 110.0 # A2
		elif beat_idx == 3: bass_freq = 123.5 # B2
		var bass_env = exp(-fmod(t, 0.25) * 11.0)
		var bass = (sin(t * TAU * bass_freq) + 0.35 * sin(t * TAU * bass_freq * 2.0)) * bass_env * 0.32
		
		# 5. Dissonant brass tension stab on bar starts (t=0.0 and t=2.0)
		var bar_time = fmod(t, 2.0)
		var brass = 0.0
		if bar_time < 0.45:
			brass = (sin(bar_time * TAU * 164.8) + sin(bar_time * TAU * 220.0) * 0.6) * exp(-bar_time * 5.0) * 0.22
			
		var sample = clampf(kick + snare + shaker + bass + brass, -1.0, 1.0)
		_write_sample(bytes, i, sample)
		
	_boss_music = _build_wav(bytes, rate, true)
	return _boss_music

static func get_dodge_whoosh() -> AudioStream:
	if _dodge_whoosh != null:
		return _dodge_whoosh
		
	var rate: int = 22050
	var dur: float = 0.18
	var num_samples: int = int(rate * dur)
	var bytes := PackedByteArray()
	bytes.resize(num_samples * 2)
	var rng := RandomNumberGenerator.new()
	rng.seed = 6601
	
	for i in range(num_samples):
		var t: float = float(i) / float(rate)
		var pitch = 220.0 * (1.0 - t / dur) + 40.0
		var tone = sin(t * TAU * pitch) * 0.4
		var noise = rng.randf_range(-0.6, 0.6) * 0.6
		var env = sin((t / dur) * PI) # Bell curve
		var sample = clampf((tone + noise) * env * 0.55, -1.0, 1.0)
		_write_sample(bytes, i, sample)
		
	_dodge_whoosh = _build_wav(bytes, rate, false)
	return _dodge_whoosh

static func get_boss_roar() -> AudioStream:
	if _boss_roar != null:
		return _boss_roar
		
	var rate: int = 22050
	var dur: float = 0.65
	var num_samples: int = int(rate * dur)
	var bytes := PackedByteArray()
	bytes.resize(num_samples * 2)
	var rng := RandomNumberGenerator.new()
	rng.seed = 8822
	
	for i in range(num_samples):
		var t: float = float(i) / float(rate)
		# Descending guttural pitch: 65 Hz down to 35 Hz
		var pitch = 65.0 - (t / dur) * 30.0
		# Guttural shudder AM modulation
		var shudder = 1.0 + 0.45 * sin(t * TAU * 26.0)
		var tone = sin(t * TAU * pitch) * shudder * 0.5
		var sub = sin(t * TAU * (pitch * 0.5)) * 0.35
		var growl_noise = rng.randf_range(-0.4, 0.4) * (1.0 - t / dur)
		var env = clampf(t / 0.04, 0.0, 1.0) * exp(-t * 3.5)
		var sample = clampf((tone + sub + growl_noise) * env * 0.8, -1.0, 1.0)
		_write_sample(bytes, i, sample)
		
	_boss_roar = _build_wav(bytes, rate, false)
	return _boss_roar

