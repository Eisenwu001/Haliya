from PIL import Image
import numpy as np

im = Image.open('scratch/transition_render_21_22.png')
arr = np.array(im)
# check where alpha == 0
print("Canvas size:", im.size)
# print per row non-zero alpha count
for r in range(im.size[1]):
    if r % 16 == 0:
        row_alpha = (arr[r, :, 3] > 0).sum()
        print(f"y={r}: opaque pixels = {row_alpha} / {im.size[0]}")
