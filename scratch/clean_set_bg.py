new_set_bg = """func set_background_theme(theme_name: String) -> void:
\tvar cur_lvl_title: String = LEVELS_DATA[current_level_idx].get("level_title", "") if current_level_idx < LEVELS_DATA.size() else ""
\tvar is_forest: bool = (theme_name == "Forest" or theme_name == "Rainy Forest")
\tvar is_rainy: bool = (theme_name == "Rainy Forest")
\tvar is_cave: bool = (theme_name == "Cave" or theme_name == "Cave Boss")

\tfor layer in forest_parallax_layers:
\t\tlayer.visible = is_forest
\t\tif is_rainy:
\t\t\tlayer.modulate = Color(0.52, 0.56, 0.70, 1.0)
\t\telse:
\t\t\tlayer.modulate = Color(1.0, 1.0, 1.0, 1.0)

\tfor layer in rice_field_parallax_layers:
\t\tlayer.visible = (not is_forest and not is_cave)
\t\tif cur_lvl_title == "Level 2-1":
\t\t\tlayer.modulate = Color(1.0, 1.0, 1.0, 1.0)
\t\telif cur_lvl_title == "Level 2-2":
\t\t\tlayer.modulate = Color(0.96, 0.90, 0.94, 1.0)
\t\telif cur_lvl_title in ["Level 2-3", "Level 2-4", "Level 2-5"]:
\t\t\tlayer.modulate = Color(1.05, 0.86, 0.80, 1.0)
\t\telse:
\t\t\tlayer.modulate = Color(1.0, 1.0, 1.0, 1.0)

\tfor i in range(cave_parallax_layers.size()):
\t\tvar layer := cave_parallax_layers[i]
\t\tlayer.visible = is_cave
\t\tif is_cave:
\t\t\tvar is_fx_layer: bool = ("GodRay" in layer.name)
\t\t\tvar is_glow_bg: bool = (i == 0)
\t\t\tvar base_tint := Color(0.16, 0.20, 0.32, 1.0)
\t\t\tif cur_lvl_title == "Level 4-1":
\t\t\t\tbase_tint = Color(0.14, 0.20, 0.30, 1.0) if is_glow_bg else Color(0.24, 0.30, 0.44, 1.0)
\t\t\telif cur_lvl_title == "Level 4-2":
\t\t\t\tbase_tint = Color(0.15, 0.13, 0.26, 1.0) if is_glow_bg else Color(0.25, 0.21, 0.38, 1.0)
\t\t\telif cur_lvl_title in ["Level 4-3", "Level 4-4"]:
\t\t\t\tbase_tint = Color(0.10, 0.12, 0.20, 1.0) if is_glow_bg else Color(0.18, 0.22, 0.32, 1.0)
\t\t\telse:
\t\t\t\tbase_tint = Color(0.14, 0.10, 0.22, 1.0) if is_glow_bg else Color(0.24, 0.18, 0.32, 1.0)
\t\t\tif is_fx_layer:
\t\t\t\tlayer.modulate = Color(base_tint.r * 1.35, base_tint.g * 1.35, base_tint.b * 1.35, 0.50)
\t\t\telse:
\t\t\t\tlayer.modulate = base_tint

\tif sky_parallax_layer:
\t\tsky_parallax_layer.visible = not is_cave

\tif sky_sprite:
\t\tif is_cave:
\t\t\tsky_sprite.modulate = Color(0.015, 0.02, 0.04, 1.0)
\t\telif is_rainy:
\t\t\tsky_sprite.modulate = Color(0.35, 0.40, 0.52, 1.0)
\t\telif cur_lvl_title == "Level 2-2":
\t\t\tsky_sprite.modulate = Color(1.02, 0.82, 0.90, 1.0)
\t\telif cur_lvl_title in ["Level 2-3", "Level 2-4", "Level 2-5"]:
\t\t\tsky_sprite.modulate = Color(1.08, 0.70, 0.58, 1.0)
\t\telse:
\t\t\tsky_sprite.modulate = Color(1.0, 1.0, 1.0, 1.0)

\t# Toggle Hollow Knight deep subterranean vignette
\tif cave_vignette:
\t\tcave_vignette.modulate = Color(1.0, 1.0, 1.0, 0.95) if is_cave else Color(1.0, 1.0, 1.0, 0.0)

\tif is_cave:
\t\tif cur_lvl_title == "Level 4-1":
\t\t\tbase_modulate_color = Color(0.24, 0.26, 0.36, 1.0)
\t\telif cur_lvl_title == "Level 4-2":
\t\t\tbase_modulate_color = Color(0.20, 0.22, 0.32, 1.0)
\t\telif cur_lvl_title in ["Level 4-3", "Level 4-4"]:
\t\t\tbase_modulate_color = Color(0.16, 0.18, 0.26, 1.0)
\t\telse:
\t\t\tbase_modulate_color = Color(0.12, 0.14, 0.22, 1.0)
\t\tif canvas_modulate:
\t\t\tcanvas_modulate.color = base_modulate_color
\t\tif is_instance_valid(player):
\t\t\tvar p_light = player.get_node_or_null("CaveSpiritLight") as PointLight2D
\t\t\tif not p_light:
\t\t\t\tvar light_tex = load("res://assets/vfx/radial_light_falloff.png")
\t\t\t\tif light_tex:
\t\t\t\t\tp_light = PointLight2D.new()
\t\t\t\t\tp_light.name = "CaveSpiritLight"
\t\t\t\t\tp_light.texture = light_tex
\t\t\t\t\tp_light.position = Vector2(0.0, -18.0)
\t\t\t\t\tp_light.color = Color(0.68, 0.88, 1.0, 0.95)
\t\t\t\t\tp_light.energy = 1.15
\t\t\t\t\tp_light.texture_scale = 0.65
\t\t\t\t\tplayer.add_child(p_light)
\t\t\telse:
\t\t\t\tp_light.color = Color(0.68, 0.88, 1.0, 0.95)
\t\t\t\tp_light.energy = 1.15
\t\t\t\tp_light.texture_scale = 0.65
\t\tif rain_particles:
\t\t\train_particles.emitting = false
\t\tif rain_particles_fg:
\t\t\train_particles_fg.emitting = false
\t\tif rain_particles_bg:
\t\t\train_particles_bg.emitting = false
\t\tif rain_splashes:
\t\t\train_splashes.emitting = false
"""

with open("scripts/main.gd", "r", encoding="utf-8") as f:
    text = f.read()

import re
pattern = r"func set_background_theme\(theme_name: String\) -> void:.*?(?=\telse:\s+if is_forest:)"
match = re.search(pattern, text, re.DOTALL)
assert match is not None, "Failed to match set_background_theme"
text = text[:match.start()] + new_set_bg + text[match.end():]

with open("scripts/main.gd", "w", encoding="utf-8") as f:
    f.write(text)

print("Replaced set_background_theme cleanly!")
