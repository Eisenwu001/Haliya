import os
from PIL import Image

p = r"c:\Users\Lin\OneDrive\Pictures\Camera Roll\Documents\project-1-test\assets\ui\menu_left_gradient.png"
if os.path.exists(p):
    img = Image.open(p)
    print("menu_left_gradient size:", img.size)
    print("menu_left_gradient mode:", img.mode)
    print("pixel (0, 0):", img.getpixel((0, 0)))
    print("pixel (img.width-1, 0):", img.getpixel((img.width-1, 0)))
