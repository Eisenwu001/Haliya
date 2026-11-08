from PIL import Image
import numpy as np

# Load base original low crouch
orig_ic = Image.open('assets/haliya_backup_originals/common_01_idle_crouch.png').convert('RGBA')
arr = np.array(orig_ic)

# Palette mapping:
# Red clothes (77, 45, 43) -> dark blue (5, 39, 50)
# Red shade (122, 74, 70) -> medium blue (15, 86, 133)
# Red dark shade (39, 3, 1) -> deep charcoal (4, 5, 6)
# Bare torso skin in chest/abdomen area (y in [195, 225], x in [110, 140]) -> tunic blue / gold trim

# Load Mask 3
mask_img = Image.open('scratch/layer_3_Mask_3.png').convert('RGBA')
arr_mask = np.array(mask_img)

synth = arr.copy()

# 1. Color transfer on existing clothing
for y in range(256):
    for x in range(256):
        r, g, b, a = synth[y, x]
        if a == 0: continue
        # Red clothing to blue fabric
        if (r, g, b) == (77, 45, 43):
            synth[y, x] = [5, 39, 50, 255]
        elif (r, g, b) == (122, 74, 70):
            synth[y, x] = [15, 86, 133, 255]
        elif (r, g, b) == (39, 3, 1) or (r, g, b) == (83, 7, 2):
            synth[y, x] = [4, 5, 6, 255]
        # Midriff skin to tunic fabric
        elif y in range(204, 222) and x in range(112, 138):
            if (r, g, b) in [(242, 173, 150), (249, 204, 181), (189, 126, 105)]:
                # Use medium/dark blue pattern
                if (x + y) % 3 == 0:
                    synth[y, x] = [19, 57, 85, 255]
                elif (x + y) % 3 == 1:
                    synth[y, x] = [5, 39, 50, 255]
                else:
                    synth[y, x] = [15, 86, 133, 255]

# 2. Place Mask 3 on face
# Face in idle_crouch is at x ~ 118, y ~ 185
mask_x0, mask_y0 = 120, 184
mh, mw, _ = arr_mask.shape
for my in range(mh):
    for mx in range(mw):
        if arr_mask[my, mx, 3] > 100:
            target_x = mask_x0 + mx
            target_y = mask_y0 + my
            if 0 <= target_x < 256 and 0 <= target_y < 256:
                synth[target_y, target_x] = arr_mask[my, mx]

img_synth = Image.fromarray(synth)
img_synth.save('scratch/synthesized_idle_crouch.png')
print('Successfully saved synthesized_idle_crouch.png!')
