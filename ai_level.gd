extends Node2D



func _on_btn_home_ai_pressed() -> void:
	get_tree().change_scene_to_file("res://main.tscn")
	pass # Replace with function body.


func _on_btn_easy_pressed() -> void:
	start_game("easy")

func _on_btn_medium_pressed() -> void:
	start_game("medium")

func _on_btn_hard_pressed() -> void:
	start_game("hard")
	
func start_game(diff):
	GameData.is_ai_mode = true
	GameData.ai_difficulty = diff
	get_tree().change_scene_to_file("res://playground.tscn")
