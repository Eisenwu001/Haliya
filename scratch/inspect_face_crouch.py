from PIL import Image
import numpy as np

img = Image.open('assets/haliya/common_01_idle_crouch.png').convert('RGBA')
arr = np.array(img)

# Print the face area around x in [115, 145], y in [180, 205]
crop = arr[180:205, 115:145]
print('Face crop shape:', crop.shape)

# Let\'s see characters representing colors
for y in range(180, 205):
    line = ''
    for x in range(115, 145):
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
