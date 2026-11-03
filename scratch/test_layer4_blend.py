import os
from PIL import Image
import numpy as np
from collections import deque
from scipy.ndimage import binary_dilation

brain = r'C:/Users/Lin/.gemini/antigravity/brain/92bde1ae-ac0c-4d62-8cfc-e89de1ad59d2'

def remove_sky(arr_rgb, thresh=242):
    H, W, _ = arr_rgb.shape
    is_sky = (arr_rgb[:, :, 0] > thresh) & (arr_rgb[:, :, 1] > thresh) & (arr_rgb[:, :, 2] > thresh)
    visited = np.zeros((H, W), dtype=bool)
    q = deque([(0, x) for x in range(W) if is_sky[0, x]])
    for _, x in q: visited[0, x] = True
    while q:
        y, x = q.popleft()
        for dy, dx in [(-1,0), (1,0), (0,-1), (0,1)]:
            ny, nx = y+dy, x+dx
            if 0 <= ny < H and 0 <= nx < W and not visited[ny, nx] and is_sky[ny, nx]:
                visited[ny, nx] = True; q.append((ny, nx))
    alpha = np.ones((H, W), dtype=np.uint8) * 255
    alpha[visited] = 0
    dil = binary_dilation(visited, iterations=2)
    fringe = dil & (~visited)
    for y, x in zip(*np.where(fringe)):
        b = float(np.mean(arr_rgb[y, x, :3]))
        if b > 215: alpha[y, x] = int(max(0, min(255, (255 - b) / 40.0 * 255)))
    res = np.zeros((H, W, 4), dtype=np.uint8)
    res[:, :, :3] = arr_rgb
    res[:, :, 3] = alpha
    res[alpha < 2] = 0
    return res

im_m = Image.open(os.path.join(brain, 'mayon_realistic_distant_1791105144497.jpg')).convert('RGB')
im_b = Image.open(os.path.join(brain, 'bicol_mountains_layer4_1791105664581.jpg')).convert('RGB')

rgba_m = remove_sky(np.array(im_m), thresh=245)
rgba_b = remove_sky(np.array(im_b), thresh=245)

h_target = 720
wm = int(im_m.width * (h_target / im_m.height))
wb = int(im_b.width * (h_target / im_b.height))

sm = np.array(Image.fromarray(rgba_m).resize((wm, h_target), Image.Resampling.LANCZOS), dtype=np.float32)
sb = np.array(Image.fromarray(rgba_b).resize((wb, h_target), Image.Resampling.LANCZOS), dtype=np.float32)

print('sm shape:', sm.shape, 'sb shape:', sb.shape)
