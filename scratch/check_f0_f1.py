from PIL import Image
import numpy as np

f0 = np.array(Image.open('scratch_carabao_f0.png'))
f1 = np.array(Image.open('scratch_carabao_f1.png'))

# Save a side-by-side comparison of f0 and f1, and their difference
comp = Image.new("RGBA", (120 * 3, 84), (50, 100, 50, 255))
comp.paste(Image.fromarray(f0), (0, 0), Image.fromarray(f0))
comp.paste(Image.fromarray(f1), (120, 0), Image.fromarray(f1))

# Diff image: red for pixels in f0 but not f1, green for pixels in f1 but not f0
diff_img = np.zeros((84, 120, 4), dtype=np.uint8)
diff_img[:, :, 3] = 255
# where f0 has alpha > 0 and f1 alpha == 0
diff_img[(f0[:, :, 3] > 0) & (f1[:, :, 3] == 0)] = [255, 0, 0, 255]
# where f1 has alpha > 0 and f0 alpha == 0
diff_img[(f1[:, :, 3] > 0) & (f0[:, :, 3] == 0)] = [0, 255, 0, 255]
# where both are non-zero:
diff_img[(f0[:, :, 3] > 0) & (f1[:, :, 3] > 0)] = [100, 100, 100, 255]

comp.paste(Image.fromarray(diff_img), (240, 0))
comp.save("scratch/f0_f1_comp.png")
print("Saved scratch/f0_f1_comp.png")

# Let's check where the red/green pixels are:
red = (diff_img[:, :, 0] == 255) & (diff_img[:, :, 1] == 0)
green = (diff_img[:, :, 1] == 255) & (diff_img[:, :, 0] == 0)
print(f"Red pixels (lost in f1): {np.count_nonzero(red)}")
print(f"Green pixels (new in f1): {np.count_nonzero(green)}")
r_ys, r_xs = np.where(red)
g_ys, g_xs = np.where(green)
print(f"Red y range: {r_ys.min()}..{r_ys.max()}, x range: {r_xs.min()}..{r_xs.max()}")
print(f"Green y range: {g_ys.min()}..{g_ys.max()}, x range: {g_xs.min()}..{g_xs.max()}")
