extends AudioStreamPlayer

var music := []


func _ready():
	randomize()
	var dir = Directory.new()
	if dir.open("res://music") == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir():
				if file_name.ends_with(".ogg.import"):
					var audio_stream_ogg = load("res://music/" + file_name.rstrip(".import"))
					audio_stream_ogg.loop = false
					music.push_back(audio_stream_ogg)
			file_name = dir.get_next()
		if music.size() > 0:
			play_next()
	else:
		print("An error occurred when trying to access the path.")


func play_next():
	stream = music[randi() % music.size()]
	play()
