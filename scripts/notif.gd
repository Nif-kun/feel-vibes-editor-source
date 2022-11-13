extends PanelContainer
class_name Notif

# Export
export var _wait_time := 1

# Nodes
onready var _Timer : Timer


func _ready():
	visible = false
	_Timer = Timer.new()
	_Timer.wait_time = _wait_time
	_Timer.one_shot = true
	# warning-ignore:return_value_discarded
	_Timer.connect("timeout", self, "_on_Timer_timeout")
	add_child(_Timer)


func popup():
	visible = true
	modulate = Color.white
	_Timer.start()


func _on_Timer_timeout():
	var TweenNode = create_tween()
	TweenNode.set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	TweenNode.tween_property(self, "modulate", Color("00ffffff"), 1)
	# warning-ignore:return_value_discarded
	TweenNode.connect("finished", self, "_on_TweenNode_finished")


func _on_TweenNode_finished():
	visible = false
