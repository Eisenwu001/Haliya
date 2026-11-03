from PIL import Image
from collections import deque
import numpy as np

path = r'C:\Users\Lin\.gemini\antigravity\brain\affaaa51-5c2e-4029-96b6-27d506de5489\bahay_kubo_1792799770439.jpg'
im = Image.open(path)
arr = np.array(im)
H, W, _ = arr.shape

# A pixel is magenta background if R > 170 and B > 170 and G < 80
is_mag = (arr[:, :, 0] > 170) & (arr[:, :, 2] > 170) & (arr[:, :, 1] < 80)

# Flood fill from all 4 borders:
visited = np.zeros((H, W), dtype=bool)
queue = deque()

for x in range(W):
    if is_mag[0, x]:
        visited[0, x] = True
        queue.append((0, x))
    if is_mag[H - 1, x]:
        visited[H - 1, x] = True
        queue.append((H - 1, x))

for y in range(H):
    if is_mag[y, 0] and not visited[y, 0]:
        visited[y, 0] = True
        queue.append((y, 0))
    if is_mag[y, W - 1] and not visited[y, W - 1]:
        visited[y, W - 1] = True
        queue.append((y, W - 1))

while queue:
    y, x = queue.popleft()
    for dy, dx in [(-1, 0), (1, 0), (0, -1), (0, 1)]:
        ny, nx = y + dy, x + dx
        if 0 <= ny < H and 0 <= nx < W and not visited[ny, nx]:
            if is_mag[ny, nx]:
                visited[ny, nx] = True
                queue.append((ny, nx))

# visited are the exterior background pixels
alpha = np.where(visited, 0, 255).astype(np.uint8)

# Find foreground bounds:
ys, xs = np.where(~visited)
print(f"Foreground bounds: x=({xs.min()}..{xs.max()}) w={xs.max()-xs.min()+1}, y=({ys.min()}..{ys.max()}) h={ys.max()-ys.min()+1}")

# Create RGBA
rgba = np.zeros((H, W, 4), dtype=np.uint8)
rgba[:, :, :3] = arr
rgba[:, :, 3] = alpha

# Also soften/defringe 1-pixel boundary:
from scipy.ndimage import binary_dilation
dilated = binary_dilation(visited, iterations=1)
fringe = dilated & (~visited)
for y, x in zip(*np.where(fringe)):
    # If pixel has magenta hue, clear it or blend
    if arr[y, x, 0] > 140 and arr[y, x, 2] > 140 and arr[y, x, 1] < 120:
        rgba[y, x, 3] = 0

# Crop tightly:
crop_kubo = Image.fromarray(rgba).crop((xs.min(), ys.min(), xs.max() + 1, ys.max() + 1))
print("Cropped Bahay Kubo size:", crop_kubo.size)

# Resize to high quality platformer dimensions:
# E.g. width = 208, height = int(208 * (crop_kubo.size[1] / crop_kubo.size[0]))
target_w = 208
aspect = crop_kubo.size[1] / crop_kubo.size[0]
target_h = int(target_w * aspect)
kubo_final = crop_kubo.resize((target_w, target_h), Image.Resampling.LANCZOS)
print("Final Bahay Kubo size:", kubo_final.size)

out_path = "assets/rice_field/bahay_kubo.png"
kubo_final.save(out_path)
print(f"Successfully saved {out_path}!")
