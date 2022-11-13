extends Control


# Handles all input events that occur.
func _input(event):
	_remove_focus(event)


# Removes focus of an object if it is user clicked out of it's bound and not another object.
func _remove_focus(event):
	if event is InputEventMouseButton:
		if event.is_pressed() and get_focus_owner() != null:
			if not get_focus_owner().get_global_rect().intersects(Rect2(get_global_mouse_position(), Vector2(2,2))):
				get_focus_owner().release_focus()
