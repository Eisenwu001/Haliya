from PIL import Image

im = Image.open('scratch/test_arch_open.png')
im.save('assets/bahay_kubo/prop_crouch_beam.png')
print('Saved arch to assets/bahay_kubo/prop_crouch_beam.png, size:', im.size)
