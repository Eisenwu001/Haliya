from PIL import Image
import numpy as np

im = Image.open('assets/bahay_kubo/tile_deck_platform.png')
arr = np.array(im)
alpha = arr[:, :, 3]

for x in range(0, 35):
    cnt = np.sum(alpha[:, x] > 20)
    print(f'x={x:2d}: {cnt} px')

print('--- right side ---')
for x in range(im.size[0] - 25, im.size[0]):
    cnt = np.sum(alpha[:, x] > 20)
    print(f'x={x:3d}: {cnt} px')
