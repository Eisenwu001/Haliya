from PIL import Image

im = Image.open("assets/cave_platformer/cave_platforms.png")
print("cave_platforms.png size:", im.size)

# Let's save individual platform crops into scratch for review
crops = {
    "island_lg_128x56": (0, 0, 128, 56),
    "island_md_96x48": (128, 0, 224, 48),
    "bridge_128x40": (0, 64, 128, 104),
    "crumble_96x48": (128, 64, 224, 112),
    "sanctuary_160x56": (0, 104, 160, 160)
}

for name, box in crops.items():
    cropped = im.crop(box)
    cropped.save(f"scratch/{name}.png")
    print(f"Saved scratch/{name}.png (size: {cropped.size})")
