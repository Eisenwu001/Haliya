import os
from PIL import Image

incoming_dir = r"c:\Users\Lin\OneDrive\Pictures\Camera Roll\Documents\project-1-test\assets\art\incoming"
files = ["bottom_foliage.png", "hanging_leaves.png", "corner_fronds_left.png", "totem_shrine.png"]

for fn in files:
    fp = os.path.join(incoming_dir, fn)
    if not os.path.exists(fp):
        print(f"MISSING: {fn}")
        continue
    img = Image.open(fp)
    w, h = img.size
    has_alpha = img.mode == "RGBA" or "A" in img.getbands()
    if not has_alpha:
        print(f"ERROR: {fn} does NOT have an alpha channel!")
        continue
    
    alpha = img.split()[-1]
    trans_count = sum(1 for p in alpha.getdata() if p == 0)
    semi_count = sum(1 for p in alpha.getdata() if 0 < p < 255)
    opaque_count = sum(1 for p in alpha.getdata() if p == 255)
    total = w * h
    
    bbox = alpha.getbbox()
    print(f"\n=== {fn} ===")
    print(f"Size: {w}x{h}, Mode: {img.mode}")
    print(f"Fully transparent pixels: {trans_count} ({trans_count/total*100:.2f}%)")
    print(f"Semi-transparent edge pixels: {semi_count} ({semi_count/total*100:.2f}%)")
    print(f"Fully opaque pixels: {opaque_count} ({opaque_count/total*100:.2f}%)")
    print(f"Alpha bbox: {bbox}")
