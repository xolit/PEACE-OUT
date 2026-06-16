shader_type canvas_item;

uniform float fade_start : hint_range(0.0, 1.0) = 0.6;
uniform float fade_end : hint_range(0.0, 1.0) = 1.0;

void fragment() {
	// UV.x goes from:
	// 0.0 = left
	// 1.0 = right

	float alpha = smoothstep(fade_start, fade_end, UV.x);

	// Left = black
	// Right = transparent
	COLOR = vec4(0.0, 0.0, 0.0, 1.0 - alpha);
}