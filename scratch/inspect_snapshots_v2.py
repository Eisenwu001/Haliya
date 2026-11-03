from PIL import Image

# Inspect Farmstead in Level 2-1:
snap_farm = Image.open('snapshot_rice_field_2_1_farmstead.png')
w, h = snap_farm.size
crop_kubo = snap_farm.crop((w // 2 - 450, h // 2 - 250, w // 2 + 450, h // 2 + 250))
crop_kubo.save('scratch/verify_new_kubo_farmstead.png')

# Inspect Level 2-2 Twilight Farmstead:
snap_2_2 = Image.open('snapshot_rice_field_2_2.png')
crop_2_2 = snap_2_2.crop((w // 2 - 450, h // 2 - 250, w // 2 + 450, h // 2 + 250))
crop_2_2.save('scratch/verify_new_level_2_2.png')

print("Saved scratch/verify_new_kubo_farmstead.png and scratch/verify_new_level_2_2.png")
