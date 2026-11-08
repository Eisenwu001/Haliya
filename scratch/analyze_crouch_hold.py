from PIL import Image
import numpy as np

ic = Image.open('assets/haliya/common_01_idle_crouch.png').convert('RGBA')
arr = np.array(ic)

# Find bounding boxes of each color group:
red_colors = [(77, 45, 43), (122, 74, 70), (39, 3, 1), (83, 7, 2)]
skin_colors = [(242, 173, 150), (249, 204, 181), (189, 126, 105)]
gold_colors = [(248, 232, 112), (218, 167, 48), (233, 200, 81), (173, 130, 39)]

def get_mask(c_list):
    m = np.zeros(arr.shape[:2], dtype=bool)
    for c in c_list:
        m |= (arr[:,:,0] == c[0]) & (arr[:,:,1] == c[1]) & (arr[:,:,2] == c[2]) & (arr[:,:,3] == 255)
    return m

m_red = get_mask(red_colors)
m_skin = get_mask(skin_colors)
m_gold = get_mask(gold_colors)

y_r, x_r = np.where(m_red)
y_s, x_s = np.where(m_skin)
y_g, x_g = np.where(m_gold)

print(f'Red clothing in idle_crouch: {np.sum(m_red)} px, x=[{x_r.min()},{x_r.max()}], y=[{y_r.min()},{y_r.max()}]')
print(f'Skin in idle_crouch: {np.sum(m_skin)} px, x=[{x_s.min()},{x_s.max()}], y=[{y_s.min()},{y_s.max()}]')
print(f'Gold in idle_crouch: {np.sum(m_gold)} px, x=[{x_g.min()},{x_g.max()}], y=[{y_g.min()},{y_g.max()}]')
