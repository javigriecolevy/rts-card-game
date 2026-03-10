extends Resource
class_name TargetFilter

# -------------------------------
# Override hooks in subclasses to define filter type
func passes(entity: Entity) -> bool:
	return true
