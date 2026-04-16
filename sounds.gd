extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	pass
	
func Click_Sound():
	%ClickSound.play()
	
func Rai_Quan():
	%RaiQuan.play()
	
func An_Quan():
	%AnQuan.play()

func play_bgm1():
	$BGM2.stop()
	$BGM.play()
	
func play_bgm2():
	$BGM.stop()
	$BGM2.play()
	
var is_muted=false
func toggle_sound():
	is_muted=!is_muted
	if is_muted:
		$%ClickSound.volume_db=-80
		$%RaiQuan.volume_db=-80
		$%AnQuan.volume_db=-80
		$BGM.volume_db=-80
		$BGM2.volume_db=-80
	else:
		$%ClickSound.volume_db=10
		$%RaiQuan.volume_db=10
		$%AnQuan.volume_db=10
		$BGM.volume_db=-10
		$BGM2.volume_db=-10
	
	
	
	
	
	
