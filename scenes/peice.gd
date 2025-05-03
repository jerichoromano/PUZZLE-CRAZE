extends Node2D

var selected = false
var original_position: Vector2
var index = 0
var defaultIndex = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	z_index = 10
	original_position = global_position  # Store the original position
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if selected:
		followMouse()
	else:
		returnToOriginalPosition()  # Move back to the original position when not selected

func followMouse():
	global_position = get_global_mouse_position()

# Function to reset to the original position
func returnToOriginalPosition():
	global_position = global_position.lerp(original_position, 0.1)

func _on_collision_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			selected = true
			z_index = (z_index + 100) % 10000
		else:
			if(index == -1): index = defaultIndex
			selected = false

func _on_area_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	if self.name == area.get_parent().name:
		area.get_parent().get_node('image').visible = true
		area.get_parent().get_node('outline').queue_free()
		self.queue_free()
		


func _on_bound_area_entered(area: Area2D) -> void:
	var parent = area.get_parent().get_parent()
	if(parent.name != 'Peices'): return
	parent._on_enter_bound_entered(area, self)
	pass # Replace with function body.
