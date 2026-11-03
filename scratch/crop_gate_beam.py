from PIL import Image
import numpy as np

im = Image.open('scratch/test_gate_tight.png')
# Rows 15..55
beam = im.crop((0, 15, im.size[0], 55))
print('Beam crop size:', beam.size)
beam.save('scratch/test_gate_beam_crop.png')
