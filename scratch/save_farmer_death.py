from PIL import Image

im = Image.open('assets/rice_field/corrupted_farmer_spritesheet.png')
fw, fh = 96, 96

for i, (r, c) in enumerate([(3, 2), (3, 3), (3, 4), (3, 5)], start=20):
    crop = im.crop((c*fw, r*fh, (c+1)*fw, (r+1)*fh))
    crop.save(f"scratch/farmer_f{i}.png")
print("Saved scratch/farmer_f20..f23.png")
