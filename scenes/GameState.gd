# GameState.gd
extends Node

var texture_folder_path: String = "res://images"

var playerTxt = 0
var aiTxt = 0

var mode = ''

var grid_x
var grid_y
var texture

var csp = CSP.new()

func easyLevel():
	mode = 'EASY'
	grid_x = 3
	grid_y = 3
	loadRamdomImage()
	

func mediumLevel():
	mode = 'MEDIUM'
	grid_x = 5
	grid_y = 5
	loadRamdomImage()

func hardLevel():
	mode = 'HARD'
	grid_x = 7
	grid_y = 7
	loadRamdomImage()
		
		
func randomLevel():
	mode = 'RANDOM'
	randomize()  # Initialize random seed
	grid_x = randi_range(2, 7)
	grid_y = randi_range(2, 7)
	loadRamdomImage()
	
func vsAILevel():
	mode = 'VS_AI'
	randomize()  # Initialize random seed
	grid_x = randi_range(2, 7)
	grid_y = randi_range(2, 7)
	loadRamdomImage()
		
func loadRamdomImage():
	texture = load_random_texture_from_folder(texture_folder_path)
	
	if texture == null:
		push_error("No valid textures found in folder!")
		return
	
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
