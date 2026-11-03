from PIL import Image
import numpy as np

im = Image.open('scratch/test_arch_preview.png')
arr = np.array(im)

# In rows 32..95, clear the middle part x in 28..115 so the center is open for player crouching
arr[32:, 28:115] = 0

arch = Image.fromarray(arr, 'RGBA')
arch.save('scratch/test_arch_open.png')
print('Open arch saved!')
