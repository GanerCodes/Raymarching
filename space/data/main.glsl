void main() {
    float FOV = 125;
    float cam_dist = 100.0;
    
    float hFOV = FOV * tan(PI * FOV / 360.0);
    vec3 p_e = vec3(
        hFOV * (vertTexCoord.xy - 0.5) * (u_resolution / u_resolution.x),
        -cam_dist
    );
    
    vec3 cast_s = vp_loc;
    vec3 cast_e = vp_loc + rot_XZ_YZ(p_e, -vp_ang.y, vp_ang.x);
    Tracer inital_tracer = raymarch(make_tracer(cast_s, normalize(cast_e - cast_s), aether));
    vec3 clr = inital_tracer.mat.tot.color;
    
    
    
    gl_FragColor = vec4(clr, 1.0);
}