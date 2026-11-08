import struct

def parse_ase(path):
    print('=== Aseprite:', path, '===')
    with open(path, 'rb') as f:
        data = f.read()
    filesize, magic, frames, width, height, color_depth = struct.unpack('<IHHHHH', data[:14])
    print(f'filesize={filesize}, magic={hex(magic)}, frames={frames}, size={width}x{height}, depth={color_depth}')
    
    pos = 128
    for fr in range(min(frames, 3)):
        frame_bytes, fmagic, chunks = struct.unpack('<IHH', data[pos:pos+8])
        pos += 16
        print(f' Frame {fr}: bytes={frame_bytes}, chunks={chunks}')
        chunk_pos = pos
        for c in range(chunks):
            chunk_size, chunk_type = struct.unpack('<IH', data[chunk_pos:chunk_pos+6])
            chunk_data = data[chunk_pos+6:chunk_pos+chunk_size]
            if chunk_type == 0x2004: # LAYER
                str_len = struct.unpack('<H', chunk_data[18:20])[0]
                name = chunk_data[20:20+str_len].decode('utf-8', errors='ignore')
                print(f'   Layer: name="{name}"')
            elif chunk_type == 0x2005: # CEL
                layer_index, x, y, opacity, cel_type = struct.unpack('<HhhBH', chunk_data[:9])
                print(f'   Cel: layer_idx={layer_index}, pos=({x},{y}), opacity={opacity}')
            chunk_pos += chunk_size
        pos = chunk_pos

parse_ase('Haliya with clothes/Haliya/Idle/w- Mask/v3/kampilan/haliya_idle_B01.ase')
parse_ase('Haliya with clothes/Haliya/Walk/haliya_walk_A01.ase')
