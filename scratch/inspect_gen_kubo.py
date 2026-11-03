from PIL import Image
import numpy as np

path = r'C:\Users\Lin\.gemini\antigravity\brain\affaaa51-5c2e-4029-96b6-27d506de5489\bahay_kubo_1792799770439.jpg'
im = Image.open(path)
print("bahay_kubo size:", im.size)
arr = np.array(im)
# Check magenta background:
is_magenta = (arr[:, :, 0] > 180) & (arr[:, :, 1] < 70) & (arr[:, :, 2] > 180)
print("Magenta fraction:", is_magenta.sum() / (arr.shape[0] * arr.shape[1]))
# Find bounding box of non-magenta:
ys, xs = np.where(~is_magenta)
print(f"Non-magenta bounds: x=({xs.min()}..{xs.max()}) w={xs.max()-xs.min()+1}, y=({ys.min()}..{ys.max()}) h={ys.max()-ys.min()+1}")

# Save a preview of cropped kubo:
crop = im.crop((xs.min(), ys.min(), xs.max() + 1, ys.max() + 1))
crop.save("scratch/kubo_preview.png")
print("Saved scratch/kubo_preview.png")
