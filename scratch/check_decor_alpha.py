from PIL import Image
import numpy as np

im = Image.open('assets/platform_assets/Decor.png')
for y in range(17):
    row_tiles = []
    for x in range(13):
        c = im.crop((x*32, y*32, (x+1)*32, (y+1)*32))
        arr = np.array(c)
        alpha = arr[:, :, 3]
        if np.any(alpha > 0):
            # non empty
            row_tiles.append(f'({x},{y}): a={np.mean(alpha>0):.2f}')
    if row_tiles:
        print(f'Row {y}: ' + ', '.join(row_tiles[:6]))
