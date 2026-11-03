from PIL import Image
import numpy as np

raw = Image.open('assets/rice_field/carabao_raw.png')
# Where is the head/horns?
# Let's check the top non-zero pixels (horns) at x=323..348: that's around the left-center.
# What about x=0..200 vs x=700..880?
arr = np.array(raw)
left_quad = arr[:, :200, :]
right_quad = arr[:, 680:, :]
print("Left quad nonz:", (left_quad[:, :, 3] > 20).sum())
print("Right quad nonz:", (right_quad[:, :, 3] > 20).sum())

# In carabao_spritesheet.png:
sheet_f0 = Image.open('scratch_carabao_f0.png')
print("sheet_f0 size:", sheet_f0.size)
# Compare clean_base to sheet_f0
