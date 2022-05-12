uniform vec3 play_loc;
uniform vec4 play_quat;

vec3 base_color = vec3(0.0, 0.0, 0.0);
vec4 f(vec3 p, bool is_dist) {
    float time = u_time;
    
    float ground_offset = 0.5;
    float ground = p.y + ground_offset;
    
    vec3 t = p - play_loc;
    t = quat_mul(
        quat_mul(
            play_quat,
            vec4(t, 0.0)),
        quat_conj(play_quat)
    ).xyz;
    
    vec3 noseloc = t - vec3(0, 0.8, 0);
    
    float body = sdf_rect(t, vec3(0.5, 1.0, 0.5));
    
    float player = max(
        min(body,
            sdf_sphere(noseloc, 0.9)),
        sdf_rect(t, vec3(0.5, 2.0, 0.5)));
    player *= 0.5;
    
    float c = min(ground, player);
    
    if(is_dist) {
        return vec4(c);
    }
    
    float I = MIN_DIST_THRESHOLD * 2.0;
    if(c <= I) {
        if(player <= I) {
            float q = 0.1 * smoothstep(1.0, 1.5, t.y);
            float w = max(
                0.2 * smoothstep(0.63, 0.69, length(t.xz)),
                0.2 * smoothstep(1.25, 1.28, length(vec2(t.y - 0.25, vmax(abs(t.xz)))))
            );
            
            return vec4(mix(0.1 * t.y + w, 0.5, q), 0.5, 0.75, 0.5 - 0.5 * q);
        }
    }
    if(ground <= I) {
        return vec4(0.0,0.0,0.02 + 0.1 * smoothstep(-0.05, 0.05,(sin(p.y+ground_offset)+cos(p.x)*sin(p.z))), 0.05);
    }
    return vec4(0.0);
}