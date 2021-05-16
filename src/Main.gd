extends Control

var time = 0
onready var time_start = OS.get_system_time_msecs()
onready var label := get_node("Label")

func _ready():
	load_game()
	pass

func _process(delta):
	time = OS.get_system_time_msecs() - time_start

func _physics_process(_delta):
	label.text = var2str(time)
	save()

func serialize():
	return {
		"time_start":time_start
	}

func save():
#	print_debug("Saving the game.")
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

func load_game():
	var save_game = File.new()
	if not save_game.file_exists("user://savegame.save"):
		print_debug("No save to load.")
		return
	
	save_game.open("user://savegame.save", File.READ)
	while save_game.get_position() < save_game.get_len():
		var node_data = parse_json(save_game.get_line())
		time_start = node_data.get("time_start",time_start)
	save_game.close()
	
func handle_error(error):
	print("An error with code %s ocurred." % error)
	pass
