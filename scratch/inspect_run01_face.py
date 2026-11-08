from PIL import Image
import numpy as np

img = Image.open('assets/haliya/common_12_run01.png').convert('RGBA')
arr = np.array(img)

# Print face area
for y in range(145, 175):
    line = ''
    for x in range(105, 140):
        r, g, b, a = arr[y, x]
        if a == 0:
            line += ' '
        elif (r, g, b) == (4, 5, 6):
            line += '#'
        elif r > 200 and g < 200 and b < 170: # skin
            line += '.'
        elif r > 200 and g > 200: # gold/white
            line += '*'
        elif r < 100 and g < 60: # red hair/top
            line += 'o'
        else:
            line += '?'
    if line.strip():
        print(f'{y:3d}: {line}')
