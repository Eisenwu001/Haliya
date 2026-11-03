from PIL import Image

l_img = Image.open(r"c:\Users\Lin\OneDrive\Pictures\Camera Roll\Documents\project-1-test\assets\art\foreground_leaves_left.png")
r_img = Image.open(r"c:\Users\Lin\OneDrive\Pictures\Camera Roll\Documents\project-1-test\assets\art\foreground_leaves_right.png")

print("Left leaves size:", l_img.size)
print("Right leaves size:", r_img.size)

l_colors = set(l_img.getpixel((x, y))[:3] for y in range(l_img.height) for x in range(l_img.width) if l_img.getpixel((x, y))[3] > 0)
r_colors = set(r_img.getpixel((x, y))[:3] for y in range(r_img.height) for x in range(r_img.width) if r_img.getpixel((x, y))[3] > 0)

print("Left colors:", sorted(l_colors))
print("Right colors:", sorted(r_colors))
print("Colors match exactly?", l_colors == r_colors)

# Check stray pixels
def check_stray(img):
    w, h = img.size
    stray = 0
    for y in range(h):
        for x in range(w):
            if img.getpixel((x, y))[3] > 0:
                # check 8 neighbors
                neighbors = 0
                for dy in [-1, 0, 1]:
                    for dx in [-1, 0, 1]:
                        if dx == 0 and dy == 0:
                            continue
                        nx, ny = x + dx, y + dy
                        if 0 <= nx < w and 0 <= ny < h:
                            if img.getpixel((nx, ny))[3] > 0:
                                neighbors += 1
                if neighbors == 0:
                    stray += 1
    return stray

print("Left isolated stray pixels:", check_stray(l_img))
print("Right isolated stray pixels:", check_stray(r_img))
