shader_type canvas_item;

uniform float speed_x;
uniform float speed_y;

void vertex() {
	UV.x += TIME * speed_x;
	UV.y += TIME * speed_y;
}