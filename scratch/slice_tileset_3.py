import numpy as np
from PIL import Image

def slice_preview(img_path, prefix, rows=4, cols=4):
    im = Image.open(img_path)
    w, h = im.size
    sw, sh = w // cols, h // rows
    print(f"Slicing {img_path}: {w}x{h} -> {rows}x{cols} grid of {sw}x{sh}")
    
    out_dir = f"scratch/{prefix}_slices"
    import os
    os.makedirs(out_dir, exist_ok=True)
    
    for r in range(rows):
        for c in range(cols):
            box = (c * sw, r * sh, (c + 1) * sw, (r + 1) * sh)
            cropped = im.crop(box)
            cropped.save(f"{out_dir}/cell_{r}_{c}.png")
    print(f"Saved {rows*cols} cells to {out_dir}")

slice_preview(r"C:\Users\Lin\.gemini\antigravity\brain\e5c63084-b9ad-4add-8dcb-68444de8a484\cave_tileset_spritesheet_1792544092516.jpg", "tileset_3", 4, 4)
