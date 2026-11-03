from PIL import Image
import numpy as np

p1 = Image.open('assets/bahay_kubo/tile_deck_platform.png')
print('tile_deck_platform.png:', p1.size, p1.mode)

p2 = Image.open('scratch/test_gate_structure.png')
print('test_gate_structure.png:', p2.size, p2.mode)
