with open('scripts/main.gd', 'r', encoding='utf-8') as f:
    c = f.read()

target = """\tvar ceiling_tex = CaveAssetsScript.get_ceiling_tex()
\tif ceiling_tex:
\t\tvar tex_w: float = float(ceiling_tex.get_width())
\t\tvar num_ceiling_tiles: int = int(ceil(LEVEL_WIDTH / tex_w)) + 2
\t\tfor i in range(-1, num_ceiling_tiles):
\t\t\tvar c_spr := Sprite2D.new()
\t\t\tc_spr.texture = ceiling_tex
\t\t\tc_spr.centered = false
\t\t\tc_spr.position = Vector2(i * tex_w, -16.0)
\t\t\tceiling_root.add_child(c_spr)

\tvar num_ceiling_spans: int = int(ceil(LEVEL_WIDTH / 96.0))
\tfor ci in range(num_ceiling_spans):
\t\tvar cx: float = ci * 96.0 + 48.0
\t\tif ci % 4 == 1:
\t\t\tvar drip := CPUParticles2D.new()
\t\t\tdrip.emitting = true
\t\t\tdrip.amount = 2
\t\t\tdrip.lifetime = 1.8
\t\t\tdrip.direction = Vector2(0, 1)
\t\t\tdrip.spread = 4.0
\t\t\tdrip.gravity = Vector2(0, 260.0)
\t\t\tdrip.initial_velocity_min = 10.0
\t\t\tdrip.initial_velocity_max = 22.0
\t\t\tdrip.scale_amount_min = 1.2
\t\t\tdrip.scale_amount_max = 2.0
\t\t\tdrip.color = Color(0.38, 0.75, 0.95, 0.65)
\t\t\tdrip.position = Vector2(cx, 80.0)
\t\t\tceiling_root.add_child(drip)

\t# 8. Subtle Subterranean Spore Motes throughout the Cavern
\tvar spores := CPUParticles2D.new()
\tspores.name = "CavernSporeMotes"
\tspores.position = Vector2(LEVEL_WIDTH / 2.0, 180.0)
\tspores.amount = 16
\tspores.lifetime = 5.0
\tspores.preprocess = 2.0
\tspores.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
\tspores.emission_rect_extents = Vector2(LEVEL_WIDTH / 2.0, 160.0)"""

replacement = """\tvar ceiling_tex = CaveAssetsScript.get_ceiling_tex()
\tif ceiling_tex:
\t\tvar tex_w: float = float(ceiling_tex.get_width())
\t\tvar num_ceiling_tiles: int = int(ceil(current_level_width / tex_w)) + 3
\t\tfor i in range(-1, num_ceiling_tiles):
\t\t\tvar c_spr := Sprite2D.new()
\t\t\tc_spr.texture = ceiling_tex
\t\t\tc_spr.centered = false
\t\t\tc_spr.position = Vector2(i * tex_w, -12.0)
\t\t\tceiling_root.add_child(c_spr)

\tvar num_ceiling_spans: int = int(ceil(current_level_width / 96.0))
\tfor ci in range(num_ceiling_spans):
\t\tvar cx: float = ci * 96.0 + 48.0
\t\tif ci % 4 == 1:
\t\t\tvar drip := CPUParticles2D.new()
\t\t\tdrip.emitting = true
\t\t\tdrip.amount = 2
\t\t\tdrip.lifetime = 1.8
\t\t\tdrip.direction = Vector2(0, 1)
\t\t\tdrip.spread = 4.0
\t\t\tdrip.gravity = Vector2(0, 260.0)
\t\t\tdrip.initial_velocity_min = 10.0
\t\t\tdrip.initial_velocity_max = 22.0
\t\t\tdrip.scale_amount_min = 1.2
\t\t\tdrip.scale_amount_max = 2.0
\t\t\tdrip.color = Color(0.38, 0.75, 0.95, 0.65)
\t\t\tdrip.position = Vector2(cx, 80.0)
\t\t\tceiling_root.add_child(drip)

\t# 8. Subtle Subterranean Spore Motes throughout the Cavern
\tvar spores := CPUParticles2D.new()
\tspores.name = "CavernSporeMotes"
\tspores.position = Vector2(current_level_width / 2.0, current_level_height / 2.0)
\tspores.amount = 32
\tspores.lifetime = 5.0
\tspores.preprocess = 2.0
\tspores.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
\tspores.emission_rect_extents = Vector2(current_level_width / 2.0, current_level_height / 2.0)"""

c_norm = c.replace('\r\n', '\n')
target_norm = target.replace('\r\n', '\n')
replacement_norm = replacement.replace('\r\n', '\n')

if target_norm in c_norm:
    c_norm = c_norm.replace(target_norm, replacement_norm, 1)
    with open('scripts/main.gd', 'w', encoding='utf-8') as f:
        f.write(c_norm)
    print("SUCCESS: Updated ceiling and spores in main.gd")
else:
    print("ERROR: Target block not found in main.gd")
