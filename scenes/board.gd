extends Node2D

func _ready():
	await get_tree().process_frame  # Wait one frame for parent to finish _ready()
	var parent = get_parent()
	
	self.position = Vector2(get_viewport().size)/2
	self.scale = parent.actual_size / Vector2(parent.max_dimension, parent.max_dimension)
	
	
	var image = parent.texture.get_image()
	$backgrund.size = parent.cell_size * parent.grid_size
	$backgrund.position = -$backgrund.size/2
	
	for x in range(parent.grid_size.x):
		for y in range(parent.grid_size.y):
			var piece = parent.piece_scene.instantiate()
			piece.name = "cell_%d_%d" % [x, y]
			piece.get_node('detector').position = Vector2(0, 0)
			piece.get_node('detector').get_node('shape').shape.extents = parent.cell_size / 4
			piece.get_node('collision').queue_free()
			piece.get_node('area').queue_free()
			
			piece.position = Vector2(x * parent.cell_size.x, y * parent.cell_size.y) + (Vector2(parent.cell_size.x, parent.cell_size.y)/2) - $backgrund.size/2
			var region = Rect2(Vector2(x * parent.cell_size.x, y * parent.cell_size.y), parent.cell_size * 1.4)

			var piece_image = image.get_region(region)
			var piece_texture = ImageTexture.create_from_image(piece_image)
			
			var polygon = parent.polygons[y][x].duplicate()
			polygon.name = "image"
			polygon.visible = false
			polygon.texture = piece_texture
			polygon.position = Vector2(-parent.cell_size.x * 0.5, -parent.cell_size.y * 0.5)
			piece.add_child(polygon)

			# Draw polygon outline using Line2D
			var outline = Line2D.new()
			outline.name = "outline"
			outline.width = 2  # Set the line width for the outline
			outline.default_color = Color(0, 0, 0, 0.1)  # Set color for the outline (red)
			
			# Assuming 'polygon' has a 'points' array containing the polygon's vertices
			for i in range(polygon.polygon.size()):
				var point1 = polygon.polygon[i]
				var point2 = polygon.polygon[(i + 1) % polygon.polygon.size()]  # Connect to the first point to close the outline
				outline.add_point(point1 + polygon.position)
				outline.add_point(point2 + polygon.position)
			
			piece.add_child(outline)  # Add outline to the piece
			
			add_child(piece)
