import os
from PIL import Image

artifact_dir = r"C:\Users\Lin\.gemini\antigravity\brain\370c75b3-591d-4ff9-a2ef-a82753b68d30"

def get_stats(img_path):
    if not os.path.exists(img_path):
        return "Not found"
    img = Image.open(img_path).resize((640, 360), Image.Resampling.NEAREST)
    # calculate average RGB
    r_total, g_total, b_total = 0, 0, 0
    count = img.width * img.height
    for y in range(img.height):
        for x in range(img.width):
            p = img.getpixel((x, y))
            r_total += p[0]
            g_total += p[1]
            b_total += p[2]
    return f"Avg RGB: ({r_total/count:.1f}, {g_total/count:.1f}, {b_total/count:.1f})"

print("diagnostic_time_1.0s:", get_stats(os.path.join(artifact_dir, "diagnostic_time_1.0s.png")))
print("diagnostic_time_8.0s:", get_stats(os.path.join(artifact_dir, "diagnostic_time_8.0s.png")))
print("before_continue_selected:", get_stats(os.path.join(artifact_dir, "before_continue_selected.png")))
print("after_continue_selected (Pass 2):", get_stats(os.path.join(artifact_dir, "after_continue_selected.png")))
print("pass3_full_menu:", get_stats(os.path.join(artifact_dir, "pass3_full_menu.png")))
print("pass4_full_menu:", get_stats(os.path.join(artifact_dir, "pass4_full_menu.png")))
