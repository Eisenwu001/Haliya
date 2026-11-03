from PIL import Image
import numpy as np

im = Image.open('assets/bahay_kubo/tile_deck_platform.png')
arr = np.array(im)

print('Alpha map x=185..205, y=0..30:')
for y in range(0, 30, 2):
    s = f'{y:2d}: '
    for x in range(185, 205):
        a = arr[y, x, 3]
        s += '#' if a > 100 else ('.' if a > 10 else ' ')
    print(s)
