from PIL import Image
import numpy as np

im = Image.open('assets/rice_field/farmer_trans.png')
arr = np.array(im)
alpha = arr[:, :, 3]

from scipy.ndimage import label
mask = alpha > 20
labeled, num = label(mask)
print("Num features:", num)

# Get bounding boxes for components with > 5000 pixels:
sizes = [(labeled == i).sum() for i in range(1, num + 1)]
for i, s in enumerate(sizes, start=1):
    if s > 3000:
        ys, xs = np.where(labeled == i)
        print(f"Feature {i}: size={s}, x=({xs.min()}..{xs.max()}) w={xs.max()-xs.min()+1}, y=({ys.min()}..{ys.max()}) h={ys.max()-ys.min()+1}")
        # Save crop
        crop = im.crop((xs.min(), ys.min(), xs.max() + 1, ys.max() + 1))
        crop.save(f"scratch/farmer_feature_{i}.png")
