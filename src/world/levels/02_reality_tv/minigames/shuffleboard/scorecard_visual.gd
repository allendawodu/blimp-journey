class_name ScorecardVisual
extends PanelContainer

@export var damping: float = 0.1

var target: Scorecard


func _ready() -> void:
	%TextureRect.modulate = target.target.color


func _process(delta: float) -> void:
	global_position = global_position.lerp(target.global_position, damping)

	match target.rank:
		1:
			%RankLabel.text = "1st"	
		2:
			%RankLabel.text = "2nd"	
		3:
			%RankLabel.text = "3rd"	
		_:
			%RankLabel.text = str(target.rank) + "th"	
