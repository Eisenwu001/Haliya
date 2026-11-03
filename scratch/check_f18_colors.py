from PIL import Image
import numpy as np

f18 = Image.open('scratch/farmer_f18.png')
arr = np.array(f18)
print("f18 shape:", arr.shape)
# Count unique colors
unique_colors = np.unique(arr.reshape(-1, 4), axis=0)
print(f"Total unique colors in f18: {len(unique_colors)}")
for c in unique_colors:
    count = (arr == c).all(axis=2).sum()
    if count > 10:
        print(f"  Color {c}: {count} pixels")
