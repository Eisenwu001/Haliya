with open('scripts/main.gd', 'r', encoding='utf-8') as f:
    code = f.read()

# 1. Update configure_cave_environment ceiling canopy placement
old_ceiling_block = """\t# 7. Sculpted Cavern Ceiling Canopy & Water Drips
\tvar ceiling_root := Node2D.new()
\tceiling_root.name = "CaveCeilingCanopy"
\tceiling_root.z_index = 2
\troot_level.add_child(ceiling_root)

\tvar ceiling_tex = CaveAssetsScript.get_ceiling_tex()
\tif ceiling_tex:
\t\tvar tex_w: float = float(ceiling_tex.get_width())
\t\tvar num_ceiling_tiles: int = int(ceil(current_level_width / tex_w)) + 3
\t\tfor i in range(-1, num_ceiling_tiles):
\t\t\tvar c_spr := Sprite2D.new()
\t\t\tc_spr.texture = ceiling_tex
\t\t\tc_spr.centered = false
\t\t\tc_spr.position = Vector2(i * tex_w, -12.0)
\t\t\tceiling_root.add_child(c_spr)"""

new_ceiling_block = """\t# 7. Sculpted Cavern Ceiling Canopy & Water Drips
\tvar ceiling_root := Node2D.new()
\tceiling_root.name = "CaveCeilingCanopy"
\tceiling_root.z_index = 2
\troot_level.add_child(ceiling_root)

\tvar ceiling_tex = CaveAssetsScript.get_ceiling_tex()
\tif ceiling_tex:
\t\tvar tex_w: float = float(ceiling_tex.get_width())
\t\tvar num_ceiling_tiles: int = int(ceil(current_level_width / tex_w)) + 3
\t\tfor i in range(-1, num_ceiling_tiles):
\t\t\tvar c_spr := Sprite2D.new()
\t\t\tc_spr.texture = ceiling_tex
\t\t\tc_spr.centered = false
\t\t\tc_spr.position = Vector2(i * tex_w, 0.0)
\t\t\tceiling_root.add_child(c_spr)

\t\t# Subterranean grotto ceiling canopy for Chamber 3 (X=1600..3200 at Y=536)
\t\tfor gx in range(1600, 3200, int(tex_w)):
\t\t\tvar g_spr := Sprite2D.new()
\t\t\tg_spr.texture = ceiling_tex
\t\t\tg_spr.centered = false
\t\t\tg_spr.position = Vector2(float(gx), 536.0)
\t\t\tceiling_root.add_child(g_spr)"""

# 2. Update camera position target_y in process loop
old_cam_block = """\t\tvar target_x: float = clamp(player.global_position.x, cam_min_x, cam_max_x)
\t\tvar target_y: float = clamp(player.global_position.y, cam_min_y, cam_max_y)
\t\tcamera.global_position = Vector2(target_x, target_y)"""

new_cam_block = """\t\tvar is_cave: bool = (current_level_idx in [11, 12, 13, 14])
\t\tvar target_x: float = clamp(player.global_position.x, cam_min_x, cam_max_x)
\t\tvar target_y: float = clamp(player.global_position.y, cam_min_y, cam_max_y)
\t\tif is_cave:
\t\t\tif player.global_position.y < 350.0:
\t\t\t\ttarget_y = 180.0
\t\t\telif player.global_position.y > 700.0:
\t\t\t\ttarget_y = clamp(player.global_position.y - 70.0, 680.0, cam_max_y)
\t\t\telse:
\t\t\t\ttarget_y = clamp(player.global_position.y - 50.0, cam_min_y, cam_max_y)
\t\tcamera.global_position = Vector2(target_x, target_y)"""

code_norm = code.replace('\r\n', '\n')
old_ceiling_norm = old_ceiling_block.replace('\r\n', '\n')
new_ceiling_norm = new_ceiling_block.replace('\r\n', '\n')
old_cam_norm = old_cam_block.replace('\r\n', '\n')
new_cam_norm = new_cam_block.replace('\r\n', '\n')

assert old_ceiling_norm in code_norm, "Old ceiling block not found!"
code_norm = code_norm.replace(old_ceiling_norm, new_ceiling_norm, 1)

assert old_cam_norm in code_norm, "Old cam block not found!"
code_norm = code_norm.replace(old_cam_norm, new_cam_norm, 1)

with open('scripts/main.gd', 'w', encoding='utf-8') as f:
    f.write(code_norm)

print("SUCCESS: Updated main.gd ceiling and camera framing!")
