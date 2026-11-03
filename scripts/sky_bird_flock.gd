class_name SkyBirdFlock
extends Node2D

## SkyBirdFlock - Cinematic animated bird flock soaring across Mount Mayon
## Features genuine animated sprite wing flapping cycles, natural soaring/gliding cadences,
## and atmospheric depth scaling across the Rice Field stages.

static var _cached_bird_tex: Texture2D = null

static func get_bird_texture() -> Texture2D:
	if _cached_bird_tex:
		return _cached_bird_tex
	if ResourceLoader.exists("res://assets/platform_assets/sky_bird_animated.png"):
		_cached_bird_tex = load("res://assets/platform_assets/sky_bird_animated.png") as Texture2D
	if not _cached_bird_tex:
		var img = Image.load_from_file("assets/platform_assets/sky_bird_animated.png")
		if img and not img.is_empty():
			_cached_bird_tex = ImageTexture.create_from_image(img)
	return _cached_bird_tex

var birds: Array[Sprite2D] = []
var base_positions: Array[Vector2] = []
var speeds: Array[float] = []
var wave_phases: Array[float] = []

# Per-bird animation tracking
var bird_frames: Array[int] = []
var bird_frame_timers: Array[float] = []
var bird_is_gliding: Array[bool] = []
var bird_glide_timers: Array[float] = []
var bird_flap_counters: Array[int] = []
var bird_target_flaps: Array[int] = []

@export var flock_size: int = 8
@export var speed: float = 24.0
@export var area_width: float = 5200.0

func _ready() -> void:
	z_index = -3 # Behind foreground and midground, in front of distant mountains
	var tex = get_bird_texture()

	for i in range(flock_size):
		var b = Sprite2D.new()
		b.texture = tex
		b.hframes = 6
		b.vframes = 1
		b.frame = 0
		b.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		
		# Atmospheric perspective depth variation (foreground vs distant soaring)
		var depth_ratio = randf() # 0 = distant small bird, 1 = nearer prominent bird
		var bird_scale = lerp(0.50, 0.95, depth_ratio)
		b.scale = Vector2(bird_scale, bird_scale)
		
		# Distant birds catch atmospheric mountain haze; nearer birds are crisper
		var haze = lerp(0.55, 0.88, depth_ratio)
		b.modulate = Color(0.18 * haze, 0.26 * haze, 0.38 * haze, lerp(0.50, 0.85, depth_ratio))
		
		# Stagger across the map with natural small grouping clusters
		var cluster_offset = (i % 3) * randf_range(30.0, 60.0)
		var start_x = (float(i) / float(flock_size)) * area_width + cluster_offset + randf_range(-80.0, 80.0)
		var start_y = randf_range(35.0, 115.0) # High up in the morning/twilight sky
		b.position = Vector2(start_x, start_y)
		
		add_child(b)
		birds.append(b)
		base_positions.append(Vector2(start_x, start_y))
		speeds.append(speed * lerp(0.85, 1.25, depth_ratio))
		wave_phases.append(randf_range(0.0, TAU))

		# Initialize individual animation rhythms
		bird_frames.append(randi() % 6)
		bird_frame_timers.append(randf_range(0.0, 0.09))
		bird_is_gliding.append(randf() < 0.4) # Some birds start gliding immediately
		bird_glide_timers.append(randf_range(1.5, 3.8))
		bird_flap_counters.append(0)
		bird_target_flaps.append(randi_range(3, 7))

func _process(delta: float) -> void:
	for i in range(birds.size()):
		var b = birds[i]
		
		# 1. Forward horizontal flight movement
		b.position.x += speeds[i] * delta
		
		# 2. Gentle vertical thermal updraft & soaring bobbing
		var t = Time.get_ticks_msec() * 0.0018 + wave_phases[i]
		var glide_lift = 2.0 if bird_is_gliding[i] else 0.0
		b.position.y = base_positions[i].y + sin(t) * 4.5 - glide_lift
		
		# 3. Flapping vs. Soaring animation state machine
		if bird_is_gliding[i]:
			b.frame = 0 # Outstretched level glide
			bird_glide_timers[i] -= delta
			if bird_glide_timers[i] <= 0.0:
				bird_is_gliding[i] = false
				bird_flap_counters[i] = 0
				bird_target_flaps[i] = randi_range(4, 8)
				bird_frames[i] = 1 # Start upstroke
				bird_frame_timers[i] = 0.0
		else:
			bird_frame_timers[i] += delta
			var flap_speed = 0.085 # Crisp, natural wing flap frequency
			if bird_frame_timers[i] >= flap_speed:
				bird_frame_timers[i] -= flap_speed
				bird_frames[i] = (bird_frames[i] + 1) % 6
				b.frame = bird_frames[i]
				
				# Count full flap cycles (reached frame 0)
				if bird_frames[i] == 0:
					bird_flap_counters[i] += 1
					if bird_flap_counters[i] >= bird_target_flaps[i]:
						bird_is_gliding[i] = true
						bird_glide_timers[i] = randf_range(1.8, 4.2)
		
		# 4. Wrap around seamlessly across map width
		if b.position.x > area_width + 120.0:
			b.position.x = -80.0
			base_positions[i].y = randf_range(35.0, 115.0)
			wave_phases[i] = randf_range(0.0, TAU)
