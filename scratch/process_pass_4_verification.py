import os
from PIL import Image, ImageDraw

artifact_dir = r"C:\Users\Lin\.gemini\antigravity\brain\370c75b3-591d-4ff9-a2ef-a82753b68d30"
raw_sel_path = os.path.join(artifact_dir, "pass4_raw_selected.png")
raw_unsel_path = os.path.join(artifact_dir, "pass4_raw_unselected.png")

img_sel = Image.open(raw_sel_path)
img_unsel = Image.open(raw_unsel_path)

print(f"Raw image size: {img_sel.size}")

# Downsample to project resolution 640x360
target_w, target_h = 640, 360
pixel_sel = img_sel.resize((target_w, target_h), Image.Resampling.NEAREST)
pixel_unsel = img_unsel.resize((target_w, target_h), Image.Resampling.NEAREST)

pixel_sel.save(os.path.join(artifact_dir, "pass4_full_menu_pixel.png"))
pixel_sel.save(os.path.join(artifact_dir, "pass4_full_menu.png"))
print("Saved pass4_full_menu.png and pass4_full_menu_pixel.png")

# 1. Totem detail (neck, chest, crossed arms, base, mound, offerings)
# Altar pos is around x=483, y=184. Base is at y=290. Offerings at y=278..292. Neck at y=137.
totem_box = (400, 110, 570, 330)
totem_crop = pixel_sel.crop(totem_box)
totem_crop_2x = totem_crop.resize((totem_crop.width * 2, totem_crop.height * 2), Image.Resampling.NEAREST)
totem_crop_2x.save(os.path.join(artifact_dir, "pass4_totem_detail.png"))
print(f"Saved pass4_totem_detail.png from box {totem_box}")

# 2. Corner leaves
# Top-left (x=0..120, y=0..70)
tl_box = (0, 0, 120, 60)
tl_crop = pixel_sel.crop(tl_box)
tl_crop_2x = tl_crop.resize((tl_crop.width * 2, tl_crop.height * 2), Image.Resampling.NEAREST)
tl_crop_2x.save(os.path.join(artifact_dir, "pass4_top_left_corner.png"))
print("Saved pass4_top_left_corner.png")

# Top-right (x=520..640, y=0..70)
tr_box = (520, 0, 640, 60)
tr_crop = pixel_sel.crop(tr_box)
tr_crop_2x = tr_crop.resize((tr_crop.width * 2, tr_crop.height * 2), Image.Resampling.NEAREST)
tr_crop_2x.save(os.path.join(artifact_dir, "pass4_top_right_corner.png"))
print("Saved pass4_top_right_corner.png")

# 3. Bottom edge (full width 640 x 50px high at bottom: y=310..360)
bottom_box = (0, 310, 640, 360)
bottom_crop = pixel_sel.crop(bottom_box)
bottom_crop_2x = bottom_crop.resize((bottom_crop.width, bottom_crop.height * 2), Image.Resampling.NEAREST)
bottom_crop_2x.save(os.path.join(artifact_dir, "pass4_bottom_edge.png"))
print("Saved pass4_bottom_edge.png")

# 4. CONTINUE and Caption Alignment Analysis
def analyze_alignment(img, state_name):
    # Crop around CONTINUE and caption: x=10..180, y=100..155
    btn_crop = img.crop((10, 100, 180, 155))
    
    # Find the leftmost bright pixel for CONTINUE (y in range 100..125) and CAPTION (y in range 125..150)
    # Bright threshold: r > 160 and g > 150
    cont_x = []
    cap_x = []
    
    for y in range(100, 125):
        for x in range(15, 120):
            r, g, b = img.getpixel((x, y))[:3]
            if r > 160 and g > 150 and b > 120:
                cont_x.append(x)
                break
                
    for y in range(125, 150):
        for x in range(15, 120):
            r, g, b = img.getpixel((x, y))[:3]
            if r > 160 and g > 150 and b > 120:
                cap_x.append(x)
                break
                
    min_cont = min(cont_x) if cont_x else -1
    min_cap = min(cap_x) if cap_x else -1
    print(f"[{state_name}] Leftmost CONTINUE pixel x={min_cont}, Leftmost CAPTION pixel x={min_cap}, Diff={min_cap - min_cont}")
    
    # Save a 4x magnified crop with an alignment guide line
    crop_guide = btn_crop.resize((btn_crop.width * 4, btn_crop.height * 4), Image.Resampling.NEAREST)
    draw = ImageDraw.Draw(crop_guide)
    # Draw red vertical dashed line at min_cont
    guide_x = (min_cont - 10) * 4
    for gy in range(0, crop_guide.height, 6):
        draw.line([(guide_x, gy), (guide_x, min(gy + 3, crop_guide.height))], fill=(255, 60, 60, 255), width=2)
        
    out_path = os.path.join(artifact_dir, f"pass4_caption_alignment_{state_name}.png")
    crop_guide.save(out_path)
    print(f"Saved {out_path}")
    return min_cont, min_cap

c_sel, a_sel = analyze_alignment(pixel_sel, "selected")
c_unsel, a_unsel = analyze_alignment(pixel_unsel, "unselected")

# 5. Measure bottom margin of totem base and offerings
# Search in column 483 for the lowest non-background pixel of the totem / offerings assembly
lowest_y = -1
for y in range(359, 200, -1):
    r, g, b = pixel_sel.getpixel((483, y))[:3]
    # Check if pixel is part of mound or offerings or totem base (not ground foliage or background)
    # Background foliage strip is at y=344..360, ground shadow is around y=290
    if (r, g, b) != (4, 5, 8) and y < 344:
        lowest_y = y
        break

print(f"Lowest totem/offerings structure y: {lowest_y}, Margin to screen bottom (360): {360 - lowest_y}px")

# 6. Contrast calculation for title and menu text
# Relative luminance formula: L = 0.2126 * R + 0.7152 * G + 0.0722 * B
def get_contrast(fg_rgb, bg_rgb):
    def lum(c):
        s = [v / 255.0 for v in c]
        s = [((v + 0.055) / 1.055) ** 2.4 if v > 0.04045 else v / 12.92 for v in s]
        return 0.2126 * s[0] + 0.7152 * s[1] + 0.0722 * s[2]
    l1 = lum(fg_rgb)
    l2 = lum(bg_rgb)
    lighter = max(l1, l2)
    darker = min(l1, l2)
    return (lighter + 0.05) / (darker + 0.05)

bg_sample = pixel_sel.getpixel((40, 115))[:3] # Under CONTINUE
fg_sample = pixel_sel.getpixel((c_sel + 2, 115))[:3] # On the 'C'
contrast = get_contrast(fg_sample, bg_sample)
print(f"Menu text contrast: FG {fg_sample} vs BG {bg_sample} => Ratio: {contrast:.2f}:1")
