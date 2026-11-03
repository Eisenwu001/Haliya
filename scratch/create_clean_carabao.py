from PIL import Image
import numpy as np

raw = Image.open('assets/rice_field/carabao_raw.png')
# Let's create an image showing carabao_raw with a clean background
# And let's see its aspect ratio and details:
print("carabao_raw size:", raw.size) # (882, 656)

# In carabao_raw, what is the padding?
# Earlier we found:
# Top non-zero: y=0 (tips at x=323..348)
# Bottom non-zero: y=655 (base at x=364..430)
# Left non-zero: x=0 (y=205..220)
# Right non-zero: x=881 (y=410..450)

# If we pad by 10 pixels around all sides:
padded = Image.new("RGBA", (raw.size[0] + 20, raw.size[1] + 20), (0, 0, 0, 0))
padded.paste(raw, (10, 10))

# If we downscale to e.g. 100x74:
clean_base = padded.resize((104, 76), Image.Resampling.LANCZOS)
clean_base.save("scratch/clean_carabao_base.png")
print("Saved scratch/clean_carabao_base.png")
