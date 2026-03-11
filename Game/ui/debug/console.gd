extends CanvasLayer

@onready var log_view: RichTextLabel = $Root/LogView
@onready var command_input: LineEdit = $Root/CommandInput

var is_open: bool = false


func _ready() -> void:
	visible = false
	command_input.text_submitted.connect(_on_command_submitted)
	_refresh_log_view()


func _process(_delta: float) -> void:
	# Toggle console with F1 (or configure an input action later).
	if Input.is_action_just_pressed("ui_f1"):
		_toggle()


func _toggle() -> void:
	is_open = !is_open
	visible = is_open
	if is_open:
		_refresh_log_view()
		command_input.grab_focus()


func _on_command_submitted(text: String) -> void:
	if text.strip_edges() == "":
		return
	CommandRouter.execute(text)
	command_input.clear()
	_refresh_log_view()


func _refresh_log_view() -> void:
	log_view.clear()
	for entry in AppLogger.get_recent_logs():
		log_view.append_text(str(entry) + "\\n")

