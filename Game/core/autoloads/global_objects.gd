extends Node

var _objects = {}

func SetObject(key: String, obj: Object) -> void:
  _objects[key] = obj

func GetObject(key: String) -> Object:
  return _objects[key]
