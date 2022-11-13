extends VBoxContainer

# Nodes
onready var display := $Display
onready var widgets := $Widgets


# Called when the node enters the scene tree for the first time.
func _ready():
	display.set_bg_color(Color.aqua)
	display.set_bg_texture(ShortLib.load_texture("F:/Programming/AppDev/Projects/ATTune-Lite/Assets/Images/PNG/20fe1e143ea1bb175a2035b1d180e398.jpg"))
	display.set_atlas_texture(ShortLib.load_texture("F:/Programming/AppDev/Projects/ATTune-Lite/Assets/Images/PNG/beemo.png"))
	display.set_hframe(5)
	display.set_vframe(3)
	display.set_end_frame(14)
	display.set_speed(0.07)
	display.start()
