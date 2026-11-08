import struct
import zlib
from PIL import Image
import numpy as np

def extract_ase_layers(path):
    print("Extracting layers from:", path)
    with open(path, 'rb') as f:
        data = f.read()
    filesize, magic, frames, width, height, color_depth = struct.unpack('<IHHHHH', data[:14])
    print(f"Frames: {frames}, Size: {width}x{height}, Depth: {color_depth}")
    
    pos = 128
    layers = []
    
    # Read frame 0
    frame_bytes, fmagic, chunks = struct.unpack('<IHH', data[pos:pos+8])
    pos += 16
    chunk_pos = pos
    
    frame_cels = []
    for c in range(chunks):
        chunk_size, chunk_type = struct.unpack('<IH', data[chunk_pos:chunk_pos+6])
        chunk_data = data[chunk_pos+6:chunk_pos+chunk_size]
        if chunk_type == 0x2004: # LAYER
            flags, layer_type, child_level, def_w, def_h, blend_mode = struct.unpack('<HHHxxHHB', chunk_data[:13])
            str_len = struct.unpack('<H', chunk_data[16:18])[0]
            name = chunk_data[18:18+str_len].decode('utf-8', errors='ignore')
            layers.append(name)
            print(f"Layer {len(layers)-1}: {name}")
        elif chunk_type == 0x2005: # CEL
            layer_index, x, y, opacity, cel_type = struct.unpack('<HhhBH', chunk_data[:9])
            # cel_type: 0 = raw, 1 = linked, 2 = compressed image
            if cel_type == 2:
                cw, ch = struct.unpack('<HH', chunk_data[16:20])
                compressed = chunk_data[20:]
                raw_pixels = zlib.decompress(compressed)
                img = Image.frombytes('RGBA', (cw, ch), raw_pixels)
                frame_cels.append((layer_index, x, y, img))
                print(f"  Cel for layer {layer_index} ({layers[layer_index]}): pos=({x},{y}), size={cw}x{ch}")
        chunk_pos += chunk_size
        
    return layers, frame_cels

layers, cels = extract_ase_layers('Haliya with clothes/Haliya/Idle/w- Mask/v3/kampilan/haliya_idle_B01.ase')
# Let's save each cel as a 256x256 image
for l_idx, x, y, img in cels:
    full = Image.new('RGBA', (256, 256), (0, 0, 0, 0))
    full.paste(img, (x, y))
    clean_name = layers[l_idx].replace(' ', '_')
    full.save(f'scratch/layer_{l_idx}_{clean_name}.png')
    print(f"Saved scratch/layer_{l_idx}_{clean_name}.png")
