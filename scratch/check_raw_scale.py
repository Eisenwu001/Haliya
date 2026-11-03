from PIL import Image
import numpy as np

raw = Image.open('assets/rice_field/carabao_raw.png')
print("raw size:", raw.size) # 882, 656
# Let's find tight bounding box of alpha > 10 in carabao_raw:
arr = np.array(raw)
alpha = arr[:, :, 3]
ys, xs = np.where(alpha > 10)
print(f"Tight bbox in raw: x=({xs.min()}..{xs.max()}) w={xs.max()-xs.min()+1}, y=({ys.min()}..{ys.max()}) h={ys.max()-ys.min()+1}")

# What is the ratio to 120x84?
bbox = raw.crop((xs.min(), ys.min(), xs.max() + 1, ys.max() + 1))
print(f"Cropped raw bbox size: {bbox.size}")

# If we scale it down with aspect ratio preserved:
# Let's say target height is ~64px or width ~104px (so it fits nicely in 120x84 with margin all around):
target_h = 70
scale = target_h / bbox.size[1]
target_w = int(bbox.size[0] * scale)
print(f"Scaled size: {target_w}x{target_h}")

scaled = bbox.resize((target_w, target_h), Image.Resampling.LANCZOS)
scaled.save("scratch/carabao_scaled_clean.png")
print("Saved scratch/carabao_scaled_clean.png")
