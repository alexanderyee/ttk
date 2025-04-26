extends Panel

@onready var enemy_word: RichTextLabel = $EnemyWord

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	size = enemy_word.get_size() + Vector2(10, 10)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
