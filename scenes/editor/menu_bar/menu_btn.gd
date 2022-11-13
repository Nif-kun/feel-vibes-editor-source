extends MenuButton

signal item_pressed(id)

# Called when the node enters the scene tree for the first time.
func _ready():
	# warning-ignore:return_value_discarded
	get_popup().connect("id_pressed", self, "_on_item_pressed")


func _on_item_pressed(id):
	emit_signal("item_pressed", id)
