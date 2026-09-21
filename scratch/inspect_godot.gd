extends SceneTree

func _init():
    var scn = load('res://scenes/scene_03.tscn')
    var inst = scn.instantiate()
    print('Instantiated class:', inst.get_class())
    if inst is TileMapLayer:
        var cells = inst.get_used_cells()
        print('Total cells in scene_03:', cells.size())
        for c in cells:
            var src = inst.get_cell_source_id(c)
            var atlas = inst.get_cell_atlas_coords(c)
            if src == 2:
                print('Water cell at: ', c, ' atlas: ', atlas)
    quit(0)
