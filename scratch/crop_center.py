from PIL import Image

snap = Image.open('snapshot_rice_field_2_1.png')
# Center of 2560x1600 is (1280, 800)
# Let's crop a 800x600 region around center
crop = snap.crop((1280 - 400, 800 - 300, 1280 + 400, 800 + 300))
crop.save("scratch/center_crop_2_1.png")
print("Saved scratch/center_crop_2_1.png")
