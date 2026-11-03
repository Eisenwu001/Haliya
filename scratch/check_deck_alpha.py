from PIL import Image
import numpy as np

im = Image.open('assets/bahay_kubo/tile_deck_platform.png')
arr = np.array(im)
alpha = arr[:, :, 3]

# Find bounding box of non-zero alpha
ys, xs = np.where(alpha > 0)
print('Y range:', ys.min(), ys.max(), 'X range:', xs.min(), xs.max())

# Check left/right border columns
for x in range(15):
    count = np.sum(alpha[:, x] > 0)
    print(f'col {x}: {count} opaque pixels')

print('--- right border ---')
for x in range(im.size[0] - 15, im.size[0]):
    count = np.sum(alpha[:, x] > 0)
    print(f'col {x}: {count} opaque pixels')
