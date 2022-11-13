extends PanelContainer

# Scenes
export var editor : PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	if editor != null:
		add_child(editor.instance())
