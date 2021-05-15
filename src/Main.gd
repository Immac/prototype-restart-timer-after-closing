extends Control

var time = 0
onready var label := get_node("Label")

func _ready():
#	time = loaded time
	pass

func _process(delta):
	time += delta

func _physics_process(_delta):
	label.text = var2str(time)
	save()

func serialize():
	return {"time":time}

func save():
	print_debug("Saving the game.")
	var save_game := File.new()
	var err = OK
	for i in 1:
		err = save_game.open("user://savegame.save", File.WRITE)
		if err: 
			handle_error(err)
			break
		var save_what = serialize()
		save_game.store_line(to_json(save_what))
	save_game.close()

func handle_error(error):
	print("An error with code %s ocurred." % error)
	pass
