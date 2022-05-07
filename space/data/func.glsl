uniform vec3 play_loc;
uniform vec3 play_ang;

uniform vec3 test;

vec3 rotStack(vec3 p, vec3 rot) {
    p = rotateAxis(p, vec3(0.0, 0.0, rot.x));
    vec3 b = rotateAxis(vec3(0.0, 1.0, 0.0), vec3(dirToAng(p), rot.x));
    p = rotateAxis(p, vec3(dirToAng(b), rot.y));
    return p;
}

vec3 base_color = vec3(0.0, 0.0, 0.0);
vec4 f(vec3 p, bool is_dist) {
    float time = u_time;
    
    float ground_offset = 3.25;
    float ground = p.y + ground_offset;
    
    float sph = min(
        sdf_sphere(p, 1.0),
        sdf_sphere(p - test, 0.2));
    vec3 l = angsToDir(play_ang.xy);
    
    vec3 t = p;
    t = rot_XZ(t, play_ang.x);
    t = rot_XY(t, play_ang.y);
    vec3 j = rot_YZ(t, play_ang.z);
    float lin = min(
        sdf_line(j, -vec3(2.0, 0.0, 0.0), vec3(2.0, 0.0, 0.0), 0.05),
        sdf_line(j, -vec3(0.0, 1.5, 0.0), vec3(0.0, 1.5, 0.0), 0.05)
    );
    t -= vec3(1.0, 0.0, 0.0);
    t = rot_YZ(t, play_ang.z);
    float cb = sdf_rect(t, vec3(0.02, 0.3, 0.3));
    
    float[] cs = {
        ground,
        sph,
        lin,
        cb
    };
    
    float c = min(cs[0], cs[1]);
    for(int i = 2; i < cs.length(); i++) {
        c = min(c, cs[i]);
    }
    
    if(is_dist) {
        return vec4(c);
    }
    
    float I = MIN_DIST_THRESHOLD * 2.0;
    if(c <= I) {
        if(ground <= I) return vec4(0.0, 0.0, 0.02 + 0.1 * float(sin(p.y + ground_offset) + cos(p.x) * sin(p.z) <= 0.0), 0.05);
        if(sph <= I) return vec4(0.0, 0.0, 0.35, 0.1);
        if(lin <= I) return vec4(0.5, 0.75, 0.75, 0.05);
    }
    return vec4(1.0, 1.0, 1.0, 0.0);
}