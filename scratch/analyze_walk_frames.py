from PIL import Image
import numpy as np

for i in range(1, 13):
    name = f'common_11_walk{i:02d}.png'
    path = f'assets/haliya/{name}'
    img = Image.open(path).convert('RGBA')
    arr = np.array(img)
    
    skin_colors = [(242, 173, 150), (249, 204, 181), (189, 126, 105)]
    s_mask = np.zeros(arr.shape[:2], dtype=bool)
    for c in skin_colors:
        s_mask |= (arr[:,:,0] == c[0]) & (arr[:,:,1] == c[1]) & (arr[:,:,2] == c[2]) & (arr[:,:,3] == 255)
    
    head_mask = s_mask & (np.arange(256)[:, None] < 155)
    if np.any(head_mask):
        yh, xh = np.where(head_mask)
        print(f'{name}: head=x[{xh.min()},{xh.max()}] y[{yh.min()},{yh.max()}]')
    else:
        print(f'{name}: no head skin (masked!)')
