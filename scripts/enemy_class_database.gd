extends Node

enum EnemyClass {COMMON_WORD, AGILE_WORD, TANK_WORD, AGILE_PHRASE, COMMON_PHRASE, NULL = -1}

const COMMON_WORD_STATS := preload("res://resources/enemies/common_word_enemy.tres")
const AGILE_WORD_STATS = preload("res://resources/enemies/agile_word_enemy.tres")
const TANK_WORD_STATS := preload("res://resources/enemies/tank_word_enemy.tres")
const COMMON_PHRASE_STATS := preload("res://resources/enemies/common_phrase_enemy.tres")
const AGILE_PHRASE_STATS = preload("res://resources/enemies/agile_phrase_enemy.tres")

var class_to_stats_dict := {
	EnemyClass.COMMON_WORD: COMMON_WORD_STATS,
	EnemyClass.AGILE_WORD: AGILE_WORD_STATS,
	EnemyClass.TANK_WORD: TANK_WORD_STATS,
	EnemyClass.COMMON_PHRASE: COMMON_PHRASE_STATS,
	EnemyClass.AGILE_PHRASE: AGILE_PHRASE_STATS,
	EnemyClass.NULL: COMMON_WORD_STATS
}

func get_enemy_stats(enemy_class: EnemyClass) -> EnemyStats:
	return class_to_stats_dict[enemy_class]
