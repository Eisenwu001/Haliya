from PIL import Image
import numpy as np

path = r'C:\Users\Lin\.gemini\antigravity\brain\affaaa51-5c2e-4029-96b6-27d506de5489\bahay_kubo_1792799770439.jpg'
im = Image.open(path)
arr = np.array(im)
print("Corners:", arr[0, 0], arr[0, -1], arr[-1, 0], arr[-1, -1])

# Let's find background color distribution:
corner_color = arr[10, 10]
print("Corner color:", corner_color)
diff = np.abs(arr.astype(int) - corner_color.astype(int)).sum(axis=2)
bg_mask = diff < 60
print("Background fraction (diff < 60 from corner):", bg_mask.sum() / bg_mask.size)

ys, xs = np.where(~bg_mask)
print(f"Foreground bounds: x=({xs.min()}..{xs.max()}) w={xs.max()-xs.min()+1}, y=({ys.min()}..{ys.max()}) h={ys.max()-ys.min()+1}")

# Clean crop on transparent background:
rgba = np.zeros((im.size[1], im.size[0], 4), dtype=np.uint8)
rgba[:, :, :3] = arr
rgba[:, :, 3] = np.where(bg_mask, 0, 255)
# Soften fringe:
semi = (diff >= 30) & (diff < 60)
rgba[semi, 3] = ((diff[semi] - 30) / 30.0 * 255).astype(np.uint8)

crop_fg = Image.fromarray(rgba).crop((xs.min(), ys.min(), xs.max()+1, ys.max()+1))
crop_fg.save("scratch/kubo_chromakey.png")
print(f"Saved scratch/kubo_chromakey.png ({crop_fg.size})")
