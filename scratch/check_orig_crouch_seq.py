from PIL import Image

i2c01 = Image.open('assets/haliya_backup_originals/common_01_idle_to_crouch01.png')
i2c02 = Image.open('assets/haliya_backup_originals/common_01_idle_to_crouch02.png')
ic = Image.open('assets/haliya_backup_originals/common_01_idle_crouch.png')
c2i01 = Image.open('assets/haliya_backup_originals/common_01_crouch_to_idle01.png')
c2i02 = Image.open('assets/haliya_backup_originals/common_01_crouch_to_idle02.png')

print('Original Crouch sequence bboxes:')
print('  idle_to_crouch01:', i2c01.getbbox())
print('  idle_to_crouch02:', i2c02.getbbox())
print('  idle_crouch:     ', ic.getbbox())
print('  crouch_to_idle01:', c2i01.getbbox())
print('  crouch_to_idle02:', c2i02.getbbox())
