vec4 f(vec3 p, bool is_dist) {
    float time = u_time;
    
    float ground = p.y + 0.2;
    
    vec3 ploc = p - vec3(0, 1.5, 0);
    
    ploc = rot_YZ(ploc, 0.05 * cos(time));
    ploc = rot_XZ(ploc, 0.05 * sin(time));
    
    ploc = rot_XZ(ploc, time);
    ploc.y += 0.1 * sin(time);
    
    float base = sdf_cylinder(ploc, 1.0, 0.03);
    float ring = min(max(
          sdf_cylinder(ploc - vec3(0,0.03,0), 1.02, 0.04) - 0.015,
        -(sdf_cylinder(ploc - vec3(0,0.03,0), 0.97, 0.04) - 0.02)
    ), sdf_cylinder(ploc + vec3(0,0.02,0), 1.01, 0.02));
    
    float ttop = sdf_rect(p - vec3(0, 1.2, 0), vec3(1.0, 0.1, 1.0));
    float ttopout = 0.5 * (max(
        sdf_rect(p - vec3(0, 1.2, 0), vec3(1.1, 0.05, 1.1)),
        -ttop
    ) - 0.03);
    float legs = sdf_line(vec3(abs(p.x), p.y, abs(p.z)),
        vec3(1.05, 1.2, 1.05),
        vec3(1.3, -0.2, 1.3),
        0.1);
    
    float table = min(ttop, min(ttopout, legs));
    
    float c = min(min(ground, table), min(
        base, ring
    ));
    
    
    if(is_dist) {
        return vec4(c);
    }
    
    float I = MIN_DIST_THRESHOLD * 2.0;
    if(c <= I) {
        if(ground <= I) {
            return vec4(0.0, 0.0, 0.1 + 0.4 * float(cos(2.5 * p.x) * sin(2.5 * p.z) <= 0.0), 0.0);
        }
        if(table <= I) {
            if(ttop <= I) {
                return vec4(0.65, 0.3, 0.8, 0.5);
            }
            return vec4(0.1, 0.3, 0.3, 0.0);
        }
        if(base <= I) {
            float v = 0;
            float q = 8.5;
            vec2 r = vec2(rand(q), rand(-q));
            int i = 0;
            while(i < 25) {
                r = 1.2 * (vec2(rand(r.x), rand(r.y)) - 0.5);
                vec2 l = ptc(1.2 * sqrt(abs(r.y)), TWO_PI * r.x + 0.2);
                v = min(v, length(ploc.xz - l) - 0.1);
                if(v < 0) break;
                i++;
            }
            
            return vec4(v < 0.0 ? 0.0 : 0.09, 0.7, mod(8.0 * atan(p.z, p.x) / TWO_PI, 1.0) <= 0.03 ? 0.0 : 0.5, 0.01);
        }
        if(ring <= I) {
            return vec4(0.13, 0.5, 0.5, 0.01);
        }
    }
    return vec4(0.0);
}