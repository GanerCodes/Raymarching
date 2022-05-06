void main() {
    float FOV = 130;
    float cam_dist = 100.0;
    
    float hFOV = FOV / 2.0 * tan(PI * FOV / 360.0) * 2.0;
    vec3 p_e = vec3(
        hFOV * (vertTexCoord.xy - 0.5) * (u_resolution / u_resolution.x),
        -cam_dist
    );
    
    float alpha = 1.0;
    float missing_alpha = 1.0;
    
    vec3 cast_s = vp_loc;
    vec3 cast_e = vp_loc + rot_XZ_YZ(p_e, -vp_ang.y, vp_ang.x);
    vec3 ray_step = normalize(cast_e - cast_s);
    vec3 ray = raymarch(
        cast_s,
        ray_step,
        MAX_ITTERS,
        vec2(MIN_DIST_THRESHOLD, MAX_DIST_THRESHOLD)
    );
    
    vec3 clr = vec3(0.0);
    // if(stars_bu(500.0 * (vertTexCoord.xy - vec2(
    //     50.0 + 0.001 * cos(0.25 * u_time),
    //     40.0 + 0.0008 * sin(0.23 * u_time)
    // ))).x < 0) {
    //     clr += 1.0;
    // }
    
    if(ray != vec3(-1.0)) {
        vec3 lightRay = ray;
        
        vec4 dat = f(
            ray + MIN_DIST_THRESHOLD * ray_step,
            false
        );
        
        float car = dat.w;
        int i = 0;
        while(dat.w > 0.01 && i < 5) {
            i++;
            vec3 n = norm(ray, 0.00001);
            n = reflect_norm(ray_step, n);
            ray = raymarch(
                ray.xyz + 2.0 * MIN_DIST_THRESHOLD * n,
                n,
                MAX_ITTERS,
                vec2(MIN_DIST_THRESHOLD, MAX_DIST_THRESHOLD)
            );
            if(ray != vec3(-1.0)) {
                vec4 new = f(ray + MIN_DIST_THRESHOLD * ray_step, false);
                
                // this is not optimal
                car *= new.w;
                dat = vec4(
                    rgb2hsv(
                        mix(
                            hsv2rgb(dat.xyz),
                            hsv2rgb(new.xyz),
                            dat.w
                        )
                    ),
                    car
                );
                ray_step = normalize(n);
            }else{
                break;
            }
        }
        
        float len = dist(lightRay, cast_s);
        vec3 lightSource = vec3(15.0, 20.0, -10.0);
        vec3 lightStep = normalize(lightRay - lightSource);
        vec3 lightLoc = raymarch(
            lightSource,
            lightStep,
            MAX_ITTERS,
            vec2(MIN_DIST_THRESHOLD, 1.25 * MAX_DIST_THRESHOLD)
        );
        
        clr = hsv2rgb(dat.xyz) * max(0.35, 1.0 - max(0.0, dist(lightRay, cast_s) / 20.0 - 0.5));
            
        float d1 = dist(lightLoc, lightRay);
        if(lightLoc != vec3(-1.0) && d1 <= 1.0) {
            clr *= max(0.65, clamp(0.9 * (1 / 1.25) * max(0.0, 1.25 - 3.0 * d1), 0.0, 1.0));
        }else{
            clr *= 0.65;
        }
    }else{
        clr *= dist(vec3(50.0, 25.0, 0.0), vec3(cast_s)) * 0.016;
        alpha = missing_alpha;
    }
    
    gl_FragColor = vec4(clr, alpha);
}