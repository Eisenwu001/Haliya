from PIL import Image
import numpy as np

# Let's inspect the 4 rice field layers directly
l1 = Image.open('assets/bicol_bg/Rice_Field_Layer1.png')
l2 = Image.open('assets/bicol_bg/Rice_Field_Layer2.png')
l3 = Image.open('assets/bicol_bg/Rice_Field_Layer3.png')
l4 = Image.open('assets/bicol_bg/Rice_Field_Layer4.png')

# Let's check left vs right edges of each layer (do they loop seamlessly?):
for i, l in enumerate([l1, l2, l3, l4], start=1):
    arr = np.array(l)
    left_col = arr[:, 0, :]
    right_col = arr[:, -1, :]
    diff = np.abs(left_col.astype(int) - right_col.astype(int))
    max_d = diff.max()
    mean_d = diff.mean()
    print(f"Layer {i}: Left vs Right edge max diff={max_d}, mean diff={mean_d:.2f}")

# Let's also composite the 4 layers together onto a clean sky and save a preview:
sky = Image.open('assets/platform_assets/background_layers/normal_bg/background_layer_5.png')
# Scale sky to 4256 x 720:
sky_scaled = sky.resize((4256, 720), Image.Resampling.LANCZOS)

comp = Image.new("RGBA", (4256, 720), (0, 0, 0, 255))
comp.paste(sky_scaled, (0, 0))
comp.paste(l4, (0, 0), l4)
comp.paste(l3, (0, 0), l3)
comp.paste(l2, (0, 0), l2)
comp.paste(l1, (0, 0), l1)

# Save a scaled-down 1064x180 preview of the full panorama
comp_small = comp.resize((1064, 180), Image.Resampling.LANCZOS)
comp_small.save("scratch/full_bg_composite_preview.png")
print("Saved scratch/full_bg_composite_preview.png")
