#!/usr/bin/env python3
import os
import numpy as np
from PIL import Image, ImageDraw

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
decor = Image.open(os.path.join(BASE_DIR, "assets", "platform_assets", "Decor.png")).convert("RGBA")
ores = Image.open(os.path.join(BASE_DIR, "assets", "platform_assets", "Ores.png")).convert("RGBA")

# Let's inspect rock mounds in Decor.png
# In Decor.png:
# Row 3/4 has small and medium rocks:
# Rocks are around (64, 192) to (256, 320)
# Let's check Decor.png size
print("Decor size:", decor.size)
