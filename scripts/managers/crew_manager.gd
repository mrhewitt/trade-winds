extends MarginContainer

#region CrewNames

const CREW_NAMES: Array[String] = [
	"Sally Black", 
	"Lady Cassandra",
	"Vera Sparrow",
	"Lou-Lou Stubbs"
]

#endregion

@export var _icon: Texture2D
@export var _edit_icon: Texture2D

@onready var _tree: Tree = $HSplitContainer/MyCrew/Tree
@onready var _file: PopupMenu = %File
@onready var _hire_grid: GridContainer = %HireGrid
@onready var _ship: MarginContainer = %Ship
@onready var _gold: HBoxContainer = %Gold

var _tree_items: Dictionary
var _possible_roles: Array
var _looking_for_work: Array


func _ready() -> void:
	get_parent().set_tab_icon(2, _icon)
	_tree.set_column_title(0,"Role")
	_tree.set_column_title(1,"Name")
	_tree.set_column_title(2,"Pay")
	_tree.set_column_expand(2,false)
	_populate_tree( _tree.get_child(0), null )
	_tree.get_root().set_editable(1,true)
	_tree.get_root().set_icon(1, _edit_icon)
	_possible_roles = _tree_items.keys()
	_possible_roles.erase("Captain")
	_possible_roles.erase("Passenger")
	_populate_hire_grid()


func pay_out() -> void:
	var total: int = 0
	for role in _file.data.crew:
		if _file.data.crew[role] is Array:
			for person in _file.data.crew[role]:
				total += person["pay"]
		else:
			total += _file.data.crew[role]["pay"]
	if not _gold.spend(total):
		print("Game Over!")

func  get_crew_count() -> int:
	var count: int = 0
	for role in _file.data.crew:
		if _file.data.crew[role] is Array:
			count += _file.data.crew[role].size()
		else:
			count += 1
	return count
	
	
func _populate_hire_grid() -> void:
	_clear_hire_grid()
	for i in 15:
		_looking_for_work.append({
			"role": CheckBox.new(),
			"name": Label.new(),
			"pay": Label.new()
		})
		_looking_for_work[i]["role"].text = _possible_roles.pick_random()
		_looking_for_work[i]["name"].text = CREW_NAMES.pick_random()
		_looking_for_work[i]["pay"].text = str(randi_range(1,9))
		_hire_grid.add_child(_looking_for_work[i]["role"])
		_hire_grid.add_child(_looking_for_work[i]["name"])
		_hire_grid.add_child(_looking_for_work[i]["pay"])
		
		
func _clear_hire_grid() -> void:
	for person in _looking_for_work:
		person["role"].queue_free()
		person["name"].queue_free()
		person["pay"].queue_free()
	_looking_for_work.clear()
	
	
func _populate_tree(current: Node, parent_tree_item: TreeItem) -> void:
	var x: int = current.name.find("x")
	var role: String = current.name
	var quantity: int = 1
	if x != -1:
		role = current.name.substr(0,x)
		quantity = int(current.name.substr(x+1))
	var new_item: TreeItem = _add_tree_item(role, quantity, parent_tree_item)
	for child in current.get_children():
		_populate_tree(child, new_item)
		
		
func _add_tree_item(text: String, quantity: int, parent_tree_item: TreeItem) -> TreeItem:
	var new_item: TreeItem
	if quantity > 1:
		_tree_items[text] = []
	for i in quantity:
		new_item = _tree.create_item(parent_tree_item)
		new_item.set_text(0, text)
		new_item.visible = i == 0
		if quantity > 1: 
			_tree_items[text].append(new_item)
		else:	
			_tree_items[text] = new_item
	return new_item


func _populate_crew_member(role: TreeItem, crew_name: String, pay: String) -> void:
	role.set_text(1, crew_name)
	role.set_cell_mode(2, TreeItem.CELL_MODE_CHECK)
	if role != _tree.get_root():		
		if pay:
			role.set_cell_mode(2, TreeItem.CELL_MODE_RANGE)
			role.set_range_config(2, 1, 9,1)
			role.set_range(2, float(pay))
			role.set_editable(2, true)
		else:
			role.set_cell_mode(2, TreeItem.CELL_MODE_STRING)
			role.set_text(2, pay)
			role.set_editable(2, false)


func _on_file_reset() -> void:
	for role in _tree_items:
		if _tree_items[role] is Array:
			var quantity: int = 1
			if _file.data.crew.has(role):
				quantity = _file.data.crew[role].size()
				for i in _tree_items[role].size():
					_tree_items[role][i].visible = i == 0 or i < quantity
					if i < quantity:
						_populate_crew_member(_tree_items[role][i], _file.data.crew[role][i]["name"], str(_file.data.crew[role][i]["pay"]))
					else:
						_populate_crew_member(_tree_items[role][i], "", "")
		else:
			if _file.data.crew.has(role):
				_populate_crew_member(_tree_items[role], _file.data.crew[role]["name"], str(_file.data.crew[role]["pay"]))
			else:
				_populate_crew_member(_tree_items[role], "", "")


func _on_tree_item_edited() -> void:
	var edited: TreeItem = _tree.get_edited()
	if edited == _tree.get_root():
		if edited.get_text(1):
			_file.data.crew["Captain"]["name"] = edited.get_text(1)
		else:
			edited.set_text(1, _file.data.crew["Captain"]["name"])
	else:
		for role in _tree_items:
			if _tree_items[role] is Array:
				for i in _tree_items[role].size():
					if _tree_items[role][i] == edited:
						_file.data.crew[role][i]["pay"] = int(edited.get_range(2))
			elif _tree_items[role] == edited:
				_file.data.crew[role]["pay"] = int(edited.get_range(2))


func _on_fire_button_pressed() -> void:
	var selected: TreeItem = _tree.get_selected()
	if not selected or selected == _tree_items["Captain"]:
		return
	var role: String = selected.get_text(0)
	if _tree_items[role] is Array:
		if _file.data.crew[role].size():
			_file.data.crew[role].remove_at(_tree_items[role].find(selected))
	else:
		_file.data.crew.erase(role)
	_on_file_reset()	


func _on_hire_button_pressed() -> void:
	var hired: Array
	var role: String
	var max_crew:int = _ship.get_crew_limits()[1]
	for person in _looking_for_work:
		if get_crew_count() > max_crew:
			break
		if person["role"].button_pressed:
			role = person["role"].text
			if _tree_items[role] is Array:
				if _file.data.crew[role].size() < _tree_items[role].size():
					_file.data.crew[role].append({"name":person["name"].text,"pay":int(person["pay"].text)})
				else:
					continue
			elif not _file.data.crew.has(role):
				_file.data.crew[role] = {"name":person["name"].text,"pay":int(person["pay"].text)}
			else:
				continue
			person["role"].queue_free()
			person["name"].queue_free()
			person["pay"].queue_free()
			hired.append(person)
	for person in hired:
		_looking_for_work.erase(person)
	_on_file_reset()	
