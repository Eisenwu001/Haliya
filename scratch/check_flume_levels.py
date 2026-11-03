from PIL import Image
import numpy as np

im = Image.open('assets/rice_field/bamboo_flume.png')
print("Flume size:", im.size) # 144x56
arr = np.array(im)
H, W, _ = arr.shape
for r in range(0, H, 8):
    density = (arr[r, :, 3] > 30).sum()
    print(f"  pixel y={r} (local y={r - 56}): {density} pixels / {W}")
