import numpy as np
from PIL import Image

print("--- PLATFORM 2 CELLS ---")
for r in range(3):
    for c in range(4):
        im = Image.open(f"scratch/plat_2_slices/cell_{r}_{c}.png")
        arr = np.array(im)
        mean_col = arr.mean(axis=(0,1)).astype(int)
        std_col = arr.std(axis=(0,1)).astype(int)
        print(f"cell_{r}_{c}: mean={mean_col} std={std_col}")
