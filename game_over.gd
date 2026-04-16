extends CanvasLayer

func _ready() -> void:
	Sounds.play_bgm2()


func _on_btn_home_pressed() -> void:
	Sounds.Click_Sound()
	get_tree().change_scene_to_file("res://main.tscn")
	pass # Replace with function body.


func _on_btn_replay_pressed() -> void:
	Sounds.Click_Sound()
	get_tree().change_scene_to_file("res://playground.tscn")
	pass # Replace with function body.
