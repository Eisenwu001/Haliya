from PIL import Image
import numpy as np

im = Image.open('assets/bahay_kubo/tile_deck_platform.png')
arr = np.array(im)
alpha = arr[:, :, 3]

for x in range(15):
    cnt = np.sum(alpha[:, x] > 20)
    print(f'cleaned x={x:2d}: {cnt} px')
