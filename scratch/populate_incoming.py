import os
import shutil

upload_dir = r"C:\Users\Lin\.gemini\antigravity\brain\370c75b3-591d-4ff9-a2ef-a82753b68d30\.user_uploaded"
incoming_dir = r"c:\Users\Lin\OneDrive\Pictures\Camera Roll\Documents\project-1-test\assets\art\incoming"
os.makedirs(incoming_dir, exist_ok=True)

mapping = {
    "media_1793713871032_366b68a5.png": "bottom_foliage.png",
    "media_1793713871040_31dbbcb7.png": "hanging_leaves.png",
    "media_1793713871043_f0741859.png": "corner_fronds_left.png",
    "media_1793713871052_e28b2c16.png": "totem_shrine.png",
}

for src_name, dst_name in mapping.items():
    src_path = os.path.join(upload_dir, src_name)
    dst_path = os.path.join(incoming_dir, dst_name)
    shutil.copy2(src_path, dst_path)
    print(f"Copied {src_name} -> {dst_path}")

print("Incoming files ready:", os.listdir(incoming_dir))
