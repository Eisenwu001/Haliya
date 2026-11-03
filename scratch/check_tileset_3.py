import os
import cv2
import numpy as np
from PIL import Image

for r in range(4):
    for c in range(4):
        fn = f"scratch/tileset_3_slices/cell_{r}_{c}.png"
        im = Image.open(fn).convert("RGB")
        arr = np.array(im)
        print(f"R{r}C{c}: mean={arr.mean(axis=(0,1)).astype(int)} min={arr.min(axis=(0,1))} max={arr.max(axis=(0,1))}")
