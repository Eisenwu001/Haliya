from PIL import Image
import numpy as np

sheet = Image.open('assets/rice_field/corrupted_farmer_spritesheet.png')
# Frame 19 is row 3, col 1
f19 = sheet.crop((1*96, 3*96, 2*96, 4*96))
arr19 = np.array(f19)
w19 = (arr19[:, :, 0] > 240) & (arr19[:, :, 1] > 240) & (arr19[:, :, 2] > 240) & (arr19[:, :, 3] > 0)
print("f19 total nonz:", (arr19[:, :, 3] > 0).sum(), "white pixels:", w19.sum())
f19.save("scratch/farmer_f19.png")
