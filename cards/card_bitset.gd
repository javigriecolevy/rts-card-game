extends RefCounted
class_name CardBitset

var bitset: PackedInt64Array = PackedInt64Array()

func set_bit(index: int) -> void:
	_ensure_capacity(index)
	@warning_ignore("integer_division")
	var int_index = index / 64
	var bit_offset = index % 64
	bitset[int_index] |= 1 << bit_offset

func _ensure_capacity(index: int) -> void:
	@warning_ignore("integer_division")   # Cant get rid of warning 
	var int_index: int = int(index / 64)  # even when casting to int ???
	while bitset.size() <= int_index:     # TODO: try floor or something
		bitset.append(0)

func to_indices() -> Array:
	var indices: Array = []
	for int_index in range(bitset.size()):
		var value: int = bitset[int_index]
		var base: int = int_index * 64
		for bit in range(64):
			if (value & (1 << bit)) != 0:
				indices.append(base + bit)
	return indices
	
func _and(other: CardBitset) -> CardBitset:
	var result = CardBitset.new()
	result.bitset.resize(max(bitset.size(), other.bitset.size()))
	
	for i in range(result.bitset.size()):
		var a = 0
		if i < bitset.size():
			a = bitset[i]
		
		var b = 0
		if i < other.bitset.size():
			b = other.bitset[i]
		result.bitset[i] = a & b
	
	return result

func get_size() -> int:
	return bitset.size() * 64
