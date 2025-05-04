extends Node2D

var pieces = []
var pressed = false
var velocity = 0.0
var friction = 0.95
var parent
var max_offset = 0.0
var current_offset = 0.0  # Total scrolled offset
var last_mouse_x = 0.0    # For tracking drag delta between frames

# This is for tracking the initial scroll position when dragging starts
var original_offset = 0.0
var csp

func _ready():
	await get_tree().process_frame
	parent = get_parent()
	var image = parent.texture.get_image()

	# Initialize pieces as before
	for x in range(parent.grid_size.x):
		for y in range(parent.grid_size.y):
			var piece = parent.piece_scene.instantiate()
			self.scale = parent.actual_size / Vector2(parent.max_dimension, parent.max_dimension)

			piece.name = "cell_%d_%d" % [x, y]
			piece.get_node('collision').position = Vector2.ZERO
			piece.get_node('collision').get_node('shape').shape.extents = parent.cell_size / 2
			piece.get_node('bound').get_node('shape').shape.extents = parent.cell_size / 2
			piece.get_node('area').position = Vector2.ZERO
			piece.get_node('area').get_node('shape').shape.extents = parent.cell_size / 4
			piece.get_node('detector').queue_free()

			var position = Vector2(x * parent.cell_size.x, y * parent.cell_size.y)
			var region = Rect2(position, parent.cell_size * 1.4)
			var piece_image = image.get_region(region)
			var piece_texture = ImageTexture.create_from_image(piece_image)

			var polygon = parent.polygons[y][x]
			polygon.name = "cell_%d_%d" % [y, x]
			polygon.texture = piece_texture
			polygon.position = Vector2(-parent.cell_size.x * 0.5, -parent.cell_size.y * 0.5)
			piece.add_child(polygon)

			pieces.append(piece)

	# Set up max offset based on grid size
	max_offset = -parent.cell_size.x
	pieces.shuffle()
	var index = 0
	for piece in pieces:
		max_offset += parent.cell_size.x * 1.4
		piece.position = Vector2(max_offset + 10, 0)
		piece.index = index
		index += 1
		add_child(piece)

	max_offset += parent.actual_size.x * 1.5
	
	# Start the AI after a random delay (between 1.0 and 3.0 seconds)
	csp = parent.CSP.new()
	var delay = randf_range(1.0, 3.0)
	await get_tree().create_timer(delay).timeout
	trigger_ai()

func _process(delta: float) -> void:
	if pressed:
		handle_drag()
	else:
		apply_momentum(delta)

func handle_drag():
	var mouse_x = get_global_mouse_position().x
	var delta_x = mouse_x - last_mouse_x

	# Initialize last_mouse_x and original_offset only once when drag starts
	if last_mouse_x == 0.0:
		last_mouse_x = mouse_x  # Only set this once
		original_offset = current_offset  # Save the current offset as the start position

	## Calculate the new offset and clamp it within bounds
	#var new_offset = original_offset + delta_x
	#if current_offset < 0:
		#delta_x = -original_offset  # Prevent going past the start
	#elif abs(new_offset) > max_offset:
		#delta_x = -(original_offset + delta_x + max_offset)  # Prevent going past the end

	# Apply delta_x and adjust piece positions
	for piece in pieces:
		if is_instance_valid(piece):
			# Adjust position based on the delta_x, ensuring pieces don't go out of bounds
			piece.position.x = current_offset + (parent.cell_size.x * 1.4 * piece.index) + delta_x + (parent.cell_size.x * 0.7)

	# Update current_offset after applying delta
	current_offset = current_offset + original_offset + delta_x
	velocity = delta_x  # Store the velocity based on drag movement
	last_mouse_x = mouse_x  # Track the last mouse position

func apply_momentum(delta: float) -> void:
	# Apply friction to the velocity to simulate momentum decay
	velocity *= friction

	# Stop momentum when velocity is small enough
	if abs(velocity) < 0.05:  # More sensitive threshold for momentum stop
		velocity = 0

	## Calculate the new offset with momentum
	#var new_offset = current_offset + velocity
	#if original_offset < 0:
		#if new_offset < 0:
			#velocity = -current_offset  # Prevent overshooting the start
		#elif abs(new_offset) > max_offset:
			#velocity = -(current_offset + velocity + max_offset)  # Prevent overshooting the end

	# Move all pieces based on the momentum velocity
	for piece in pieces:
		if is_instance_valid(piece):
			# Apply momentum to the piece's position
			piece.position.x = current_offset + (parent.cell_size.x * 1.4 * piece.index) + velocity + (parent.cell_size.x * 0.7)
			# Update piece's original position to reflect the momentum movement
			piece.original_position.x = current_offset + (parent.cell_size.x * 1.4 * piece.index) + velocity + (parent.cell_size.x * 0.7)

	# Update current_offset after applying momentum
	current_offset += velocity

func _on_scroll_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	for piece in pieces: 
		if is_instance_valid(piece):
			if(piece.selected):
				pressed = false
				return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			pressed = true
			last_mouse_x = get_global_mouse_position().x
			velocity = 0  # Stop momentum when user starts dragging
		else:
			pressed = false

func _on_scroll_mouse_exited() -> void:
	pressed = false
	
	
func _on_leave_area_entered(area: Area2D) -> void:
	var selectedPiece = area.get_parent()
	var index = selectedPiece.index
	for piece in pieces: 
		if !is_instance_valid(piece) || piece.selected || piece.index < selectedPiece.index : continue
		piece.index = index
		index  = index + 1
	selectedPiece.defaultIndex = selectedPiece.index
	selectedPiece.index = -1
	pass # Replace with function body.


func _on_enter_bound_entered(area: Area2D, curPiece) -> void:
	var piece = area.get_parent()
	if(!curPiece.selected): 
		if(piece.index == curPiece.index):
			var index = curPiece.index
			for p in pieces: 
				if !is_instance_valid(p) || p.selected || p.index < curPiece.index : continue
				p.index = index
				index  = index + 1
		return
	
	var index = curPiece.index
	
	curPiece.index = piece.index
	piece.index = index
	
	pass # Replace with function body.


func _on_scroll_area_entered(area: Area2D) -> void:
	pass # Replace with function body.

func trigger_ai():
	var solution = csp.solve(parent.grid_size, parent.polygons, parent.edge_data)
	if solution: spawn_ai_solution(solution)
	else: print("AI failed to solve the puzzle.")
	
	var delay = randf_range(1.0, 3.0)
	await get_tree().create_timer(delay).timeout
	trigger_ai()

func spawn_ai_solution(solution: Dictionary) -> void:
	# If solution is empty, exit the function
	if solution.size() == 0:
		return
	
	# Get the keys and shuffle them to ensure randomness
	var keys = solution.keys()
	keys.shuffle()  # Shuffle the keys for better randomness

	# Loop through shuffled keys to get random positions and their corresponding polygons
	for pos in keys:
		var poly = solution[pos]
		# Loop through the pieces and find the matching one
		for piece in pieces:
			if is_instance_valid(piece):
				var parts = piece.name.split("_")
				if (poly.name == piece.name):
					setPiecePosition(piece, parts[1],parts[2])  # Set position once match is found
					return  # Exit once we have matched a piece

	for pos in keys:
		var poly = solution[pos]
		# Loop through the pieces and find the matching one
		for piece in pieces:
			if is_instance_valid(piece):
				var parts = piece.name.split("_")
				if (str(parts[1]) == str(pos.x) && str(parts[2]) == str(pos.y)):
					setPiecePosition(piece, parts[1],parts[2])  # Set position once match is found
					return  # Exit once we have matched a piece

func setPiecePosition(piece, x, y):
	piece.selected = "AI"
	piece.global_position = parent.board.global_position + (Vector2(int(x) * parent.cell_size.x, int(y) * parent.cell_size.y) + (Vector2(parent.cell_size.x, parent.cell_size.y)/2) - parent.board.get_node('backgrund').size/2) * parent.board.scale 
