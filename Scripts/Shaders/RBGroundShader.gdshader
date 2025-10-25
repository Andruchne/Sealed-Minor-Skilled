shader_type canvas_item;

uniform sampler2D overlay_tex_red: repeat_enable, filter_nearest;
uniform sampler2D overlay_tex_blue: repeat_enable, filter_nearest;

uniform float scale_red = 0.001; // 1/texture size (e.g., 1/144)
uniform float scale_blue = 0.012;   // 1/texture size (e.g., 1/144)

varying vec2 world_position;

void vertex(){
    // Calculate the world position for use in the fragment shader.
    world_position = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}

void fragment() {
    vec4 pos_color = texture(TEXTURE, UV);

    if (pos_color.r == 1.0) {
        vec4 overlay_color_red = texture(overlay_tex_red, world_position * scale_red);
		COLOR = mix(COLOR, overlay_color_red, overlay_color_red.a);
    }
    else if (pos_color.b == 1.0) {
        vec4 overlay_color_blue = texture(overlay_tex_blue, world_position * scale_blue);
        COLOR = mix(COLOR, overlay_color_blue, overlay_color_blue.a);
    }
}