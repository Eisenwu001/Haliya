from PIL import Image
import numpy as np

raw = Image.open('assets/rice_field/carabao_raw.png')
arr = np.array(raw)
alpha = arr[:, :, 3]

# Let's check connected components of alpha > 50!
from scipy.ndimage import label
mask = alpha > 50
labeled, num_features = label(mask)
print(f"Num features: {num_features}")

# Find component sizes:
sizes = [(labeled == i).sum() for i in range(1, num_features + 1)]
largest_idx = np.argmax(sizes) + 1
print(f"Largest component size: {sizes[largest_idx - 1]} out of {mask.sum()} masked pixels")

# Where is this largest component?
ys, xs = np.where(labeled == largest_idx)
print(f"Main body bbox: x=({xs.min()}..{xs.max()}) w={xs.max()-xs.min()+1}, y=({ys.min()}..{ys.max()}) h={ys.max()-ys.min()+1}")

# What about the other components?
other_total = 0
for i, s in enumerate(sizes, start=1):
    if i != largest_idx and s > 10:
        o_ys, o_xs = np.where(labeled == i)
        print(f"  Feature {i}: size={s}, x=({o_xs.min()}..{o_xs.max()}), y=({o_ys.min()}..{o_ys.max()})")
        other_total += s
print(f"Total other pixels: {other_total}")
