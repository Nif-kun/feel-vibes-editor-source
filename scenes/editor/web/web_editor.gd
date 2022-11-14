extends PanelContainer
class_name WebEditor

# Javascript
onready var Window = JavaScript.get_interface("window")
onready var Console = JavaScript.get_interface("console")
var loadProjectCallback = JavaScript.create_callback(self, "_on_read_project_file")
var loadImageCallback = JavaScript.create_callback(self, "_on_read_image_file")
export var home_url := ""

# Nodes:
onready var ViewerNode := $Docker/Viewer
onready var Properties := $Docker/Properties
onready var UILock := $UILock
onready var SizeWarning := $Notifs/Margin/HLayout/SizeWarning

# Paths
var base_dir := OS.get_user_data_dir()
var temp_dir := base_dir+"/"+"temp"
var image_temp_dir := base_dir+"/"+"image_temp"
var project_temp_dir := base_dir+"/"+"project_temp"
export var save_file_name := "save"
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
	# warning-ignore:return_value_discarded
#	connect("resized", self, "_on_resized")
	OS.min_window_size = _min_window_size
	Properties.load_requirements(ViewerNode)
	
	# Creates and clean temp directory
	_create_directories()
	_clean_directories()


func _create_directories():
	var dir := Directory.new()
	if !dir.dir_exists(temp_dir):
		# warning-ignore:return_value_discarded
		dir.make_dir(temp_dir)
	if !dir.dir_exists(image_temp_dir):
		# warning-ignore:return_value_discarded
		dir.make_dir(image_temp_dir)
	if !dir.dir_exists(project_temp_dir):
		# warning-ignore:return_value_discarded
		dir.make_dir(project_temp_dir)


func _clean_directories():
	var temp_dir_files = ShortLib.get_dir_files(temp_dir)
	var image_temp_dir_files = ShortLib.get_dir_files(image_temp_dir)
	var project_temp_dir_files = ShortLib.get_dir_files(project_temp_dir)
	ShortLib.remove_files(temp_dir_files, temp_dir)
	ShortLib.remove_files(image_temp_dir_files, image_temp_dir)
	ShortLib.remove_files(project_temp_dir_files, project_temp_dir)


func _download_project(save_path:String, clean_download:bool=true):
	var save_file = File.new()
	save_file.open(save_path, File.READ)
	JavaScript.download_buffer(save_file.get_buffer(save_file.get_len()), save_file_name+project_extension)
	save_file.close()
	
	# Remove created project file
	if clean_download:
		ShortLib.remove_file(save_path)


func _on_Properties_save_project_pressed():
	if _save_path.empty():
		_on_SaveFile_file_selected(project_temp_dir+"/"+save_file_name)
	else:
		Properties.save_data(temp_dir, config_file, _save_path, false)
		_download_project(_save_path)


func _on_Properties_open_project_pressed():
	_opening_save = true
	Window.getProjectFileDialog(loadProjectCallback)


func _on_Properties_new_project_pressed():
	_save_path = ""
	_opening_save = false
	Properties.reset()
	_clean_directories()


func _on_Properties_open_file_pressed(object, _filter):
	_event_object = object
	Window.getImageFileDialog(loadImageCallback)


func _on_Properties_file_size_warning():
	SizeWarning.popup()


func _on_read_project_file(args):
	_clean_directories()
	var buffer = JavaScript.eval("dataBuffer.result", true)
	var file = File.new()
	var file_name = args[0]
	var file_path = project_temp_dir+"/"+file_name
	
	file.open(file_path, File.WRITE)
	file.store_buffer(buffer)
	file.close()
	_on_OpenFile_files_selected(file_path)


func _on_read_image_file(args):
	var buffer = JavaScript.eval("dataBuffer.result", true)
	var file = File.new()
	var file_name = args[0]
	var file_path = image_temp_dir+"/"+file_name
	
	file.open(file_path, File.WRITE)
	file.store_buffer(buffer)
	file.close()
	_on_OpenFile_files_selected(file_path)


func _on_OpenFile_files_selected(files):
	# Handles how to handle array of files or singular one.
	# NativeDialog gives array while GodotDialog only gives a singluar path.
	var file_path = ""
	if files is PoolStringArray:
		if !files.empty():
			file_path = files[0]
	else:
		file_path = files
	
	# Load image file
	if _event_object != null:
		# Checks if object event came from Properties tab.
		if _event_object is PropBase and _event_object.has_method("set_selected_file"):
			_event_object.set_selected_file(file_path)
		_event_object = null
	
	# Load project file
	if _opening_save:
		if Directory.new().file_exists(file_path):
			Properties.load_data(file_path, temp_dir, config_file)
			_save_path = file_path
		_opening_save = false


func _on_SaveFile_file_selected(file):
	UILock.visible = false
	if !file.empty():
		var extension = ShortLib.get_file_extension(file) # Gets overwritten extension.
		Properties.save_data(temp_dir, temp_dir+"/"+config_file, file.trim_suffix(extension)+project_extension)
		_save_path = file.trim_suffix(extension)+project_extension
		_download_project(_save_path)


func _on_Return_pressed():
	Window.returnHome()
