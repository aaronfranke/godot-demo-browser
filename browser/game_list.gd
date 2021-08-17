extends VBoxContainer

const MAX_DEPTH = 10

export(PackedScene) var list_entry_scene = preload("res://browser/list_entry.tscn")

onready var game_info = $"../../../GameInfo"


func _ready():
	randomize()
	_load_projects_from_path(".")
	yield(get_tree(), "idle_frame")
	if get_child_count() == 0:
		printerr("Couldn't find any projects!")
		return
	game_info.show_game(get_child(0))


func _load_projects_from_path(path: String, depth = 0):
	if depth > MAX_DEPTH:
		return
	var dir = Directory.new()
	if dir.open(path) == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not file_name.begins_with("."):
				if dir.current_is_dir():
					_load_projects_from_path(path.plus_file(file_name), depth + 1)
				else:
					if file_name.ends_with("project.godot") and path != ".":
						_load_project(path)
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path " + path)


func _load_project(project_path):
	var config = ConfigFile.new()
	config.load(project_path.plus_file("project.godot"))
	var project_name = config.get_value("application", "config/name")
	var project_desc = config.get_value("application", "config/description", "No description.")
	var project_icon = config.get_value("application", "config/icon", false)
	var project_image = null
	if project_icon:
		project_image = Image.new()
		project_image.load(project_path.plus_file(project_icon.right(6)))
	var project_readme = ""
	var file = File.new()
	if file.open(project_path.plus_file("README.md"), File.READ) == OK:
		project_readme = file.get_as_text()
		file.close()
	var assetlib_url = ""
	for line in project_readme.split("\n"):
		if line.begins_with("Check out this demo on the asset library: "):
			assetlib_url = line.right(42)
	# Create the list entry.
	var list_entry = list_entry_scene.instance()
	list_entry.setup(project_name, project_desc, project_path, project_image, assetlib_url, game_info)
	add_child(list_entry)


func _on_SearchBar_text_changed(new_text):
	for project in get_children():
		project.visible = new_text.empty() or project.project_name.countn(new_text) > 0
