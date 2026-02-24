extends RefCounted
class_name GameCommand

var tick: int

func _init(_tick: int = -1) -> void:
	tick = _tick
	
func serialize() -> Dictionary:
	var data: Dictionary = {}
	for prop in get_property_list():
		if prop.name != "script":
			data[prop.name] = get(prop.name)
	return {
		"type": get_script().resource_path,
		"data": data
	}

func deserialize(payload: Dictionary) -> void:
	var data: Dictionary = payload["data"]
	for key in data.keys():
		if key in self:
			set(key, data[key])
