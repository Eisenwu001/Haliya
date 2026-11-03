from PIL import Image
import numpy as np

def extract_chromakey(jpg_path, out_png_path, target_size=None):
    im = Image.open(jpg_path)
    arr = np.array(im, dtype=float)
    H, W, _ = arr.shape
    
    # Magenta chroma key condition:
    # High R, high B, low G
    # And R ~ B (magenta has roughly equal R and B)
    diff_rb = np.abs(arr[:, :, 0] - arr[:, :, 2])
    is_mag = (arr[:, :, 0] > 140) & (arr[:, :, 2] > 140) & (arr[:, :, 1] < 90) & (diff_rb < 70)
    
    # Also catch dark magenta JPEG compression artifacts (e.g. [54, 0, 53]):
    is_dark_mag = (arr[:, :, 0] > 30) & (arr[:, :, 2] > 30) & (arr[:, :, 1] < 40) & (diff_rb < 30)
    
    bg = is_mag | is_dark_mag
    
    # Clean alpha:
    alpha = np.where(bg, 0, 255).astype(np.uint8)
    
    # Check bounds of foreground:
    ys, xs = np.where(~bg)
    if len(xs) == 0:
        print("Error: no foreground found in", jpg_path)
        return
        
    print(f"{out_png_path}: bounds x=({xs.min()}..{xs.max()}) w={xs.max()-xs.min()+1}, y=({ys.min()}..{ys.max()}) h={ys.max()-ys.min()+1}")
    
    rgba = np.zeros((H, W, 4), dtype=np.uint8)
    rgba[:, :, :3] = np.clip(arr, 0, 255).astype(np.uint8)
    rgba[:, :, 3] = alpha
    
    # Crop tightly
    cropped = Image.fromarray(rgba).crop((xs.min(), ys.min(), xs.max() + 1, ys.max() + 1))
    
    if target_size:
        cropped = cropped.resize(target_size, Image.Resampling.LANCZOS)
        
    cropped.save(out_png_path)
    print(f"Saved {out_png_path} ({cropped.size})")

extract_chromakey(
    r'C:\Users\Lin\.gemini\antigravity\brain\affaaa51-5c2e-4029-96b6-27d506de5489\bamboo_flume_1792799791201.jpg',
    'scratch/flume_clean.png',
    (160, 64)
)

extract_chromakey(
    r'C:\Users\Lin\.gemini\antigravity\brain\affaaa51-5c2e-4029-96b6-27d506de5489\corrupted_farmer_poses_1792799815492.jpg',
    'scratch/farmer_poses_clean.png'
)
