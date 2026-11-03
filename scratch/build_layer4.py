import os
from collections import deque
import numpy as np
from PIL import Image
from scipy.ndimage import binary_dilation

BRAIN_DIR = r"C:/Users/Lin/.gemini/antigravity/brain/92bde1ae-ac0c-4d62-8cfc-e89de1ad59d2"
OUT_PATH = "assets/bicol_bg/Rice_Field_Layer4.png"
THUMB_PATH = "scratch/layer4_preview.png"

def remove_sky_clean(arr_rgb, thresh=242):
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

def blend_horizontal(arrA, arrB, blend_w=120):
    H, WA, _ = arrA.shape
    _, WB, _ = arrB.shape
    total_w = WA + WB - blend_w
    out = np.zeros((H, total_w, 4), dtype=np.float32)
    out[:, :WA - blend_w] = arrA[:, :WA - blend_w]
    
    t = (0.5 - 0.5 * np.cos(np.linspace(0, np.pi, blend_w))).reshape(1, blend_w, 1)
    overlapA = arrA[:, WA - blend_w:]
    overlapB = arrB[:, :blend_w]
    
    alphaA = overlapA[:, :, 3:4]
    alphaB = overlapB[:, :, 3:4]
    
    # Combined alpha is max
    comb_alpha = np.maximum(alphaA, alphaB)
    
    both = (alphaA > 15) & (alphaB > 15)
    onlyA = (alphaA > 15) & (alphaB <= 15)
    onlyB = (alphaB > 15) & (alphaA <= 15)
    neither = (alphaA <= 15) & (alphaB <= 15)
    
    rgb = np.zeros((H, blend_w, 3), dtype=np.float32)
    rgb[onlyA[:, :, 0]] = overlapA[:, :, :3][onlyA[:, :, 0]]
    rgb[onlyB[:, :, 0]] = overlapB[:, :, :3][onlyB[:, :, 0]]
    rgb[both[:, :, 0]] = (overlapA[:, :, :3] * (1.0 - t) + overlapB[:, :, :3] * t)[both[:, :, 0]]
    
    out[:, WA - blend_w:WA, :3] = rgb
    out[:, WA - blend_w:WA, 3:4] = comb_alpha
    out[:, WA - blend_w:WA][neither[:, :, 0]] = 0
    out[:, WA:] = arrB[:, blend_w:]
    return out

def main():
    im_m = Image.open(os.path.join(BRAIN_DIR, 'mayon_realistic_distant_1791105144497.jpg')).convert('RGB')
    im_b = Image.open(os.path.join(BRAIN_DIR, 'bicol_mountains_layer4_1791105664581.jpg')).convert('RGB')

    rgba_m = remove_sky_clean(np.array(im_m), thresh=245)
    rgba_b = remove_sky_clean(np.array(im_b), thresh=245)

    h_target = 720
    wm = int(im_m.width * (h_target / im_m.height))
    wb = int(im_b.width * (h_target / im_b.height))

    sm = np.array(Image.fromarray(rgba_m).resize((wm, h_target), Image.Resampling.LANCZOS), dtype=np.float32)
    sb = np.array(Image.fromarray(rgba_b).resize((wb, h_target), Image.Resampling.LANCZOS), dtype=np.float32)

    # Let's inspect Bicol mountains ridge vs Mayon ridge
    # Mayon left ridge is ~523, right ridge is ~527
    # In sb, let's find the best slice to connect smoothly
    # We want a continuous mountain chain: sb -> sm (Mayon) -> sb_flip -> sb
    # Then wrap seamlessly to 4256
    arr = blend_horizontal(sb, sm, blend_w=150)
    arr = blend_horizontal(arr, sb[:, ::-1], blend_w=150)
    arr = blend_horizontal(arr, sb, blend_w=150)
    
    # Now seamless loop to 4256
    W_TARGET = 4256
    blend_w = 150
    final = arr[:, :W_TARGET].copy()
    over = arr[:, W_TARGET:W_TARGET+blend_w]
    
    t = (0.5 - 0.5 * np.cos(np.linspace(0, np.pi, blend_w))).reshape(1, blend_w, 1)
    al = final[:, :blend_w, 3:4]
    ao = over[:, :, 3:4]
    
    both = (al > 15) & (ao > 15)
    only_l = (al > 15) & (ao <= 15)
    only_o = (ao > 15) & (al <= 15)
    neither = (al <= 15) & (ao <= 15)
    
    rgb = np.zeros((h_target, blend_w, 3), dtype=np.float32)
    rgb[only_l[:, :, 0]] = final[:, :blend_w, :3][only_l[:, :, 0]]
    rgb[only_o[:, :, 0]] = over[:, :, :3][only_o[:, :, 0]]
    rgb[both[:, :, 0]] = (final[:, :blend_w, :3] * (1.0 - t) + over[:, :, :3] * t)[both[:, :, 0]]
    
    final[:, :blend_w, :3] = rgb
    final[:, :blend_w, 3:4] = np.maximum(al, ao)
    final[:, :blend_w][neither[:, :, 0]] = 0
    final[:, -1] = final[:, 0] # exact seam
    
    out_img = Image.fromarray(np.clip(final, 0, 255).astype(np.uint8))
    out_img.save(OUT_PATH)
    out_img.resize((1064, 180)).save(THUMB_PATH)
    print("Layer 4 saved successfully! Seam diff:", np.mean(np.abs(final[:, 0] - final[:, -1])))

if __name__ == '__main__':
    main()
