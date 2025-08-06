extends HBoxContainer

@export var _resource_name: String
@export var _maximum: int = 1000

@onready var _file: PopupMenu = %File
@onready var label: Label = $Label

var _quantity: int


func receive(amount: int) -> void:
	_quantity = _file.data.get(_resource_name)
	_quantity = min(amount + _quantity, _maximum)
	update_counter()
	_file.data.set(_resource_name, _quantity)


func spend(amount: int) -> bool:
	if has_enough(amount):
		_file.data.set(_resource_name, _file.data.get(_resource_name) - amount)
		update_counter() 
		return true
	else:		
		return false
	
	
func has_enough(amount: int) -> bool:
	return _file.data.get(_resource_name) >= amount
	
	
func update_counter() -> void:
	label.text = str(_file.data.get(_resource_name))


#func _input(event: InputEvent) -> void:
#	if event.is_action_pressed("ui_up"):
#		receive(randi_range(1,100))
#	elif event.is_action_pressed("ui_down"):
#		print(spend(randi_range(1,100)))
	
	
	
