extends PropBase

# Note:
# label for size should be checked on a match case and apply value accordingly, something something lmao


# Nodes:
onready var _size_preset := $VLayout/VLayout/SizePreset
onready var _width_edit := $VLayout/VLayout/SizeEdit/WidthEdit
onready var _height_edit := $VLayout/VLayout/SizeEdit/HeightEdit
var screen : Control # Refer to Editor > Docker > Viewer > Viewbox > Viewport > Screen
var viewbox : ViewportContainer


# Private var:
var _default_width := 0.0
var _default_height := 0.0
enum SizePreset {
	CUSTOM = 0,
	
}
const custom_label := "Custom"
var width_buffer := 0.0
var height_buffer := 0.0


# Called when the node enters the scene tree for the first time.
func _ready():
	ShortLib.set_script_all([_width_edit, _height_edit], StrictSpinBox)
	yield(self, "node_recieved") # Ensures that screen is loaded first before running code below
	_width_edit.set_min(screen.rect_min_size.x)
	_height_edit.set_min(screen.rect_min_size.y)
	_width_edit.set_value(screen.rect_size.x)
	_height_edit.set_value(screen.rect_size.y)
	_default_width = screen.rect_size.x
	_default_height = screen.rect_size.y


func reset():
	_width_edit.set_value(_default_width)
	_height_edit.set_value(_default_height)


func _on_WidthEdit_value_changed(value):
	screen.rect_size.x = value
	screen.rect_position.x = (viewbox.rect_size.x / 2) - (value / 2)
	width_buffer = screen.rect_size.x
	_size_preset.text = custom_label+" "+"("+str(width_buffer)+" x "+str(height_buffer)+")"


func _on_HeightEdit_value_changed(value):
	screen.rect_size.y = value
	screen.rect_position.y = (viewbox.rect_size.y / 2) - (value / 2)
	height_buffer = screen.rect_size.y
	_size_preset.text = custom_label+" "+"("+str(width_buffer)+" x "+str(height_buffer)+")"
