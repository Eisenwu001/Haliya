from PIL import Image

shrine_raw = Image.open("assets/art/incoming/totem_shrine.png")
# Let's crop from y=405 to y=660, x=80 to x=915
shrine_base = shrine_raw.crop((80, 405, 915, 660))
print("Shrine base crop size:", shrine_base.size)
shrine_base.save(r"C:\Users\Lin\.gemini\antigravity\brain\370c75b3-591d-4ff9-a2ef-a82753b68d30\test_shrine_base_crop.png")
