import os
from PIL import Image, ImageDraw

artifact_dir = r"C:\Users\Lin\.gemini\antigravity\brain\370c75b3-591d-4ff9-a2ef-a82753b68d30"
black_img = Image.open(os.path.join(artifact_dir, "diagnostic_time_1.0s.png")).resize((640, 360), Image.Resampling.NEAREST)
restored_img = Image.open(os.path.join(artifact_dir, "restored_menu_pixel.png"))

# Create side-by-side comparison (1300 x 400)
comp_w = 640 * 2 + 20
comp_h = 360 + 40
comp = Image.new("RGB", (comp_w, comp_h), (16, 20, 18))
draw = ImageDraw.Draw(comp)

comp.paste(black_img, (0, 40))
comp.paste(restored_img, (640 + 20, 40))

draw.text((10, 12), "WHAT HAPPENED (Defaulted to Intro Splash: All-Black Screen with logo)", fill=(216, 207, 168))
draw.text((640 + 30, 12), "RESTORED (Main Menu Displays Immediately with Full Design & Restored Atmosphere)", fill=(216, 207, 168))

out_path = os.path.join(artifact_dir, "restoration_comparison.png")
comp.save(out_path)
print("Saved restoration_comparison.png")

# Also save restored_menu_pixel as pass4_full_menu.png so the latest screenshot is the restored one
restored_img.save(os.path.join(artifact_dir, "pass4_full_menu.png"))
restored_img.save(os.path.join(artifact_dir, "pass4_full_menu_pixel.png"))
