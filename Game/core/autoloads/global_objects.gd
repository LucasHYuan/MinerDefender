extends Node

var _objects = {}

func SetObject(key: String, obj: Object) -> void:
	_objects[key] = obj

func GetObject(key: String) -> Object:
	return _objects[key]

func GetObjectOrNull(key: String) -> Object:
	return _objects.get(key, null)

func HasObject(key: String) -> bool:
	return _objects.has(key)
