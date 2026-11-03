from PIL import Image
import numpy as np

im = Image.open('assets/rice_field/farmer_trans.png')
print("farmer_trans size:", im.size)
arr = np.array(im)
print("farmer_trans mode:", im.mode)
# Find bounding boxes of figures
alpha = arr[:, :, 3]
ys, xs = np.where(alpha > 20)
print(f"Overall bounds: x=({xs.min()}..{xs.max()}) y=({ys.min()}..{ys.max()})")

# Let's inspect columns with non-zero alpha to see figure separations:
col_sums = (alpha > 20).sum(axis=0)
import matplotlib
# Find gaps where col_sums == 0:
gaps = np.where(col_sums == 0)[0]
print(f"Total columns: {len(col_sums)}, columns with 0 alpha: {len(gaps)}")
