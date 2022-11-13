extends PanelContainer
class_name PropBase

# warning-ignore:UNUSED_SIGNAL
signal node_recieved
# warning-ignore:UNUSED_SIGNAL
signal file_size_warning

# Private
export var _texture_file_filter := ["*.png, *.jpg, *.jpeg ; Supported Images", "*.jpg ; JPG Images", "*.jpeg ; JPEG Images", "*.png ; PNG Images"]
export var _image_file_filter := ["*.png, *.jpg, *.jpeg, *.svg ; Supported Images", "*.jpg ; JPG Images", "*.jpeg ; JPEG Images", "*.png ; PNG Images", "*.svg ; SVG Images"]

# Const
const SAVE_ERR_COPY_FILE = 'SaveERR: failed to copy "%s" to "%s". ERR_CODE: %s'
const SAVE_ERR_OPEN_FILE = 'SaveERR: failed to open "%s". ERR_CODE: %s'

# CS-objects
var zipper_script = preload("res://scripts/Zipper.cs")
var Zipper = zipper_script.new()
