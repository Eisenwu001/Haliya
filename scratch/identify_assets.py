import os
from PIL import Image

upload_dir = r"C:\Users\Lin\.gemini\antigravity\brain\370c75b3-591d-4ff9-a2ef-a82753b68d30\.user_uploaded"

for f in os.listdir(upload_dir):
    fp = os.path.join(upload_dir, f)
    img = Image.open(fp)
    # Check alpha channel
    alpha = img.split()[-1]
    bbox = alpha.getbbox()
    total_pixels = img.width * img.height
    transparent_pixels = sum(1 for p in alpha.getdata() if p == 0)
    pct_trans = (transparent_pixels / total_pixels) * 100
    
    # Sample non-transparent pixels to see dominant colors
    sample_colors = []
    for y in range(0, img.height, 10):
        for x in range(0, img.width, 10):
            p = img.getpixel((x, y))
            if p[3] > 10:
                sample_colors.append(p[:3])
                
    avg_r = sum(c[0] for c in sample_colors) / max(1, len(sample_colors))
    avg_g = sum(c[1] for c in sample_colors) / max(1, len(sample_colors))
    avg_b = sum(c[2] for c in sample_colors) / max(1, len(sample_colors))
    
    print(f"\n--- {f} ---")
    print(f"Size: {img.size}")
    print(f"Alpha bbox: {bbox}")
    print(f"Transparent percent: {pct_trans:.1f}%")
    print(f"Average color of opaque pixels: ({avg_r:.1f}, {avg_g:.1f}, {avg_b:.1f})")
