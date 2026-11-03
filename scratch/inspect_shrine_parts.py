import os
from PIL import Image

shrine = Image.open(r"c:\Users\Lin\OneDrive\Pictures\Camera Roll\Documents\project-1-test\assets\art\incoming\totem_shrine.png")
artifact_dir = r"C:\Users\Lin\.gemini\antigravity\brain\370c75b3-591d-4ff9-a2ef-a82753b68d30"

# crop top part
top_crop = shrine.crop((0, 0, shrine.width, 420))
top_crop.save(os.path.join(artifact_dir, "shrine_top_inspection.png"))

# crop bottom part (the stone altar mound + offerings + roots)
bot_crop = shrine.crop((0, 390, shrine.width, shrine.height))
bot_crop.save(os.path.join(artifact_dir, "shrine_bottom_inspection.png"))

print("Saved inspection crops for totem_shrine.png")
