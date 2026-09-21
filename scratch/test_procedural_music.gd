extends SceneTree

func _init() -> void:
	print("Synthesizing full soundtrack suite...")
	var t0 = Time.get_ticks_msec()
	
	var rate = 22050
	var dur = 4.0
	var num_samples = int(rate * dur)
	
	# Test Boss Music generator
	var bytes = PackedByteArray()
	bytes.resize(num_samples * 2)
	var rng = RandomNumberGenerator.new()
	rng.seed = 7712
	
	for i in range(num_samples):
		var t = float(i) / float(rate)
		var beat_time = fmod(t, 0.5) # 120 BPM = 0.5s per beat
		var bar_time = fmod(t, 2.0)  # 2.0s per bar
		var sixteenth = fmod(t, 0.125)
		
		# 1. Kick on beats 0.0, 1.0, 2.0, 3.0
		var kick_time = fmod(t, 1.0)
		var kick = 0.0
		if kick_time < 0.18:
			var k_freq = 68.0 * exp(-kick_time * 22.0)
			kick = sin(kick_time * TAU * k_freq) * exp(-kick_time * 18.0) * 0.7
			
		# 2. Snare crack on beats 0.5, 1.5, 2.5, 3.5
		var snare_time = fmod(t + 0.5, 1.0)
		var snare = 0.0
		if snare_time < 0.14:
			var s_noise = rng.randf_range(-1.0, 1.0)
			var s_tone = sin(snare_time * TAU * 190.0) * 0.4
			snare = (s_noise * 0.7 + s_tone) * exp(-snare_time * 28.0) * 0.45
			
		# 3. 16th-note tribal shaker
		var shaker = 0.0
		if sixteenth < 0.04:
			shaker = rng.randf_range(-0.3, 0.3) * exp(-sixteenth * 80.0)
			
		# 4. Driving bassline ostinato
		var note_idx = int(floor(t / 0.5)) % 4
		var bass_freq = 82.4 # E2
		if note_idx == 1: bass_freq = 98.0 # G2
		elif note_idx == 2: bass_freq = 110.0 # A2
		elif note_idx == 3: bass_freq = 123.5 # B2
		var bass_env = exp(-fmod(t, 0.25) * 12.0)
		var bass = (sin(t * TAU * bass_freq) + 0.3 * sin(t * TAU * bass_freq * 2.0)) * bass_env * 0.35
		
		var sample = clampf(kick + snare + shaker + bass, -1.0, 1.0)
		var val16 = int(round(sample * 32767.0))
		if val16 < 0: val16 += 65536
		bytes[i * 2] = val16 & 0xFF
		bytes[i * 2 + 1] = (val16 >> 8) & 0xFF
		
	var wav = AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = rate
	wav.data = bytes
	wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
	wav.loop_begin = 0
	wav.loop_end = num_samples
	
	var elapsed = Time.get_ticks_msec() - t0
	print("Boss music loop generated in %d ms!" % elapsed)
	quit()
