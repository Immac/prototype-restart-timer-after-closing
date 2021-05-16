extends Control

const save_game_file_name := "user://background-timer.save"

var time_elapsed := 0.0
var running := false
var time_started := OS.get_system_time_msecs()

onready var display := get_node("Display")
func _ready():
	load_timer()

# business
func _physics_process(_delta):
	display_time()

func display_time():
	var time_delta = OS.get_system_time_msecs() - time_started if running else 0
	display.text = format_time(time_elapsed + time_delta)
	pass

func toggle_pause():
	self.running = not self.running
	
	if self.running:
		time_started = OS.get_system_time_msecs()
	else:
		time_elapsed += OS.get_system_time_msecs() - time_started
	
	save()

func reset():
	time_elapsed = 0.0
	running = false
	time_started = OS.get_system_time_msecs()

# save 
func save():
	var save_game := File.new()
	var err = OK
	for i in 1: # Try/Catch (´。＿。｀)
		err = save_game.open(save_game_file_name, File.WRITE)
		if err:
			print_debug("Error %d while opening File: %s" % [err,save_game_file_name])
			break
		var save_what = serialize()
		save_game.store_line(to_json(save_what))
	save_game.close()

func load_timer():
	var save_game = File.new()
	if not save_game.file_exists(save_game_file_name):
		print_debug("No save to load.")
		return
	
	save_game.open(save_game_file_name, File.READ)
	while save_game.get_position() < save_game.get_len():
		var save_data = parse_json(save_game.get_line())
		self.time_elapsed = save_data.time_elapsed
		self.running = save_data.running
		self.time_started = save_data.time_started
	save_game.close()

func serialize():
	return {
		"time_elapsed":time_elapsed,
		"running":running,
		"time_started":time_started,
	}

# util

func format_time(time:float) -> String:
	var mils = fmod(time,1000)
	var secs = fmod(time/1000,60)
	var mins = fmod(time/(1000*60),60)
	var hours = fmod(time/(1000*60*60),60)
	var _days = fmod(time/(1000*60*60*60),24)
	return "%02d:%02d:%02d:%03d" % [hours,mins,secs,mils]
 
# signals
func _on_PausePlay_pressed():
	toggle_pause()

func _on_Reset_pressed():
	reset()
