from PIL import Image
import numpy as np

im = Image.open("scratch/verify_snap1_carabao.png")
arr = np.array(im)

# Carabao color range in the scene
# Check for any bright white lines (R>230, G>230, B>230) in the carabao body
# Let's see:
print("Crop size:", im.size)
bright = (arr[:, :, 0] > 220) & (arr[:, :, 1] > 220) & (arr[:, :, 2] > 220)
print("Bright pixels count in crop:", np.count_nonzero(bright))
# The player has white hair / mask, so bright pixels exist there, but let's check the carabao area
