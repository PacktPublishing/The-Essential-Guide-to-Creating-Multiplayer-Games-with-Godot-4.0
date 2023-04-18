extends Label

@onready var timer = $Timer


func _ready():
	set_process(false)


func _process(delta):
	text = "Next round starting in: %d seconds" % timer.time_left


@rpc("call_local")
func wait(wait_time):
	timer.start(wait_time)
	set_process(true)
	show()


func _on_timer_timeout():
	set_process(true)
	hide()
