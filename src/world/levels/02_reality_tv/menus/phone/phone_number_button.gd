class_name PhoneNumberButton
extends Panel

signal pressed(value: String)

static var letters: Array[String] = [
	"",
	"ABC",
	"DEF",
	"GHI",
	"JKL",
	"MNO",
	"PQRS",
	"TUV",
	"WXYZ",
	"TONE",
	"OPER",
	"",
]

var index: int:
	set(value):
		%LettersLabel.text = letters[value]
		match value:
			9:
				%NumberLabel.text = "*"
			10:
				%NumberLabel.text = "0"
			11:
				%NumberLabel.text = "#"
			_:
				%NumberLabel.text = str(value + 1)


func _ready() -> void:
	%Button.pressed.connect(pressed.emit.bind(%NumberLabel.text))
