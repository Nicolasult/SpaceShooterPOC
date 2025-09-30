extends Resource
class_name ShipInfo

@export var id: StringName           # ex: &"starter", &"falcon"
@export var title: String = ""
@export var scene: PackedScene       # scène Player pour ce vaisseau
@export var cost: int = 0            # coût en pièces
@export var thumbnail: Texture2D
@export_multiline var description: String = ""
