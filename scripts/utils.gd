extends Node

class_name utils

static func create_timer(parent: Node, wait_time: float, callback: Callable, autostart: bool = true) -> Timer:
	var timer = Timer.new()
	parent.add_child(timer)
	timer.wait_time = wait_time
	timer.timeout.connect(callback)
	if autostart:
		timer.start()
	return timer
