from PIL import Image
import numpy as np

path = r'C:\Users\Lin\.gemini\antigravity\brain\affaaa51-5c2e-4029-96b6-27d506de5489\corrupted_farmer_poses_1792799815492.jpg'
im = Image.open(path)
print("corrupted_farmer_poses size:", im.size)
arr = np.array(im)
corner_color = arr[10, 10]
diff = np.abs(arr.astype(int) - corner_color.astype(int)).sum(axis=2)
bg_mask = diff < 60
print("Background fraction:", bg_mask.sum() / bg_mask.size)

rgba = np.zeros((im.size[1], im.size[0], 4), dtype=np.uint8)
rgba[:, :, :3] = arr
rgba[:, :, 3] = np.where(bg_mask, 0, 255)
semi = (diff >= 30) & (diff < 60)
rgba[semi, 3] = ((diff[semi] - 30) / 30.0 * 255).astype(np.uint8)

Image.fromarray(rgba).save("scratch/farmer_poses_chromakey.png")
print("Saved scratch/farmer_poses_chromakey.png")
