extends Camera2D
class_name DisplayCamera

signal zooming(value)

# Object var:
onready var zoom_camera = CameraZoom2D.new(self, "zoom_in", "zoom_out", false, 0.1)


# Public var:
export var zoom_rate := 0.1


func zoom_event(event):
	zoom_camera.set_zoom_rate(zoom_rate)
	zoom_camera.handle_input(event)
	var state = zoom_camera.state()
	if state == 1 or state == 2:
		emit_signal("zooming", zoom)


func zoom(value):
	zoom.x = value
	zoom.y = value
