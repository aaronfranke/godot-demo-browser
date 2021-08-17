extends Button

var project_name
var description
var path
var assetlib_url
var game_info

func setup(p_name, p_description, p_path, p_image, p_assetlib_url, p_game_info):
	project_name = p_name
	name = p_name
	$Name.text = p_name
	path = p_path
	description = p_description
	assetlib_url = p_assetlib_url
	game_info = p_game_info
	if p_image:
		var tex = ImageTexture.new()
		tex.create_from_image(p_image)
		$Icon.texture = tex


func _show_game():
	game_info.show_game(self)
