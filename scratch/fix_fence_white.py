from PIL import Image
import numpy as np

im = Image.open('assets/bahay_kubo/prop_wooden_fence.png')
arr = np.array(im)

# Check near-white pixels: R > 230, G > 230, B > 230
white_mask = (arr[:, :, 0] > 230) & (arr[:, :, 1] > 230) & (arr[:, :, 2] > 230)
print('White pixels in fence:', np.sum(white_mask))

# If we set alpha=0 for all white pixels:
arr[white_mask, 3] = 0
cleaned = Image.fromarray(arr, 'RGBA')
cleaned.save('assets/bahay_kubo/prop_wooden_fence.png')
print('Cleaned prop_wooden_fence.png!')
