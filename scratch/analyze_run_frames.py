from PIL import Image
import numpy as np

for i in range(1, 7):
    name = f'common_12_run{i:02d}.png'
    path = f'assets/haliya/{name}'
    img = Image.open(path).convert('RGBA')
    arr = np.array(img)
    
    # Find head (skin with y < 175)
    skin_colors = [(242, 173, 150), (249, 204, 181), (189, 126, 105)]
    s_mask = np.zeros(arr.shape[:2], dtype=bool)
    for c in skin_colors:
        s_mask |= (arr[:,:,0] == c[0]) & (arr[:,:,1] == c[1]) & (arr[:,:,2] == c[2]) & (arr[:,:,3] == 255)
    
    head_mask = s_mask & (np.arange(256)[:, None] < 175)
    yh, xh = np.where(head_mask)
    
    # Find feet (lowest visible pixels)
    yv, xv = np.where(arr[:,:,3] > 0)
    
    print(f'{name}: bbox={img.getbbox()}, head=x[{xh.min()},{xh.max()}] y[{yh.min()},{yh.max()}], feet_y={yv.max()}')
