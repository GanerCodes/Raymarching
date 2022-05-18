const uint BIT_DEFLT = 0;
const uint BIT_SOLID = 1;
const uint BIT_RFLCT = 2;
const uint BIT_DEBUG = 3;

struct Material {
    vec3 color;
    float dense;
    uint state;
} aether = {vec3(0.0), 0.0, 0};

struct Tracer_materials {
    Material tot; // Total
    Material cur; // Current
    Material def; // Default
};
struct Tracer {
    vec3 cur_pos;   // Continious ray position
    vec3 pre_pos;   // Previous surface intersection location
    vec3 dir;       // Travel direction
    float dist;     // SDF distance, set by function
    bool flag;      // Currectly interacting with surface (used to )
    int num_bounce; // Number of bounces ray has had
    Tracer_materials mat; // Three materials used in calculations
};

Tracer make_tracer(vec3 cur_pos, vec3 dir, Material default_material) {
    return Tracer(cur_pos, cur_pos, dir,
                  0.0, false, 0,
                  Tracer_materials(aether,
                                   aether,
                                   default_material));
}

Material Solid(vec3 color, float dense           ) { return Material(color, dense, 0); }
Material Solid(vec3 color                        ) { return Material(color, 1.0, BIT_SOLID); }
Material Solid(vec4 color                        ) { return Material(color.rgb, color.a, 0); }
Material Solid(float r, float g, float b, float d) { return Material(vec3(r,g,b), d, 0); }
Material Solid(float r, float g, float b         ) { return Material(vec3(r,g,b), 0, BIT_SOLID); }