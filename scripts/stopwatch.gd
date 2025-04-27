class_name Stopwatch
extends Node3D

var time_elapsed = 0.0
var started = false
var paused = false

func start():
	started = true

func get_time():
	return time_elapsed

func reset():
	time_elapsed = 0.0
	started = false

func pause():
	paused = true

func is_started():
	return started

func _process(delta: float) -> void:
	if started and not paused:
			time_elapsed += delta
