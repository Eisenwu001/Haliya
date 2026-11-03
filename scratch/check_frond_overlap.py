from PIL import Image

fronds = Image.open("assets/art/corner_fronds_left.png")
print("fronds size:", fronds.size) # (134, 88)

# Title lockup starts at x=26, y=48.
# Let's check which pixels in fronds have alpha > 0 where x >= 26 and y >= 48
overlap_pixels = []
for y in range(48, fronds.height):
    for x in range(26, fronds.width):
        p = fronds.getpixel((x, y))
        if p[3] > 0:
            overlap_pixels.append((x, y))

print(f"Number of opaque frond pixels in title box (x>=26, y>=48): {len(overlap_pixels)}")
if overlap_pixels:
    print(f"Min y: {min(p[1] for p in overlap_pixels)}, Max y: {max(p[1] for p in overlap_pixels)}")
    print(f"Min x: {min(p[0] for p in overlap_pixels)}, Max x: {max(p[0] for p in overlap_pixels)}")
