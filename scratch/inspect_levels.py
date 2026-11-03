import re

def inspect_scene_tiles(scene_path):
    print("=== INSPECTING", scene_path, "===")
    with open(scene_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Check if it has BaseGround
    m = re.search(r'\[node name="BaseGround" type="TileMapLayer"[^\]]*\]', content)
    if m:
        print("Has BaseGround TileMapLayer!")
    m2 = re.search(r'\[node name="WaterBackground" type="TileMapLayer"[^\]]*\]', content)
    if m2:
        print("Has WaterBackground TileMapLayer!")

    # Check child nodes of root
    children = re.findall(r'\[node name="([^"]+)" type="([^"]+)" parent="\."', content)
    print("Children:", children)

    # Check enemies
    enemies = re.findall(r'\[node name="([^"]+)" type="([^"]+)" parent="Enemies"[^\]]*\]\s*(?:(?:[^\n]*\n)*?)position = Vector2\(([^)]+)\)', content)
    print(f"Enemies ({len(enemies)}):", enemies[:5])

for sc in [
    'scenes/forest/level_1_1.tscn',
    'scenes/forest/level_1_2.tscn',
    'scenes/forest/level_1_3.tscn',
    'scenes/rainy_forest/level_3_5.tscn'
]:
    inspect_scene_tiles(sc)
