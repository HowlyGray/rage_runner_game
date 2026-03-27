extends Node

# Audio players
var music_player: AudioStreamPlayer
var sfx_player: AudioStreamPlayer

func _ready():
	# Créer les lecteurs audio
	music_player = AudioStreamPlayer.new()
	music_player.bus = "Music"
	add_child(music_player)
	
	sfx_player = AudioStreamPlayer.new()
	sfx_player.bus = "SFX"
	add_child(sfx_player)
	
	update_volumes()

func update_volumes():
	AudioServer.set_bus_volume_db(0, linear_to_db(GameManager.master_volume))
	
	var music_bus_idx = AudioServer.get_bus_index("Music")
	if music_bus_idx != -1:
		AudioServer.set_bus_volume_db(music_bus_idx, linear_to_db(GameManager.music_volume))
	
	var sfx_bus_idx = AudioServer.get_bus_index("SFX")
	if sfx_bus_idx != -1:
		AudioServer.set_bus_volume_db(sfx_bus_idx, linear_to_db(GameManager.sfx_volume))

func play_music(stream: AudioStream):
	if music_player.stream != stream:
		music_player.stream = stream
		music_player.play()

func stop_music():
	music_player.stop()

func play_sfx(stream: AudioStream):
	sfx_player.stream = stream
	sfx_player.play()

func linear_to_db(linear: float) -> float:
	if linear <= 0:
		return -80
	return 20 * log(linear) / log(10)
