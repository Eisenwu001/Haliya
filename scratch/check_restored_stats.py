import os
from PIL import Image

artifact_dir = r"C:\Users\Lin\.gemini\antigravity\brain\370c75b3-591d-4ff9-a2ef-a82753b68d30"
raw_path = os.path.join(artifact_dir, "restored_menu_raw.png")

img = Image.open(raw_path)
pixel = img.resize((640, 360), Image.Resampling.NEAREST)
out_pixel_path = os.path.join(artifact_dir, "restored_menu_pixel.png")
pixel.save(out_pixel_path)

def lum(c):
    s = [v / 255.0 for v in c]
    s = [((v + 0.055) / 1.055) ** 2.4 if v > 0.04045 else v / 12.92 for v in s]
    return 0.2126 * s[0] + 0.7152 * s[1] + 0.0722 * s[2]

def get_contrast(fg_rgb, bg_rgb):
    l1 = lum(fg_rgb)
    l2 = lum(bg_rgb)
    lighter = max(l1, l2)
    darker = min(l1, l2)
    return (lighter + 0.05) / (darker + 0.05)

# Calculate stats
r_tot, g_tot, b_tot = 0, 0, 0
count = pixel.width * pixel.height
for y in range(pixel.height):
    for x in range(pixel.width):
        p = pixel.getpixel((x, y))
        r_tot += p[0]
        g_tot += p[1]
        b_tot += p[2]

print(f"Restored menu overall brightness Avg RGB: ({r_tot/count:.1f}, {g_tot/count:.1f}, {b_tot/count:.1f})")
print(f"Sky right (480, 80): {pixel.getpixel((480, 80))}")
print(f"Center trees (320, 180): {pixel.getpixel((320, 180))}")
print(f"Totem (483, 200): {pixel.getpixel((483, 200))}")

# Check contrast of CONTINUE button at x=35, y=130 against background panel at x=15, y=130
fg_text = pixel.getpixel((35, 130))[:3]
bg_panel = pixel.getpixel((15, 130))[:3]
print(f"CONTINUE text color: {fg_text}, BG: {bg_panel}, Contrast: {get_contrast(fg_text, bg_panel):.2f}:1")

# Check caption text at x=35, y=147
fg_cap = pixel.getpixel((35, 147))[:3]
print(f"Caption text color: {fg_cap}, BG: {bg_panel}, Contrast: {get_contrast(fg_cap, bg_panel):.2f}:1")

# Check title text at x=37, y=66
fg_title = pixel.getpixel((37, 66))[:3]
bg_title = pixel.getpixel((15, 66))[:3]
print(f"Title text color: {fg_title}, BG: {bg_title}, Contrast: {get_contrast(fg_title, bg_title):.2f}:1")
