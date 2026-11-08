import struct, zlib
from PIL import Image

with open('Haliya with clothes/Haliya/Walk/haliya_walk_A01.ase', 'rb') as f:
    data = f.read()

offset = 128
# Frame 0
frame_size, frame_magic, old_chunks, duration, _, new_chunks = struct.unpack('<IH2H2sI', data[offset:offset+16])
chunks_count = new_chunks if new_chunks != 0 else old_chunks

chunk_offset = offset + 16
layers = []
cels = {}

for c in range(chunks_count):
    chunk_size, chunk_type = struct.unpack('<IH', data[chunk_offset:chunk_offset+6])
    chunk_data = data[chunk_offset+6:chunk_offset+chunk_size]
    
    if chunk_type == 0x2004:
        name_len = struct.unpack('<H', chunk_data[16:18])[0]
        name = chunk_data[18:18+name_len].decode('utf-8', errors='ignore')
        layers.append(name)
    elif chunk_type == 0x2005:
        layer_idx, cel_x, cel_y, cel_opacity, cel_type = struct.unpack('<HhhBH', chunk_data[:9])
        if cel_type == 2:
            w, h = struct.unpack('<HH', chunk_data[16:20])
            raw_pixels = zlib.decompress(chunk_data[20:])
            img = Image.frombytes('RGBA', (w, h), raw_pixels)
            cels[layer_idx] = (cel_x, cel_y, img)
            print(f'Decompressed cel for layer {layer_idx} ({layers[layer_idx]}): size={w}x{h}, pos=({cel_x}, {cel_y})')
    chunk_offset += chunk_size

for idx, (x, y, img) in cels.items():
    clean_name = layers[idx].replace(' ', '_')
    img.save(f'scratch/layer_{idx}_{clean_name}.png')
print('Successfully saved isolated layer images!')
