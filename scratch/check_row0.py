from PIL import Image
import numpy as np

path = r'C:\Users\Lin\.gemini\antigravity\brain\affaaa51-5c2e-4029-96b6-27d506de5489\bahay_kubo_1792799770439.jpg'
im = Image.open(path)
arr = np.array(im)
r0 = arr[0, :, :]
# Find where r0 is not magenta:
is_mag = (r0[:, 0] > 150) & (r0[:, 2] > 150) & (r0[:, 1] < 100)
non_mag = np.where(~is_mag)[0]
print("Non-magenta x indices in row 0 (count", len(non_mag), "):", non_mag[0], "..", non_mag[-1])
print("Sample colors along row 0 non-magenta:", [r0[x].tolist() for x in non_mag[::40]])
