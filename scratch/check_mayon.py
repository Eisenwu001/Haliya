from PIL import Image
import numpy as np

l4 = Image.open('assets/bicol_bg/Rice_Field_Layer4.png')
# Mayon is typically in the center of the image (x around 1500..2600)
# Let's crop the volcano and check it:
w, h = l4.size
crop_mayon = l4.crop((w // 2 - 500, 0, w // 2 + 500, 450))
crop_mayon.save("scratch/mayon_crop.png")
print("Saved scratch/mayon_crop.png")
