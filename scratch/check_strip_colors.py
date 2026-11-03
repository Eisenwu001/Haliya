from PIL import Image

strip_img = Image.open(r"c:\Users\Lin\OneDrive\Pictures\Camera Roll\Documents\project-1-test\assets\art\ground_foliage_strip.png")
print("Strip size:", strip_img.size)

colors = set()
for y in range(strip_img.height):
    for x in range(strip_img.width):
        p = strip_img.getpixel((x, y))
        if p[3] > 0:
            colors.add(p[:3])

print("Unique non-transparent colors in ground_foliage_strip.png:")
for c in sorted(colors):
    print(f"  RGB: {c}")
