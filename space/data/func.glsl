Tracer scene(Tracer tracer, bool no_mat) {
    vec3 p = tracer.cur_pos;
    
    float ground = p.y;
    // float cube = sdf_sphere(p - vec3(2.0, 1.0, 2.0), vec3(1.0));
    float shape1 = sdf_sphere(p - vec3(2.0, 5.0, 2.0), 1.0);
    float shape2 = sdf_rect(p - vec3(-2.0, 5.0, 2.0), vec3(1.0));
    
    tracer.dist = min(ground, min(shape1, shape2));
    if(no_mat) return tracer;
    
    // Not within any object, use default material
    if(tracer.dist > MCR) {
        tracer.mat.cur = tracer.mat.def;
        return tracer;
    }
    
    if(ground <= MCR) {
        // tracer.mat.cur = Material(0.25 * vec3(cos(p.x)*sin(p.z) <= 0), 0.5, BIT_RFLCT);
        tracer.mat.cur = Solid(mod(0.5 + 0.1 * p.x, 1.0), 0.5, 0.0);
    }else if(min(shape1, shape2) <= MCR) {
        tracer.mat.cur = Solid(0.0, 1.0, 0.0);
    }
    
    return tracer;
}


/* uniform vec3 play_loc;
uniform vec4 play_quat;

vec3 base_color = vec3(0.0, 0.0, 0.0);
vec4 scene(vec3 p, bool is_dist) {
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
    
    float skybox = -sdf_sphere(p, 500.0);
    
    float player = max(
        min(body,
            sdf_sphere(noseloc, 0.9)),
        sdf_rect(t, vec3(0.5, 2.0, 0.5)));
    player *= 0.5;
    
    vec3 monitor_loc = p + vec3(0.0, 0.0, 6.0);
    float[] objects = {
        ground,
        player,
        object_keyboard(p, true).x,
        object_monitor(monitor_loc, true).x,
        skybox
    };
    
    float c = min(objects[0], objects[1]);
    for(int i = 2; i < objects.length(); i++) {
        c = min(c, objects[i]);
    }
    
    if(is_dist) return vec4(c);
    
    if(c <= MCR) {
        // if(objects[4] <= MCR) {
            // return vec4(mix(-0.2, 0.1, 0.5 + 0.5 * sin(mod(0.5 * time + tan(0.001 * sum(p)), TWO_PI))), 0.75, 0.8, 0.0);
        // }
        if(player <= MCR) {
            float q = 0.1 * smoothstep(1.0, 1.5, t.y);
            float w = max(
                0.2 * smoothstep(0.63, 0.69, length(t.xz)),
                0.2 * smoothstep(1.25, 1.28, length(vec2(t.y - 0.25, vmax(abs(t.xz)))))
            );
            
            return vec4(mix(0.1 * t.y + w, 0.5, q), 0.5, 0.75, 0.5 - 0.5 * q);
        }
        if(objects[2] <= MCR) {
            return object_keyboard(p, false);
        }
        if(objects[3] <= MCR) {
            return object_monitor(monitor_loc, false);
        }
    }
    if(ground <= MCR) {
        return vec4(0.0,0.0,0.02 + 0.1 * smoothstep(-0.05, 0.05,(sin(p.y+ground_offset)+cos(p.x)*sin(p.z))), 0.05);
    }
    return vec4(0.0);
} */