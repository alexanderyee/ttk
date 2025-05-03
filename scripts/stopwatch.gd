class_name Stopwatch
extends Node3D

var time_elapsed = 0.0
var started = false
var paused = false

func start():
	started = true

func stop():
	started = false

func get_time():
	return time_elapsed

func reset():
	time_elapsed = 0.0
	started = false

func pause():
	if started:
		paused = true
	
func unpause():
	if started:
		paused = false

func is_started():
	return started
	
func is_paused():
	return paused
	

func _process(delta: float) -> void:
	if started and not paused:
			time_elapsed += delta
