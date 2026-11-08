from PIL import Image
import numpy as np

mask_img = Image.open('scratch/layer_3_Mask_3.png').convert('RGBA')
arr_mask = np.array(mask_img)

# Official colors from v3 Clothes Copy:
C_DARK_BLUE = [5, 39, 50, 255]
C_WEAVE_BLUE = [19, 57, 85, 255]
C_MID_BLUE = [15, 86, 133, 255]
C_LIGHT_BLUE = [78, 95, 120, 255]
C_SHADOW = [4, 5, 6, 255]
C_BRIGHT_GOLD = [248, 232, 112, 255]
C_GOLD = [233, 200, 81, 255]
C_DEEP_GOLD = [130, 97, 26, 255]

def remake_run_frame(idx):
    name = f'common_12_run{idx:02d}.png'
    arr = np.array(Image.open(f'assets/haliya_backup_originals/{name}').convert('RGBA'))
    out = arr.copy()
    h, w, _ = out.shape
    
    # 1. Palette map all original red fabric
    for y in range(h):
        for x in range(w):
            r, g, b, a = out[y, x]
            if a == 0: continue
            if (r in [78, 77] and g in [46, 45] and b in [43, 44]):
                out[y, x] = C_DARK_BLUE if (x + y) % 2 == 0 else C_WEAVE_BLUE
            elif (r in [122, 123] and g in [74, 75] and b in [70, 69]):
                out[y, x] = C_MID_BLUE
            elif (r in [39, 83] and g in [3, 7] and b in [1, 2]):
                out[y, x] = C_SHADOW
            elif (r in [228, 245] and g in [87, 138] and b in [79, 132]):
                out[y, x] = C_GOLD
                
    # 2. Organic contoured torso & angled sablay
    # Detect head & spine
    skin_mask = ((out[:,:,0] == 249) | (out[:,:,0] == 242) | (out[:,:,0] == 189)) &                 ((out[:,:,1] == 206) | (out[:,:,1] == 204) | (out[:,:,1] == 174) | (out[:,:,1] == 173) | (out[:,:,1] == 126)) &                 (out[:,:,3] > 0)
    ys, xs = np.where(skin_mask)
    y_head_top = ys.min()
    head_skin = skin_mask & (np.arange(h)[:, None] < y_head_top + 26)
    yh, xh = np.where(head_skin)
    
    face_x = xh.max() - 14
    face_y = yh.min()
    
    # Composite Mask 3
    mh, mw, _ = arr_mask.shape
    for my in range(mh):
        for mx in range(mw):
            if arr_mask[my, mx, 3] > 100:
                tx = face_x + mx
                ty = face_y + my
                if 0 <= tx < w and 0 <= ty < h and out[ty, tx, 3] > 0:
                    out[ty, tx] = arr_mask[my, mx]
                    
    # Contoured Bodice & Angled Belt:
    # Identify torso rows between y_head_top + 24 and y_head_top + 50
    # In run, torso tilts forward ~15 degrees
    waist_y = y_head_top + 46
    
    for y in range(y_head_top + 24, waist_y + 4):
        # find body boundaries on this row
        row_body = np.where(out[y, :, 3] > 0)[0]
        if len(row_body) == 0: continue
        
        # Center of spine shifts forward as y increases
        t_prog = (y - (y_head_top + 24)) / (waist_y + 4 - (y_head_top + 24))
        spine_center = int(np.mean(xh) + t_prog * 4)
        
        # Ribcage half-width contours: narrower at top (8px), widens at chest (12px), tapers at waist (10px)
        rib_w = int(10 + 3 * np.sin(t_prog * np.pi))
        t_left = spine_center - rib_w
        t_right = spine_center + rib_w
        
        # Diagonal sablay (belt) line at waist: slants from back (higher y) to front (lower y)
        is_belt_zone = abs(y - (waist_y - int((spine_center - t_left) * 0.15))) <= 1
        
        for x in range(max(0, t_left), min(w, t_right)):
            if skin_mask[y, x]:
                # Diagonal sash wrap seam line
                diag_dist = (x - t_left) - int(t_prog * (t_right - t_left))
                
                if is_belt_zone:
                    # Angled Gold Belt with shadow crease
                    if y == waist_y - 1:
                        out[y, x] = C_SHADOW # fold crease
                    elif y == waist_y:
                        out[y, x] = C_BRIGHT_GOLD if (x % 3 == 0) else C_GOLD
                    else:
                        out[y, x] = C_DEEP_GOLD
                elif abs(diag_dist) <= 1:
                    # Gold piping along diagonal wrap edge
                    out[y, x] = C_GOLD
                elif diag_dist < 0:
                    # Under-wrap bodice panel (darker slate)
                    out[y, x] = C_DARK_BLUE
                else:
                    # Over-wrap bodice panel (patterned blue)
                    out[y, x] = C_WEAVE_BLUE if (x + y) % 2 == 0 else C_MID_BLUE
                    
    # 3. Dynamic Velocity Drape: Trailing sash flutter behind the hips (x < t_left)
    # Fluttering ribbons trailing backwards at horizontal velocity
    sash_y0 = waist_y - 2
    for sy in range(sash_y0, sash_y0 + 18):
        trail_len = int(8 + 6 * np.sin((sy - sash_y0) / 18.0 * np.pi) + (idx % 3) * 2)
        # Find back of torso at this y
        row_b = np.where(out[sy, :, 3] > 0)[0]
        if len(row_b) > 0:
            back_x = row_b.min()
            for sx in range(back_x - trail_len, back_x):
                if 0 <= sx < w:
                    if sx == back_x - trail_len:
                        out[sy, sx] = C_SHADOW # outline
                    elif sy == sash_y0 + 17 or sy == sash_y0:
                        out[sy, sx] = C_DEEP_GOLD # gold trim edge
                    elif (sx + sy) % 3 == 0:
                        out[sy, sx] = C_GOLD
                    else:
                        out[sy, sx] = C_DARK_BLUE if (sx + sy) % 2 == 0 else C_WEAVE_BLUE

    return Image.fromarray(out)

# Generate all 6 remade run frames
for i in range(1, 7):
    img = remake_run_frame(i)
    img.save(f'assets/haliya/common_12_run{i:02d}.png')
    print(f'Remade common_12_run{i:02d}.png')

print('All 6 run frames organically remade!')
