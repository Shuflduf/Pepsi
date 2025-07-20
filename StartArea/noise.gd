extends AudioStreamPlayer

var playback: AudioStreamGeneratorPlayback
var volume = 0.001

func _ready():
    play()
    playback = get_stream_playback()

func _process(_delta):
    fill_buffer()

func fill_buffer():
    var frames_available = playback.get_frames_available()
    for i in range(frames_available):
        playback.push_frame(Vector2(volume, volume) * randf())
