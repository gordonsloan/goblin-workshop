shader_type canvas_item;

uniform vec4 dark_square_color : source_color = vec4(0.035, 0.045, 0.060, 1.0);
uniform vec4 light_square_color : source_color = vec4(0.070, 0.090, 0.115, 1.0);
uniform vec4 tint_color : source_color = vec4(0.100, 0.450, 0.700, 1.0);
uniform float tint_strength : hint_range(0.0, 1.0, 0.01) = 0.12;
uniform float tile_size : hint_range(16.0, 256.0, 1.0) = 72.0;
uniform float scroll_speed : hint_range(0.0, 256.0, 1.0) = 18.0;
uniform vec2 scroll_direction = vec2(1.0, 0.25);
uniform float vignette_strength : hint_range(0.0, 1.0, 0.01) = 0.35;
uniform vec2 base_size = vec2(1280.0, 720.0);

void fragment() {
	vec2 direction = normalize(scroll_direction);
	vec2 screen_size = 1.0 / SCREEN_PIXEL_SIZE;
	vec2 safe_base_size = max(base_size, vec2(1.0));
	float canvas_scale = max(min(screen_size.x / safe_base_size.x, screen_size.y / safe_base_size.y), 0.001);
	vec2 design_position = FRAGCOORD.xy / canvas_scale;
	vec2 moving_position = design_position + direction * TIME * scroll_speed;
	vec2 board_position = floor(moving_position / tile_size);
	float checker = mod(board_position.x + board_position.y, 2.0);

	vec4 square_color = mix(dark_square_color, light_square_color, checker);
	square_color.rgb = mix(square_color.rgb, tint_color.rgb, tint_strength);

	vec2 centered_uv = UV * 2.0 - 1.0;
	float edge_fade = smoothstep(1.25, 0.25, length(centered_uv));
	square_color.rgb *= mix(1.0 - vignette_strength, 1.0, edge_fade);

	COLOR = square_color;
}
