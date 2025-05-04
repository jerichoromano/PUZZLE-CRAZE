extends Node2D

@onready var CSP := preload("res://scenes/CSP.gd")

@export var playerLabel: Label
@export var aiLabel: Label
@export var piece_scene: PackedScene
@export var board: Node2D
var texture_folder_path: String = "res://images"
var grid_size: Vector2 = Vector2(10, 10)
var texture: Texture2D
var distortion_size = 20  # Strength of jigsaw distortion
var edge_data = {}
var actual_size = Vector2(470, 470)
var polygons = []
var cell_size = Vector2(100, 100)
var max_dimension

func _ready():
	randomize()  # Initialize random seed

	var grid_x = randi_range(2, 7)
	var grid_y = randi_range(2, 7)
	grid_size = Vector2(grid_x, grid_y)
	
	texture = load_random_texture_from_folder(texture_folder_path)
	
	if texture == null:
		push_error("No valid textures found in folder!")
		return
	
	max_dimension = min(texture.get_size().x, texture.get_size().y)
	cell_size = Vector2(max_dimension / grid_size.x, max_dimension / grid_size.y)
	
	$reference.texture = texture
	polygons = generate_polygon_grid(grid_size, cell_size)
	
	
	var image = texture.get_image()
	var region = Rect2(Vector2(0, 0), Vector2(max_dimension, max_dimension))
	var piece_image = image.get_region(region)
	var piece_texture = ImageTexture.create_from_image(piece_image)
	$reference.name = "reference"
	$reference.texture = piece_texture
	$reference.stretch_mode = TextureRect.STRETCH_SCALE
	$reference.size = Vector2(150, 150)  # Or use rect_size in Godot 3.x
	
	

func generate_polygon_grid(grid_size: Vector2, cell_size: Vector2):
	var polygons= []
	for row in range(grid_size.y):
		var row_array = []
		for col in range(grid_size.x):
			var x = col * cell_size.x
			var y = row * cell_size.y
			var key = Vector2(col, row)

			# Reuse or generate interlocking distortions
			var left = edge_data.get("cell_%d_%d_right" % [col - 1, row], 0) if col > 0 else 0
			var top = edge_data.get("cell_%d_%d_bottom" % [col, row - 1], 0) if row > 0 else 0
			var right = randf_range(5 * sign(randf() - 0.5), distortion_size) if col < grid_size.x - 1 else 0
			var bottom = randf_range(5 * sign(randf() - 0.5), distortion_size) if row < grid_size.y - 1 else 0

			# Store edge distortions for interlocking
			edge_data["cell_%d_%d_right" % [col, row]] = right
			edge_data["cell_%d_%d_bottom" % [col, row]] = bottom
			edge_data["cell_%d_%d_left" % [col + 1, row]] = -right
			edge_data["cell_%d_%d_top" % [col, row + 1]] = -bottom

			var polygon = create_jigsaw_polygon(Vector2(x, y), cell_size, left, top, right, bottom)
			polygon.name = "cell_%d_%d_right" % [col, row]
			row_array.append(polygon)
		polygons.append(row_array)
	
	return polygons

func create_jigsaw_polygon(position: Vector2, size: Vector2, left: float, top: float, right: float, bottom: float) -> Polygon2D:
	var poly = Polygon2D.new()

	# Define polygon points ensuring no gaps
	var points = PackedVector2Array([
		Vector2(0, 0),  
		Vector2(size.x * 0.25, 0),  
		Vector2(size.x * 0.5, top),  # Top-middle (must match bottom of above cell)
		Vector2(size.x * 0.75, 0),  
		Vector2(size.x, 0),  

		Vector2(size.x, size.y * 0.25),  
		Vector2(size.x + right, size.y * 0.5),  # Right-middle (must match left of next cell)
		Vector2(size.x, size.y * 0.75),  
		Vector2(size.x, size.y),  

		Vector2(size.x * 0.75, size.y),  
		Vector2(size.x * 0.5, size.y + bottom),  # Bottom-middle (must match top of next row)
		Vector2(size.x * 0.25, size.y),  
		Vector2(0, size.y),  

		Vector2(0, size.y * 0.75),  
		Vector2(left, size.y * 0.5),  # Left-middle (must match right of previous cell)
		Vector2(0, size.y * 0.25)
	])

	poly.polygon = points
	poly.position = position
	return poly
	
func load_random_texture_from_folder(folder_path: String) -> Texture2D:
	# Manually list textures instead of reading the folder
	var texture_paths = [
		"res://images/1.webp",
		"res://images/2.jpg",
		"res://images/3.jpg",
		"res://images/4.jpg",
		"res://images/5.jpg",
		# Add all expected image paths here
	]

	var textures := []
	for path in texture_paths:
		var tex = load(path)
		if tex is Texture2D:
			textures.append(tex)

	if textures.size() == 0:
		push_error("No valid textures found in hardcoded list!")
		return null

	return textures[randi() % textures.size()]


func _on_restart_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Main.tscn")
	pass # Replace with function body.


func _on_quit_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Home.tscn")
	pass # Replace with function body.
