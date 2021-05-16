extends Control

var is_running := false
var time_elapsed := 0.0

onready var label := get_node("Label")
func _ready():
	load_game()
	pass

func _process(delta:float):
	var delta_ms := delta * 1000
	if is_running :
		time_elapsed += delta_ms

func _physics_process(_delta):
	save()
	label.text = formatted_time(time_elapsed)

func formatted_time(time:float) -> String:
	var mils = fmod(time,1000)
	var secs = fmod(time/1000,60)
	var mins = fmod(time/(1000*60),60)
	var hours = fmod(time/(1000*60*60),60)
	var _days = fmod(time/(1000*60*60*60),24)
	return "%02d:%02d:%02d:%03d" % [hours,mins,secs,mils]

func serialize():
	return {
		"save_time":OS.get_system_time_msecs(), #This would be better as metadata on the save itself, but this is a prototype
		"time_elapsed":time_elapsed,
		"is_running":is_running
	}

func save():
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
		var save_data = parse_json(save_game.get_line())
		var save_elapsed_time = OS.get_system_time_msecs() - save_data.save_time
		self.time_elapsed = save_data.time_elapsed
		self.is_running = save_data.is_running
		if save_data.is_running:
			self.time_elapsed += save_elapsed_time
	save_game.close()
	
func handle_error(error):
	print("An error with code %s ocurred." % error)
	pass

func reset():
	self.time_elapsed = 0

func toggle_pause():
	is_running = not is_running

# signals
func _on_Button_pressed():
	reset()

func _on_PausePlay_pressed():
	toggle_pause()
