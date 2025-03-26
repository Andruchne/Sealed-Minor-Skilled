shader_type canvas_item;

uniform sampler2D overlay_tex_ground: repeat_enable, filter_nearest;
uniform float scale = 0.01; // 1/texture size (e.g., 1/144)

varying vec2 world_position;

void vertex(){
    // Calculate the world position for use in the fragment shader.
    world_position = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}

void fragment() {
    vec4 pos_color = texture(TEXTURE, UV);

    if (pos_color.b == 1.0) {
		vec4 overlay_color_ground = texture(overlay_tex_ground, world_position * scale);
        COLOR = mix(COLOR, overlay_color_ground, 1.0);
	}
}