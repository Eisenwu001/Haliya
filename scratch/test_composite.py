import numpy as np
from PIL import Image

sky_raw = Image.open(r"c:\Users\Lin\OneDrive\Pictures\Camera Roll\Documents\project-1-test\assets\platform_assets\background_layers\normal_bg\background_layer_5.png").convert("RGBA")
l4_raw = Image.open(r"scratch\test_l4_clean.png").convert("RGBA")
l3_raw = Image.open(r"scratch\test_l3_clean.png").convert("RGBA")
l2_raw = Image.open(r"scratch\test_l2_clean.png").convert("RGBA")
l1_raw = Image.open(r"c:\Users\Lin\OneDrive\Pictures\Camera Roll\Documents\project-1-test\assets\bicol_bg\Rice_Field_Layer1.png").convert("RGBA")

# Let's check aspect ratio and sizing:
# Target viewport preview resolution: 1280 x 720 (or 2160 x 720)
CANVAS_W = 2160
CANVAS_H = 720

# Sky: resize to fit canvas
sky = sky_raw.resize((CANVAS_W, CANVAS_H), Image.Resampling.BILINEAR)

# For L4 (Mayon):
# If Mayon is scaled to height 720: width is int(1376 * (720 / 768)) = 1290
# We can center Mayon or place it across the 2160 canvas.
# Or if scaled to (2160, 720):
l4_stretch = l4_raw.resize((CANVAS_W, CANVAS_H), Image.Resampling.BILINEAR)

# Let's also test a centered Mayon where the tree canopy extends to 2160:
l4_centered = Image.new("RGBA", (CANVAS_W, CANVAS_H), (0, 0, 0, 0))
scale_4 = 720.0 / l4_raw.height
w4_proportional = int(l4_raw.width * scale_4)
l4_prop = l4_raw.resize((w4_proportional, 720), Image.Resampling.BILINEAR)

# For L3 (Terraced hills):
l3_fit = l3_raw.resize((CANVAS_W, CANVAS_H), Image.Resampling.BILINEAR)

# For L2 (Midground rice paddies):
l2_fit = l2_raw.resize((CANVAS_W, CANVAS_H), Image.Resampling.BILINEAR)

# For L1: already 2160 x 720
l1_fit = l1_raw

# Composite 1: With L4 stretched to 2160
comp1 = Image.alpha_composite(sky, l4_stretch)
comp1 = Image.alpha_composite(comp1, l3_fit)
comp1 = Image.alpha_composite(comp1, l2_fit)
comp1 = Image.alpha_composite(comp1, l1_fit)
comp1.save(r"scratch\test_composite_all_layers.png")

print("Saved test_composite_all_layers.png successfully!")
