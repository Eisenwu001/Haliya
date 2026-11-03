from PIL import Image
import numpy as np

snap = Image.open('snapshot_rice_field_2_1.png')
# let's find the position where carabao appears
# In Godot 640x360 rendered into 2560x1600 (aspect 16:10 vs 16:9)
# Usually black bars on top/bottom or left/right
# Let's inspect where non-black pixels are:
arr = np.array(snap)
row_max = arr.max(axis=(1, 2))
col_max = arr.max(axis=(0, 2))
print("Non-black rows:", np.where(row_max > 20)[0][[0, -1]])
print("Non-black cols:", np.where(col_max > 20)[0][[0, -1]])
