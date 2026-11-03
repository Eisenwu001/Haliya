import re

def audit_scene(scene_path):
    print(f"\n==========================================")
    print(f"AUDITING COLLISION NODES IN: {scene_path}")
    print(f"==========================================")
    
    with open(scene_path, 'r', encoding='utf-8') as f:
        text = f.read()

    # Find all nodes
    node_pattern = re.compile(r'\[node name="([^"]+)" type="([^"]+)"(?:\s+parent="([^"]*)")?\](.*?)(?=\[node|\Z)', re.DOTALL)
    
    nodes = {}
    for m in node_pattern.finditer(text):
        name = m.group(1)
        ntype = m.group(2)
        parent = m.group(3) or ""
        body = m.group(4)
        nodes[name] = {"type": ntype, "parent": parent, "body": body}

    print(f"Total nodes: {len(nodes)}")
    
    collision_nodes = []
    for name, data in nodes.items():
        if "Collision" in data["type"] or "Body" in data["type"]:
            pos_m = re.search(r'position = Vector2\(([^)]+)\)', data["body"])
            pos = pos_m.group(1) if pos_m else "default"
            shape_m = re.search(r'shape = SubResource\("([^"]+)"\)', data["body"])
            shape = shape_m.group(1) if shape_m else ""
            collision_nodes.append((name, data["type"], data["parent"], pos, shape))
            
    print(f"Collision-related nodes ({len(collision_nodes)}):")
    for name, ntype, parent, pos, shape in collision_nodes:
        # Check if parent or node has a visual sprite or script
        pdata = nodes.get(parent, {})
        has_sprite = False
        has_script = "script = " in data["body"] or "script = " in pdata.get("body", "")
        # Check if sibling has Sprite2D
        for sname, sdata in nodes.items():
            if sdata["parent"] == parent and "Sprite" in sdata["type"]:
                has_sprite = True
                break
        print(f"  {ntype} '{name}' (parent: '{parent}') at {pos} | shape={shape} | has_sprite={has_sprite} | has_script={has_script}")

for sc in ["scenes/cave/level_4_1.tscn", "scenes/cave/level_4_2.tscn", "scenes/cave/level_4_3.tscn", "scenes/cave/level_5.tscn"]:
    audit_scene(sc)
