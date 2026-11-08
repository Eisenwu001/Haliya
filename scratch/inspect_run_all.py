from PIL import Image
import numpy as np

for i in range(1, 7):
    name = f'common_12_run{i:02d}.png'
    img = Image.open(f'assets/haliya_backup_originals/{name}').convert('RGBA')
    arr = np.array(img)
    
    # Red fabric
    red_mask = (arr[:,:,0] == 78) | (arr[:,:,0] == 77) | (arr[:,:,0] == 122)
    red_mask &= (arr[:,:,1] == 46) | (arr[:,:,1] == 45) | (arr[:,:,1] == 74)
    
    # Skin
    skin_mask = (arr[:,:,0] == 249) | (arr[:,:,0] == 242) | (arr[:,:,0] == 189)
    skin_mask &= (arr[:,:,1] == 206) | (arr[:,:,1] == 204) | (arr[:,:,1] == 174) | (arr[:,:,1] == 173) | (arr[:,:,1] == 126)
    
    # Head skin (skin above y=175)
    head_mask = skin_mask & (np.arange(256)[:, None] < 175)
    # Midriff skin (skin between y=175 and y=200, x around torso)
    midriff_mask = skin_mask & (np.arange(256)[:, None] >= 175) & (np.arange(256)[:, None] < 202)
    
    yr, xr = np.where(red_mask)
    yh, xh = np.where(head_mask)
    ym, xm = np.where(midriff_mask)
    
    print(f'Frame {i}:')
    print(f'  Red px: {np.sum(red_mask)} in x[{xr.min()},{xr.max()}] y[{yr.min()},{yr.max()}]')
    print(f'  Head skin: {np.sum(head_mask)} in x[{xh.min()},{xh.max()}] y[{yh.min()},{yh.max()}]')
    if len(ym) > 0:
        print(f'  Midriff skin: {np.sum(midriff_mask)} in x[{xm.min()},{xm.max()}] y[{ym.min()},{ym.max()}]')
    else:
        print('  Midriff skin: None')
