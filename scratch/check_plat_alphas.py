import numpy as np
from PIL import Image

im = Image.open("scratch/extracted_ai_props/ai_plat_ledge1.png")
arr = np.array(im)
alpha = arr[:,:,3]
print("ai_plat_ledge1 size:", im.size)
print("Row alphas (first 10 rows):", [alpha[r].max() for r in range(min(10, alpha.shape[0]))])

im_br = Image.open("scratch/extracted_ai_props/ai_bamboo_bridge.png")
arr_br = np.array(im_br)
alpha_br = arr_br[:,:,3]
print("ai_bamboo_bridge size:", im_br.size)
print("Bridge row alphas (first 10 rows):", [alpha_br[r].max() for r in range(min(10, alpha_br.shape[0]))])
