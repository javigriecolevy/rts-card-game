# core/entities/entity.gd
extends RefCounted
class_name Entity

var id: int
var owner_id: int
var health: int
var max_health: int
var display_name: String
