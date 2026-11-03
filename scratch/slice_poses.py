from PIL import Image
import numpy as np

im = Image.open('scratch/farmer_poses_clean.png')
arr = np.array(im)
alpha = arr[:, :, 3]

from scipy.ndimage import label
mask = alpha > 30
labeled, num_features = label(mask)
print(f"Num features: {num_features}")

# Let's inspect large components
sizes = [(labeled == i).sum() for i in range(1, num_features + 1)]
for i, s in enumerate(sizes, start=1):
    if s > 3000:
        ys, xs = np.where(labeled == i)
        print(f"Pose {i}: size={s}, x=({xs.min()}..{xs.max()}) w={xs.max()-xs.min()+1}, y=({ys.min()}..{ys.max()}) h={ys.max()-ys.min()+1}")
        # Crop each pose
        crop = im.crop((xs.min(), ys.min(), xs.max()+1, ys.max()+1))
        crop.save(f"scratch/gen_pose_{i}.png")
