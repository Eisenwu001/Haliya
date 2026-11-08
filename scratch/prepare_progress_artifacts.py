import os
from PIL import Image

ARTIFACT_DIR = r"C:\Users\Lin\.gemini\antigravity\brain\b7e90845-ca12-439f-9bfd-ca181b043a07"
os.makedirs(ARTIFACT_DIR, exist_ok=True)

capture_names = [
    "progress_canopy_0",
    "progress_canopy_25",
    "progress_canopy_50",
    "progress_canopy_75",
    "progress_canopy_100",
    "progress_sky_0",
    "progress_sky_25",
    "progress_sky_50",
    "progress_sky_75",
    "progress_sky_100",
]

for name in capture_names:
    src_path = name + ".png"
    if not os.path.exists(src_path):
        print(f"Warning: {src_path} not found!")
        continue
    raw_img = Image.open(src_path)
    
    # 1. Downscale 4x viewport stretch with NEAREST to obtain exact 1x base resolution 640x360
    base_img = raw_img.resize((640, 360), Image.Resampling.NEAREST)
    dst_full = os.path.join(ARTIFACT_DIR, f"fullscreen_{name}_640x360.png")
    base_img.save(dst_full)
    
    # 2. 3x Progress Bar Crop (tight around the progress bar: x=224..416, y=5..29 -> 192x24 at 3x is 576x72)
    crop_tight = base_img.crop((224, 5, 416, 29))
    crop_3x = crop_tight.resize((crop_tight.size[0] * 3, crop_tight.size[1] * 3), Image.Resampling.NEAREST)
    dst_crop = os.path.join(ARTIFACT_DIR, f"crop_3x_{name}.png")
    crop_3x.save(dst_crop)
    
    # 3. 3x Wide Header Crop (x=0..640, y=0..36 -> shows HP cluster, progress bar, kill counter)
    if "50" in name:
        crop_wide = base_img.crop((0, 0, 640, 36))
        crop_wide_3x = crop_wide.resize((crop_wide.size[0] * 3, crop_wide.size[1] * 3), Image.Resampling.NEAREST)
        dst_wide = os.path.join(ARTIFACT_DIR, f"crop_wide_3x_{name}.png")
        crop_wide_3x.save(dst_wide)

print("All artifacts prepared and downscaled to base-resolution correctly.")
