shader_type canvas_item;

uniform float time_scale : hint_range(0.1, 5.0) = 1.5;
uniform float distortion_strength : hint_range(0.0, 10.0) = 2.0;
uniform float flicker_speed : hint_range(0.1, 5.0) = 2.0;
uniform float flicker_intensity : hint_range(0.0, 1.0) = 0.5;

void fragment() {
    vec2 uv = UV;
    
    // Time-based distortion using sine waves for a wavy effect
    //float distortion = sin(uv.y * 10.0 + TIME * time_scale) * 0.05;
    //distortion += sin(uv.y * 20.0 + TIME * (time_scale * 0.8)) * 0.03;
    //uv.x += distortion * distortion_strength;
    
    // Flickering effect using noise-like variation
    float flicker = sin(TIME * flicker_speed + sin(TIME * 0.8)) * flicker_intensity;
    vec4 tex_color = texture(TEXTURE, uv);
    
    // Softening edges using smoothstep for better blending
    //float edge_factor = smoothstep(0.2, 0.8, tex_color.a);
    //tex_color.a *= edge_factor;
    
    // Preserve modulate color without darkening
    vec3 modulate_color = COLOR.rgb / max(dot(COLOR.rgb, vec3(0.333)), 0.001); // Normalize brightness
    tex_color.rgb = tex_color.rgb * modulate_color;
    
    // Modifying alpha for a more organic, flame-like fade
    tex_color.a *= 1.0 + flicker;
    
    COLOR = tex_color;
}