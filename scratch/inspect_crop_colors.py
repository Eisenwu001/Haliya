from PIL import Image
import numpy as np

im = Image.open('scratch/center_crop_2_1.png')
print("Size:", im.size)
arr = np.array(im)
# Find the carabao in this crop
# The carabao has specific dark grey/blue tones
# Let's see what colors are present in this crop
# Let's save a smaller or sliced version, or detect regions
print("RGB min:", arr.min(axis=(0,1)), "RGB max:", arr.max(axis=(0,1)), "RGB mean:", arr.mean(axis=(0,1)))
