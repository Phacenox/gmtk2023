extends Node2D

@export var sounds: Array[AudioStream]
var players

func _ready():
	players = []
	for i in sounds:
		var n: AudioStreamPlayer = AudioStreamPlayer.new()
		add_child(n)
		n.stream = i
		players.append(n)
func play(i):
	(players[i] as AudioStreamPlayer).play()