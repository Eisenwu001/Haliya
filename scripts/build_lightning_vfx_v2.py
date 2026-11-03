import os
import numpy as np
from PIL import Image
from collections import deque

def remove_black_flood(img, threshold=18, feather=3):
    arr = np.array(img.convert('RGBA'))
    h, w = arr.shape[:2]
    visited = np.zeros((h, w), dtype=bool)
    q = deque()
    
    # Flood from borders
    for x in range(w):
        for y in [0, h - 1]:
            if np.max(arr[y, x, :3]) <= threshold:
                visited[y, x] = True
                q.append((y, x))
    for y in range(h):
        for x in [0, w - 1]:
            if not visited[y, x] and np.max(arr[y, x, :3]) <= threshold:
                visited[y, x] = True
                q.append((y, x))
                
    while q:
        cy, cx = q.popleft()
        arr[cy, cx, 3] = 0
        for dy, dx in [(-1,0), (1,0), (0,-1), (0,1)]:
            ny, nx = cy + dy, cx + dx
            if 0 <= ny < h and 0 <= nx < w and not visited[ny, nx]:
                visited[ny, nx] = True
                if np.max(arr[ny, nx, :3]) <= threshold:
                    q.append((ny, nx))
                    
    # Feather boundary pixels
    alpha = arr[:, :, 3].astype(np.float32)
    lum = np.max(arr[:, :, :3], axis=2).astype(np.float32)
    fade = (lum < 35) & (alpha > 0)
    alpha[fade] = alpha[fade] * (lum[fade] / 35.0)
    arr[:, :, 3] = np.clip(alpha, 0, 255).astype(np.uint8)
    return Image.fromarray(arr)

def clean_additive_vfx(img, black_thresh=14, gamma=1.2):
    arr = np.array(img.convert('RGB')).astype(np.float32)
    r, g, b = arr[:, :, 0], arr[:, :, 1], arr[:, :, 2]
    energy = np.maximum(g * 0.95 + b * 0.70, r * 1.0)
    alpha = np.clip((energy - black_thresh) / (255.0 - black_thresh), 0.0, 1.0)
    alpha = np.power(alpha, gamma) * 255.0
    
    rgba = np.zeros((arr.shape[0], arr.shape[1], 4), dtype=np.uint8)
    rgba[:, :, :3] = arr.astype(np.uint8)
    rgba[:, :, 3] = alpha.astype(np.uint8)
    return Image.fromarray(rgba)

def build_hazard_warning(src_path, out_path):
    src = Image.open(src_path)
    # Center is at (512, 512)
    # Radius of outer ring is ~440 px
    crop_box = (512 - 460, 512 - 460, 512 + 460, 512 + 460)
    cropped = src.crop(crop_box)
    clean = clean_additive_vfx(cropped, black_thresh=14, gamma=1.15)
    
    # Resize to 512x512
    out_img = clean.resize((512, 512), Image.Resampling.LANCZOS)
    os.makedirs(os.path.dirname(out_path), exist_ok=True)
    out_img.save(out_path, "PNG")
    print(f"Saved Hazard Warning VFX: {out_path} ({out_img.size})")

def build_scorch_spritesheet(src_path, out_path):
    src = Image.open(src_path)
    
    # 4 crater stages in source:
    # 0: Plasma burst: (27, 290, 336, 480)
    # 1: Cyan fissures + embers: (368, 290, 668, 480)
    # 2: Faint embers in dark basin: (702, 290, 1011, 480)
    # 3: Cooled dark carbon crater: (1040, 290, 1348, 480)
    boxes = [
        (27, 290, 336, 480),
        (368, 290, 668, 480),
        (702, 290, 1011, 480),
        (1040, 290, 1348, 480)
    ]
    
    # Clean transparent versions
    crops = []
    # For stage 0 (plasma burst), use clean_additive_vfx
    c0 = clean_additive_vfx(src.crop(boxes[0]), black_thresh=16, gamma=1.2)
    crops.append(c0)
    
    # For stages 1, 2, 3, use flood removal to preserve interior rock
    for i in range(1, 4):
        c = remove_black_flood(src.crop(boxes[i]), threshold=16)
        crops.append(c)
        
    FRAME_W = 256
    FRAME_H = 160
    # Desired on-screen width is ~200-210 px (which scales by 0.5 to 105 px ~ BLAST_RADIUS*2)
    TARGET_W = 210
    
    master = Image.new("RGBA", (FRAME_W * 5, FRAME_H), (0, 0, 0, 0))
    
    # We want ground contact baseline at Y = 120 so it matches existing Godot offset (0, 0)
    # A shallow recessed crater dish sits between Y = 100 and Y = 155
    # The rim / flat ground line is at Y = 110-120
    # Let's resize and position each frame:
    
    # Frame 0: High-energy electric impact burst (Crater 0)
    scale0 = TARGET_W / float(crops[0].width)
    f0 = crops[0].resize((TARGET_W, int(crops[0].height * scale0)), Image.Resampling.LANCZOS)
    px0 = (FRAME_W - TARGET_W) // 2
    py0 = 120 - int(f0.height * 0.45)
    master.paste(f0, (0 * FRAME_W + px0, py0), f0)
    
    # Frame 1: Sizzling surface arcs (Blend of Crater 0 and Crater 1)
    f1_a = f0.copy()
    arr1_a = np.array(f1_a).astype(np.float32)
    arr1_a[:, :, 3] *= 0.65
    scale1 = TARGET_W / float(crops[1].width)
    f1_b = crops[1].resize((TARGET_W, int(crops[1].height * scale1)), Image.Resampling.LANCZOS)
    px1 = (FRAME_W - TARGET_W) // 2
    py1 = 120 - int(f1_b.height * 0.45)
    
    f1_comb = Image.new("RGBA", (FRAME_W, FRAME_H), (0, 0, 0, 0))
    f1_comb.paste(f1_b, (px1, py1), f1_b)
    f1_comb.paste(Image.fromarray(arr1_a.astype(np.uint8)), (px0, py0), Image.fromarray(arr1_a.astype(np.uint8)))
    master.paste(f1_comb, (1 * FRAME_W, 0), f1_comb)
    
    # Frame 2: Cooling crackle & embers (Crater 2)
    scale2 = TARGET_W / float(crops[2].width)
    f2 = crops[2].resize((TARGET_W, int(crops[2].height * scale2)), Image.Resampling.LANCZOS)
    px2 = (FRAME_W - TARGET_W) // 2
    py2 = 120 - int(f2.height * 0.45)
    master.paste(f2, (2 * FRAME_W + px2, py2), f2)
    
    # Frame 3: Fresh crater basin with glowing cyan fissures (Crater 1)
    scale3 = TARGET_W / float(crops[1].width)
    f3 = crops[1].resize((TARGET_W, int(crops[1].height * scale3)), Image.Resampling.LANCZOS)
    px3 = (FRAME_W - TARGET_W) // 2
    py3 = 120 - int(f3.height * 0.45)
    master.paste(f3, (3 * FRAME_W + px3, py3), f3)
    
    # Frame 4: Permanent cooled carbon crater basin (Crater 3, zero bumps)
    scale4 = TARGET_W / float(crops[3].width)
    f4 = crops[3].resize((TARGET_W, int(crops[3].height * scale4)), Image.Resampling.LANCZOS)
    px4 = (FRAME_W - TARGET_W) // 2
    py4 = 120 - int(f4.height * 0.45)
    master.paste(f4, (4 * FRAME_W + px4, py4), f4)
    
    os.makedirs(os.path.dirname(out_path), exist_ok=True)
    master.save(out_path, "PNG")
    print(f"Saved Flat Scorch Spritesheet: {out_path} ({master.size})")

if __name__ == "__main__":
    brain = r"C:\Users\Lin\.gemini\antigravity\brain\c7718a4a-5c4f-4a83-8604-730ecde0e295"
    base = r"c:\Users\Lin\OneDrive\Pictures\Camera Roll\Documents\project-1-test"
    
    warn_src = os.path.join(brain, "lightning_hazard_warning_1791199926065.jpg")
    warn_out = os.path.join(base, "assets", "vfx", "vfx_lightning_warning.png")
    
    crater_src = os.path.join(brain, "crater_decal_stages_1791199962501.jpg")
    crater_out = os.path.join(base, "assets", "vfx", "vfx_lightning_scorch.png")
    
    build_hazard_warning(warn_src, warn_out)
    build_scorch_spritesheet(crater_src, crater_out)
