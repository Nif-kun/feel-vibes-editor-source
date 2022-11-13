extends PropBase

# Signals:
signal open_file_pressed(object, filter)

# Nodes:
onready var ColorEdit := $VLayout/BGEdit/ColorEdit
onready var TextureEdit := $VLayout/BGEdit/TextureEdit/LineEdit
var DisplayNode : Display

# Private
var _texture_name := ""
var _loaded_texture : Texture = null # Always null until loading data


# Called when the node enters the scene tree for the first time.
func _ready():
	yield(self, "node_recieved") # Ensures that screen is loaded first before running code below
	DisplayNode.set_bg_color(ColorEdit.color)
	DisplayNode.set_bg_texture(ShortLib.load_texture(TextureEdit.text, false))


func reset():
	_texture_name = ""
	_loaded_texture = null
	ColorEdit.color = Color.white
	TextureEdit.text = ""
	DisplayNode.set_bg_color(Color.white)
	DisplayNode.set_bg_texture(null)


func set_data(data:Dictionary):
	reset()
	if data.has("color"):
		ColorEdit.color = Color(data["color"])
		DisplayNode.set_bg_color(Color(data["color"]))
	if data.has("texture_name") and data.has("texture"):
		TextureEdit.text = data["texture_name"]
		_texture_name = data["texture_name"]
		DisplayNode.set_bg_texture(data["texture"])
		_loaded_texture = data["texture"]


func get_data(temp_dir:String, is_save:bool=false, new_save:bool=false, save_file:String="") -> Dictionary:
	var file_name = _texture_name
	if DisplayNode.get_bg_texture() != null and DisplayNode.get_bg_texture() != _loaded_texture:
		var image_extension := ShortLib.get_file_extension(TextureEdit.text)
		file_name = "bg_image"+image_extension
		if is_save and !image_extension.empty():
			if new_save:
				var dir = Directory.new()
				var copy_err = dir.copy(TextureEdit.text, temp_dir+"/"+file_name)
				if copy_err != OK:
					push_error(SAVE_ERR_COPY_FILE % [TextureEdit.text, temp_dir, copy_err])
			elif !save_file.empty():
				Zipper.AppendFile(save_file, TextureEdit.text, file_name, true, true)
				_loaded_texture = null
			_texture_name = file_name
	elif !new_save and !save_file.empty():
		if TextureEdit.text != _texture_name:
			Zipper.DisposeFile(save_file, "bg_image"+ShortLib.get_file_extension(_texture_name))
			_texture_name = ""
			_loaded_texture = null
	return {
		"color":ColorEdit.color.to_html(),
		"texture":file_name
	}


func _on_ColorEdit_color_changed(color):
	DisplayNode.set_bg_color(color)


func _on_TextureEdit_text_changed(text):
	var texture = ShortLib.load_texture(text, false)
	var file_size = ShortLib.get_file_size(text)
	if file_size > 3000000: # 3MB
		emit_signal("file_size_warning")
	if texture != null:
		DisplayNode.set_bg_texture(texture)
	elif !_texture_name.empty() and _loaded_texture != null and text == _texture_name:
		DisplayNode.set_bg_texture(_loaded_texture)
	else:
		DisplayNode.set_bg_texture(null)


func _on_open_file_pressed():
	emit_signal("open_file_pressed", self, _texture_file_filter)


func set_selected_file(path):
	TextureEdit.text = path
	TextureEdit.emit_signal("text_changed", path)
