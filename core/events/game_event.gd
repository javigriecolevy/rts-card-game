extends RefCounted
class_name GameEvent

var tick: int
var sequence_id: int
var cancelled: bool = false

# -------------------------
# Puts every field into payload
func serialize() -> Dictionary:
	var data: Dictionary = {}
	for prop in get_property_list():
		if prop.name != "script":
			data[prop.name] = get(prop.name)
	
	return {
		"type": get_script().resource_path,
		"data": data
	}

# -------------------------
# Sets all fields from payload
func deserialize(payload: Dictionary) -> void:
	print("Deserializing script path: ", payload["type"])
	var data: Dictionary = payload["data"]
	for key in data.keys():
		if key in self && data[key]:	#only assign if property exists and data not null
			#print("key: %s, data: %s" % [key, data[key]])
			set(key, data[key])

## Usage:
## sender
#var payload = event.serialize()
#rpc("receive_event", payload)
## receiver
#func receive_event(data: Dictionary):
	#var script: Script = load(data["type"])
	#var event: GameEvent = script.new()
	#event.deserialize(data)
