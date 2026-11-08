from PIL import Image
import numpy as np

# Load Mask 3
mask_img = Image.open('scratch/layer_3_Mask_3.png').convert('RGBA')
arr_mask = np.array(mask_img)

jump_configs = [
    ('common_21_jump01.png', (137, 136), (118, 142), 170, 195),
    ('common_21_jump02.png', (148, 147), (118, 144), 168, 185),
    ('common_21_jump03.png', (148, 148), (118, 144), 168, 185),
    ('common_21_jump04.png', (148, 147), (118, 144), 168, 185),
    ('common_21_jump05.png', (148, 145), (118, 144), 168, 190),
    ('common_21_jump_down01.png', (150, 143), (120, 146), 168, 195),
    ('common_21_jump_down02.png', (150, 143), (120, 146), 168, 195),
    ('common_21_jump_down03.png', (150, 143), (120, 146), 168, 195)
]

for name, (mx0, my0), (mid_xmin, mid_xmax), mid_ymin, mid_ymax in jump_configs:
    orig = Image.open(f'assets/haliya_backup_originals/{name}').convert('RGBA')
    arr = np.array(orig)
    out = arr.copy()
    
    h, w, _ = out.shape
    for y in range(h):
        for x in range(w):
            r, g, b, a = out[y, x]
            if a == 0: continue
            
            # Map red fabric to blue cloth
            if (r, g, b) in [(78, 46, 43), (77, 45, 43)]:
                if (x + y) % 2 == 0:
                    out[y, x] = [5, 39, 50, 255]
                else:
                    out[y, x] = [19, 57, 85, 255]
            elif (r, g, b) == (122, 74, 70):
                out[y, x] = [15, 86, 133, 255]
            elif (r, g, b) in [(39, 3, 1), (83, 7, 2)]:
                out[y, x] = [4, 5, 6, 255]
            # Midriff skin -> cloth tunic
            elif y in range(mid_ymin, mid_ymax) and x in range(mid_xmin, mid_xmax):
                if (r, g, b) in [(249, 206, 182), (242, 174, 151), (189, 126, 105), (249, 204, 181), (242, 173, 150)]:
                    if y == mid_ymax - 1:
                        out[y, x] = [233, 200, 81, 255]
                    elif (x + y) % 2 == 0:
                        out[y, x] = [5, 39, 50, 255]
                    else:
                        out[y, x] = [19, 57, 85, 255]
                        
    # Composite Mask 3
    mh, mw, _ = arr_mask.shape
    for my in range(mh):
        for mx in range(mw):
            if arr_mask[my, mx, 3] > 100:
                tx = mx0 + mx
                ty = my0 + my
                if 0 <= tx < 256 and 0 <= ty < 256:
                    out[ty, tx] = arr_mask[my, mx]
                    
    img_out = Image.fromarray(out)
    img_out.save(f'assets/haliya/{name}')
    print(f'Generated clothed {name}')

print('All 8 jump frames successfully generated!')
