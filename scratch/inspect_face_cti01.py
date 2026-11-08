from PIL import Image
import numpy as np

img = Image.open('Haliya with clothes/Haliya/Crouch/with mask/kampilan/common_01_crouch_to_idle01.png').convert('RGBA')
arr = np.array(img)

# Mask in crouch_to_idle01 was at x=[128, 145], y=[148, 166]
for y in range(145, 170):
    line = ''
    for x in range(125, 150):
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
        elif r < 50 and b > 40: # blue cloth
            line += '~'
        else:
            line += '?'
    if line.strip():
        print(f'{y:3d}: {line}')
