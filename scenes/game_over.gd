extends Control

@export var playerLabel: Label
@export var aiLabel: Label

var playerTxt = 0
var aiTxt = 0

func _ready():
	playerLabel.text = str(playerTxt)
	aiLabel.text = str(aiTxt)
	
func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Main.tscn")
	pass # Replace with function body.


func _on_quit_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/home.tscn")
	pass # Replace with function body.
