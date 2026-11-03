import os
from PIL import Image

upload_dir = r"C:\Users\Lin\.gemini\antigravity\brain\370c75b3-591d-4ff9-a2ef-a82753b68d30\.user_uploaded"
files = os.listdir(upload_dir)
print("Uploaded files in user_uploaded:", files)

for f in files:
    fp = os.path.join(upload_dir, f)
    img = Image.open(fp)
    print(f"{f}: size={img.size}, mode={img.mode}")
