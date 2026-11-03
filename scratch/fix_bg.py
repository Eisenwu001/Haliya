with open("scripts/main.gd", "r", encoding="utf-8") as f:
    lines = f.readlines()

# Find the start of func set_background_theme
start_idx = -1
for i, line in enumerate(lines):
    if line.startswith("func set_background_theme(theme_name: String) -> void:"):
        start_idx = i
        break

assert start_idx != -1

# Find elif is_rainy
end_idx = -1
for i in range(start_idx, len(lines)):
    if lines[i].startswith("\telif is_rainy:"):
        end_idx = i
        break

assert end_idx != -1

new_bg_block = [
    "func set_background_theme(theme_name: String) -> void:\n",
    "\tvar cur_lvl_title: String = LEVELS_DATA[current_level_idx].get(\"level_title\", \"\") if current_level_idx < LEVELS_DATA.size() else \"\"\n",
    "\tvar is_forest: bool = (theme_name == \"Forest\" or theme_name == \"Rainy Forest\")\n",
    "\tvar is_rainy: bool = (theme_name == \"Rainy Forest\")\n",
    "\tvar is_cave: bool = (theme_name == \"Cave\" or theme_name == \"Cave Boss\")\n",
    "\n",
    "\tfor layer in forest_parallax_layers:\n",
    "\t\tlayer.visible = is_forest\n",
    "\t\tif is_rainy:\n",
    "\t\t\tlayer.modulate = Color(0.52, 0.56, 0.70, 1.0)\n",
    "\t\telse:\n",
    "\t\t\tlayer.modulate = Color(1.0, 1.0, 1.0, 1.0)\n",
    "\n",
    "\tfor layer in rice_field_parallax_layers:\n",
    "\t\tlayer.visible = (not is_forest and not is_cave)\n",
    "\t\tif cur_lvl_title == \"Level 2-1\":\n",
    "\t\t\tlayer.modulate = Color(1.0, 1.0, 1.0, 1.0)\n",
    "\t\telif cur_lvl_title == \"Level 2-2\":\n",
    "\t\t\tlayer.modulate = Color(0.96, 0.90, 0.94, 1.0)\n",
    "\t\telif cur_lvl_title in [\"Level 2-3\", \"Level 2-4\", \"Level 2-5\"]:\n",
    "\t\t\tlayer.modulate = Color(1.05, 0.86, 0.80, 1.0)\n",
    "\t\telse:\n",
    "\t\t\tlayer.modulate = Color(1.0, 1.0, 1.0, 1.0)\n",
    "\n",
    "\tfor i in range(cave_parallax_layers.size()):\n",
    "\t\tvar layer := cave_parallax_layers[i]\n",
    "\t\tlayer.visible = is_cave\n",
    "\t\tif is_cave:\n",
    "\t\t\tvar is_fx_layer: bool = (\"GodRay\" in layer.name)\n",
    "\t\t\tvar is_glow_bg: bool = (i == 0)\n",
    "\t\t\tvar base_tint := Color(0.16, 0.20, 0.32, 1.0)\n",
    "\t\t\tif cur_lvl_title == \"Level 4-1\":\n",
    "\t\t\t\tbase_tint = Color(0.14, 0.20, 0.30, 1.0) if is_glow_bg else Color(0.24, 0.30, 0.44, 1.0)\n",
    "\t\t\telif cur_lvl_title == \"Level 4-2\":\n",
    "\t\t\t\tbase_tint = Color(0.15, 0.13, 0.26, 1.0) if is_glow_bg else Color(0.25, 0.21, 0.38, 1.0)\n",
    "\t\t\telif cur_lvl_title in [\"Level 4-3\", \"Level 4-4\"]:\n",
    "\t\t\t\tbase_tint = Color(0.10, 0.12, 0.20, 1.0) if is_glow_bg else Color(0.18, 0.22, 0.32, 1.0)\n",
    "\t\t\telse:\n",
    "\t\t\t\tbase_tint = Color(0.14, 0.10, 0.22, 1.0) if is_glow_bg else Color(0.24, 0.18, 0.32, 1.0)\n",
    "\t\t\tif is_fx_layer:\n",
    "\t\t\t\tlayer.modulate = Color(base_tint.r * 1.35, base_tint.g * 1.35, base_tint.b * 1.35, 0.50)\n",
    "\t\t\telse:\n",
    "\t\t\t\tlayer.modulate = base_tint\n",
    "\n",
    "\tif sky_parallax_layer:\n",
    "\t\tsky_parallax_layer.visible = not is_cave\n",
    "\n",
    "\tif sky_sprite:\n",
    "\t\tif is_cave:\n",
    "\t\t\tsky_sprite.modulate = Color(0.015, 0.02, 0.04, 1.0)\n",
    "\t\telif is_rainy:\n",
    "\t\t\tsky_sprite.modulate = Color(0.35, 0.40, 0.52, 1.0)\n",
    "\t\telif cur_lvl_title == \"Level 2-2\":\n",
    "\t\t\tsky_sprite.modulate = Color(1.02, 0.82, 0.90, 1.0)\n",
    "\t\telif cur_lvl_title in [\"Level 2-3\", \"Level 2-4\", \"Level 2-5\"]:\n",
    "\t\t\tsky_sprite.modulate = Color(1.08, 0.70, 0.58, 1.0)\n",
    "\t\telse:\n",
    "\t\t\tsky_sprite.modulate = Color(1.0, 1.0, 1.0, 1.0)\n",
    "\n",
    "\t# Toggle Hollow Knight deep subterranean vignette\n",
    "\tif cave_vignette:\n",
    "\t\tcave_vignette.modulate = Color(1.0, 1.0, 1.0, 0.95) if is_cave else Color(1.0, 1.0, 1.0, 0.0)\n",
    "\n",
    "\tif is_cave:\n",
    "\t\tif cur_lvl_title == \"Level 4-1\":\n",
    "\t\t\tbase_modulate_color = Color(0.24, 0.26, 0.36, 1.0)\n",
    "\t\telif cur_lvl_title == \"Level 4-2\":\n",
    "\t\t\tbase_modulate_color = Color(0.20, 0.22, 0.32, 1.0)\n",
    "\t\telif cur_lvl_title in [\"Level 4-3\", \"Level 4-4\"]:\n",
    "\t\t\tbase_modulate_color = Color(0.16, 0.18, 0.26, 1.0)\n",
    "\t\telse:\n",
    "\t\t\tbase_modulate_color = Color(0.12, 0.14, 0.22, 1.0)\n",
    "\t\tif canvas_modulate:\n",
    "\t\t\tcanvas_modulate.color = base_modulate_color\n",
    "\t\tif is_instance_valid(player):\n",
    "\t\t\tvar p_light = player.get_node_or_null(\"CaveSpiritLight\") as PointLight2D\n",
    "\t\t\tif not p_light:\n",
    "\t\t\t\tvar light_tex = load(\"res://assets/vfx/radial_light_falloff.png\")\n",
    "\t\t\t\tif light_tex:\n",
    "\t\t\t\t\tp_light = PointLight2D.new()\n",
    "\t\t\t\t\tp_light.name = \"CaveSpiritLight\"\n",
    "\t\t\t\t\tp_light.texture = light_tex\n",
    "\t\t\t\t\tp_light.position = Vector2(0.0, -18.0)\n",
    "\t\t\t\t\tp_light.color = Color(0.68, 0.88, 1.0, 0.95)\n",
    "\t\t\t\t\tp_light.energy = 1.15\n",
    "\t\t\t\t\tp_light.texture_scale = 0.65\n",
    "\t\t\t\t\tplayer.add_child(p_light)\n",
    "\t\t\telse:\n",
    "\t\t\t\tp_light.color = Color(0.68, 0.88, 1.0, 0.95)\n",
    "\t\t\t\tp_light.energy = 1.15\n",
    "\t\t\t\tp_light.texture_scale = 0.65\n",
    "\t\tif rain_particles:\n",
    "\t\t\train_particles.emitting = false\n",
    "\t\tif rain_particles_fg:\n",
    "\t\t\train_particles_fg.emitting = false\n",
    "\t\tif rain_particles_bg:\n",
    "\t\t\train_particles_bg.emitting = false\n",
    "\t\tif rain_splashes:\n",
    "\t\t\train_splashes.emitting = false\n",
    "\t\tif storm_fog:\n",
    "\t\t\tstorm_fog.emitting = true\n",
    "\t\t\tstorm_fog.modulate = Color(0.32, 0.62, 0.92, 0.24)\n"
]

lines = lines[:start_idx] + new_bg_block + lines[end_idx:]

with open("scripts/main.gd", "w", encoding="utf-8") as f:
    f.writelines(lines)

print("Cleanly replaced background theme setup!")
