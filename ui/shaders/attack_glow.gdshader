shader_type canvas_item;

uniform vec4 glow_color : source_color = vec4(0.2, 1.0, 0.2, 1.0);
uniform float glow_radius = 10.0;
uniform float glow_strength = 5.0;
uniform float pulse_speed = 2.5;

const int SAMPLES = 16;

void fragment() {

    vec4 tex = texture(TEXTURE, UV);
    vec2 px = TEXTURE_PIXEL_SIZE;

    float pulse = sin(TIME * pulse_speed) * 0.5 + 0.5;

    float glow = 0.0;
    float rim = 0.0;

    for (int i = 0; i < SAMPLES; i++) {

        float angle = float(i) / float(SAMPLES) * 6.283185;
        vec2 dir = vec2(cos(angle), sin(angle));

        float inner_sample = texture(TEXTURE, UV + dir * px * 1.5).a;
        float outer_sample = texture(TEXTURE, UV + dir * px * glow_radius).a;

        rim += inner_sample;
        glow += outer_sample;
    }

    rim /= float(SAMPLES);
    glow /= float(SAMPLES);

    float rim_strength = rim * 1.5;
    float glow_strength_final = glow * glow_strength * pulse;

    vec3 glow_color_final =
        vec3(1.0) * rim_strength +
        glow_color.rgb * glow_strength_final;

    float glow_alpha = max(rim_strength, glow_strength_final);

    // Only show glow where the texture is transparent
    vec3 final_color = mix(glow_color_final, tex.rgb, tex.a);
    float final_alpha = max(tex.a, glow_alpha * (1.0 - tex.a));

    COLOR = vec4(final_color, final_alpha);
}