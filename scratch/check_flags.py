import struct

def check_layer_flags(path):
    print("=== Checking Layer Flags in:", path, "===")
    with open(path, 'rb') as f:
        data = f.read()
    filesize, magic, frames, width, height, color_depth = struct.unpack('<IHHHHH', data[:14])
    pos = 128
    frame_bytes, fmagic, chunks = struct.unpack('<IHH', data[pos:pos+8])
    pos += 16
    chunk_pos = pos
    for c in range(chunks):
        chunk_size, chunk_type = struct.unpack('<IH', data[chunk_pos:chunk_pos+6])
        chunk_data = data[chunk_pos+6:chunk_pos+chunk_size]
        if chunk_type == 0x2004: # LAYER
            flags, layer_type, child_level, def_w, def_h, blend_mode = struct.unpack('<HHHxxHHB', chunk_data[:13])
            str_len = struct.unpack('<H', chunk_data[16:18])[0]
            name = chunk_data[18:18+str_len].decode('utf-8', errors='ignore')
            # flags: 1 = Visible, 2 = Editable, 4 = Lock movement, etc.
            is_visible = bool(flags & 1)
            is_editable = bool(flags & 2)
            print(f"Layer '{name}': flags={bin(flags)}, visible={is_visible}, editable={is_editable}")
        chunk_pos += chunk_size

check_layer_flags('Haliya with clothes/Haliya/Idle/w- Mask/v3/kampilan/haliya_idle_B01.ase')
check_layer_flags('Haliya with clothes/Haliya/Walk/haliya_walk_A01.ase')
