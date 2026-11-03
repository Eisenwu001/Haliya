from PIL import Image

shrine = Image.open("assets/art/incoming/totem_shrine.png")
# Let's inspect the visual appearance around the stone base top: y=380..450
crop_trans = shrine.crop((200, 370, 800, 480))
crop_trans.save(r"C:\Users\Lin\.gemini\antigravity\brain\370c75b3-591d-4ff9-a2ef-a82753b68d30\shrine_transition_area.png")
print("Saved shrine_transition_area.png")
