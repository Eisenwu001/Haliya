from PIL import Image
import numpy as np

im = Image.open("assets/bicol_bg/Rice_Field_Layer4.png")
arr = np.array(im)
alpha = arr[:, :, 3]
print("Layer 4 alpha:")
print("Row 0 alpha:", alpha[0, :].mean())
print("Row 100 alpha:", alpha[100, :].mean())
print("Row 200 alpha:", alpha[200, :].mean())
print("Row 360 alpha:", alpha[360, :].mean())
print("Row 600 alpha:", alpha[600, :].mean())

# Where is alpha == 0?
ys, xs = np.where(alpha == 0)
print(f"Zero alpha y range: {ys.min()}..{ys.max()}")
