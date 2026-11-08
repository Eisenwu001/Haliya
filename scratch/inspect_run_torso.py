from PIL import Image
import numpy as np

for i in [1, 2, 3]:
    name = f'common_12_run{i:02d}.png'
    img = Image.open(f'assets/haliya_backup_originals/{name}').convert('RGBA')
    arr = np.array(img)
    
    print(f'=== Run {i} Midriff (y=175..195) ===')
    for y in range(175, 195, 2):
        line = ''
        for x in range(90, 150):
            r, g, b, a = arr[y, x]
            if a == 0: line += ' '
            elif (r, g, b) == (4, 5, 6) or (r, g, b) == (0, 0, 0): line += '#'
            elif r > 180 and g > 120 and b > 100: line += '.' # skin
            elif r < 100 and g < 60: line += 'R' # red cloth
            elif r > 180 and g > 150: line += '*' # gold
            else: line += '?'
        if line.strip():
            print(f'{y:3d}: {line}')
