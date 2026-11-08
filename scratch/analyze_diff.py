from PIL import Image
import numpy as np

# Let's compare assets/haliya/common_00_idle_stand_A01.png
# and Haliya with clothes/Haliya/Idle/w- Mask/v3/kampilan/haliya_idle_A01.png
# and Haliya with clothes/Haliya/Idle/w- Mask/v3/fist/haliya_idle_A01.png

base = Image.open('assets/haliya/common_00_idle_stand_A01.png').convert('RGBA')
cloth_kamp = Image.open('Haliya with clothes/Haliya/Idle/w- Mask/v3/kampilan/haliya_idle_A01.png')
cloth_fist = Image.open('Haliya with clothes/Haliya/Idle/w- Mask/v3/fist/haliya_idle_A01.png')

arr_base = np.array(base)
arr_kamp = np.array(cloth_kamp)
arr_fist = np.array(cloth_fist)

# Let's see what is changed between base and cloth_kamp:
# Where arr_kamp != arr_base
diff_mask = np.any(arr_kamp != arr_base, axis=-1)

# Let's create an image showing:
# 1. Base
# 2. Cloth kampilan
# 3. Exactly what changed (diff pixels from cloth_kamp)
# 4. If we composite only the diff over base:
diff_only = np.zeros_like(arr_kamp)
diff_only[diff_mask] = arr_kamp[diff_mask]
Image.fromarray(diff_only).save('scratch/diff_kamp_over_base.png')

# What about kampilan vs fist?
diff_kamp_fist = np.any(arr_kamp != arr_fist, axis=-1)
# Where kampilan has weapon, what does it look like?
wp_only = np.zeros_like(arr_kamp)
wp_only[diff_kamp_fist] = arr_kamp[diff_kamp_fist]
Image.fromarray(wp_only).save('scratch/weapon_diff_kamp_fist.png')

print("Saved diff images to scratch/")
