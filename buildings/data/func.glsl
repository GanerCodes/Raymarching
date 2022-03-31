vec4 f(vec3 p, bool is_dist) {
    float time = u_time;

    float base = p.y;
    
    float v = 2.5;
    vec2 l_ = modloop(p.xz, v);
    vec2 n = floor((p.xz + 0.5 * v) / v);
    vec3 l = vec3(l_.x, p.y, l_.y);
    
    float r = rand(n);
    float buildType = floor(2.0 * r);
    
    float buildingWidth = 0.5;
    float windowScale = 4.0;
    float windowSize = windowScale / buildingWidth;
    float win = 1.0 / windowScale;
    float buildingHeight = 2 * win * round(3 + r / win);
    float buildings = sdf_rect(
        l - vec3(0.0, 0.5 * buildingHeight, 0.0),
        vec3(buildingWidth, buildingHeight, buildingWidth)
    ) * 0.5;
    
    float awy = modloop(l.y + 0.5 * win, win);
    float windows = max(
        buildings,
        min(
            sdf_rect(windowSize * vec3(
                abs(l.x) - 1.0 * buildingWidth,
                awy,
                modloop(l.z - buildingWidth / windowScale, win)
            ), vec3(buildingWidth)),
            sdf_rect(windowSize * vec3(
                modloop(l.x - buildingWidth / windowScale, win),
                awy,
                abs(l.z) - 1.0 * buildingWidth
            ), vec3(buildingWidth))
        )
    );
    
    float c = min(
        base,
        buildings
    );
    
    if(is_dist) {
        return vec4(c);
    }
    
    float I = 2.0 * MIN_DIST_THRESHOLD;
    if(base <= I) {
        float r = vmax(abs(l.xz));
        if(r >= 0.85) {
            if(r >= 1.24 && mod(vmin(abs(l.xz)), 0.2) <= 0.12) {
                return vec4(0.0, 0.0, 1.0, 0.0);
            }
            return vec4(0.0, 0.0, 0.1 + 0.1 * rand(l.xz), 0.0);
        }
        return vec4(0.02, 0.02, (cos(5.0 * p.x) * sin(5.0 * p.z)) <= 0 ? 0.3 : 0.35, 0.0);
    }
    if(windows - 0.12 <= I) {
        if(windows <= I)
            return vec4(0.5, 0.1, 0.2, 0.33);
        return vec4(0.0);
    }
    if(buildings <= I)
        return vec4(0.5 * buildType, 0.5, 0.5, 0.0);
}