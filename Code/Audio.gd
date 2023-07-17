extends Node2D

@export var sounds: Array[AudioStream]
var stream_players: Array[AudioStreamPlayer]

func _ready():
	stream_players = []
	for i in sounds:
		var player = AudioStreamPlayer.new()
		add_child(player)
		player.stream = i
		stream_players.append(player)

func play(i):
	stream_players[i].play()