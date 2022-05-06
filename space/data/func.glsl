uniform vec3 play_loc;
uniform vec3 play_ang;

vec3 nearest_point_line(vec3 p, vec3 dir, vec3 orig) {
    return orig + dir * dot(p - orig, normalize(dir));
}
vec3 nearest_point_line(vec3 p, vec3 dir) {
    return dir * dot(p, normalize(dir));
}
vec3 angsToDir(float rot1, float rot2) {
    return rot_XZ(
        rot_XY(
            vec3(1.0, 0.0, 0.0),
            rot2),
        rot1);
}
vec3 angsToDir(vec2 rots) {
    return rot_XZ(
        rot_XY(
            vec3(1.0, 0.0, 0.0),
            rots.y),
        rots.x);
}
vec2 dirToAng(vec3 p) {
    return vec2(
        atan(p.z, p.x),
        atan(p.y, length(p.xz)));
}
vec3 rotate3d(vec3 p, vec3 rot) {
    p = rot_XZ(p, -rot.x);
    p = rot_XY(p, -rot.y);
    p = rot_YZ(p, rot.z);
    p = rot_XY(p, rot.y);
    p = rot_XZ(p, rot.x);
    return p;
}
vec3 rotStack(vec3 p, vec3 rot) {
    p = rotate3d(p, vec3(0.0, 0.0, rot.x));
    vec3 b = rotate3d(vec3(0.0, 1.0, 0.0), vec3(dirToAng(p), rot.x));
    p = rotate3d(p, vec3(dirToAng(b), rot.y));
    return p;
}
vec2 getAngle(vec3 p) {
    return vec2(atan(p.y, p.x), atan(p.z, p.x));
}

float w(float x, float y, float d) {
    return y-0.5*(
        0.5*cos(2.0*d)*sin(x+d)+0.5*pow(abs(cos(x-0.8))+0.01, 0.01+3+cos(2*d))
    );
}
float w2(vec3 p, float d) {
    return w(p.x - d, p.y, d) + w(1.1 * p.z - d, 1.05 * p.y, 0.95 * d);
}

vec3 base_color = vec3(0.0, 0.5, 0.9);
vec4 f(vec3 p, bool is_dist) {
    float time = u_time;
    
    float d = time;
    float water = w2(p, time);
    float ground = min(p.y, water);
    
    vec3 v  = rot_XZ_YZ(p - vec3(1.0, 0.4, 0.0), 0.1 + 0.13 * cos(time), sin(time) + 0.2);
    vec3 v2 = rot_XZ_YZ(p - vec3(1.0, 0.2, 1.5), 0.4 - 0.12 * sin(time), -0.3);
    vec3 v3 = rot_XZ_YZ(p - vec3(-0.6, 0.5, 1.5), 0.2 - 0.12 * cos(time), 0.3);
    float tri = sdf_cone(vec3(v.x, v.y, v.z), 0.5);
    float cub = sdf_rect(v2, vec3(0.5));
    float sph = sdf_sphere(v3, 0.4);
    
    float q = ground <= 0 ? 0 : 0.03;
    float c = min(q, min(
        tri, min(
            cub, sph)));
    
    // vec3 t = p - play_loc;
    
    // vec3 a_x = vec3(1, 0, 0);
    // vec3 a_y = vec3(0, 1, 0);
    // vec3 a_z = vec3(0, 0, 1);
    // t = rotate3d(t, vec3(dirToAng(a_x), play_ang.x));
    // t = rotate3d(t, vec3(dirToAng(a_y), play_ang.y));
    // t = rotate3d(t, vec3(dirToAng(a_z), play_ang.z));
    // float l_a_x = sdf_line(t, -a_x, a_x, 0.025);
    // float l_a_y = sdf_line(t, -a_y, a_y, 0.025);
    // float l_a_z = sdf_line(t, -a_z, a_z, 0.025);
    
    // float player = 500 + sdf_rect(t, vec3(0.5));
    // float c = min(ground, min(
    //     player,
    //     min(
    //         l_a_x,
    //         min(
    //             l_a_y,
    //             l_a_z))));
    
    if(is_dist) {
        return vec4(c);
    }
    
    float I = MIN_DIST_THRESHOLD * 2.0;
    if(c <= I) {
        if(ground <= I) {
            // return vec4(0.0, 0.0, 0.1 + 0.4 * float(cos(p.x) * sin(p.z) <= 0.0), 0.5);
            return vec4(0.5, 0.5 + 0.5 * abs(p.y), 0.5 + 0.25 * abs(p.y), 0.75);
        }
        if(tri <= I) {
            return vec4(0.0, 0.5, 0.5, 0.25);
        }
        if(cub <= I) {
            return vec4(0.3, 0.5, 0.5, 0.25);
        }
        if(sph <= I) {
            return vec4(0.7, 0.5, 0.5, 0.25);
        }
        // if(player <= I) {
        //     return vec4(length(t), 0.5, 0.75, 0.1);
        // }
        // if(l_a_x <= I) return vec4(0.00, 0.75, 0.5, 0.0);
        // if(l_a_y <= I) return vec4(0.33, 0.75, 0.5, 0.0);
        // if(l_a_z <= I) return vec4(0.66, 0.75, 0.5, 0.0);
        // return vec4(0.5 + 0.1 * sin(sum(5.0 * p)), 1.0, 1.0, 0.0);
    }
    return vec4(0.0);
}