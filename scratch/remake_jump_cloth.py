from PIL import Image
import numpy as np

mask_img = Image.open('scratch/layer_3_Mask_3.png').convert('RGBA')
arr_mask = np.array(mask_img)

C_DARK_BLUE = [5, 39, 50, 255]
C_WEAVE_BLUE = [19, 57, 85, 255]
C_MID_BLUE = [15, 86, 133, 255]
C_LIGHT_BLUE = [78, 95, 120, 255]
C_SHADOW = [4, 5, 6, 255]
C_BRIGHT_GOLD = [248, 232, 112, 255]
C_GOLD = [233, 200, 81, 255]
C_DEEP_GOLD = [130, 97, 26, 255]

jump_files = [
    ('common_21_jump01.png', 'ascend', 1),
    ('common_21_jump02.png', 'ascend', 2),
    ('common_21_jump03.png', 'ascend', 3),
    ('common_21_jump04.png', 'ascend', 4),
    ('common_21_jump05.png', 'ascend', 5),
    ('common_21_jump_down01.png', 'fall', 1),
    ('common_21_jump_down02.png', 'fall', 2),
    ('common_21_jump_down03.png', 'fall', 3),
]

for name, mode, f_idx in jump_files:
    arr = np.array(Image.open(f'assets/haliya_backup_originals/{name}').convert('RGBA'))
    out = arr.copy()
    h, w, _ = out.shape
    
    # 1. Palette map original red fabric
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
                
    # 2. Detect head & anatomical spine
    skin_mask = ((out[:,:,0] == 249) | (out[:,:,0] == 242) | (out[:,:,0] == 189)) &                 ((out[:,:,1] == 206) | (out[:,:,1] == 204) | (out[:,:,1] == 174) | (out[:,:,1] == 173) | (out[:,:,1] == 126)) &                 (out[:,:,3] > 0)
    ys, xs = np.where(skin_mask)
    if len(ys) == 0: continue
    
    y_head_top = ys.min()
    head_skin = skin_mask & (np.arange(h)[:, None] < y_head_top + 26)
    yh, xh = np.where(head_skin)
    
    if len(yh) > 0:
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
                        
    # 3. Contoured Bodice & Angled Sablay
    waist_y = y_head_top + (42 if mode == 'ascend' else 46)
    
    for y in range(y_head_top + 22, waist_y + 4):
        row_body = np.where(out[y, :, 3] > 0)[0]
        if len(row_body) == 0: continue
        
        t_prog = (y - (y_head_top + 22)) / max(1, (waist_y + 4 - (y_head_top + 22)))
        spine_center = int(np.mean(xh))
        rib_w = int(11 + 2 * np.sin(t_prog * np.pi))
        t_left = spine_center - rib_w
        t_right = spine_center + rib_w
        
        is_belt = abs(y - waist_y) <= 1
        
        for x in range(max(0, t_left), min(w, t_right)):
            if skin_mask[y, x]:
                diag_dist = (x - t_left) - int(t_prog * (t_right - t_left))
                if is_belt:
                    if y == waist_y - 1:
                        out[y, x] = C_SHADOW
                    elif y == waist_y:
                        out[y, x] = C_BRIGHT_GOLD if (x % 3 == 0) else C_GOLD
                    else:
                        out[y, x] = C_DEEP_GOLD
                elif abs(diag_dist) <= 1:
                    out[y, x] = C_GOLD
                elif diag_dist < 0:
                    out[y, x] = C_DARK_BLUE
                else:
                    out[y, x] = C_WEAVE_BLUE if (x + y) % 2 == 0 else C_MID_BLUE
                    
    # 4. Velocity-Responsive Drape Dynamics
    if mode == 'ascend':
        # Downward cling: vertical drapery folds clinging downward around thighs
        for dy in range(waist_y + 3, waist_y + 22):
            if dy >= h: break
            row_b = np.where(out[dy, :, 3] > 0)[0]
            if len(row_b) > 0:
                bx_min, bx_max = row_b.min(), row_b.max()
                # Vertical fold creases
                for fx in [bx_min + 3, bx_min + 7, (bx_min + bx_max) // 2]:
                    if 0 <= fx < w and out[dy, fx, 3] > 0:
                        out[dy, fx] = C_SHADOW if (dy % 4 == 0) else C_DARK_BLUE
    else:
        # Jump fall / apex: upward billowing sashes & flared hem
        billow_y0 = waist_y - 6
        for by in range(billow_y0, billow_y0 + 16):
            if by < 0 or by >= h: continue
            flare_len = int(10 + 6 * np.sin((by - billow_y0) / 16.0 * np.pi) + f_idx * 2)
            row_b = np.where(out[by, :, 3] > 0)[0]
            if len(row_b) > 0:
                back_x = row_b.min()
                for sx in range(back_x - flare_len, back_x):
                    if 0 <= sx < w:
                        if sx == back_x - flare_len:
                            out[by, sx] = C_SHADOW
                        elif by == billow_y0:
                            out[by, sx] = C_GOLD
                        else:
                            out[by, sx] = C_WEAVE_BLUE if (sx + by) % 2 == 0 else C_DARK_BLUE

    img_out = Image.fromarray(out)
    img_out.save(f'assets/haliya/{name}')
    print(f'Remade {name}')

print('All 8 jump frames organically remade!')
