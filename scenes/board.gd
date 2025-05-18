extends Node2D

var pieces = []
var parent

func _ready():
	await get_tree().process_frame  # Wait one frame for parent to finish _ready()
	parent = get_parent()
	
	self.position = Vector2(get_viewport().get_visible_rect().size) / 2
	self.scale = parent.actual_size / Vector2(parent.max_dimension, parent.max_dimension)
	
	var image = parent.texture.get_image()
	$backgrund.size = parent.cell_size * parent.grid_size
	$backgrund.position = -$backgrund.size / 2
	
	for x in range(parent.grid_size.x):
		for y in range(parent.grid_size.y):
			var piece = parent.piece_scene.instantiate()
			piece.name = "cell_%d_%d" % [x, y]
			piece.get_node('detector').position = Vector2(0, 0)
			piece.get_node('detector').get_node('shape').shape.extents = parent.cell_size / 4
			piece.get_node('collision').queue_free()
			piece.get_node('area').queue_free()
			
			piece.position = Vector2(x * parent.cell_size.x, y * parent.cell_size.y) + (parent.cell_size / 2) - $backgrund.size / 2
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
			outline.width = 2
			outline.default_color = Color(0, 0, 0, 0.1)
			
			for i in range(polygon.polygon.size()):
				var point1 = polygon.polygon[i]
				var point2 = polygon.polygon[(i + 1) % polygon.polygon.size()]
				outline.add_point(point1 + polygon.position)
				outline.add_point(point2 + polygon.position)
			
			piece.add_child(outline)
			
			# Add pulsing glow effect
			var glow = Polygon2D.new()
			glow.name = "glow"
			glow.polygon = polygon.polygon.duplicate()
			glow.position = polygon.position
			glow.visible = false
			glow.z_index = -1  # Behind the polygon
			glow.color = Color(1, 1, 0, 0.6)
			
			var shader = Shader.new()
			shader.code = """
			shader_type canvas_item;

			uniform float time;
			uniform vec4 base_color : source_color = vec4(1.0, 1.0, 0.0, 0.6);

			void fragment() {
				float pulse = 0.6 + 0.4 * sin(time * 3.0);
				COLOR = base_color;
				COLOR.a *= pulse;
			}
			"""
			
			var shader_material = ShaderMaterial.new()
			shader_material.shader = shader
			glow.material = shader_material
			
			piece.add_child(glow)
			
			pieces.append(piece)
			add_child(piece)

func _process(delta: float) -> void:
	var playerLabel = 0
	var aiLabel = 0
	for piece in pieces:
		if piece.type == "PLAYER":
			playerLabel += 1
		elif piece.type == "AI":
			aiLabel += 1
		
		# Update glow shader time uniform for pulsing effect
		var glow = piece.get_node_or_null("glow")
		if glow and glow.material:
			glow.material.set_shader_parameter("time", Time.get_ticks_msec() / 1000.0)
	
	parent.playerLabel.text = str(playerLabel)
	parent.aiLabel.text = str(aiLabel)
	
	if playerLabel + aiLabel == pieces.size():
		GameState.playerTxt = playerLabel
		GameState.aiTxt = aiLabel
		get_tree().change_scene_to_file("res://scenes/gameOver.tscn")
