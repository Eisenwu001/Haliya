from PIL import Image
import numpy as np

path = r'C:\Users\Lin\.gemini\antigravity\brain\affaaa51-5c2e-4029-96b6-27d506de5489\bahay_kubo_1792799770439.jpg'
im = Image.open(path)
arr = np.array(im)

for name, img in [
    ("bahay_kubo", r'C:\Users\Lin\.gemini\antigravity\brain\affaaa51-5c2e-4029-96b6-27d506de5489\bahay_kubo_1792799770439.jpg'),
    ("bamboo_flume", r'C:\Users\Lin\.gemini\antigravity\brain\affaaa51-5c2e-4029-96b6-27d506de5489\bamboo_flume_1792799791201.jpg'),
    ("farmer_poses", r'C:\Users\Lin\.gemini\antigravity\brain\affaaa51-5c2e-4029-96b6-27d506de5489\corrupted_farmer_poses_1792799815492.jpg')
]:
    a = np.array(Image.open(img))
    print(f"=== {name} ({a.shape[1]}x{a.shape[0]}) ===")
    print("  Top row avg:", a[0, :, :].mean(axis=0).astype(int))
    print("  Bottom row avg:", a[-1, :, :].mean(axis=0).astype(int))
    print("  Left col avg:", a[:, 0, :].mean(axis=0).astype(int))
    print("  Right col avg:", a[:, -1, :].mean(axis=0).astype(int))
