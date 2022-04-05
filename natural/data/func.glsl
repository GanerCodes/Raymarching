vec4 f(vec3 p, bool is_dist) {
    float time = u_time;
    
    vec3 o = p;
    p = rot_XZ(p, angle((-vp_loc).zx));

    vec3 place = 0.2*vec3(
        cos(1.0*time),
        sin(2.0*time),
        cos(1.5*time));
    vec3 b = 0.4 * (p + 0.3 * place);
    
    vec3 offs = vec3(
        1.0 * b.x + 0.25*sin(b.x*(6.0 + 0.8*sin(time          ))),
        1.0 * b.y + 0.3*sin(b.y*(6.0 + 0.8*cos(time+sin(time)))),
        1.0 * b.z + 0.3*sin(b.z*(5.0 + 0.8*cos(time-cos(time)))));
    float k = 0.08 * length(offs);
    
    vec3 e1 = vec3( 0.06, 0.07, -0.2) - 0.2 * place;
    vec3 e2 = vec3(-0.06, 0.07, -0.2) - 0.2 * place;
    
    float eyes = 0.25 * min(
        sdf_sphere(p - e1, 0.03),
        sdf_sphere(p - e2, 0.03)
    );
    
    float s = length(b);
    
    float hat = sdf_cylinder(b + vec3(0.0, -0.053, 0.0), 0.06, 0.005);
    float hat2 = sdf_cylinder(b + vec3(0.0, -0.106, 0.0), 0.035 + 0.03 * b.y, 0.05);
    
    float c = 1.0 * min(
        0.1 * (s - 0.15 <= 0 ? (k) : s - 0.1),
        min(
            eyes,
            min(hat, hat2)
        ));
    
    if(is_dist) {
        return 0.75 * vec4(c);
    }
    
    float L = 2.0 * MIN_DIST_THRESHOLD;
    if(eyes <= L) {
        if(
            dist(p, e1 - rot_YZ(vec3(0.0, 0.0, 0.04), 0.5 * sin(atan(vp_loc.y, e1.y) - 0.9))) <= 0.02 || 
            dist(p, e2 - rot_YZ(vec3(0.0, 0.0, 0.04), 0.5 * sin(atan(vp_loc.y, e1.y) - 0.9))) <= 0.02
        ) {
            return vec4(0.0);
        }
        return vec4(0.0, 0.0, 1.0, 0.05);
    }
    if(hat <= L) {
        return vec4(0.0, 0.0, 0.5, 0.0);
    }
    if(hat2 <= L) {
        return vec4(0.4 * sum(p) + 0.2 * time, 0.4, 0.7, 0.0);
    }
    return vec4(0.2, 1.0, 0.4 + sum(0.1 * normalize(p)), 0.0);
}