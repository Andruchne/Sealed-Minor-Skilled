shader_type canvas_item;

uniform sampler2D overlay_tex_ground: repeat_enable, filter_nearest;
uniform sampler2D overlay_tex_water_ground: repeat_enable, filter_nearest;
uniform sampler2D overlay_tex_water: repeat_enable, filter_nearest;

uniform float scale_ground = 0.001; // 1/texture size (e.g., 1/144)
uniform float scale_water = 0.012;   // 1/texture size (e.g., 1/144)

uniform float water_opacity = 0.55;
uniform float distortion_strength = 0.01; // Adjust for more or less visible distortion
uniform float distortion_frequency = 0.1;   // Controls the wave frequency
uniform float time_speed = 1.5;             // Speed multiplier for the time animation

varying vec2 world_position;

void vertex(){
    // Calculate the world position for use in the fragment shader.
    world_position = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}

void fragment() {
    vec4 pos_color = texture(TEXTURE, UV);

    if (pos_color.r == 1.0) {
        // Regular ground overlay without distortion.
        vec4 overlay_color_ground = texture(overlay_tex_ground, world_position * scale_ground);
        COLOR = mix(COLOR, overlay_color_ground, 1.0);
    }
    else if (pos_color.b == 1.0) {
        // Apply time-based distortion to mimic a moving watery effect.
        vec2 distorted_uv = world_position * scale_water;
        // Animate the distortion using sine and cosine functions with TIME.
        vec2 distortion = vec2(sin(world_position.y * distortion_frequency + TIME * time_speed),
                               cos(world_position.x * distortion_frequency + TIME * time_speed));
        distorted_uv += distortion * distortion_strength;
        
        vec4 overlay_color_water_ground = texture(overlay_tex_water_ground, distorted_uv);
        // Replace the ground color with the dynamically distorted version.
        COLOR = mix(COLOR, overlay_color_water_ground, 1.0);

        vec4 overlay_color_water = texture(overlay_tex_water, world_position * scale_water);
        // Blend in the water overlay with the specified opacity.
        COLOR = mix(COLOR, overlay_color_water, water_opacity);
    }
}