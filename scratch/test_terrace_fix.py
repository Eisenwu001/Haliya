from typing import Dict, Tuple

def get_surface_row(cells: Dict[Tuple[int, int], Tuple[int, int, int, int]], col: int) -> int:
    col_rows = [r for (c, r) in cells if c == col]
    return min(col_rows) if col_rows else 9

def test_paint_paddies():
    cells = {}
    base_row = 9
    bottom_row = 23
    
    # 1. Base ground
    for c in range(160):
        cells[(c, base_row)] = (0, 1, 0, 0)
        for r in range(base_row + 1, bottom_row + 1):
            cells[(c, r)] = (0, 1, 1, 0)
            
    # 2. Terrace
    # Terrace 1: col 22..38 at top_row 8
    col_start, col_end, top_row = 22, 38, 8
    left_neighbor_top = get_surface_row(cells, col_start - 1)
    right_neighbor_top = get_surface_row(cells, col_end + 1)
    print(f"Terrace {col_start}..{col_end} at row {top_row}: left_neighbor={left_neighbor_top}, right_neighbor={right_neighbor_top}")
    
    for c in range(col_start, col_end + 1):
        if c == col_start:
            cells[(c, top_row)] = (0, 0, 0, 0)
        elif c == col_end:
            cells[(c, top_row)] = (0, 2, 0, 0)
        else:
            cells[(c, top_row)] = (0, 1, 0, 0)
            
        for r in range(top_row + 1, bottom_row + 1):
            if c == col_start:
                if r < left_neighbor_top:
                    cells[(c, r)] = (0, 0, 1, 0) # Exposed left cliff
                else:
                    cells[(c, r)] = (0, 1, 1, 0) # Solid underground dirt
            elif c == col_end:
                if r < right_neighbor_top:
                    cells[(c, r)] = (0, 2, 1, 0) # Exposed right cliff
                else:
                    cells[(c, r)] = (0, 1, 1, 0) # Solid underground dirt
            else:
                cells[(c, r)] = (0, 1, 1, 0)
                
    # Check cells at col 21, 22, 23
    print("Col 21 rows 8..11:", [cells.get((21, r)) for r in range(8, 12)])
    print("Col 22 rows 8..11:", [cells.get((22, r)) for r in range(8, 12)])

test_paint_paddies()
