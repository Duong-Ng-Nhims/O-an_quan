extends Node2D



func _on_btn_home_ai_pressed() -> void:
	get_tree().change_scene_to_file("res://main.tscn")
	pass # Replace with function body.


func _on_btn_easy_pressed() -> void:
	Sounds.Click_Sound()
	start_game("easy")

func _on_btn_medium_pressed() -> void:
	Sounds.Click_Sound()
	start_game("medium")

func _on_btn_hard_pressed() -> void:
	Sounds.Click_Sound()
	start_game("hard")
	
func start_game(diff):
	GameData.is_ai_mode = true
	GameData.ai_difficulty = diff
	get_tree().change_scene_to_file("res://playground.tscn")


func _on_btn_setting_ai_toggled(toggled_on: bool) -> void:
	Sounds.Click_Sound()
	pass # Replace with function body.


func _on_btn_sounds_pressed() -> void:
	Sounds.Click_Sound()
	Sounds.toggle_sound()
	pass # Replace with function body.
