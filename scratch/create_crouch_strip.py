from PIL import Image

names = [
    'common_01_idle_to_crouch01.png',
    'common_01_idle_to_crouch02.png',
    'common_01_idle_crouch.png',
    'common_01_crouch_to_idle01.png',
    'common_01_crouch_to_idle02.png'
]

crop_w, crop_h = 130, 140
c_strip = Image.new('RGBA', (crop_w * 5, crop_h * 2), (28, 30, 36, 255))

for i, name in enumerate(names):
    orig = Image.open(f'assets/haliya_backup_originals/{name}').convert('RGBA').crop((50, 115, 180, 255))
    clothed = Image.open(f'assets/haliya/{name}').convert('RGBA').crop((50, 115, 180, 255))
    c_strip.paste(orig, (i * crop_w, 0), orig)
    c_strip.paste(clothed, (i * crop_w, crop_h), clothed)

c_strip.save('scratch/crouch_strip_crop_1x.png')
c_strip_3x = c_strip.resize((c_strip.width * 3, c_strip.height * 3), Image.NEAREST)
c_strip_3x.save('scratch/crouch_strip_crop_3x.png')

print('Saved crouch_strip_crop_1x.png and crouch_strip_crop_3x.png!')
