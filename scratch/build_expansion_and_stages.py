import os
import re

print("Starting stage polish and expansion generation...")

# ── 1. Polish Stage 2 Scenes: level_2_1.tscn, level_2_2.tscn, level_2_3.tscn ──

def polish_rice_field_scene(file_path):
    with open(file_path, "r", encoding="utf-8") as f:
        content = f.read()

    # Replace ext_resources for kubo and flume with pilapil and mud puddle hazard
    content = content.replace(
        'path="res://scripts/bahay_kubo_prop.gd" id="7_kubo"',
        'path="res://scripts/pilapil_dike_prop.gd" id="7_pilapil"'
    )
    content = content.replace(
        'path="res://scripts/bamboo_flume_prop.gd" id="8_flume"',
        'path="res://scripts/mud_puddle_hazard.gd" id="8_puddle_hazard"'
    )

    # In level nodes: replace ExtResource("7_kubo") and ExtResource("8_flume")
    content = re.sub(
        r'\[node name="BahayKubo_(\d+)" type="StaticBody2D" parent="Props"\]\s+position = Vector2\(([^)]+)\)\s+script = ExtResource\("7_kubo"\)',
        r'[node name="PilapilDike_\1" type="StaticBody2D" parent="Props"]\nposition = Vector2(\2)\nscript = ExtResource("7_pilapil")',
        content
    )
    content = re.sub(
        r'\[node name="BambooFlume_(\d+)" type="StaticBody2D" parent="Props"\]\s+position = Vector2\(([^)]+)\)\s+script = ExtResource\("8_flume"\)',
        r'[node name="MudPuddle_\1" type="Area2D" parent="Props"]\nposition = Vector2(\2)\nscript = ExtResource("8_puddle_hazard")',
        content
    )

    # Update any legacy references to 7_kubo / 8_flume
    content = content.replace('ExtResource("7_kubo")', 'ExtResource("7_pilapil")')
    content = content.replace('ExtResource("8_flume")', 'ExtResource("8_puddle_hazard")')

    with open(file_path, "w", encoding="utf-8") as f:
        f.write(content)
    print(f"Polished {file_path}")

polish_rice_field_scene("scenes/rice_field/level_2_1.tscn")
polish_rice_field_scene("scenes/rice_field/level_2_2.tscn")
polish_rice_field_scene("scenes/rice_field/level_2_3.tscn")

# ── 2. Create scenes/rice_field/level_2_4.tscn (The Caldera Foothills) ─────────
# Read level_2_3.tscn as template for ground tilemap data and imports
with open("scenes/rice_field/level_2_3.tscn", "r", encoding="utf-8") as f:
    l23_text = f.read()

# Generate level_2_4.tscn
l24_text = l23_text.replace('[node name="Level_2_3" type="Node2D"]', '[node name="Level_2_4" type="Node2D"]')
# Add more Mud Puddle hazards and Pilapil dikes, adjust enemies for escalating challenge
l24_props = """[node name="Props" type="Node2D" parent="."]

[node name="MudPuddle_1" type="Area2D" parent="Props"]
position = Vector2(750.0, 288.0)
script = ExtResource("8_puddle_hazard")

[node name="PilapilDike_1" type="StaticBody2D" parent="Props"]
position = Vector2(750.0, 240.0)
script = ExtResource("7_pilapil")

[node name="MudPuddle_2" type="Area2D" parent="Props"]
position = Vector2(1650.0, 288.0)
script = ExtResource("8_puddle_hazard")

[node name="PilapilDike_2" type="StaticBody2D" parent="Props"]
position = Vector2(1650.0, 235.0)
script = ExtResource("7_pilapil")

[node name="Carabao_1" type="AnimatableBody2D" parent="Props"]
position = Vector2(2150.0, 288.0)
script = ExtResource("6_carabao")
facing_left = true

[node name="MudPuddle_3" type="Area2D" parent="Props"]
position = Vector2(2650.0, 256.0)
script = ExtResource("8_puddle_hazard")

[node name="PilapilDike_3" type="StaticBody2D" parent="Props"]
position = Vector2(2650.0, 210.0)
script = ExtResource("7_pilapil")

[node name="MudPuddle_4" type="Area2D" parent="Props"]
position = Vector2(3450.0, 256.0)
script = ExtResource("8_puddle_hazard")

[node name="PilapilDike_4" type="StaticBody2D" parent="Props"]
position = Vector2(3450.0, 210.0)
script = ExtResource("7_pilapil")

[node name="Carabao_2" type="AnimatableBody2D" parent="Props"]
position = Vector2(3950.0, 288.0)
script = ExtResource("6_carabao")
facing_left = false

[node name="RiceStalks_1" type="Node2D" parent="Props"]
position = Vector2(480.0, 288.0)
script = ExtResource("10_stalks")

[node name="RiceStalks_2" type="Node2D" parent="Props"]
position = Vector2(920.0, 288.0)
script = ExtResource("10_stalks")

[node name="RiceStalks_3" type="Node2D" parent="Props"]
position = Vector2(1420.0, 288.0)
script = ExtResource("10_stalks")

[node name="RiceStalks_4" type="Node2D" parent="Props"]
position = Vector2(2400.0, 256.0)
script = ExtResource("10_stalks")

[node name="RiceStalks_5" type="Node2D" parent="Props"]
position = Vector2(3180.0, 256.0)
script = ExtResource("10_stalks")

[node name="RiceStalks_6" type="Node2D" parent="Props"]
position = Vector2(3700.0, 288.0)
script = ExtResource("10_stalks")

[node name="Pot_1" type="StaticBody2D" parent="Props"]
position = Vector2(750.0, 228.0)
script = ExtResource("12_pot")

[node name="Pot_2" type="StaticBody2D" parent="Props"]
position = Vector2(2650.0, 198.0)
script = ExtResource("12_pot")
"""

# Replace Props section in l24_text
props_pattern = r'\[node name="Props" type="Node2D" parent="\."\].*?(?=\[node name="Enemies")'
l24_text = re.sub(props_pattern, l24_props + "\n", l24_text, flags=re.DOTALL)

with open("scenes/rice_field/level_2_4.tscn", "w", encoding="utf-8") as f:
    f.write(l24_text)
print("Created scenes/rice_field/level_2_4.tscn")

# ── 3. Create scenes/rice_field/level_2_5.tscn (The Burning Kiln Village) ───────
l25_text = l23_text.replace('[node name="Level_2_3" type="Node2D"]', '[node name="Level_2_5" type="Node2D"]')
l25_props = """[node name="Props" type="Node2D" parent="."]

[node name="MudPuddle_1" type="Area2D" parent="Props"]
position = Vector2(620.0, 288.0)
script = ExtResource("8_puddle_hazard")

[node name="PilapilDike_1" type="StaticBody2D" parent="Props"]
position = Vector2(620.0, 240.0)
script = ExtResource("7_pilapil")

[node name="Pot_1" type="StaticBody2D" parent="Props"]
position = Vector2(620.0, 228.0)
script = ExtResource("12_pot")

[node name="MudPuddle_2" type="Area2D" parent="Props"]
position = Vector2(1380.0, 288.0)
script = ExtResource("8_puddle_hazard")

[node name="PilapilDike_2" type="StaticBody2D" parent="Props"]
position = Vector2(1380.0, 235.0)
script = ExtResource("7_pilapil")

[node name="Pot_2" type="StaticBody2D" parent="Props"]
position = Vector2(1380.0, 223.0)
script = ExtResource("12_pot")

[node name="Carabao_1" type="AnimatableBody2D" parent="Props"]
position = Vector2(1950.0, 288.0)
script = ExtResource("6_carabao")
facing_left = true

[node name="MudPuddle_3" type="Area2D" parent="Props"]
position = Vector2(2520.0, 256.0)
script = ExtResource("8_puddle_hazard")

[node name="PilapilDike_3" type="StaticBody2D" parent="Props"]
position = Vector2(2520.0, 210.0)
script = ExtResource("7_pilapil")

[node name="Pot_3" type="StaticBody2D" parent="Props"]
position = Vector2(2520.0, 198.0)
script = ExtResource("12_pot")

[node name="MudPuddle_4" type="Area2D" parent="Props"]
position = Vector2(3350.0, 256.0)
script = ExtResource("8_puddle_hazard")

[node name="PilapilDike_4" type="StaticBody2D" parent="Props"]
position = Vector2(3350.0, 210.0)
script = ExtResource("7_pilapil")

[node name="Pot_4" type="StaticBody2D" parent="Props"]
position = Vector2(3350.0, 198.0)
script = ExtResource("12_pot")

[node name="RiceStalks_1" type="Node2D" parent="Props"]
position = Vector2(380.0, 288.0)
script = ExtResource("10_stalks")

[node name="RiceStalks_2" type="Node2D" parent="Props"]
position = Vector2(1040.0, 288.0)
script = ExtResource("10_stalks")

[node name="RiceStalks_3" type="Node2D" parent="Props"]
position = Vector2(1720.0, 288.0)
script = ExtResource("10_stalks")

[node name="RiceStalks_4" type="Node2D" parent="Props"]
position = Vector2(2280.0, 256.0)
script = ExtResource("10_stalks")

[node name="RiceStalks_5" type="Node2D" parent="Props"]
position = Vector2(3040.0, 256.0)
script = ExtResource("10_stalks")

[node name="RiceStalks_6" type="Node2D" parent="Props"]
position = Vector2(3820.0, 288.0)
script = ExtResource("10_stalks")
"""

l25_text = re.sub(props_pattern, l25_props + "\n", l25_text, flags=re.DOTALL)

with open("scenes/rice_field/level_2_5.tscn", "w", encoding="utf-8") as f:
    f.write(l25_text)
print("Created scenes/rice_field/level_2_5.tscn")

# ── 4. Create scenes/cave/level_4_4.tscn (The Chasm of Devoured Moons) ─────────
with open("scenes/cave/level_4_3.tscn", "r", encoding="utf-8") as f:
    l43_text = f.read()

l44_text = l43_text.replace('[node name="Level4_3" type="Node2D"]', '[node name="Level4_4" type="Node2D"]')
with open("scenes/cave/level_4_4.tscn", "w", encoding="utf-8") as f:
    f.write(l44_text)
print("Created scenes/cave/level_4_4.tscn")

print("All scenes generated successfully!")
