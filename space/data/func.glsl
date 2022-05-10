uniform vec3 play_loc;
uniform vec3 play_ang;

uniform vec3 what1, what2, what3, what4;

vec3 base_color = vec3(0.0, 0.0, 0.0);
vec4 f(vec3 p, bool is_dist) {
    float time = u_time;
    
    float ground_offset = 3.25;
    float ground = p.y + ground_offset;
    
    vec3 t = p;
    t = rot_YZ(t, play_ang.x);
    t = rot_XZ(t, play_ang.y);
    t = rot_XY(t, play_ang.z);
    float funnycube = 0.8 * sdf_rect(t, vec3(1.0));
    float[] cs = {
        ground,
        funnycube
    };
    
    float c = min(cs[0], cs[1]);
    // for(int i = 2; i < cs.length(); i++) {
    //     c = min(c, cs[i]);
    // }
    
    if(is_dist) {
        return vec4(c);
    }
    
    float I = MIN_DIST_THRESHOLD * 2.0;
    if(c <= I) {
        if(ground <= I) return vec4(0.0, 0.0, 0.02 + 0.1 * float(sin(p.y + ground_offset) + cos(p.x) * sin(p.z) <= 0.0), 0.05);
        if(funnycube <= I) return vec4(0.5, 0.4, 0.5, 0.2);
        // if(whatsphere1 <= I) return vec4(0.4, 0.5, 0.5, 0.0);
        // if(whatsphere2 <= I) return vec4(0.7, 0.5, 0.5, 0.0);
        // if(lins2 <= I) return vec4(0.5, 0.5, 0.5, 0.0);
    }
    return vec4(1.0, 1.0, 1.0, 0.0);
}