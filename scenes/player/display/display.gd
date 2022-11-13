extends PanelContainer
class_name Display

# Nodes
onready var _color_bg := $ColorBG
onready var _texture_bg := $TextureBG
onready var _atlas_player := $AtlasPlayer

# Exports
var _bg_color := Color.white setget set_bg_color, get_bg_color
var _bg_texture : Texture setget set_bg_texture, get_bg_texture
var _atlas_texture : Texture setget set_atlas_texture, get_atlas_texture
var _hframe := 1 setget set_hframe, get_hframe
var _vframe := 1 setget set_vframe, get_vframe
var _start_frame := 1 setget set_start_frame, get_start_frame
var _end_frame := 1 setget set_end_frame, get_end_frame
var _speed := 1.0 setget set_speed, get_speed
var _loop := true setget set_loop, get_loop
var _auto_start := false setget set_auto_start, get_auto_start


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# AtlasPlayer get
func connect_atlas_player(signal_string:String, object, method:String):
	# warning-ignore:return_value_discarded
	_atlas_player.connect(signal_string, object, method)


# ColorBG setget
func set_bg_color(color:Color):
	_bg_color = color
	_color_bg.color = color

func get_bg_color() -> Color:
	return _bg_color


# TextureBG setget
func set_bg_texture(texture:Texture):
	_bg_texture = texture
	_texture_bg.texture = texture

func get_bg_texture() -> Texture:
	return _bg_texture


# AtlasTexture setget
func set_atlas_texture(texture:Texture):
	_atlas_texture = texture
	_atlas_player.set_atlas_texture(texture)

func get_atlas_texture() -> Texture:
	return _atlas_texture


# HFrame setget
func set_hframe(value:int):
	_hframe = value
	_atlas_player.set_hframe(value)

func get_hframe() -> int:
	return _hframe


# VFrame setget
func set_vframe(value:int):
	_vframe = value
	_atlas_player.set_vframe(value)

func get_vframe():
	return _vframe


# StartFrame setget
func set_start_frame(value:int):
	_start_frame = value
	_atlas_player.set_start_frame(value)

func get_start_frame() -> int:
	return _start_frame


# EndFrame setget
func set_end_frame(value:int):
	_end_frame = value
	_atlas_player.set_end_frame(value)

func get_end_frame() -> int:
	return _end_frame


# Speed setget
func set_speed(value:float):
	_speed = value
	_atlas_player.set_speed(value)

func get_speed() -> float:
	return _speed


# Loop setget
func set_loop(flag:bool):
	_loop = flag
	_atlas_player.set_loop(flag)

func get_loop() -> bool:
	return _loop


# Autostart setget
func set_auto_start(flag:bool):
	_auto_start = flag
	_atlas_player.set_auto_start(flag)

func get_auto_start() -> bool:
	return _auto_start


# AtlasPlayer start/stop
func start():
	_atlas_player.start()

func stop():
	_atlas_player.stop()
