extends Control

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Main.tscn")
	pass # Replace with function body.

func _on_easy_pressed() -> void:
	GameState.easyLevel()
	_on_play_pressed()


func _on_medium_pressed() -> void:
	if(GameState.easy == 1): 
		GameState.mediumLevel()
		_on_play_pressed()


func _on_hard_pressed() -> void:
	if(GameState.medium == 1):
		GameState.hardLevel()
		_on_play_pressed()


func _on_random_pressed() -> void:
	GameState.randomLevel()
	_on_play_pressed()


func _on_ai_pressed() -> void:
	GameState.vsAILevel()
	_on_play_pressed()


func _on_quit_pressed() -> void:
	get_tree().quit()
	pass # Replace with function body.


func _on_about_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/about.tscn")
	
	
func _process(delta: float) -> void:
	$MarginContainer/VBoxContainer/Medium/TextureRect.modulate = Color(0.5, 0.5, 0.5, 1.0)
	$MarginContainer/VBoxContainer/Hard/TextureRect.modulate = Color(0.5, 0.5, 0.5, 1.0)
	

	if(GameState.easy == 1): $MarginContainer/VBoxContainer/Medium/TextureRect.modulate = Color(1, 1, 1, 1)
	if(GameState.medium == 1): $MarginContainer/VBoxContainer/Hard/TextureRect.modulate = Color(1, 1, 1, 1)
