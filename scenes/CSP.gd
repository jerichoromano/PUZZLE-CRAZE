extends Node
class_name PuzzleCSP

var variables: Array = []
var domains: Dictionary = {}
var constraints: Dictionary = {}

func add_variable(piece: Object, possible_positions: Array) -> void:
	variables.append(piece)
	domains[piece] = possible_positions
	constraints[piece] = []

func add_constraint(piece: Object, constraint_fn: Callable) -> void:
	if not constraints.has(piece):
		constraints[piece] = []
	constraints[piece].append(constraint_fn)

func is_valid_assignment(assignments: Dictionary) -> bool:
	for piece in assignments:
		if constraints.has(piece):
			for constraint_fn in constraints[piece]:
				if not constraint_fn.call(assignments):
					return false
	return true

func solve(assignments := {}) -> Dictionary:
	if assignments.size() == variables.size():
		return assignments  # All assigned

	var unassigned := variables.filter(func(v): return not assignments.has(v))
	if unassigned.is_empty():
		return assignments

	var piece = unassigned[0]

	for value in domains[piece]:
		assignments[piece] = value
		if is_valid_assignment(assignments):
			var result = solve(assignments.duplicate())
			if result:
				return result
		assignments.erase(piece)

	return {}

func get_solution(assignments := {}) -> Array:
	var unassigned := variables.filter(func(v): return not assignments.has(v))
	if unassigned.is_empty():
		return []

	var piece = unassigned[0]

	var possible_solution = []
	for value in domains[piece]:
		assignments[piece] = value
		if is_valid_assignment(assignments):
			possible_solution.append(value)
		assignments.erase(piece)

	return possible_solution
