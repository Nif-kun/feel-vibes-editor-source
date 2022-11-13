extends PanelContainer
class_name Viewer


# Nodes:
onready var viewbox := $ViewBox
onready var viewport := $ViewBox/Viewport
onready var camera := $ViewBox/Viewport/Camera2D
onready var screen := $ViewBox/Viewport/Screen
onready var display := $ViewBox/Viewport/Screen/Display
onready var widgets := $ViewBox/Viewport/Screen/Widgets


# Called when the node enters the scene tree for the first time.
func _ready():
	# warning-ignore:RETURN_VALUE_DISCARDED
	connect("resized", self, "_resized")
	viewport.size = viewbox.rect_size #this container should've fixed the sizing but Godot is retarded at times.
	camera.position = viewbox.rect_size / 2
	screen.rect_position = (viewbox.rect_size / 2 ) - (screen.rect_size / 2)


func _resized():
	yield(viewbox, "resized") # Yielded to avoid early value of viewbox as there is a delay.
	camera.position = viewbox.rect_size / 2
	screen.rect_position = (viewbox.rect_size / 2 ) - (screen.rect_size / 2)


func _gui_input(event):
	camera.zoom_event(event) # Moved from camera script to avoid zooming even when out of display.
