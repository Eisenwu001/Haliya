import os

def update_level_4_1():
    path = 'scenes/cave/level_4_1.tscn'
    with open(path, 'r', encoding='utf-8') as f:
        text = f.read()

    # Move CrystalGeode_1 from (340, 215) to (200, 288) so CavePlatform_1 is clean
    if '[node name="CrystalGeode_1"' in text:
        parts = text.split('[node name="CrystalGeode_1"')
        sub = parts[1].replace('position = Vector2(340, 215)', 'position = Vector2(200, 288)', 1)
        text = parts[0] + '[node name="CrystalGeode_1"' + sub
        with open(path, 'w', encoding='utf-8') as f:
            f.write(text)
        print('Updated level_4_1.tscn: CrystalGeode_1 moved to (200, 288)')

if __name__ == '__main__':
    update_level_4_1()
