extends PanelContainer

# File Signals
signal new_file_pressed
signal open_file_pressed
signal export_file_pressed
signal save_pressed
signal return_pressed


func _on_File_item_pressed(id):
	match id:
		0: emit_signal("new_file_pressed")
		1: emit_signal("open_file_pressed")
		2: emit_signal("export_file_pressed")
		3: emit_signal("save_pressed")


func _on_Edit_item_pressed(_id):
	pass # Replace with function body.


func _on_Help_item_pressed(_id):
	pass # Replace with function body.


func _on_Return_pressed():
	emit_signal("return_pressed")
