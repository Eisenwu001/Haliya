import sys
sys.path.insert(0, ".")
from PIL import Image
from scratch.process_layers import extract_alpha_from_black, make_seamless_horizontal

# Load raw generated images
l4_raw = Image.open(r"C:\Users\Lin\.gemini\antigravity\brain\92bde1ae-ac0c-4d62-8cfc-e89de1ad59d2\mayon_volcano_layer4_1791096068295.jpg")
l3_raw = Image.open(r"C:\Users\Lin\.gemini\antigravity\brain\92bde1ae-ac0c-4d62-8cfc-e89de1ad59d2\rice_terraces_hills_layer3_1791096044337.jpg")
l2_raw = Image.open(r"C:\Users\Lin\.gemini\antigravity\brain\92bde1ae-ac0c-4d62-8cfc-e89de1ad59d2\rice_field_midground_layer2_1791096004300.jpg")

print("Extracting alphas...")
l4_rgba = extract_alpha_from_black(l4_raw, flood_threshold=30, fringe_threshold=60)
l3_rgba = extract_alpha_from_black(l3_raw, flood_threshold=30, fringe_threshold=60)
l2_rgba = extract_alpha_from_black(l2_raw, flood_threshold=30, fringe_threshold=60)

print("Alphas extracted.")
l4_rgba.save(r"scratch\test_l4_rgba.png")
l3_rgba.save(r"scratch\test_l3_rgba.png")
l2_rgba.save(r"scratch\test_l2_rgba.png")
print("Saved test pngs.")
