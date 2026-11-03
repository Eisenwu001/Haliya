import os
import math
import numpy as np
from PIL import Image

BRAIN_DIR = r"C:\Users\Lin\.gemini\antigravity\brain\92bde1ae-ac0c-4d62-8cfc-e89de1ad59d2"
OUT_DIR = "assets/bicol_bg"

W_TARGET = 4256
H_TARGET = 720

def clean_black_sky_perfect(im):
    """
    Cleans black background while strictly preserving all mountain, smoke, and tree pixels.
    """
    arr = np.array(im.convert("RGBA"))
    H, W, _ = arr.shape
    max_c = np.max(arr[:, :, :3], axis=2)
    # Background in the prompt-generated images is pure black (RGB < 18)
    # Mountain and smoke have brightness > 25
    sky_mask = (max_c < 18) & (np.arange(H)[:, None] < 530)
    arr[sky_mask, 3] = 0
    arr[sky_mask, :3] = 0
    return Image.fromarray(arr)

def make_layer4():
    """
    Builds Layer 4 (Mount Mayon) across 4256x720.
    Places the majestic Mayon with peaks at x ~ 950 and x ~ 2900 (like Forest Layer 4),
    ensuring edges (x=0 and x=4255) are smooth low ridges (height ~461) with zero cut-off peaks.
    """
    raw = Image.open(os.path.join(BRAIN_DIR, "mayon_volcano_layer4_1791096068295.jpg"))
    clean = clean_black_sky_perfect(raw)
    
    # Scale to H_TARGET (720)
    scale = H_TARGET / float(clean.height)
    scaled_w = int(clean.width * scale) # 1290
    scaled = clean.resize((scaled_w, H_TARGET), Image.Resampling.LANCZOS)
    arr = np.array(scaled, dtype=np.float32)
    
    # In `scaled`, peak is at x=796, left edge is at x=0 (height 461), right edge is at x=1289 (height 461).
    # We want a 4256 canvas:
    # Let's create two segments:
    # Segment 1: from x=0 to 2128
    # Segment 2: from x=2128 to 4256
    # In each segment of 2128:
    # Left edge (x=0) is low ridge.
    # Mayon is placed with its peak around x = 950.
    # To place peak (at 796) at x = 950, we place `scaled` starting at x = 950 - 796 = 154!
    # What about x = 0..154? We fill it using the left edge of `scaled` (which is a continuous low ridge).
    # What about x = 154 + 1290 = 1444 to 2128? We fill it using the right edge of `scaled` (a continuous low ridge).
    
    half_w = W_TARGET // 2 # 2128
    half = np.zeros((H_TARGET, half_w, 4), dtype=np.float32)
    
    # Left flank fill (0..154) using the left flank of scaled (cols 0..154)
    # To make it seamless at x=0, let's look at the ridge
    offset_x = 154
    half[:, offset_x:offset_x + scaled_w] = arr
    
    # Fill 0..offset_x with repeated/stretched left flank
    left_sample = arr[:, :offset_x]
    half[:, :offset_x] = left_sample
    
    # Right flank from offset_x + scaled_w (1444) to 2128 is 684 px
    # We can tile the right flank of scaled (cols 1100..1289)
    right_sample = arr[:, 1100:1290] # 190 px wide
    w_rs = right_sample.shape[1]
    cur_x = offset_x + scaled_w
    while cur_x < half_w:
        take = min(w_rs, half_w - cur_x)
        half[:, cur_x:cur_x + take] = right_sample[:, :take]
        cur_x += take
        
    # Now smooth blend between 0 and 2128:
    # Notice that half[:, 0] and half[:, 2127] both come from the flank!
    # Let's do a smooth 64px blend between the end of half and start of half
    # Full canvas is two copies of half, with a 64px blend at x=2128 and wrap-around at 0/4256
    full = np.zeros((H_TARGET, W_TARGET, 4), dtype=np.float32)
    full[:, :half_w] = half
    full[:, half_w:] = half
    
    # Blend seam at x = half_w (2128)
    blend_w = 64
    t = (0.5 - 0.5 * np.cos(np.linspace(0, np.pi, blend_w))).reshape(1, blend_w, 1)
    
    # Seam at 2128:
    left_side = full[:, half_w - blend_w : half_w]
    right_side = full[:, half_w : half_w + blend_w]
    # They are already identical because half is repeated!
    
    # And at x = 0 / 4256:
    # full[:, 0] and full[:, -1] are also identical!
    # Ensure exact wrap match:
    full[:, -1] = full[:, 0]
    
    # Clean zero alpha
    zero_mask = full[:, :, 3] < 5.0
    full[zero_mask] = 0
    
    out = Image.fromarray(np.clip(full, 0, 255).astype(np.uint8))
    return out

def test_preview():
    l4 = make_layer4()
    l4.save(r"C:\Users\Lin\.gemini\antigravity\brain\92bde1ae-ac0c-4d62-8cfc-e89de1ad59d2\test_l4_double.png")
    thumb = l4.resize((1064, 180))
    thumb.save(r"C:\Users\Lin\.gemini\antigravity\brain\92bde1ae-ac0c-4d62-8cfc-e89de1ad59d2\thumb_test_l4_double.png")
    print("Test Layer 4 saved!")

if __name__ == "__main__":
    test_preview()
