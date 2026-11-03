@tool
extends SceneTree

func _init() -> void:
	print("=== Verifying Tree Sway Parameters & Foliage Shader ===")

	# 1. Verify foliage_wind.gdshader
	var shader = load("res://shaders/foliage_wind.gdshader")
	assert(shader != null, "foliage_wind.gdshader must exist")
	var code: String = shader.code
	assert("pow(clamp(1.0 - UV.y, 0.0, 1.0), 2.0)" in code, "Shader must use quadratic canopy sway falloff")
	print("  1. Shader code confirmed: quadratic sway falloff anchored at trunk base.")

	# 2. Check forest scenes (1_1 to 1_3)
	for i in range(1, 4):
		var p = "res://scenes/forest/level_1_%d.tscn" % i
		var scn: PackedScene = load(p)
		assert(scn != null, "Scene %s missing" % p)
		var inst = scn.instantiate()
		var foliage = inst.find_child("Foliage", true, false)
		assert(foliage != null, "Foliage missing in %s" % p)
		var verified_trees = 0
		for child in foliage.get_children():
			if child is Sprite2D and child.material is ShaderMaterial:
				var sm := child.material as ShaderMaterial
				var speed = sm.get_shader_parameter("wind_speed")
				var strength = sm.get_shader_parameter("wind_strength")
				assert(speed <= 2.0, "Forest tree wind_speed should be gentle (<= 2.0)")
				assert(strength <= 2.0, "Forest tree wind_strength should be reduced (<= 2.0)")
				verified_trees += 1
		print("  2. %s verified: %d trees with gentle sway (speed <= 2.0, strength <= 2.0)" % [p, verified_trees])
		inst.free()

	# 3. Check rainy forest scenes (3_1 to 3_5)
	for i in range(1, 6):
		var p = "res://scenes/rainy_forest/level_3_%d.tscn" % i
		var scn: PackedScene = load(p)
		assert(scn != null, "Scene %s missing" % p)
		var inst = scn.instantiate()
		var foliage = inst.find_child("Foliage", true, false)
		assert(foliage != null, "Foliage missing in %s" % p)
		var verified_trees = 0
		for child in foliage.get_children():
			if child is Sprite2D and child.material is ShaderMaterial:
				var sm := child.material as ShaderMaterial
				var speed = sm.get_shader_parameter("wind_speed")
				var strength = sm.get_shader_parameter("wind_strength")
				assert(speed <= 3.0, "Rainy forest tree wind_speed should be calm/moderate (<= 3.0)")
				assert(strength <= 3.0, "Rainy forest tree wind_strength should be reduced (<= 3.0)")
				verified_trees += 1
		print("  3. %s verified: %d trees with reduced sway (speed <= 3.0, strength <= 3.0)" % [p, verified_trees])
		inst.free()

	print("\n=== ALL TREE SWAY & FOLIAGE VERIFICATIONS PASSED! ===")
	quit(0)
