from PIL import Image

snap1 = Image.open('snapshot_rice_field_2_1.png')
# crop top half (sky and mountains)
top1 = snap1.crop((0, 0, 2560, 1000))
top1.resize((640, 250)).save("scratch/bg_preview_2_1.png")

snap2 = Image.open('snapshot_rice_field_2_2.png')
top2 = snap2.crop((0, 0, 2560, 1000))
top2.resize((640, 250)).save("scratch/bg_preview_2_2.png")

snap3 = Image.open('snapshot_rice_field_2_3.png')
top3 = snap3.crop((0, 0, 2560, 1000))
top3.resize((640, 250)).save("scratch/bg_preview_2_3.png")

print("Saved scratch/bg_preview_2_1..3.png")
