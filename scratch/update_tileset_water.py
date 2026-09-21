import shutil

shutil.copyfile('scenes/tileset.tres', 'scratch/tileset.tres.bak')

with open('scenes/tileset.tres', 'r', encoding='utf-8') as f:
    text = f.read()

target_start = '[sub_resource type="TileSetAtlasSource" id="TileSetAtlasSource_6jiih"]'
idx_start = text.find(target_start)
if idx_start == -1:
    print('Error: TileSetAtlasSource_6jiih not found')
    exit(1)

idx_end = text.find('[sub_resource', idx_start + 1)
if idx_end == -1:
    idx_end = text.find('[resource]', idx_start + 1)

lines = [
    '[sub_resource type="TileSetAtlasSource" id="TileSetAtlasSource_6jiih"]',
    'texture = ExtResource("3_1srhd")',
    'texture_region_size = Vector2i(32, 32)'
]

for r in range(11):
    if r == 2:
        # Row 2 is the static Solid Abyss Fill tile
        lines.append(f'0:{r}/0 = 0')
    else:
        # Rows 0, 1, and 3-10 are animated 20-frame rows
        lines.append(f'0:{r}/animation_columns = 20')
        for f in range(20):
            lines.append(f'0:{r}/animation_frame_{f}/duration = 0.15')
        lines.append(f'0:{r}/0 = 0')

new_source = '\n'.join(lines) + '\n\n'
new_text = text[:idx_start] + new_source + text[idx_end:]

with open('scenes/tileset.tres', 'w', encoding='utf-8', newline='\n') as f:
    f.write(new_text)

print('Successfully updated scenes/tileset.tres')

