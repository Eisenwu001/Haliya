from PIL import Image
import numpy as np

img = Image.open('assets/haliya/common_01_idle_crouch.png').convert('RGBA')
arr = np.array(img)

# Print unique colors and counts
from collections import Counter
colors = Counter([tuple(c) for c in arr.reshape(-1, 4) if c[3] > 0])
print('Original idle_crouch colors:')
for col, cnt in colors.most_common(12):
    print(f'  {col}: {cnt}')

# Head / face position:
# In idle_crouch, head is at y ~ 178-205, x ~ 108-150.
# Torso is at y ~ 195-225, x ~ 90-135.
# Knees/legs are at y ~ 220-247, x ~ 76-159.
