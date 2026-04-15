extends Control

signal het_gio

@onready var frame = $frame
@onready var time_label = $timeLabel
@onready var turn_timer = $turnTimer

var time_left: int = 30

func _on_turn_timer_timeout():
	time_label.text = "0"
	het_gio.emit()

const color_waiting = Color(1,0,0)
const color_active = Color(0,1,0)

func _process(_delta):
	if not turn_timer.is_stopped():
		var time_left = turn_timer.time_left
		if time_left < 0.1:
			time_label.text = "0"
		else:
			time_label.text = str(ceil(time_left))

func set_active(is_active:bool):
	var style_box = frame.get_theme_stylebox("panel").duplicate()
	
	if is_active:
		style_box.border_color = color_active
		time_label.show()
		turn_timer.start(30)
	else:
		style_box.border_color = color_waiting
		turn_timer.stop()
		time_label.hide()
	frame.add_theme_stylebox_override("panel", style_box)
	
func set_avt(new_texture: Texture2D):
	$frame/avartar.texture = new_texture

func stop_timer():
	turn_timer.stop()
	
func start_timer():
	turn_timer.start()

func reset_timer():
	time_left = 30
	time_label.text = str(time_left)
	turn_timer.start()
