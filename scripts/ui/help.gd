extends PopupMenu

@onready var _about: PanelContainer = %About


func _on_id_pressed(id: int) -> void:
	match id:
		0: _about.show()
		2:
			if OS.get_name() == "Web":
				JavaScriptBridge.eval("window.location.href='http://www.github.com/mrhewitt'")
			else:
				OS.shell_open("http://www.github.com/mrhewitt")	
