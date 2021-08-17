extends Button

onready var tabs = $About/VBoxContainer/TabContainer


func _ready():
	$About/VBoxContainer/Label.text = "Godot " + Engine.get_version_info()["string"] + "\n\nLicenses:"
	_add_license_nodes("Godot Engine", godot_license)
	_add_license_nodes("FreeType", freetype_license)
	_add_license_nodes("ENet", enet_license)
	_add_license_nodes("MBedTLS", mbedtls_license)
	_load_licenses_from_path(".")


func _on_About_pressed():
	$About.popup_centered()


func _load_licenses_from_path(path: String):
	var dir = Directory.new()
	if dir.open(path) == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not file_name.begins_with("."):
				if dir.current_is_dir():
					_load_licenses_from_path(path.plus_file(file_name))
				else:
					if file_name.findn("LICENSE") > -1:
						_load_license(path, file_name)
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")


func _load_license(path, file_name):
	var license_path = path.plus_file(file_name)
	var file = File.new()
	if file.open(license_path, File.READ) == OK:
		_add_license_nodes(file_name.get_basename(), license_path + "\n\n" + file.get_as_text())
		file.close()


func _add_license_nodes(tab_name, text):
	var scroll_container = ScrollContainer.new()
	scroll_container.name = tab_name
	scroll_container.scroll_horizontal = false
	scroll_container.size_flags_horizontal = SIZE_EXPAND_FILL
	scroll_container.size_flags_vertical = SIZE_EXPAND_FILL
	tabs.add_child(scroll_container)
	var license_text = Label.new()
	license_text.rect_min_size = Vector2(580, 200)
	license_text.autowrap = true
	license_text.text = text
	scroll_container.add_child(license_text)


var mit = """
Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE."""

var godot_license = """Godot Engine is under the MIT License, with some components under different licenses.

Copyright (c) 2007-2021 Juan Linietsky, Ariel Manzur.
Copyright (c) 2014-2021 Godot Engine contributors.
""" + mit

var freetype_license = """FreeType

Portions of this software are copyright © 2021 The FreeType Project (www.freetype.org). All rights reserved."""

var enet_license = """ENet

Copyright (c) 2002-2020 Lee Salzman
""" + mit

var mbedtls_license = """MBedTLS

Copyright The Mbed TLS Contributors

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License."""
