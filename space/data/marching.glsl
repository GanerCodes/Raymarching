vec3 norm(Tracer tracer, float delt) {
    float base = scene(tracer, true).dist;
    vec3 pos = tracer.cur_pos;
    
    tracer.cur_pos = pos + delt*vec3(1,0,0);
    float x = scene(tracer, true).dist;
    tracer.cur_pos = pos + delt*vec3(0,1,0);
    float y = scene(tracer, true).dist;
    tracer.cur_pos = pos + delt*vec3(0,0,1);
    float z = scene(tracer, true).dist;
    
    return normalize(vec3(x, y, z) - base);
}

Tracer raymarch(Tracer tracer) {
    // Set current material to material ray is initally interacting with
    tracer.mat.cur = scene(tracer, false).mat.cur;
    
    for(int itter = 0; itter < MAX_ITTERS; itter++) {
        // Get distance from SDF scene
        tracer = scene(tracer, true);
        
        // If outside shape, use default material
        if(tracer.dist > MCR) tracer.mat.cur = tracer.mat.def;
        
        // Distance to surface, independant of inside or outside
        float d = abs(tracer.dist);
        // Distance to previous surface contact
        float last_material_dist = dist(tracer.pre_pos, tracer.cur_pos);
        // How much material this ray has interacted with since last surface interaction
        float mat_dense = min(1.0, tracer.mat.cur.dense * last_material_dist);
        // Proportion of total color-density that remains to be changed
        float prop = 1.0 - tracer.mat.tot.dense;
        // Actual density effect
        float dense = prop * mat_dense;
        
        // Ray's calculated total density.
        // 0 = no collisions with any type of opaque object
        // 1 = has hit a solid object or traversed a certain distance over a translucent material
        float tot_dense = tracer.mat.tot.dense + dense;
        // Intersecting a surface
        bool surface_check = d <= MIN_DIST_THRESHOLD;
        // Must return in these conditions (not bounce / get denser)
        bool exit_check = (d > MAX_DIST_THRESHOLD) || (tot_dense > DENSITY_THRESHOLD) || (itter == MAX_ITTERS - 1);
        
        // Check for interaction, boundry change, maximum travel distance
        if(surface_check || exit_check) {
            if(surface_check) {
                // Useful indicatior for having at least one surface intersection 
                tracer.mat.tot.state = 1;
                // Check if were still crossing a previously found border, if so move some minimum amount until "unstuck"
                if(tracer.flag && !exit_check) {
                    // Move a small amount
                    tracer.cur_pos += TMCR * tracer.dir;
                    continue;
                }
                // New surface, mark as so
                tracer.flag = true;
                // Set surface interaction as previous position for use in next surface.
                tracer.pre_pos = tracer.cur_pos;
            }else{
                // Not within range of a surface, next interaction within threshold is new
                tracer.flag = false;
            }
            
            // Merge material
            tracer.mat.tot.color = mix(tracer.mat.tot.color, tracer.mat.cur.color, dense);
            tracer.mat.tot.dense = tot_dense;
            
            // Store previous material
            Material old_material = tracer.mat.cur;
            // Get new material
            tracer.mat.cur = scene(tracer, false).mat.cur;
            
            if(tracer.mat.cur.state == BIT_DEFLT && tracer.mat.def.state == 3) return tracer;
            
            // Solid, set remaining light color to the color and return
            if(tracer.mat.cur.state == BIT_SOLID) {
                tracer.mat.tot.color = mix(tracer.mat.tot.color, tracer.mat.cur.color, prop);
                tracer.mat.tot.dense = 1.0;
                return tracer;
            }
            
            // Reflective, merge color according to its density property, then bounce light
            if(tracer.mat.cur.state == BIT_RFLCT) {
                // newp is what proportion of the remaining ray color will be the reflective material's color
                float newp = prop * tracer.mat.cur.dense;
                tracer.mat.tot.color = mix(tracer.mat.tot.color, tracer.mat.cur.color, newp);
                tracer.mat.tot.dense += newp;
                // Use previous state as a reflection isn't an indication that material has changed
                tracer.mat.cur = old_material;
                
                // Increase bounce count
                tracer.num_bounce++;
                // Return if bounce limit has been reached
                if(tracer.num_bounce == MAX_BOUNCE_COUNT) return tracer;
                tracer.flag = false;
                
                vec3 n = norm(tracer, 0.001); // Surface normal
                tracer.dir = reflect(tracer.dir, n); // Reflect trace direction off normal
            }
            
            // Return on must exit condition
            if(exit_check) return tracer;
        }
        
        // Move ray safe distance in its direction
        tracer.cur_pos += max(d, MIN_DIST_THRESHOLD) * tracer.dir;
    }
    return tracer;
}