extends Node

class_name CSP

func solve(grid_size: Vector2, polygons: Array, edge_data: Dictionary) -> Dictionary:
	var assignment = {}
	var positions = []

	for y in range(int(grid_size.y)):
		for x in range(int(grid_size.x)):
			if !is_instance_valid(polygons[y][x]): continue
			positions.append(Vector2(x, y))

	return backtrack(assignment, positions, polygons, edge_data)

func backtrack(assignment: Dictionary, positions: Array, polygons: Array, edge_data: Dictionary) -> Dictionary:
	if positions.is_empty():
		return assignment

	var pos = positions.pop_front()

	for row in polygons:
		for piece in row:
			if not piece in assignment.values():
				if !is_instance_valid(piece): continue
				if is_consistent(pos, piece, assignment, edge_data):
					assignment[pos] = piece
					var result = backtrack(assignment.duplicate(), positions.duplicate(), polygons, edge_data)
					if  result.has("error") == false:
						return result
					assignment.erase(pos)

	return {"error": true}

func is_consistent(pos: Vector2, piece: Polygon2D, assignment: Dictionary, edge_data: Dictionary) -> bool:
	# Check left neighbor
	var left_pos = pos + Vector2(-1, 0)
	if assignment.has(left_pos):
		var left_piece = assignment[left_pos]
		var expected_left = edge_data.get("cell_%d_%d_right" % [left_pos.x, left_pos.y], null)
		var actual_left = edge_data.get("cell_%d_%d_left" % [pos.x, pos.y], null)
		if expected_left != -actual_left:
			return false

	# Check top neighbor
	var top_pos = pos + Vector2(0, -1)
	if assignment.has(top_pos):
		var top_piece = assignment[top_pos]
		var expected_top = edge_data.get("cell_%d_%d_bottom" % [top_pos.x, top_pos.y], null)
		var actual_top = edge_data.get("cell_%d_%d_top" % [pos.x, pos.y], null)
		if expected_top != -actual_top:
			return false

	return true
