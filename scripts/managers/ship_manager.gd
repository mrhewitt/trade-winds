extends MarginContainer

const SHIP_NAMES : Array[String] = [
	"Serenity",
	"Liberty",
	"Escape",
	"Blue Moon",
	"Spirit",
	"Destiny",
	"Carpe Diem",
	"Serendipity",
	"Relentless"	
]

@export var _icon: Texture2D
@export var _ships: Array[Ship]

@onready var _file: PopupMenu = %File
@onready var _gold: HBoxContainer = %Gold

@onready var _my_ship_image: TextureRect = $HBoxContainer/MyShipInfo/VBoxContainer/MyShipImage
@onready var _my_ship_name_value: LineEdit = $HBoxContainer/MyShipInfo/VBoxContainer/Stats/NameValue
@onready var _my_ship_type_value: Label = $HBoxContainer/MyShipInfo/VBoxContainer/Stats/TypeValue
@onready var _my_ship_crew_value: Label = $HBoxContainer/MyShipInfo/VBoxContainer/Stats/CrewValue
@onready var _my_ship_cargo_value: Label = $HBoxContainer/MyShipInfo/VBoxContainer/Stats/CargoValue

@onready var _other_ship_image: TextureRect = $HBoxContainer/ShipsForSale/OtherShipImage
@onready var _other_ship_type_value: OptionButton = $HBoxContainer/ShipsForSale/Stats/TypeValue
@onready var _other_ship_crew_value: Label = $HBoxContainer/ShipsForSale/Stats/CrewValue
@onready var _other_ship_cargo_value: Label = $HBoxContainer/ShipsForSale/Stats/CargoValue
@onready var _other_ship_cost_value: Label = $HBoxContainer/ShipsForSale/Stats/CostValue

@onready var _buy_button: Button = $HBoxContainer/ShipsForSale/BuyButton

var _my_ship: int


func _ready() -> void:
	get_parent().set_tab_icon(3, _icon)
	for ship in _ships:
		_other_ship_type_value.add_item(ship.type)
		
		
func get_crew_limits() -> Array[int]:
	return [_ships[_my_ship].min_crew, _ships[_my_ship].max_crew]


func get_speed() -> float:
	return _ships[_my_ship].speed
	
	
func _update_my_ship_info() -> void:
	_my_ship_image.texture = _ships[_my_ship].image
	_my_ship_name_value.text = _file.data.ship_name
	_my_ship_type_value.text = _ships[_my_ship].type
	_my_ship_crew_value.text = str(_ships[_my_ship].min_crew) + " - " + str(_ships[_my_ship].max_crew)
	_my_ship_cargo_value.text = str(_ships[_my_ship].cargo) + " tons"


func _on_file_reset() -> void:
	_my_ship = _file.data.ship
	if not _file.data.ship_name:
		_file.data.ship_name = SHIP_NAMES.pick_random()
	_update_my_ship_info()
	for i in _ships.size():
		_other_ship_type_value.set_item_disabled(i, i <= _my_ship)
	if _my_ship == _ships.size() - 1:
		_other_ship_type_value.select(-1)
		_on_type_value_item_selected(-1)
	else:
		_other_ship_type_value.select(_my_ship+1)
		_on_type_value_item_selected(_my_ship+1)


func _on_name_value_text_submitted(new_text: String) -> void:
	if new_text:
		_file.data.ship_name = new_text
	else:
		_my_ship_name_value.text = _file.data.ship_name
	_my_ship_name_value.release_focus()
	

func _on_buy_button_pressed() -> void:
	if _gold.spend(_ships[_other_ship_type_value.selected].price):
		_file.data.ship = _other_ship_type_value.selected
		_on_file_reset()
		

func _on_type_value_item_selected(index: int) -> void:
	if index == -1:
		_other_ship_image.texture = null
		_other_ship_crew_value.text = ""
		_other_ship_cargo_value.text = ""
		_other_ship_cost_value.text = ""
		_buy_button.disabled = true
		return
	_other_ship_image.texture = _ships[index].image
	_other_ship_crew_value.text = str(_ships[index].min_crew) + " - " + str(_ships[index].max_crew)
	_other_ship_cargo_value.text = str(_ships[index].cargo) + " tons"
	_other_ship_cost_value.text = str(_ships[index].price)
	_buy_button.disabled = not _gold.has_enough(_ships[index].price)
