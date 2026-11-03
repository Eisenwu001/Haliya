import os
from PIL import Image, ImageDraw, ImageFont

artifact_dir = r"C:\Users\Lin\.gemini\antigravity\brain\370c75b3-591d-4ff9-a2ef-a82753b68d30"
raw_sel = Image.open(os.path.join(artifact_dir, "pass4_raw_selected.png"))
raw_unsel = Image.open(os.path.join(artifact_dir, "pass4_raw_unselected.png"))

pixel_sel = raw_sel.resize((640, 360), Image.Resampling.NEAREST)
pixel_unsel = raw_unsel.resize((640, 360), Image.Resampling.NEAREST)

# Save full menu images
pixel_sel.save(os.path.join(artifact_dir, "pass4_full_menu.png"))
pixel_sel.save(os.path.join(artifact_dir, "pass4_full_menu_pixel.png"))

# 1. Totem detail crop (x=410..560, y=70..305) -> 150x235
totem_crop = pixel_sel.crop((410, 70, 560, 305))
totem_2x = totem_crop.resize((totem_crop.width * 2, totem_crop.height * 2), Image.Resampling.NEAREST)
totem_2x.save(os.path.join(artifact_dir, "pass4_totem_detail.png"))

# 2. Top-left corner (x=0..120, y=0..60)
tl_crop = pixel_sel.crop((0, 0, 120, 60))
tl_2x = tl_crop.resize((tl_crop.width * 2, tl_crop.height * 2), Image.Resampling.NEAREST)
tl_2x.save(os.path.join(artifact_dir, "pass4_top_left_corner.png"))

# 3. Top-right corner (x=520..640, y=0..60)
tr_crop = pixel_sel.crop((520, 0, 640, 60))
tr_2x = tr_crop.resize((tr_crop.width * 2, tr_crop.height * 2), Image.Resampling.NEAREST)
tr_2x.save(os.path.join(artifact_dir, "pass4_top_right_corner.png"))

# 4. Bottom edge (full width 640 x 50px high at bottom: y=310..360)
bottom_crop = pixel_sel.crop((0, 310, 640, 360))
bottom_2x = bottom_crop.resize((bottom_crop.width, bottom_crop.height * 2), Image.Resampling.NEAREST)
bottom_2x.save(os.path.join(artifact_dir, "pass4_bottom_edge.png"))

# 5. Combined side-by-side CONTINUE / caption alignment comparison
# Crop box: x=15..175, y=115..155 (160 x 40)
crop_s = pixel_sel.crop((15, 115, 175, 155))
crop_u = pixel_unsel.crop((15, 115, 175, 155))

# Zoom 4x
z_s = crop_s.resize((crop_s.width * 4, crop_s.height * 4), Image.Resampling.NEAREST)
z_u = crop_u.resize((crop_u.width * 4, crop_u.height * 4), Image.Resampling.NEAREST)

# Draw red vertical guide lines on both
# Selected: 'C' and 'A' are at x=35. Relative to box x=15, offset is 20px -> 80px in 4x zoom
draw_s = ImageDraw.Draw(z_s)
line_s_x = (35 - 15) * 4
for y in range(0, z_s.height, 8):
    draw_s.line([(line_s_x, y), (line_s_x, min(y + 4, z_s.height))], fill=(255, 60, 60), width=2)

# Unselected: 'C' and 'A' are at x=29. Relative to box x=15, offset is 14px -> 56px in 4x zoom
draw_u = ImageDraw.Draw(z_u)
line_u_x = (29 - 15) * 4
for y in range(0, z_u.height, 8):
    draw_u.line([(line_u_x, y), (line_u_x, min(y + 4, z_u.height))], fill=(255, 60, 60), width=2)

# Stitch side-by-side with a small label header
combined_w = z_s.width + z_u.width + 16
combined_h = z_s.height + 36
combined = Image.new("RGB", (combined_w, combined_h), (18, 24, 22))
draw_c = ImageDraw.Draw(combined)

# Paste crops
combined.paste(z_s, (0, 36))
combined.paste(z_u, (z_s.width + 16, 36))

# Labels
draw_c.text((10, 10), "SELECTED STATE (Both aligned at x=35 px)", fill=(216, 207, 168))
draw_c.text((z_s.width + 26, 10), "UNSELECTED STATE (Both aligned at x=29 px)", fill=(216, 207, 168))

combined.save(os.path.join(artifact_dir, "pass4_caption_alignment.png"))
print("All final crops generated successfully!")
