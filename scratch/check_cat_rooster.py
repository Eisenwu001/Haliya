from PIL import Image

for name in ['prop_sleeping_cat.png', 'prop_rooster.png']:
    im = Image.open('assets/bahay_kubo/' + name)
    print(name, 'size:', im.size, 'mode:', im.mode)
