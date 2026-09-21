extends Node2D

func _ready() -> void:
	print("=== Starting Stage 3 Atmospheric & Visual Details Verification ===")

	var main_scene = load("res://scenes/main.tscn")
	assert(main_scene != null, "main.tscn must exist")

	var main = main_scene.instantiate()
	add_child(main)

	# Jump to Level 3-1 (idx 6)
	main.current_level_idx = 6
	main.load_current_level()
	main.set_background_theme("Rainy Forest")
	main.spawn_level_enemies()

	for _i in range(15):
		main._process(0.016)

	print("\n1. Testing 3-Layer Rain & Particle Systems:")
	print("  Midground Rain Emitting: ", main.rain_particles.emitting, " Amount: ", main.rain_particles.amount)
	print("  Foreground Rain Emitting: ", main.rain_particles_fg.emitting, " Amount: ", main.rain_particles_fg.amount)
	print("  Background Rain Emitting: ", main.rain_particles_bg.emitting, " Amount: ", main.rain_particles_bg.amount)
	print("  Rain Splashes Emitting: ", main.rain_splashes.emitting, " Amount: ", main.rain_splashes.amount)
	print("  Storm Fog Emitting: ", main.storm_fog.emitting, " Amount: ", main.storm_fog.amount)

	assert(main.rain_particles.emitting, "Midground rain must be emitting")
	assert(main.rain_particles_fg.emitting, "Foreground rain must be emitting")
	assert(main.rain_particles_bg.emitting, "Background rain must be emitting")
	assert(main.rain_splashes.emitting, "Ground splashes must be emitting")
	assert(main.storm_fog.emitting, "Storm floor mist must be emitting")

	print("\n2. Testing Reflective Puddles & Lens Rain Overlay:")
	print("  Puddles Count: ", main.puddles_list.size())
	print("  Lens Rain Overlay: ", main.lens_rain_overlay != null)
	assert(main.puddles_list.size() >= 8, "Stage 3 must spawn reflective rain puddles")
	assert(main.lens_rain_overlay != null, "Lens rain overlay must exist on storm layer")

	print("\n2b. Testing Lighting & Storm Vignette:")
	print("  Canvas Modulate: ", main.canvas_modulate.color)
	print("  Storm Vignette Alpha: ", main.storm_vignette.modulate.a)
	assert(main.canvas_modulate.color.r < 0.35, "Stage 3 canvas modulate should be deep stormy blue")
	assert(main.storm_vignette.modulate.a >= 0.50, "Storm vignette should be active in Stage 3")

	print("\n3. Testing Foliage Wind Shaders & Torch Storm Mode:")
	var torches_node = main.current_level_instance.find_child("Torches", true, false)
	assert(torches_node != null, "Torches node must exist in 3-1")
	for torch in torches_node.get_children():
		assert(torch.get("is_stormy") == true, "Torches in Stage 3 must have is_stormy enabled")
	print("  All torches confirmed in is_stormy mode!")

	var foliage_node = main.current_level_instance.find_child("Foliage", true, false)
	assert(foliage_node != null, "Foliage node must exist in 3-1")
	var checked_tree: bool = false
	for spr in foliage_node.get_children():
		if spr is Sprite2D and spr.material is ShaderMaterial:
			var sm := spr.material as ShaderMaterial
			var speed = sm.get_shader_parameter("wind_speed")
			var strength = sm.get_shader_parameter("wind_strength")
			print("  Tree Shader: wind_speed = %s, wind_strength = %s" % [speed, strength])
			assert(speed >= 3.5, "Tree wind speed should be amplified in storm")
			assert(strength >= 10.0, "Tree wind strength should be amplified in storm")
			checked_tree = true
			break
	assert(checked_tree, "Must have verified at least one foliage tree shader")

	print("\n4. Testing Lightning Hazard Details (Single Sky Strand, Ground Scatter & Debris):")
	var hazard_script = load("res://scripts/lightning_hazard.gd")
	var hazard = hazard_script.new() as LightningHazard
	hazard.target_position = Vector2(250, 250)
	main.lightning_container.add_child(hazard)

	print("  Single Bolt Line: ", hazard.bolt_line != null)
	print("  Single Bolt Core: ", hazard.bolt_core != null)
	print("  Ground Scatter Lines Count: ", hazard.ground_scatter_lines.size())
	print("  Ground Scatter Cores Count: ", hazard.ground_scatter_cores.size())
	print("  Burst Ray Lines Count: ", hazard.burst_ray_lines.size())
	print("  Shockwave Ring: ", hazard.shockwave_ring != null)
	print("  Impact Flash Sprite: ", hazard.impact_flash_sprite != null)
	print("  Debris Particles: ", hazard.debris_particles != null)
	print("  Dust Particles: ", hazard.dust_particles != null)
	print("  Crater Embers: ", hazard.crater_embers != null)
	print("  Canopy Leaves: ", hazard.canopy_leaves != null)
	print("  Strike Light: ", hazard.strike_light != null)
	print("  Scorch Line: ", hazard.scorch_line != null)
	print("  Smoke Particles: ", hazard.smoke_particles != null)

	assert(hazard.bolt_line != null and hazard.bolt_core != null, "Lightning must have single sky bolt")
	assert(hazard.ground_scatter_lines.size() == 16, "Lightning must have 16 jagged ground scatter lines")
	assert(hazard.ground_scatter_cores.size() == 16, "Lightning must have 16 ground scatter cores")
	assert(hazard.burst_ray_lines.size() >= 12, "Lightning must have at least 12 radiant burst ray lines")
	assert(hazard.shockwave_ring != null, "Lightning must have shockwave ring")
	assert(hazard.impact_flash_sprite != null, "Lightning must have impact flash sprite")
	assert(hazard.debris_particles != null, "Lightning must have debris particles")
	assert(hazard.dust_particles != null, "Lightning must have dust particles")
	assert(hazard.crater_embers != null, "Lightning must have crater embers")
	assert(hazard.canopy_leaves != null, "Lightning must have canopy falling leaves")
	assert(hazard.strike_light != null, "Lightning must have PointLight2D impact flash")
	assert(hazard.scorch_line != null, "Lightning must have ground scorch mark")
	assert(hazard.smoke_particles != null, "Lightning must have residual steam/smoke particles")

	# Step past telegraph duration into strike
	for _i in range(85):
		hazard._process(0.016)

	assert(hazard.is_striking, "Hazard should have triggered strike")
	assert(hazard.strike_light.energy > 0.0, "PointLight2D should be illuminated on strike")

	print("\n5. Testing Sheet Lightning & Thunder Audio System:")
	main.trigger_sheet_lightning(1.0, 2.0)
	print("  Flash Timer: ", main.lightning_flash_timer)
	print("  Thunder Rumble Timer: ", main.thunder_rumble_timer)
	assert(main.lightning_flash_timer > 0.1, "Sheet lightning must set flash timer")
	assert(main.thunder_rumble_timer > 0.2, "Sheet lightning must schedule delayed thunder rumble")

	print("\n=== ALL STAGE 3 DETAILS & ATMOSPHERE TESTS PASSED! ===")
	get_tree().quit(0)
