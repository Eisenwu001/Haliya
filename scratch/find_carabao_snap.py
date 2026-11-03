from PIL import Image

snap = Image.open('snapshot_rice_field_2_1.png')
# The carabao_1 is at (520, 288) in world coordinates.
# In a 640x360 game viewport scaled to 2560x1600 (scale 4.0 or stretched):
# Let's crop a window around where the carabao is.
# In 2560x1600: 520 * 4 = 2080, 288 * 4 = 1152?
# But player starts at x ~ 100, camera might be centered around player (x ~ 150..320)
# So carabao at x=520 might be on screen!
# Let's search for carabao dark grey pixels (RGB ~ (40..70, 40..70, 45..75)) in the snapshot:
import numpy as np
arr = np.array(snap)
print("Snapshot shape:", arr.shape)

# Let's crop several sections across the screen at y around 800..1400:
crop1 = snap.crop((0, 600, 1280, 1600))
crop1.resize((640, 500)).save("scratch/snap_left.png")
crop2 = snap.crop((1280, 600, 2560, 1600))
crop2.resize((640, 500)).save("scratch/snap_right.png")
print("Saved scratch/snap_left.png and scratch/snap_right.png")
