import numpy as np
from PIL import Image

print("--- TILESET 1 CELLS ---")
for r in range(4):
    for c in range(4):
        fn = f"scratch/tileset_1_slices/cell_{r}_{c}.png"
        im = Image.open(fn).convert("RGB")
        arr = np.array(im)
        print(f"R{r}C{c}: mean={arr.mean(axis=(0,1)).astype(int)} min={arr.min(axis=(0,1))} max={arr.max(axis=(0,1))}")
