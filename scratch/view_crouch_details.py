from PIL import Image

cti01 = Image.open('assets/haliya/common_01_crouch_to_idle01.png').convert('RGBA')
cti02 = Image.open('assets/haliya/common_01_crouch_to_idle02.png').convert('RGBA')
ic = Image.open('assets/haliya_backup_originals/common_01_idle_crouch.png').convert('RGBA')

comp = Image.new('RGBA', (256 * 3, 256), (30, 32, 40, 255))
comp.paste(ic, (0, 0), ic)
comp.paste(cti01, (256, 0), cti01)
comp.paste(cti02, (512, 0), cti02)

comp.save('scratch/crouch_details_3x.png')
print('Saved crouch_details_3x.png')
