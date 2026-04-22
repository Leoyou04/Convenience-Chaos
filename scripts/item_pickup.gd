extends Area3D

@export var item_resource: Resource

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	if not body.is_in_group("player"):
		return

	if item_resource == null:
		return

	if HotBarManager.add_item_to_first_empty(item_resource):
		queue_free()
