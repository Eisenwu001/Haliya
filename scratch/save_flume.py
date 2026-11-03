from PIL import Image
import numpy as np

im = Image.open('scratch/flume_clean.png')
# Target platformer dimensions: width ~ 140, height ~ 56
flume = im.resize((144, 56), Image.Resampling.LANCZOS)
flume.save("assets/rice_field/bamboo_flume.png")
print("Saved assets/rice_field/bamboo_flume.png (144x56) successfully!")
