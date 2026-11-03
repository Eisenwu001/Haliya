from PIL import Image
import numpy as np

path = r'C:\Users\Lin\.gemini\antigravity\brain\affaaa51-5c2e-4029-96b6-27d506de5489\bahay_kubo_1792799770439.jpg'
im = Image.open(path)
arr = np.array(im)

# What are the colors around the edges?
print("Top row colors (x=0, 200, 600, 1000):", [arr[0, x].tolist() for x in [0, 200, 600, 1000]])
print("Bottom row colors (x=0, 200, 600, 1000):", [arr[-1, x].tolist() for x in [0, 200, 600, 1000]])
print("Left col colors (y=0, 200, 450, 700):", [arr[y, 0].tolist() for y in [0, 200, 450, 700]])
print("Right col colors (y=0, 200, 450, 700):", [arr[y, -1].tolist() for y in [0, 200, 450, 700]])
