import re

scenes = [
    r'scenes\cave\level_4_1.tscn',
    r'scenes\cave\level_4_2.tscn',
    r'scenes\cave\level_4_3.tscn',
    r'scenes\cave\level_5.tscn'
]

for s_path in scenes:
    with open(s_path, 'r', encoding='utf-8') as f:
        content = f.read()

    # Find SpikeHazards to get pit bounds:
    # position = Vector2(x, 448) ... hazard_width = w
    spike_ranges = []
    # search for SpikeBed nodes
    spike_pattern = re.compile(r'\[node name=\"SpikeBed_\d+\"[^\]]*\]\s*position = Vector2\(([^,\)]+),\s*([^\)]+)\)[^\n]*\n(?:[^\n]*\n)*?hazard_width = ([^\n]+)')
    for m in spike_pattern.finditer(content):
        sx = float(m.group(1))
        sw = float(m.group(3))
        # Spike bed is centered or starts at sx
        # In cave_spike_hazard.gd: collision shape is at hazard_width * 0.5
        # so pit is roughly [sx - 32, sx + sw + 32]
        spike_ranges.append((sx - 32.0, sx + sw + 32.0))
    
    print(f'=== {s_path} ===')
    print(f'Detected {len(spike_ranges)} spike pits: {spike_ranges}')

    # Process LevelProps
    # Split content by [node name=
    blocks = content.split('[node name=')
    new_blocks = [blocks[0]]
    
    removed_count = 0
    snapped_count = 0

    for b in blocks[1:]:
        header = b.split('\n')[0]
        # Check if this node is inside LevelProps
        if 'parent="LevelProps"' in header or 'parent="LevelProps"' in b[:100]:
            name = header.split('"')[1]
            pos_m = re.search(r'position = Vector2\(([^,\)]+),\s*([^\)]+)\)', b)
            if pos_m:
                px = float(pos_m.group(1))
                py = float(pos_m.group(2))
                
                # Check if px falls inside any spike pit
                in_pit = False
                for (p_start, p_end) in spike_ranges:
                    if p_start <= px <= p_end:
                        in_pit = True
                        break
                
                if in_pit:
                    print(f'  REMOVING prop in pit: {name} at ({px}, {py})')
                    removed_count += 1
                    continue # Do not include this node block!
                
                # Otherwise, snap to ground floor
                if 'CrystalSpire' in name or 'Stele' in name:
                    # Anito stone idol (height 48) sitting on y=288
                    new_y = 264.0
                    b = re.sub(r'position = Vector2\([^,\)]+,\s*[^\)]+\)', f'position = Vector2({px}, {new_y})', b)
                    snapped_count += 1
                elif 'Flora' in name:
                    # Blue glow moss (height 32) sitting on y=288
                    new_y = 272.0
                    b = re.sub(r'position = Vector2\([^,\)]+,\s*[^\)]+\)', f'position = Vector2({px}, {new_y})', b)
                    snapped_count += 1
                    
        new_blocks.append(b)

    final_content = '[node name='.join(new_blocks)
    with open(s_path, 'w', encoding='utf-8') as f:
        f.write(final_content)
    print(f'Finished {s_path}: removed {removed_count} floating props, snapped {snapped_count} ground props.\n')
