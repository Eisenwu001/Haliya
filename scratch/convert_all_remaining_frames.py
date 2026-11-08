import os
from PIL import Image
import numpy as np

# Load Mask 3
mask_img = Image.open('scratch/layer_3_Mask_3.png').convert('RGBA')
arr_mask = np.array(mask_img)

src_dir = 'assets/haliya_backup_originals'
dst_dir = 'assets/haliya'

# Identify already clothed frames from earlier steps
already_clothed = set()
for prefix in ['A', 'B']:
    for i in range(1, 9):
        already_clothed.add(f'common_00_idle_stand_{prefix}{i:02d}.png')
for i in range(1, 13):
    already_clothed.add(f'common_11_walk{i:02d}.png')
already_clothed.update([
    'common_01_idle_to_crouch01.png',
    'common_01_idle_to_crouch02.png',
    'common_01_idle_crouch.png',
    'common_01_crouch_to_idle01.png',
    'common_01_crouch_to_idle02.png'
])
for i in range(1, 7):
    already_clothed.add(f'common_12_run{i:02d}.png')
for i in range(1, 6):
    already_clothed.add(f'common_21_jump{i:02d}.png')
for i in range(1, 4):
    already_clothed.add(f'common_21_jump_down{i:02d}.png')

all_pngs = sorted([f for f in os.listdir(src_dir) if f.endswith('.png')])
to_convert = [f for f in all_pngs if f not in already_clothed]

print(f'Starting conversion of {len(to_convert)} frames...')

converted_count = 0

for filename in to_convert:
    in_path = os.path.join(src_dir, filename)
    out_path = os.path.join(dst_dir, filename)
    
    orig = Image.open(in_path).convert('RGBA')
    arr = np.array(orig)
    out = arr.copy()
    h, w, _ = out.shape
    
    # 1. Palette transfer on red fabric
    for y in range(h):
        for x in range(w):
            r, g, b, a = out[y, x]
            if a == 0: continue
            
            # Base red shades
            if (r in [78, 77] and g in [46, 45] and b in [43, 44]) or (r == 77 and g == 45 and b == 43):
                out[y, x] = [5, 39, 50, 255] if (x + y) % 2 == 0 else [19, 57, 85, 255]
            # Medium/highlight red
            elif (r in [122, 123] and g in [74, 75] and b in [70, 69]):
                out[y, x] = [15, 86, 133, 255]
            # Dark red shadow
            elif (r in [39, 83] and g in [3, 7] and b in [1, 2]):
                out[y, x] = [4, 5, 6, 255]
            # Light red / coral trim -> gold trim
            elif (r in [228, 245] and g in [87, 138] and b in [79, 132]):
                out[y, x] = [233, 200, 81, 255]
                
    # 2. Find head position
    skin_mask = ((out[:,:,0] == 249) | (out[:,:,0] == 242) | (out[:,:,0] == 189)) &                 ((out[:,:,1] == 206) | (out[:,:,1] == 204) | (out[:,:,1] == 174) | (out[:,:,1] == 173) | (out[:,:,1] == 126)) &                 (out[:,:,3] > 0)
    ys, xs = np.where(skin_mask)
    if len(ys) > 0:
        y_top = ys.min()
        head_skin = skin_mask & (np.arange(h)[:, None] < y_top + 28)
        yh, xh = np.where(head_skin)
        if len(yh) > 0:
            face_x = xh.max() - 14
            face_y = yh.min()
            
            # Composite mask onto face (only where character pixels exist)
            mh, mw, _ = arr_mask.shape
            for my in range(mh):
                for mx in range(mw):
                    if arr_mask[my, mx, 3] > 100:
                        tx = face_x + mx
                        ty = face_y + my
                        if 0 <= tx < w and 0 <= ty < h and out[ty, tx, 3] > 0:
                            out[ty, tx] = arr_mask[my, mx]
                            
            # 3. Torso midriff coverage
            torso_ymin = y_top + 26
            torso_ymax = y_top + 48
            torso_xmin = int(np.mean(xh)) - 12
            torso_xmax = int(np.mean(xh)) + 12
            
            for ty in range(torso_ymin, min(h, torso_ymax)):
                for tx in range(max(0, torso_xmin), min(w, torso_xmax)):
                    if skin_mask[ty, tx]:
                        if ty == torso_ymax - 1:
                            out[ty, tx] = [233, 200, 81, 255]
                        else:
                            out[ty, tx] = [5, 39, 50, 255] if (tx + ty) % 2 == 0 else [19, 57, 85, 255]
                            
    img_out = Image.fromarray(out)
    img_out.save(out_path)
    converted_count += 1

print(f'Successfully converted all {converted_count} frames!')
