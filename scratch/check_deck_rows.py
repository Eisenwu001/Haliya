from PIL import Image
import numpy as np

im = Image.open('assets/bahay_kubo/tile_deck_platform.png')
arr = np.array(im)
print('Total shape:', arr.shape)

# Let's inspect rows 0..10 and rows 65..78
alpha = arr[:, :, 3]
for y in range(15):
    print(f'row {y}: {np.sum(alpha[y, :] > 0)} pixels')

print('--- bottom rows ---')
for y in range(65, 79):
    print(f'row {y}: {np.sum(alpha[y, :] > 0)} pixels')
