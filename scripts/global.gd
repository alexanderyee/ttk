extends Node

# Constants
var rng := RandomNumberGenerator.new()
@export var DEBUG_MODE := true
@export var LEVEL_COUNTDOWN_TIME := 3.0 if not DEBUG_MODE else .2
# Utility Functions
