class_name SaveData
extends Resource

@export var mute: bool
@export var difficulty: int
@export var gold: int
@export var wood: int
@export var ship_name: String
@export var ship: int
@export var crew: Dictionary
@export var port: int
@export var is_anchored: bool = true
@export var sail: float

func _init() -> void:
	difficulty = 0
	ship = 0
	gold = 100
	wood = 10
	mute = false
	crew = {
		"Captain": { "name": "James", "pay": 0},
		"Navigator": { "name": "Billy", "pay": 5},
		"Helmsman": { "name": "Joe", "pay": 3},
		"Topman": [{ "name": "Bob", "pay": 2},{ "name": "Anne", "pay": 2}],
		"Seaman": [{ "name": "Sue", "pay": 1},{ "name": "Josephine", "pay": 1}]
	}
