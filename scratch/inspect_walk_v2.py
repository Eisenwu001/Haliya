from PIL import Image
import numpy as np

im = Image.open(r'C:\Users\Lin\.gemini\antigravity\brain\affaaa51-5c2e-4029-96b6-27d506de5489\farmer_walk_v2_1792756759455.jpg')
print("walk_v2 size:", im.size)
arr = np.array(im)
print("RGB sample at corners:", arr[0,0], arr[0,-1], arr[-1,0], arr[-1,-1])
# Magenta is ~ [255, 0, 255]
# Let's check non-magenta pixels:
is_magenta = (arr[:, :, 0] > 200) & (arr[:, :, 1] < 50) & (arr[:, :, 2] > 200)
print("Magenta fraction:", is_magenta.sum() / (arr.shape[0] * arr.shape[1]))
non_mag = ~is_magenta
ys, xs = np.where(non_mag)
print(f"Non-magenta bounds: x=({xs.min()}..{xs.max()}) y=({ys.min()}..{ys.max()})")
