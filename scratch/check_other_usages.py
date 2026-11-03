for path in ['scripts/act1_bahay_kubo.gd', 'scripts/level_builder.gd']:
    print('===', path, '===')
    with open(path, 'r', encoding='utf-8', errors='ignore') as f:
        for line in f:
            if any(k in line for k in ['prop_wooden_fence', 'prop_firewood', 'prop_mossy_rocks', 'prop_banana_tree', 'scale']):
                print(line.rstrip())
