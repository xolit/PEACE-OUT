extends Control

@export var progress_bar: ProgressBar 

@onready var sub_text: Label = $ColorRect/Control/sub_text
@onready var sub_text_2: Label = $ColorRect/Control/sub_text2
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var sub_texts: Array[String] = [
	"Don’t stop running.",
	"It hears every step.",
	"You are not alone here.",
	"Some exits should stay hidden.",
	"If you see it… run.",
	"The maze remembers you.",
	"Every corridor looks the same.",
	"Something is following.",
	"You were never meant to escape.",
	"Keep moving. Don’t look back.",
	"Reality has glitched.",
	"Level loading… stay alive.",
	"No signal. No help.",
	"The walls are breathing.",
	"Lost between dimensions.",
	"The deeper you go, the darker it gets.",
	"There is no safe room.",
	"This place was not built for humans."
]

var progress := 0.0

func _ready() -> void:
	var ui_nodes = get_tree().get_nodes_in_group("ui")
	if ui_nodes.size() > 0:
		var canvas = ui_nodes[0]
		if canvas is CanvasLayer or canvas is Control:
			canvas.hide()
	else:
		push_warning("No CanvasLayer found in group 'ui'")
	giv_new_sub_text()

func set_progress(value: float):
	progress = clamp(value, 0.0, 100.0)
	progress_bar.value = progress * 100.0


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "giving_new_sub_text":
		giv_new_sub_text()

# =========================
# RANDOM SUBTEXT
# =========================
func giv_new_sub_text() -> void:

	if sub_texts.size() < 2:
		return

	var first_text = sub_texts.pick_random()

	var second_text = sub_texts.pick_random()

	# Prevent duplicates
	while second_text == first_text:
		second_text = sub_texts.pick_random()

	sub_text.text = first_text
	sub_text_2.text = second_text
	animation_player.play("giving_new_sub_text")
