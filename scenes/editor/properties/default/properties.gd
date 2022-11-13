extends VBoxContainer

# Signals
signal open_file_pressed(object, filter)
signal save_project_pressed
signal open_project_pressed
signal new_project_pressed
signal file_size_warning

# Nodes:
onready var ProjectProp := $ScrollBox/VLayout/ProjectProp
onready var ViewProp := $ScrollBox/VLayout/ViewProp
onready var ScreenProp := $ScrollBox/VLayout/ScreenProp
onready var BackgroundProp := $ScrollBox/VLayout/BackgroundProp
onready var AtlasProp := $ScrollBox/VLayout/AtlasProp
onready var WidgetProp := $ScrollBox/VLayout/WidgetProp
onready var ScrollBox := $ScrollBox

# CS-objects
var zipper_script = preload("res://scripts/Zipper.cs")
var Zipper = zipper_script.new()

# Data var
export var _editor_version := "1.0"
var _data_format := {
	"editor_ver":_editor_version,
	"project_name":"",
	"author":"",
	"icon":"",
	"background":{},
	"sprite":{}
}


func _ready():
	ScrollBox.scroll_vertical = 0


func reset():
	ProjectProp.reset()
	ViewProp.reset()
	ScreenProp.reset()
	BackgroundProp.reset()
	AtlasProp.reset()


func save_data(temp_dir:String, config_file:String, save_file:String, new_save:bool=true):
	var data : Dictionary = _data_format
	var project_data = ProjectProp.get_data(temp_dir, true, new_save, save_file)
	data["project_name"] = project_data["project_name"]
	data["author"] = project_data["author"]
	data["icon"] = project_data["icon"]
	data["background"] = BackgroundProp.get_data(temp_dir, true, new_save, save_file)
	data["sprite"] = AtlasProp.get_data(temp_dir, true, new_save, save_file)
	if new_save:
		var file := File.new()
		var open_err = file.open(config_file, File.WRITE)
		if open_err != OK:
			push_error(PropBase.SAVE_ERR_OPEN_FILE % [config_file, open_err])
		file.store_string(JSON.print(data, "\t"))
		file.close()
		Zipper.Zip(temp_dir, save_file, true, true)
	else:
		Zipper.WriteTextFile(save_file, config_file, JSON.print(data, "\t"), true, false)


func load_data(save_file:String, config_file:String):
	print(self.name+":"+save_file)
	print(self.name+":"+config_file)
	var texture_images = Zipper.CollectTextureImages(save_file)
	var config_json = JSON.parse(Zipper.ReadTextFile(save_file, config_file)).result
	var has_background = config_json.has("background")
	var has_sprite = config_json.has("sprite")
	
	# Check if texture_images and config_json has same file names.
	# If so, replaces config_json key-value.
	# Note: I'm getting brain aneurysm just by looking at the code below. :'> 
	if texture_images != null:
		if !texture_images.empty():
			if config_json.has("icon") and texture_images.has(config_json["icon"]):
				config_json["icon_name"] = config_json["icon"]
				config_json["icon"] = texture_images[config_json["icon"]]
			if has_background and config_json["background"].has("texture") and texture_images.has(config_json["background"]["texture"]):
				config_json["background"]["texture_name"] = config_json["background"]["texture"]
				config_json["background"]["texture"] = texture_images[config_json["background"]["texture"]]
			if has_sprite and config_json["sprite"].has("texture") and texture_images.has(config_json["sprite"]["texture"]):
				config_json["sprite"]["texture_name"] = config_json["sprite"]["texture"]
				config_json["sprite"]["texture"] = texture_images[config_json["sprite"]["texture"]]
	ProjectProp.set_data(config_json)
	if !has_background:
		config_json["background"] = {}
	if !has_sprite:
		config_json["sprite"] = {}
	BackgroundProp.set_data(config_json["background"])
	AtlasProp.set_data(config_json["sprite"])


func load_requirements(viewer : Viewer):
	ViewProp.camera = viewer.camera
	ViewProp.emit_signal("node_recieved")
	ScreenProp.screen = viewer.screen
	ScreenProp.viewbox = viewer.viewbox
	ScreenProp.emit_signal("node_recieved")
	BackgroundProp.DisplayNode = viewer.display
	BackgroundProp.emit_signal("node_recieved")
	AtlasProp.DisplayNode = viewer.display
	AtlasProp.emit_signal("node_recieved")


func _on_open_file_pressed(object, filter):
	emit_signal("open_file_pressed", object, filter)


func _on_file_size_warning():
	emit_signal("file_size_warning")


func _on_save_project_pressed():
	emit_signal("save_project_pressed")


func _on_open_project_pressed():
	emit_signal("open_project_pressed")


func _on_new_project_pressed():
	emit_signal("new_project_pressed")
