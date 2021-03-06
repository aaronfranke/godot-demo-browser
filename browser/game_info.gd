extends VBoxContainer

var current_game
var screenshots := []
var screenshot_index := 0
var auto_release_focus: bool = true
var is_project_imported: bool = false
var is_project_ever_playable: bool = false

# Hard-coded list of unplayable demos (ones that only make sense to open in the Godot editor).
var _unplayable_demos = [
	"/misc/matrix_transform",
	"/mobile/android_iap",
	"/plugins"
]

onready var loading_rect = $"../../LoadingRect"
onready var name_label = $Name/Name
onready var description = $Description/Scroll/Label
onready var screenshot = $Screenshots/Screenshot
onready var prev_screenshot = $Screenshots/Prev
onready var next_screenshot = $Screenshots/Next
onready var buttons = $Buttons
# The Play button also functions as the Import button.
onready var play_button = $Buttons/Play
onready var play_label = $Buttons/Play/Label
onready var edit_button = $Buttons/Edit
onready var assetlib_button = $Buttons/AssetLib
onready var github_button = $Buttons/GitHub


func _ready():
	OS.min_window_size = Vector2(640, 400)


func _process(_delta):
	# Handle small screens by changing the text and sizes.
	if rect_size.x < 500:
		buttons.rect_min_size.y = 60
		edit_button.text = "Edit"
		assetlib_button.text = "AssetLib"
		github_button.text = "GitHub"
		if not is_project_imported:
			play_label.text = "Import"
		elif is_project_ever_playable:
			play_label.text = "Play Demo"
		else:
			play_label.text = "This demo\ncan't be\nplayed"
	else:
		buttons.rect_min_size.y = 80
		edit_button.text = "Edit Demo"
		assetlib_button.text = "View on Asset Library"
		github_button.text = "View on GitHub"
		if not is_project_imported:
			play_label.text = "Import Demo"
		elif is_project_ever_playable:
			play_label.text = "Play Demo"
		else:
			play_label.text = "This demo\ncan't be played"
	if Input.is_action_just_pressed("ui_toggle_fullscreen"):
		OS.window_fullscreen = not OS.window_fullscreen


func show_game(list_entry):
	current_game = list_entry
	name_label.text = list_entry.project_name
	description.text = list_entry.description
	_load_screenshots(list_entry.path.plus_file("screenshots"))
	var dir = Directory.new()
	is_project_imported = dir.dir_exists(list_entry.path.plus_file(".import/"))
	var path_suffix = "unplayable"
	if current_game.path.count("godot-demo-projects") > 0:
		path_suffix = current_game.path.split("godot-demo-projects")[1]
	is_project_ever_playable = not _unplayable_demos.has(path_suffix)
	play_button.disabled = is_project_imported and not is_project_ever_playable
	play_button.focus_mode = FOCUS_NONE if play_button.disabled else FOCUS_ALL
	assetlib_button.disabled = current_game.assetlib_url == ""
	assetlib_button.focus_mode = FOCUS_NONE if assetlib_button.disabled else FOCUS_ALL
	github_button.disabled = path_suffix == "unplayable"
	github_button.focus_mode = FOCUS_NONE if github_button.disabled else FOCUS_ALL
	if auto_release_focus:
		play_button.release_focus()
		edit_button.release_focus()
		assetlib_button.release_focus()
		github_button.release_focus()


func _load_screenshots(screenshot_path):
	screenshots.clear()
	var dir = Directory.new()
	if not dir.dir_exists(screenshot_path):
		screenshot.texture = null
		return
	if dir.open(screenshot_path) == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not file_name.begins_with("."):
				if not dir.current_is_dir():
					if file_name.ends_with(".png"):
						var image = Image.new()
						image.load(dir.get_current_dir().plus_file(file_name))
						var tex = ImageTexture.new()
						tex.create_from_image(image)
						screenshots.push_back(tex)
			file_name = dir.get_next()
		if screenshots.size() > 1:
			screenshot_index = randi() % screenshots.size()
			screenshot.texture = screenshots[screenshot_index]
			prev_screenshot.disabled = false
			next_screenshot.disabled = false
			prev_screenshot.modulate.a = 1.0
			next_screenshot.modulate.a = 1.0
		else:
			prev_screenshot.disabled = true
			next_screenshot.disabled = true
			prev_screenshot.modulate.a = 0.25
			next_screenshot.modulate.a = 0.25
			if screenshots.size() == 0:
				screenshot.texture = null
			else:
				screenshot.texture = screenshots[0]
	else:
		print("An error occurred when trying to access the screen path " + screenshot_path)


# The Play button also functions as the Import button.
func _on_Play_pressed():
	if is_project_imported:
		loading_rect.show_message("The game is running. To return to Godot Demo Browser, close the game.")
		run(["--path"])
	else:
		loading_rect.show_message("Please wait while resources are being imported...")
		run(["--editor", "--no-window", "--quit", "--path"])


func _on_Edit_pressed():
	loading_rect.show_message("The Godot editor has been opened. To return to Godot Demo Browser, close the editor.")
	run(["--editor", "--path"])


func _on_AssetLib_pressed():
	if current_game == null:
		return
	# warning-ignore:return_value_discarded
	OS.shell_open(current_game.assetlib_url)


func _on_GitHub_pressed():
	if current_game == null:
		return
	var path_suffix = current_game.path.split("godot-demo-projects")[1]
	# warning-ignore:return_value_discarded
	OS.shell_open("https://github.com/godotengine/godot-demo-projects/tree/master" + path_suffix)


func run(args):
	if current_game == null:
		return
	args.push_back(current_game.path)
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	# warning-ignore:return_value_discarded
	OS.execute(OS.get_executable_path(), PoolStringArray(args))
	show_game(current_game)


func _on_Prev_pressed():
	screenshot_index = posmod(screenshot_index - 1, screenshots.size())
	screenshot.texture = screenshots[screenshot_index]


func _on_Next_pressed():
	screenshot_index = posmod(screenshot_index + 1, screenshots.size())
	screenshot.texture = screenshots[screenshot_index]
