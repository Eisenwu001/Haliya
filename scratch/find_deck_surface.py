from PIL import Image
import numpy as np

im = Image.open('assets/bahay_kubo/tile_deck_platform.png')
arr = np.array(im)
alpha = arr[:, :, 3]

# In the middle (x = 50..150), find first row with alpha > 100
for y in range(30):
    cnt = np.sum(alpha[y, 50:150] > 100)
    print(f'y={y:2d}: {cnt} solid pixels in middle')
