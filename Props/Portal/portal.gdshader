shader_type spatial;
render_mode unshaded, depth_draw_always;

uniform sampler2D portal_texture : source_color;

void vertex() {
    POSITION = PROJECTION_MATRIX * MODELVIEW_MATRIX * vec4(VERTEX, 1.0);
}

void fragment() {
    ALBEDO = texture(portal_texture, SCREEN_UV).rgb;
    DEPTH = FRAGCOORD.z;
}