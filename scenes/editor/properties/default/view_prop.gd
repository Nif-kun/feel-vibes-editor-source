extends PropBase


# Nodes:
onready var _zoom_edit := $VLayout/ZoomEdit/SpinBox
var camera : DisplayCamera

# Private
var _default_zoom := 0


# Called when the node enters the scene tree for the first time.
func _ready():
	_zoom_edit.set_script(StrictSpinBox)
	yield(self, "node_recieved") # Ensures that screen is loaded first before running code below
	# warning-ignore:RETURN_VALUE_DISCARDED
	camera.connect("zooming", self, "_on_Camera_zooming")
	_zoom_edit.step = camera.zoom_rate * 100
	_zoom_edit.min_value = _zoom_edit.step
	_default_zoom = _zoom_edit.value


func reset():
	_zoom_edit.value = _default_zoom


func _on_Zoom_value_changed(value):
	camera.zoom(ShortLib.invert_float(_zoom_edit.min_value * 0.01, _zoom_edit.max_value * 0.01, (value * 0.01)))


func _on_Camera_zooming(value):
	# Using width (x) but height (y) also applies.
	_zoom_edit.set_value(ShortLib.invert_int(_zoom_edit.min_value, _zoom_edit.max_value, (value.x * 100))) 
