from PIL import Image
import numpy as np

im = Image.open('scratch/test_gate_tight.png')
print('test_gate_tight size:', im.size)
# Let's see rows 0 to 100
# It has horizontal beam in rows 20..50, and side posts going all the way down!
sub = im.crop((15, 15, 160, 110))
print('Sub size:', sub.size)
sub.save('scratch/test_arch_preview.png')
