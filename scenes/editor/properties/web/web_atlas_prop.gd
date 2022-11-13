extends PropBase

# Signals:
signal open_file_pressed(object, filter)

# Nodes:
onready var TextureEdit := $VLayout/Grid/TextureEdit/LineEdit
onready var HFrameEdit := $VLayout/Grid/HFrameEdit
onready var VFrameEdit := $VLayout/Grid/VFrameEdit
onready var StartFrameEdit := $VLayout/Grid/StartFrameEdit
onready var EndFrameEdit := $VLayout/Grid/EndFrameEdit
onready var SpeedEdit := $VLayout/Grid/SpeedEdit
onready var LoopCheck := $VLayout/Grid/LoopCheck
onready var PlayButton := $VLayout/PlayButton
#var atlas_player # AtlasPlayer type; Unable to set due to Godot inconsistency with set_custom_type()
var DisplayNode : Display

# Private:
var _texture_name := ""
var _loaded_texture : Texture = null

# Called when the node enters the scene tree for the first time.
func _ready():
	ShortLib.set_script_all([HFrameEdit, VFrameEdit, StartFrameEdit, EndFrameEdit, SpeedEdit], StrictSpinBox)
	_update_max_frame()
	yield(self, "node_recieved") # Ensures that screen is loaded first before running code below
	_setup_atlas_player()
	# warning-ignore:RETURN_VALUE_DISCARDED
	DisplayNode.connect_atlas_player("stopped", self, "_on_AtlasPlayer_stopped")

func _update_max_frame():
	StartFrameEdit.max_value = (HFrameEdit.value * VFrameEdit.value)
	EndFrameEdit.max_value = (HFrameEdit.value * VFrameEdit.value)


func reset():
	PlayButton.pressed = false
	TextureEdit.text = ""
	HFrameEdit.value = 1
	VFrameEdit.value = 1
	StartFrameEdit.value = 1
	EndFrameEdit.min_value = 1
	EndFrameEdit.value = 1
	_update_max_frame()
	SpeedEdit.value = 1
	LoopCheck.pressed = true
	_setup_atlas_player(true)


func _setup_atlas_player(emitted_ready:bool=false, skip_texture:bool=false):
	if !skip_texture:
		DisplayNode.set_atlas_texture(ShortLib.load_texture(TextureEdit.text, emitted_ready))
	DisplayNode.set_hframe(HFrameEdit.value)
	DisplayNode.set_vframe(VFrameEdit.value)
	DisplayNode.set_start_frame(StartFrameEdit.value)
	DisplayNode.set_end_frame(EndFrameEdit.value)
	DisplayNode.set_speed(SpeedEdit.value)
	DisplayNode.set_loop(LoopCheck.pressed)


func set_data(data:Dictionary):
	reset()
	if data.has("texture_name") and data.has("texture"):
		TextureEdit.text = data["texture_name"]
		_texture_name = data["texture_name"]
		DisplayNode.set_atlas_texture(data["texture"])
		_loaded_texture = data["texture"]
	if data.has("hframe"):
		HFrameEdit.value = data["hframe"]
	if data.has("vframe"):
		VFrameEdit.value = data["vframe"]
	_update_max_frame()
	if data.has("start_frame"):
		StartFrameEdit.value = data["start_frame"]
		EndFrameEdit.min_value = data["start_frame"]
	if data.has("end_frame"):
		EndFrameEdit.value = data["end_frame"]
	if data.has("speed"):
		SpeedEdit.value = data["speed"]
	if data.has("loop"):
		LoopCheck.pressed = data["loop"]
	_setup_atlas_player(true, true) 


func get_data(temp_dir:String, is_save:bool=false, new_save:bool=false, save_file:String="") -> Dictionary:
	var file_name = _texture_name
	if DisplayNode.get_atlas_texture() != null and DisplayNode.get_atlas_texture() != _loaded_texture:
		var image_extension := ShortLib.get_file_extension(TextureEdit.text)
		file_name = "sprite_image"+image_extension.to_lower()
		if is_save and !image_extension.empty():
			var dir = Directory.new()
			ShortLib.remove_file(temp_dir+"/"+file_name, true)
			var copy_err = dir.copy(TextureEdit.text, temp_dir+"/"+file_name)
			if copy_err != OK:
				push_error(SAVE_ERR_COPY_FILE % [TextureEdit.text, temp_dir, copy_err])
			if !new_save:
				_loaded_texture = null
			_texture_name = file_name
	elif !new_save and !save_file.empty():
		if TextureEdit.text != _texture_name:
			ShortLib.remove_file(temp_dir+"/"+file_name)
			_texture_name = ""
			_loaded_texture = null
	return {
		"texture":file_name,
		"hframe":HFrameEdit.value,
		"vframe":VFrameEdit.value,
		"start_frame":StartFrameEdit.value,
		"end_frame":EndFrameEdit.value,
		"speed":SpeedEdit.value,
		"loop":LoopCheck.pressed
	}


func _on_TextureEdit_text_changed(text):
	var texture = ShortLib.load_texture(text)
	var file_size = ShortLib.get_file_size(text)
	if file_size > 3000000: # 3MB
		emit_signal("file_size_warning")
	if texture != null:
		DisplayNode.set_atlas_texture(texture)
		PlayButton.disabled = false
	elif !_texture_name.empty() and _loaded_texture != null and text == _texture_name:
		DisplayNode.set_atlas_texture(_loaded_texture)
	else:
		DisplayNode.set_atlas_texture(null)
		PlayButton.disabled = true


func _on_open_file_pressed():
	PlayButton.pressed = false
	emit_signal("open_file_pressed", self, _texture_file_filter)


func set_selected_file(path):
	TextureEdit.text = path
	TextureEdit.emit_signal("text_changed", path)


func _on_HFrameEdit_value_changed(value):
	DisplayNode.set_hframe(value)
	_update_max_frame()


func _on_VFrameEdit_value_changed(value):
	DisplayNode.set_vframe(value)
	_update_max_frame()


func _on_StartFrameEdit_value_changed(value):
	DisplayNode.set_start_frame(value)
	EndFrameEdit.min_value = value


func _on_EndFrameEdit_value_changed(value):
	DisplayNode.set_end_frame(value)


func _on_SpeedEdit_value_changed(value):
	DisplayNode.set_speed(value)


func _on_LoopCheck_toggled(button_pressed):
	PlayButton.pressed = false
	DisplayNode.set_loop(button_pressed)


func _on_PlayButton_toggled(button_pressed):
	if button_pressed:
		PlayButton.text = "Stop"
		DisplayNode.start()
	else:
		PlayButton.text = "Start"
		DisplayNode.stop()


func _on_AtlasPlayer_stopped():
	PlayButton.pressed = false


func _on_Clear_pressed():
	# This is to keep previous program from running without re-writting.
	TextureEdit.emit_signal("text_changed", "") 
