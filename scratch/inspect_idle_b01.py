import struct, zlib
from PIL import Image

with open('Haliya with clothes/Haliya/Idle/w- Mask/v3/kampilan/haliya_idle_B01.ase', 'rb') as f:
    data = f.read()

offset = 128
frames_count = struct.unpack('<H', data[6:8])[0]
layers = []

for frame_idx in range(frames_count):
    frame_size, frame_magic, old_chunks, duration, _, new_chunks = struct.unpack('<IH2H2sI', data[offset:offset+16])
    chunks_count = new_chunks if new_chunks != 0 else old_chunks
    chunk_offset = offset + 16
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
                print(f'Frame {frame_idx}, Layer {layer_idx} ({layers[layer_idx]}): pos=({cel_x}, {cel_y}), size={w}x{h}')
        chunk_offset += chunk_size
    offset += frame_size
