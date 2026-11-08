from PIL import Image
import numpy as np

# Load Mask 3
mask_img = Image.open('scratch/layer_3_Mask_3.png').convert('RGBA')
arr_mask = np.array(mask_img)

# Mask placement offsets per run frame (calibrated from head skin coordinates):
# Frame 1: head=x[97,145] y[150,174] -> mask at (127, 149)
# Frame 2: head=x[99,147] y[145,174] -> mask at (129, 145)
# Frame 3: head=x[98,147] y[147,174] -> mask at (129, 147)
# Frame 4: head=x[97,145] y[150,174] -> mask at (127, 149)
# Frame 5: head=x[99,147] y[145,174] -> mask at (129, 145)
# Frame 6: head=x[98,147] y[147,174] -> mask at (129, 147)

mask_coords = [
    (127, 149),
    (129, 145),
    (129, 147),
    (127, 149),
    (129, 145),
    (129, 147)
]

midriff_x_ranges = [
    (118, 138),
    (120, 140),
    (120, 140),
    (118, 138),
    (120, 140),
    (120, 140)
]

for idx in range(1, 7):
    name = f'common_12_run{idx:02d}.png'
    orig = Image.open(f'assets/haliya_backup_originals/{name}').convert('RGBA')
    arr = np.array(orig)
    out = arr.copy()
    
    mx0, my0 = mask_coords[idx - 1]
    mid_xmin, mid_xmax = midriff_x_ranges[idx - 1]
    
    h, w, _ = out.shape
    for y in range(h):
        for x in range(w):
            r, g, b, a = out[y, x]
            if a == 0: continue
            
            # Map red fabric to blue cloth
            # Base red
            if (r, g, b) in [(78, 46, 43), (77, 45, 43)]:
                # Checker/tweed pattern matching v3 Clothes Copy
                if (x + y) % 2 == 0:
                    out[y, x] = [5, 39, 50, 255]
                else:
                    out[y, x] = [19, 57, 85, 255]
            # Highlight red
            elif (r, g, b) == (122, 74, 70):
                out[y, x] = [15, 86, 133, 255]
            # Dark red shadow
            elif (r, g, b) in [(39, 3, 1), (83, 7, 2)]:
                out[y, x] = [4, 5, 6, 255]
            # Midriff skin -> cloth tunic
            elif y in range(175, 198) and x in range(mid_xmin, mid_xmax):
                if (r, g, b) in [(249, 206, 182), (242, 174, 151), (189, 126, 105), (249, 204, 181), (242, 173, 150)]:
                    if y == 197: # gold belt hem
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
    print(f'Generated prototype {name}')

print('All 6 run frames successfully generated!')
