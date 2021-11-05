extends ColorRect

onready var label = $Label
onready var music = $"../Music"

func show_message(status):
	label.text = status
	music.stop()
	show()
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	hide()
