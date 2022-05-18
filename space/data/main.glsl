void main() {
    float FOV = 125;
    float cam_dist = 100.0;
    
    float hFOV = FOV * tan(PI * FOV / 360.0);
    vec3 p_e = vec3(
        hFOV * (vertTexCoord.xy - 0.5) * (u_resolution / u_resolution.x),
        -cam_dist);
    
    vec3 p_cast_s = vp_loc;
    vec3 p_cast_e = vp_loc + rot_XZ_YZ(p_e, -vp_ang.y, vp_ang.x);
    Tracer inital_tracer = raymarch(make_tracer(
        p_cast_s,
        normalize(p_cast_e - p_cast_s),
        aether));
    vec3 clr = inital_tracer.mat.tot.color;
    
    if(inital_tracer.mat.tot.state == 1) {
        // Tracer intersected a surface, mark it
        vec3 l_cast_s = mix(
            inital_tracer.cur_pos,
            rot_XZ(vec3(5.0, 40.0, 5.0), u_time),
            0.5);
        vec3 l_cast_e = inital_tracer.cur_pos;
        Tracer light_tracer = raymarch(make_tracer(
            l_cast_s,
            normalize(l_cast_e - l_cast_s),
            Material(vec3(0.0), 0.0, BIT_DEBUG)));
        
        if(light_tracer.mat.tot.state == 1) {
            float d = dist(light_tracer.cur_pos, l_cast_e);
            
            float t = 0.1 * d;
            clr *= 1.0 - min(0.5, t);
        }else{
            clr *= 0.5;
        }
    }
    
    gl_FragColor = vec4(clr, 1.0);
}