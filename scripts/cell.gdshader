shader_type canvas_item;

uniform float pulse_speed : hint_range(0.1, 10) = 1.5;
uniform float pulse_strength : hint_range(0.0, 1.0) = 0.12;
uniform float membrane_noise_scale : hint_range(1.0, 10.0) = 4.0;
uniform float membrane_distort : hint_range(0.0, 0.2) = 0.08;

uniform vec4 base_color : source_color = vec4(0.2, 0.8, 1.0, 1.0);
uniform float alpha_min : hint_range(0.0, 1.0) = 0.25;
uniform float alpha_max : hint_range(0.0, 1.0) = 1.0;

float noise(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453123);
}

float smooth_noise(vec2 uv) {
    vec2 i = floor(uv);
    vec2 f = fract(uv);
    float a = noise(i);
    float b = noise(i + vec2(1.0, 0.0));
    float c = noise(i + vec2(0.0, 1.0));
    float d = noise(i + vec2(1.0, 1.0));
    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
}

void fragment() {
    vec2 uv = UV * membrane_noise_scale;

    // Oscillation globale (pulsation)
    float t = TIME * pulse_speed;
    float pulse = sin(t) * pulse_strength;

    // Distorsion de membrane
    float n = smooth_noise(uv + vec2(sin(t), cos(t)) * 0.5);
    float distortion = (n - 0.5) * membrane_distort;

    // Application de la distorsion
    vec2 distorted_uv = UV + distortion;

    // Couleur finale
    vec4 color = texture(TEXTURE, UV);
	color = mix(color, base_color, color.a);

    // Transparence dynamique
    float alpha_wave = mix(alpha_min, alpha_max, 0.5 + 0.5 * sin(t + n * 3.14));
    color.a *= alpha_wave;

    // Dessin final
    COLOR = color;
}