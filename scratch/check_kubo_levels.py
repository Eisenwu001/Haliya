from PIL import Image
import numpy as np

im = Image.open('assets/rice_field/bahay_kubo.png')
print("Kubo size:", im.size) # 192x143
arr = np.array(im)
H, W, _ = arr.shape

# Let's inspect density per row from top (y=0) to bottom (y=H-1):
# In Godot, spr.offset = Vector2(0.0, -H/2) = Vector2(0.0, -71.5)
# Ground is at local y = 0.0 (pixel y = 143)
# Local y = pixel_y - 143
print("Row densities (alpha > 30):")
for r in range(0, H, 10):
    density = (arr[r, :, 3] > 30).sum()
    print(f"  pixel y={r} (local y={r - 143}): {density} pixels / {W}")
