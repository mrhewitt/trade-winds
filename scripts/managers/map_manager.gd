extends MarginContainer

const DISTANCES: Array = [
	[800,743,657,939],
	[743,800,278,428],
	[657,428,800,444],
	[939,428,444,800],
]

@onready var _file: PopupMenu = %File
@onready var _days: Label = %Days
@onready var _embark_button: Button = %EmbarkButton
@onready var _ship: MarginContainer = %Ship
@onready var _anchor: CheckButton = $VBoxContainer/HBoxContainer/Anchor
@onready var _ports: Array[Node] = $VBoxContainer/Map/Ports.get_children()
@onready var _sails: VSlider = $VBoxContainer/HBoxContainer/Sails
@onready var _voyage_progress: ProgressBar = %VoyageProgress
@onready var _crew: MarginContainer = %Crew

var _destination: int = -1
var _is_sailing: bool
var _time_elapsed: float
var _days_at_sea: int


func set_destination(toggled_on: bool, port_id: int) -> void:
	if _is_sailing:
		_ports[_destination].button_press = true
		return
	if toggled_on:
		_destination = port_id
	else:
		_destination = -1
	if _destination == -1 or _destination == _file.data.port:
		_days.visible = false
		_embark_button.disabled = true
	else:
		_days.text = str(ceil(DISTANCES[_file.data.port][_destination] / _ship.get_speed())) + " days"
		_days.visible = true
		_embark_button.disabled = false
		_voyage_progress.value = 0


func _on_anchor_toggled(toggled_on: bool) -> void:
	_file.data.is_anchored = toggled_on


func _on_file_reset() -> void:
	_anchor.button_pressed = _file.data.is_anchored
	for i in _ports.size():
		_ports[i].disabled = _file.data.port == i
		_ports[i].button_pressed = false
	_sails.value = _file.data.sail

func _on_sails_value_changed(value: float) -> void:
	_file.data.sail = value


func _on_embark_button_pressed() -> void:
	_is_sailing = true
	_time_elapsed = 0
	_days_at_sea = 0
	for i in range(1,4):
		get_parent().set_tab_disabled(i,true)
	_voyage_progress.max_value = DISTANCES[_file.data.port][_destination]
	_embark_button.disabled = true


func _process(delta: float) -> void:
	if not _is_sailing or _file.data.is_anchored or _file.data.sail == 0:
		return
	_time_elapsed += delta
	if _time_elapsed > _days_at_sea:
		_days_at_sea += 1
		_crew.pay_out()
	_voyage_progress.value += _ship.get_speed() * _file.data.sail * delta
	if _voyage_progress.value >= _voyage_progress.max_value:
		_arrive_at_port(_destination)


func _arrive_at_port(port_id: int) -> void:
	_is_sailing = false
	_ports[_file.data.port].disabled = false
	_file.data.port = port_id
	_ports[port_id].disabled = true
	_destination = -1
	for i in range(1,4):
		get_parent().set_tab_disabled(i,false)
