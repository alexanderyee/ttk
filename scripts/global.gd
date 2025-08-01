extends Node

# Constants
var rng := RandomNumberGenerator.new()
@export var DEBUG_MODE := false
@export var LEVEL_COUNTDOWN_TIME := 3.0 if not DEBUG_MODE else 0.5
# Utility Functions
