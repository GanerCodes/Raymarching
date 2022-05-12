uniform vec3 play_loc;
uniform vec3 play_ang;

uniform vec4 quat;

vec3 base_color = vec3(0.0, 0.0, 0.0);
vec4 f(vec3 p, bool is_dist) {
    float time = u_time;
    
    float ground_offset = 3.25;
    float ground = p.y + ground_offset;
    
    vec3 t = p;
    t = quat_mul(
        quat_mul(
            quat,
            vec4(t, 0.0)),
        quat_conj(quat)
    ).xyz;
    
    float player = 0.8 * sdf_rect(t, vec3(0.5, 1.0, 0.5));
    
    float c = min(ground, player);
    
    if(is_dist) {
        return vec4(c);
    }
    
    float I = MIN_DIST_THRESHOLD * 2.0;
    if(c <= I) {
        if(ground <= I) return vec4(0.0, 0.0, 0.02 + 0.1 * smoothstep(
            -0.05, 0.05,
            (sin(p.y+ground_offset)+cos(p.x)*sin(p.z))
        ), 0.05);
        if(player <= I) return vec4(2.0 * max(0, max(0.5, t.y) - 0.5), 0.4, 0.35, 0.1);
    }
    return vec4(0.0);
}