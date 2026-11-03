from PIL import Image
import numpy as np

# Let's inspect the carabao frames in detail
sheet = Image.open('assets/rice_field/carabao_spritesheet.png')
w, h = sheet.size
fw = w // 5

for f in range(5):
    f_arr = np.array(sheet.crop((f*fw, 0, (f+1)*fw, h)))
    alpha = f_arr[:, :, 3]
    ys, xs = np.where(alpha > 20)
    # The sprite position in Godot is (0, -22)
    # So Godot local y = (pixel_y - 42) + (-22) = pixel_y - 64
    print(f"Frame {f}: pixel_y range=({ys.min()}..{ys.max()}) => Godot local y range=({ys.min()-64}..{ys.max()-64})")
    # Where is the back/spine (center x columns e.g. 40..80)?
    mid_x_ys, _ = np.where(alpha[:, 40:80] > 20)
    print(f"  Spine (x 40..80): min pixel_y={mid_x_ys.min()} => Godot local y={mid_x_ys.min()-64}")
