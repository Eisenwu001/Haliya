from PIL import Image

shrine = Image.open("assets/art/totem_shrine.png")
# crop center lamp region: x=60..86, y=10..32
center_lamp = shrine.crop((60, 10, 86, 32))
center_lamp_4x = center_lamp.resize((center_lamp.width * 4, center_lamp.height * 4), Image.Resampling.NEAREST)
center_lamp_4x.save(r"C:\Users\Lin\.gemini\antigravity\brain\370c75b3-591d-4ff9-a2ef-a82753b68d30\shrine_center_lamp.png")

# crop left lamp region: x=46..62, y=14..32
left_lamp = shrine.crop((46, 14, 62, 32))
left_lamp_4x = left_lamp.resize((left_lamp.width * 4, left_lamp.height * 4), Image.Resampling.NEAREST)
left_lamp_4x.save(r"C:\Users\Lin\.gemini\antigravity\brain\370c75b3-591d-4ff9-a2ef-a82753b68d30\shrine_left_lamp.png")

# crop right lamp region: x=84..100, y=14..32
right_lamp = shrine.crop((84, 14, 100, 32))
right_lamp_4x = right_lamp.resize((right_lamp.width * 4, right_lamp.height * 4), Image.Resampling.NEAREST)
right_lamp_4x.save(r"C:\Users\Lin\.gemini\antigravity\brain\370c75b3-591d-4ff9-a2ef-a82753b68d30\shrine_right_lamp.png")

print("Saved lamp crop inspections")
