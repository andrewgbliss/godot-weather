shader_type canvas_item;

void fragment() {
	vec4 t = texture(TEXTURE, UV);
	t.a -= t.r;
	COLOR = t;
}