from PIL import Image
import numpy as np

f0 = Image.open('scratch/farmer_f0.png')
arr0 = np.array(f0)
w0 = (arr0[:, :, 0] > 235) & (arr0[:, :, 1] > 235) & (arr0[:, :, 2] > 235) & (arr0[:, :, 3] > 0)
ys, xs = np.where(w0)
print(f"Frame 0 white pixels: {len(xs)}")
for i in range(min(10, len(xs))):
    print(f"  f0 ({xs[i]}, {ys[i]}): RGBA={arr0[ys[i], xs[i]]}")

# What neighbors do these white pixels have in f0?
for i in range(min(5, len(xs))):
    y, x = ys[i], xs[i]
    neighbors = []
    for dy in [-1, 0, 1]:
        for dx in [-1, 0, 1]:
            if 0 <= y+dy < 96 and 0 <= x+dx < 96:
                if not (dy == 0 and dx == 0) and not w0[y+dy, x+dx] and arr0[y+dy, x+dx, 3] > 20:
                    neighbors.append(arr0[y+dy, x+dx, :3])
    if neighbors:
        avg_neighbor = np.mean(neighbors, axis=0).astype(int)
        print(f"  neighbor avg around ({x}, {y}): {avg_neighbor}")
