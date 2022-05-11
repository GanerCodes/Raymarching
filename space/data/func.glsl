uniform vec3 play_loc;
uniform vec3 play_ang;

uniform vec4 quat;

vec3 base_color = vec3(0.0, 0.0, 0.0);
vec4 f(vec3 p, bool is_dist) {
    float time = u_time;
    
    float ground_offset = 3.25;
    float ground = p.y + ground_offset;
    
    vec3 t = p;
    // t = quat_rot(vec4(t, 0.0), quat, HALF_PI).xyz;
    t = rot_XY(t, -play_ang.z);
    t = rot_XZ(t, -play_ang.y);
    t = rot_YZ(t, -play_ang.x);
    float funnycube = 0.8 * sdf_rect(t, vec3(1.0));
    
    float c = min(ground, funnycube);
    
    if(is_dist) {
        return vec4(c);
    }
    
    float I = MIN_DIST_THRESHOLD * 2.0;
    if(c <= I) {
        if(ground <= I) return vec4(0.0, 0.0, 0.02 + 0.1 * float(sin(p.y + ground_offset) + cos(p.x) * sin(p.z) <= 0.0), 0.05);
        if(funnycube <= I) return vec4(0.5, 0.4, 0.5, 0.2);
    }
    return vec4(1.0, 1.0, 1.0, 0.0);
}