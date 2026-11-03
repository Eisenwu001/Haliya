import os

with open('scripts/main.gd', 'r', encoding='utf-8') as f:
    text = f.read()

# 1. Add level dimensions variables
var_decl = """const LEVEL_WIDTH: float = 5120.0
const MAP_TRANSITION_EDGE_X: float = 5050.0
var current_level_width: float = 5120.0
var current_level_height: float = 360.0
var current_level_transition_x: float = 5050.0"""

text = text.replace("""const LEVEL_WIDTH: float = 5120.0
const MAP_TRANSITION_EDGE_X: float = 5050.0""", var_decl)

# 2. In load_current_level, configure per-level dimensions
level_cfg_target = """\tvar data = LEVELS_DATA[current_level_idx]
\tvar scene_path: String = data.get("scene_path", "")"""

level_cfg_repl = """\tvar data = LEVELS_DATA[current_level_idx]
\tvar scene_path: String = data.get("scene_path", "")

\tvar is_cave_stage_dim: bool = (data.get("theme", "") == "Cave" or data.get("theme", "") == "Cave Boss")
\tif is_cave_stage_dim:
\t\tcurrent_level_width = 6400.0
\t\tcurrent_level_height = 1152.0
\t\tcurrent_level_transition_x = 6300.0
\t\tif is_instance_valid(player):
\t\t\tplayer.fall_death_y = 1350.0
\telse:
\t\tcurrent_level_width = LEVEL_WIDTH
\t\tcurrent_level_height = 360.0
\t\tcurrent_level_transition_x = MAP_TRANSITION_EDGE_X
\t\tif is_instance_valid(player):
\t\t\tplayer.fall_death_y = 600.0"""

text = text.replace(level_cfg_target, level_cfg_repl)

# 3. In setup_map_edge_boundaries, update wall dimensions
text = text.replace(
    'left_rect.size = Vector2(32.0, 900.0)\n\tleft_shape.shape = left_rect\n\tleft_wall.position = Vector2(-16.0, 150.0)',
    'left_rect.size = Vector2(32.0, 2400.0)\n\tleft_shape.shape = left_rect\n\tleft_wall.position = Vector2(-16.0, 500.0)'
)
text = text.replace(
    'right_floor.position = Vector2(5120.0 + 300.0, ground_end_y + 32.0)',
    'right_floor.position = Vector2(current_level_width + 300.0, ground_end_y + 32.0)'
)
text = text.replace(
    'backstop_rect.size = Vector2(32.0, 900.0)\n\tbackstop_shape.shape = backstop_rect\n\tbackstop.position = Vector2(5120.0 + 600.0 + 16.0, ground_end_y - 450.0 + 32.0)',
    'backstop_rect.size = Vector2(32.0, 2400.0)\n\tbackstop_shape.shape = backstop_rect\n\tbackstop.position = Vector2(current_level_width + 600.0 + 16.0, 500.0)'
)

# 4. In setup_exit_barrier, update wall dimensions and position
text = text.replace(
    'rect.size = Vector2(32.0, 900.0)\n\t\tshape.shape = rect\n\t\texit_barrier_body.add_child(shape)\n\t\texit_barrier_body.global_position = Vector2(MAP_TRANSITION_EDGE_X - 40.0, 150.0)',
    'rect.size = Vector2(32.0, 2400.0)\n\t\tshape.shape = rect\n\t\texit_barrier_body.add_child(shape)\n\t\texit_barrier_body.global_position = Vector2(current_level_transition_x - 40.0, 500.0)'
)

# 5. In _process, update camera tracking and transition
old_cam = """\t\tvar cam_min_x: float = 320.0
\t\tvar cam_max_x: float = LEVEL_WIDTH - 320.0
\t\tif is_boss_active:
\t\t\tcam_min_x = 4080.0
\t\t\tcam_max_x = 4760.0
\t\telif is_miniboss_arena_locked:
\t\t\tcam_min_x = 4300.0
\t\t\tcam_max_x = 4760.0
\t\tvar target_x: float = clamp(player.global_position.x, cam_min_x, cam_max_x)
\t\tcamera.global_position = Vector2(target_x, 180.0)"""

new_cam = """\t\tvar cam_min_x: float = 320.0
\t\tvar cam_max_x: float = current_level_width - 320.0
\t\tvar cam_min_y: float = 180.0
\t\tvar cam_max_y: float = max(180.0, current_level_height - 180.0)
\t\tif is_boss_active:
\t\t\tcam_min_x = 4080.0
\t\t\tcam_max_x = 4760.0
\t\telif is_miniboss_arena_locked:
\t\t\tcam_min_x = 4300.0
\t\t\tcam_max_x = 4760.0
\t\tvar target_x: float = clamp(player.global_position.x, cam_min_x, cam_max_x)
\t\tvar target_y: float = clamp(player.global_position.y, cam_min_y, cam_max_y)
\t\tcamera.global_position = Vector2(target_x, target_y)"""

text = text.replace(old_cam, new_cam)

text = text.replace(
    'elif player.global_position.x >= MAP_TRANSITION_EDGE_X:',
    'elif player.global_position.x >= current_level_transition_x:'
)

text = text.replace(
    'camera.global_position = Vector2(clamp(SPAWN_POS.x, 320.0, LEVEL_WIDTH - 320.0), 180.0)',
    'camera.global_position = Vector2(clamp(SPAWN_POS.x, 320.0, current_level_width - 320.0), 180.0)'
)

with open('scripts/main.gd', 'w', encoding='utf-8', newline='\r\n') as f:
    f.write(text)

print('Updated scripts/main.gd with vertical camera and dynamic bounds!')
