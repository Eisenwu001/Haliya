import os
from PIL import Image
import numpy as np

def check_anim(folder):
    p = os.path.join('assets', 'haliya', folder)
    if not os.path.exists(p):
        print("Folder not found:", p)
        return
    files = sorted([f for f in os.listdir(p) if f.endswith('.png')])
    print(f"=== {folder} ({len(files)} frames) ===")
    for f in files[:3]:
        im = Image.open(os.path.join(p, f))
        arr = np.array(im)
        alpha = arr[:, :, 3]
        y_idxs, x_idxs = np.where(alpha > 15)
        # sprite is scaled by 0.5, centered at (0, -59.0)
        # im height is im.size[1]
        # sprite center in original pixels is im.size[1]/2
        # bottom of sprite relative to sprite center: (y_idxs.max() - im.size[1]/2) * 0.5
        # bottom of sprite in player coordinates: -59.0 + (y_idxs.max() - im.size[1]/2) * 0.5
        spr_h = im.size[1]
        max_y = y_idxs.max()
        bottom_rel_player = -59.0 + (max_y - spr_h / 2.0) * 0.5
        print(f"  {f}: size={im.size}, opaque y=[{y_idxs.min()}..{max_y}], player foot Y = {bottom_rel_player:.2f}")

for anim in ['idle', 'walk', 'run']:
    check_anim(anim)
