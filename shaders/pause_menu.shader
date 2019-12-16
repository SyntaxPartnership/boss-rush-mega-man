shader_type canvas_item;

uniform vec4 black : hint_color;

uniform vec4 t_col1 : hint_color;
uniform vec4 t_col2 : hint_color;
uniform vec4 t_col3 : hint_color;
uniform vec4 t_col4 : hint_color;

uniform vec4 r_col1 : hint_color;
uniform vec4 r_col2 : hint_color;
uniform vec4 r_col3 : hint_color;
uniform vec4 r_col4 : hint_color;

void fragment() {
	vec4 color = texture(TEXTURE, UV);
	
//	Set black color
	if (color == black) COLOR = black;
	
//	Set other colors
	if (color == t_col1) COLOR = r_col1;
	else if (color == t_col2) COLOR = r_col2;
	else if (color == t_col3) COLOR = r_col3;
	else if (color == t_col4) COLOR = r_col4;
}