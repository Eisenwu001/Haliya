from PIL import Image
import numpy as np

orig = Image.open('assets/haliya_backup_originals/common_01_crouch_to_idle01.png').convert('RGBA')
clothed = Image.open('Haliya with clothes/Haliya/Crouch/with mask/kampilan/common_01_crouch_to_idle01.png').convert('RGBA')

a_orig = np.array(orig)
a_cloth = np.array(clothed)

# Overlay image showing changes:
# Green = unchanged
# Red = removed original pixel
# Blue = added clothed pixel
# Yellow = color changed
h, w, _ = a_orig.shape
vis = np.zeros((h, w, 4), dtype=np.uint8)

changed_cnt = 0
for y in range(h):
    for x in range(w):
        po = tuple(a_orig[y, x])
        pc = tuple(a_cloth[y, x])
        if po[3] == 0 and pc[3] == 0:
            continue
        elif po[3] > 0 and pc[3] == 0:
            vis[y, x] = [255, 0, 0, 255] # removed
        elif po[3] == 0 and pc[3] > 0:
            vis[y, x] = [0, 100, 255, 255] # added
        elif po != pc:
            vis[y, x] = [255, 255, 0, 255] # modified
            changed_cnt += 1
        else:
            vis[y, x] = [0, 255, 0, 128] # identical

print(f'Total modified pixels: {changed_cnt}')
Image.fromarray(vis).save('scratch/crouch_diff_vis.png')
