from PIL import Image

charms_img = Image.open(r"c:\Users\Lin\OneDrive\Pictures\Camera Roll\Documents\project-1-test\assets\art\charms.png")
print("Charms size:", charms_img.size)

charms_colors = set(charms_img.getpixel((x, y))[:3] for y in range(charms_img.height) for x in range(charms_img.width) if charms_img.getpixel((x, y))[3] > 0)
print("Charms colors:", sorted(charms_colors))
