extends PanelContainer
class_name Editor

# Nodes:
onready var ViewerNode := $Docker/Viewer
onready var Properties := $Docker/Properties
onready var NativeOpenFileDialog := $NativeDialogs/OpenFile
onready var NativeSaveFileDialog := $NativeDialogs/SaveFile
onready var UILock := $UILock
onready var SizeWarning := $Notifs/Margin/HLayout/SizeWarning

# Paths
var base_dir := OS.get_user_data_dir()
var temp_dir := base_dir+"/"+"temp"
export var config_file := "fvd_config.json"
export var project_extension := ".fvd"

# Private 
export var _editor_version := "1.0"
export var _min_window_size := Vector2(545,393)
var _data_buffer := {}
var _event_object
var _last_focused
var _save_path := ""
var _opening_save := false


# Called when the node enters the scene tree for the first time.
func _ready():
	OS.min_window_size = _min_window_size
	Properties.load_requirements(ViewerNode)
	
	# Creates temp directory
	var dir := Directory.new()
	if !dir.dir_exists(temp_dir):
		# warning-ignore:return_value_discarded
		dir.make_dir(temp_dir)
	var dir_files = ShortLib.get_dir_files(temp_dir)
	ShortLib.remove_files(dir_files, temp_dir)
	# warning-ignore:return_value_discarded
	NativeOpenFileDialog.connect("files_selected", self, "_on_OpenFile_files_selected")
	# warning-ignore:return_value_discarded
	NativeSaveFileDialog.connect("file_selected", self, "_on_SaveFile_file_selected")


func _lock_ui():
	UILock.visible = true
	_last_focused = get_focus_owner()
	UILock.grab_focus()

func _unlock_ui():
	UILock.visible = false
	if _last_focused != null:
		_last_focused.grab_focus()
		_last_focused = null


func _on_Properties_save_project_pressed():
	if _save_path.empty():
		_lock_ui()
		NativeSaveFileDialog.filters = ["*.fvd ; Feelvibes Design (.fvd)"]
		NativeSaveFileDialog.show()
	else:
		Properties.save_data(temp_dir, config_file, _save_path, false)


func _on_Properties_open_project_pressed():
	_lock_ui()
	_opening_save = true
	NativeOpenFileDialog.title = "Open save file from directory"
	NativeOpenFileDialog.filters = ["*.fvd ; Feelvibes Design (.fvd)"]
	NativeOpenFileDialog.show() 


func _on_Properties_new_project_pressed():
	_save_path = ""
	_opening_save = false
	Properties.reset()


func _on_Properties_open_file_pressed(object, filter):
	_lock_ui()
	_event_object = object
	NativeOpenFileDialog.title = "Select an image file"
	NativeOpenFileDialog.filters = filter
	NativeOpenFileDialog.show()


func _on_Properties_file_size_warning():
	SizeWarning.popup()


func _on_OpenFile_files_selected(files):
	# Handles how to handle array of files or singular one.
	# NativeDialog gives array while GodotDialog only gives a singluar path.
	var file_path = ""
	if files is PoolStringArray:
		if !files.empty():
			file_path = files[0]
	else:
		file_path = files
	
	_unlock_ui()
	
	if _event_object != null:
		# Checks if object event came from Properties tab.
		if _event_object is PropBase and _event_object.has_method("set_selected_file"):
			_event_object.set_selected_file(file_path)
		_event_object = null
	
	if _opening_save:
		if Directory.new().file_exists(file_path):
			Properties.load_data(file_path, config_file)
			_save_path = file_path
		_opening_save = false


func _on_SaveFile_file_selected(file):
	UILock.visible = false
	if !file.empty():
		var extension = ShortLib.get_file_extension(file) # Gets overwritten extension.
		Properties.save_data(temp_dir, temp_dir+"/"+config_file, file.trim_suffix(extension)+project_extension)
		_save_path = file.trim_suffix(extension)+project_extension
