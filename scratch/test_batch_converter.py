from PIL import Image
import numpy as np

# Load Mask 3
mask_img = Image.open('scratch/layer_3_Mask_3.png').convert('RGBA')
arr_mask = np.array(mask_img)

def convert_frame(in_path):
    orig = Image.open(in_path).convert('RGBA')
    arr = np.array(orig)
    out = arr.copy()
    h, w, _ = out.shape
    
    # 1. Palette transfer on red fabric
    for y in range(h):
        for x in range(w):
            r, g, b, a = out[y, x]
            if a == 0: continue
            
            # Base red
            if (r in [78, 77] and g in [46, 45] and b == 43) or (r == 77 and g == 45 and b == 43):
                out[y, x] = [5, 39, 50, 255] if (x + y) % 2 == 0 else [19, 57, 85, 255]
            # Medium/highlight red
            elif (r in [122, 123] and g == 74 and b in [70, 69]):
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
            # Front of face is usually rightmost skin pixels for right-facing character
            face_x = xh.max() - 14
            face_y = yh.min()
            
            # Composite mask onto face
            mh, mw, _ = arr_mask.shape
            for my in range(mh):
                for mx in range(mw):
                    if arr_mask[my, mx, 3] > 100:
                        tx = face_x + mx
                        ty = face_y + my
                        if 0 <= tx < w and 0 <= ty < h and out[ty, tx, 3] > 0:
                            out[ty, tx] = arr_mask[my, mx]
                            
            # 3. Torso midriff coverage (between head bottom and waist sash)
            torso_ymin = y_top + 26
            torso_ymax = y_top + 48
            torso_xmin = int(np.mean(xh)) - 12
            torso_xmax = int(np.mean(xh)) + 12
            
            for ty in range(torso_ymin, min(h, torso_ymax)):
                for tx in range(max(0, torso_xmin), min(w, torso_xmax)):
                    if skin_mask[ty, tx]:
                        if ty == torso_ymax - 1:
                            out[ty, tx] = [233, 200, 81, 255] # gold belt
                        else:
                            out[ty, tx] = [5, 39, 50, 255] if (tx + ty) % 2 == 0 else [19, 57, 85, 255]
                            
    return Image.fromarray(out)

# Test on 6 diverse samples
test_samples = [
    'common_13_break01.png',
    'common_31_guard_stand01.png',
    'attack_01_cobination0101.png',
    'attack_04_cobination0405.png',
    'damage_01_damage_head.png',
    'damage_11_blow_air01.png'
]

crop_w, crop_h = 130, 150
preview = Image.new('RGBA', (crop_w * len(test_samples), crop_h * 2), (25, 27, 34, 255))

for i, name in enumerate(test_samples):
    p = f'assets/haliya_backup_originals/{name}'
    orig_crop = Image.open(p).convert('RGBA').crop((55, 100, 185, 250))
    conv_crop = convert_frame(p).crop((55, 100, 185, 250))
    preview.paste(orig_crop, (i * crop_w, 0), orig_crop)
    preview.paste(conv_crop, (i * crop_w, crop_h), conv_crop)

preview.save('scratch/test_batch_preview_1x.png')
preview_3x = preview.resize((preview.width * 3, preview.height * 3), Image.NEAREST)
preview_3x.save('scratch/test_batch_preview_3x.png')
print('Successfully converted test samples and saved preview strips!')
