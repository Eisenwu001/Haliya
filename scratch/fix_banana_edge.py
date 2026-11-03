from PIL import Image
import numpy as np

im = Image.open('assets/bahay_kubo/prop_banana_tree.png')
arr = np.array(im)

# Check cols 0..5 for white pixels
for x in range(6):
    col = arr[:, x]
    white_mask = (col[:, 0] > 220) & (col[:, 1] > 220) & (col[:, 2] > 220)
    print(f'col {x}: {np.sum(white_mask)} white pixels')

# Clean near-white pixels throughout banana tree
white_all = (arr[:, :, 0] > 225) & (arr[:, :, 1] > 225) & (arr[:, :, 2] > 225)
print('Total near-white pixels in banana tree:', np.sum(white_all))
arr[white_all, 3] = 0

# Also clean any non-zero alpha in cols 0..2 if they are artifacts
arr[:, :2, 3] = 0

cleaned = Image.fromarray(arr, 'RGBA')
cleaned.save('assets/bahay_kubo/prop_banana_tree.png')
print('Cleaned prop_banana_tree.png!')
