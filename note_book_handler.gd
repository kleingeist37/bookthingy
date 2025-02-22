class_name NoteBookHandler extends Control

@export var max_lines := 25;
@export var max_chars_per_line := 50;

@onready var text_edit: TextEdit = %text_edit;
@onready var rtl_left: RichTextLabel = %rtl_left;
@onready var rtl_right: RichTextLabel = %rtl_right;
@onready var file_dialog: FileDialog = %file_dialog;

var is_save_mode := false;
var example_text := "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet."



func _input(event: InputEvent) -> void:
	if Input.is_key_pressed(KEY_ALT):
		
		if Input.is_key_pressed(KEY_1): #ALT + 1
			text_edit.text = example_text;
			text_edit.text_changed.emit();
			
		if Input.is_key_pressed(KEY_2): #ALT + 2
			text_edit.text += example_text;
			text_edit.text_changed.emit();


func calculate_labels() -> void:
	var words := text_edit.text.split(" ");
	
	var left_lines := 0;
	var right_lines := 0;
	var current_line := "";
	var use_right := false;
	var left_text := "";
	var right_text := "";

	for word in words:
		# check if current word fits to current line.
		if len(current_line) + len(word) + 1 <= max_chars_per_line:
			current_line += word + " ";
		else:
			# start new line
			if use_right:
				right_text += current_line.strip_edges() + "\n";
				right_lines += 1;
			else:
				left_text += current_line.strip_edges() + "\n";
				left_lines += 1;
			
			current_line = word + " ";

		# check if max_lines reached, if yes use the next label
		if !use_right && left_lines >= max_lines:
			use_right = true;

	# add overflow to right text;
	# if you want to set a new page, you'll need add the content to an array wich holds the TextResources, or something like this. 
	if current_line.strip_edges():
		if use_right:
			right_text += current_line.strip_edges();
		else:
			left_text += current_line.strip_edges();

	rtl_left.text = left_text;
	rtl_right.text = right_text;


#region EventListener
func _on_btn_load_pressed() -> void:
	is_save_mode = false;
	_config_file_mode();
	file_dialog.show();

func _on_btn_save_pressed() -> void:
	is_save_mode = true;
	_config_file_mode();
	file_dialog.show();

func _on_text_edit_text_changed() -> void:
	calculate_labels();

func _on_file_dialog_file_selected(path: String) -> void:
	var text_resource :TextResource;
	if is_save_mode:
		text_resource = TextResource.new();
		text_resource.content = text_edit.text;
		ResourceSaver.save(text_resource, path);
	else:
		text_resource = ResourceLoader.load(path) as TextResource;
		text_edit.text = text_resource.content;
		calculate_labels();

#endregion


#region helper
func _config_file_mode() -> void:
	file_dialog.access = FileDialog.ACCESS_RESOURCES;
	file_dialog.filters = ["*.tres"];
	file_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE \
								if is_save_mode \
								else FileDialog.FILE_MODE_OPEN_FILE;

#endregion
