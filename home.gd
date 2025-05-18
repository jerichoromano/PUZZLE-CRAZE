extends Control

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Main.tscn")
	pass # Replace with function body.

func _on_easy_pressed() -> void:
	GameState.easyLevel()
	_on_play_pressed()


func _on_medium_pressed() -> void:
	GameState.mediumLevel()
	_on_play_pressed()


func _on_hard_pressed() -> void:
	GameState.hardLevel()
	_on_play_pressed()


func _on_random_pressed() -> void:
	GameState.randomLevel()
	_on_play_pressed()


func _on_ai_pressed() -> void:
	GameState.randomLevel()
	_on_play_pressed()


func _on_quit_pressed() -> void:
	get_tree().quit()
	pass # Replace with function body.
