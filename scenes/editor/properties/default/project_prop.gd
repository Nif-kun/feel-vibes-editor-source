extends PropBase

# Signals
signal open_file_pressed(object, filter)
signal save_project_pressed
signal open_project_pressed
signal new_project_pressed

# Nodes
onready var IconContainer := $VLaout/Flex/Icon
onready var IconTexture := $VLaout/Flex/Icon/Texture
onready var ProjectName := $VLaout/Flex/ProjectName
onready var Author := $VLaout/Flex/Author

# Private 
export var _stock_icon : Texture = preload("res://assets/icons/material/white_48dp/palette_white_48dp.svg")
export var _stock_icon_color := Color("dfc8ff")
onready var _default_icon : Texture = _stock_icon
onready var _default_icon_color : Color = _stock_icon_color
var _icon_path := ""
var _icon_name := ""
var _project_name := ""
var _author := ""


func reset():
	_default_icon = _stock_icon
	_default_icon_color = _stock_icon_color
	_icon_path = ""
	_icon_name = ""
	_project_name = ""
	_author = ""
	ProjectName.text = ""
	Author.text = ""
	IconTexture.texture = _stock_icon
	IconTexture.modulate = _stock_icon_color
	IconContainer.self_modulate = Color.white


func set_data(data:Dictionary):
	reset()
	if data.has("project_name"):
		_project_name = data["project_name"]
		ProjectName.text = data["project_name"]
	if data.has("author"):
		_author = data["author"]
		Author.text = Author.prefix+" "+data["author"]+" "+Author.suffix
	if data.has("icon_name") and data.has("icon"):
		IconTexture.modulate = Color.white
		IconTexture.texture = data["icon"]
		_default_icon_color = Color.white
		_default_icon = data["icon"]
		_icon_name = data["icon_name"]
		IconContainer.self_modulate = Color("00ffffff")


func get_data(temp_dir:String, is_save:bool=false, new_save:bool=false, save_file:String="") -> Dictionary:
	var icon_file = _icon_name # _icon_name is always empty unless loaded icon exists.
	
	# Handles removing of texture file in save if icon is stock texture.
	# Note: this can only occur during the first edit session. 
	if !_icon_name.empty() and IconTexture.texture == _stock_icon:
		Zipper.DisposeFile(save_file, _icon_name)
		_icon_name = ""
		icon_file = ""
	
	# Handles saving of icon texture.
	if IconTexture.texture != _default_icon:
		var icon_extension := ShortLib.get_file_extension(_icon_path)
		if is_save and !icon_extension.empty():
			icon_file = "icon_image"+icon_extension
			if new_save:
				var dir = Directory.new()
				var copy_err = dir.copy(_icon_path, temp_dir+"/"+icon_file)
				if copy_err != OK:
					push_error(SAVE_ERR_COPY_FILE % [_icon_path, temp_dir, copy_err])
			elif !save_file.empty():
				Zipper.AppendFile(save_file, _icon_path, icon_file, true, true)
			_icon_name = icon_file
	
	# Handles default value for project name and author.
	if _project_name.empty():
		_project_name = "Untitled"
	if _author.empty():
		_author = "Unknown"
	return {
		"project_name":_project_name,
		"author":_author,
		"icon":icon_file
	}


func _on_Icon_pressed():
	emit_signal("open_file_pressed", self, _texture_file_filter)


func set_selected_file(path):
	var icon = ShortLib.load_texture(path, false)
	var file_size = ShortLib.get_file_size(path, false)
	if file_size > 3000000: # 3MB
		emit_signal("file_size_warning")
	if icon != null:
		IconTexture.modulate = Color.white
		IconTexture.texture = icon
		_icon_path = path
		IconContainer.self_modulate = Color("00ffffff")
	else:
		IconTexture.modulate = _default_icon_color
		IconTexture.texture = _default_icon
		_icon_path = ""
		# This can only occur on unsaved or before loading data.
		if _stock_icon == _default_icon: 
			IconContainer.self_modulate = Color.white


func _on_ProjectName_text_changed(new_text):
	_project_name = new_text


func _on_Author_text_changed(new_text):
	_author = new_text


func _on_Save_pressed():
	emit_signal("save_project_pressed")


func _on_Open_pressed():
	emit_signal("open_project_pressed")


func _on_New_pressed():
	emit_signal("new_project_pressed")
