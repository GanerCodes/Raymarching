#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

varying vec4 vertTexCoord;
uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

float PI=3.14159;float sq(float x){return x*x;}float hypot(vec2 p){return sqrt(sq(p.r)+sq(p.g));}float dist(vec2 p1,vec2 p2){return hypot(p2-p1);}float angle(vec2 p){return atan(p.g,p.r);}float angle_between(vec2 p1,vec2 p2){return atan(p2.g-p1.g,p2.r-p1.r);}float pml(float x,float a,float b){float t=abs(b-a);return mod(-x*sign(mod(floor(x/t),2.0)-0.5),t)+a;}vec2 ptc(float d,float a){return vec2(d*cos(a),d*sin(a));}vec3 rgb2hsv(vec3 c){vec4 K=vec4(0.0,-1.0/3.0,2.0/3.0,-1.0),p=mix(vec4(c.bg,K.ab),vec4(c.gb,K.rg),step(c.b,c.g)),q=mix(vec4(p.rga,c.r),vec4(c.r,p.gbr),step(p.r,c.r));float d=q.r-min(q.a,q.g),e=1e-10;return vec3(abs(q.b+(q.a-q.g)/(6.0*d+e)),d/(q.r+e),q.r);}vec3 hsv2rgb(vec3 c){vec4 K=vec4(1.0,0.66666,0.33333,3.0);vec3 p=abs(fract(c.rrr+K.rgb)*6.0-K.aaa);return c.b*mix(K.rrr,p-K.rrr,c.g);}

bool fastDistCompare(vec3 l, float lSquared) {
    return sq(l.x) + sq(l.y) + sq(l.z) > lSquared;
}

float smoothMax(float a, float b, float k) {
    return max(a, b) - k * 0.166666666 * pow(
        max(0.0, k - abs(a - b)) / k,
        3.0
    );
}

float g(vec3 p) {
    return (
        abs(p.x) + abs(p.y) + abs(p.z) - 1.0
    );
}

float f(vec3 p) {
    float r = u_time / 2.0;
    float a = sin(u_time) / 2.0 + 0.05;
    
    vec3 o = p;
    
    p += vec3(
        0.0,
        0.5 + 0.5 * (sin(u_time / 2.0) - 1.0),
        0.0
    );
    p = vec3(
        p.x*cos(r) - p.z*sin(r),
        p.y,
        p.x*sin(r) + p.z*cos(r)
    );
    
    float ang = atan(p.x, p.z);
    float ang_mod = mod(ang + PI / 10, PI / 5) - PI / 10;
    float d = length(p.xz);
    vec2 rc = ptc(d, ang_mod);
    
    p = vec3(
        p.x,
        p.y*cos(a) - p.z*sin(a),
        p.y*sin(a) + p.z*cos(a)
    );
    p = vec3(
        p.x*cos(a) - p.y*sin(a),
        p.x*sin(a) + p.y*cos(a),
        p.z
    );
    
    return (abs(p.x) + abs(p.y) + abs(p.z) - 0.5) <= 0 ? -0.2 : 1.0;
    
    vec3 ball = (p + vec3(
        0.0, -0.05, 0.0
    )) * vec3(
        1.0, 1.5, 1.0
    );
    
    return max(
        length(p.xy) - 1.0,
        abs(p.y) - 0.2 + max(
            0.2 * (pow(p.x, 2.0) + pow(p.z, 2.0)),
            0.05 + p.y + 0.2 * pow(length(p.xz), 2.0)
        )
    ) <= 0 ? (
        (1.0 - 50.0 * abs(p.y + 0.02) >= 0) ? (
            -mod(ang / (PI) - u_time / 3.0, 1.0)
        ) : (
            (p.y >= 0) ? (
                mod(length(p - ang_mod * vec3(0.0, 1.0, 0.0)), 0.1) >= 0.05 ? (
                    -3.07
                ) : -3.02
            ) : (
                length(p - vec3(0.0, -0.6, 0.0)) <= 0.45 ? (
                    -1.3
                ) : (
                    -(3 + abs(p.z) / 15.0)
                )
            )
        )
    ) : (
        length(
            ball
        ) - pow(0.6, 2.0)
    ) <= 0 ? (
        0.1 + 0.4 * p.y - 0.9
    ) : (
        length(
            vec3(rc.x, p.y, rc.y) - 
            vec3(0.75, -0.07, 0.0)
        ) - pow(0.2, 2.0)
    ) <= 0 ? (
        sign(cos(4.0 * u_time)) * sin(5.0 * (ang + PI / 10.0)) <= 0 ? (
            -0.3
        ) : (-5.3)
    ) : (
        1
    );
}

void main() {
    vec3 p = vec3(
        2.0 * (vertTexCoord.xy - 0.5),
        20.0 * u_mouse.x / u_resolution.x
    );
    
    int itters = 64;
    
    vec3 cast_s = vec3(0.0, 0.0, p.z);
    vec3 cast_e = vec3(3.0 * p.xy, -10.0);
    
    float dist = length(cast_e - cast_s);
    vec3 cast_l = cast_s;
    vec3 cast_step = (cast_e - cast_s) / float(itters);
    
    vec3 clr = vec3(0.0);
    for(int i = 0; i < itters; i++) {
        vec3 cast_t = cast_l + cast_step;
        if( (f(cast_l) >= 0.0) == (f(cast_t) >= 0.0) ) {
            cast_l = cast_t;
        }else{
            if(!fastDistCompare(cast_step, 0.0001)) {
                vec3 loc = cast_l + 1.5 * cast_step;
                float v = abs(f(loc));
                float bm = 1.0 / (1.0 + floor(v));
                dist = length(cast_s - loc) / dist;
                v = mod(v, 1.0);
                
                clr = hsv2rgb(vec3(
                    v,
                    0.6,
                    min(
                        50.0 * pow(max(0.0, 0.7 - dist), 3.0) * bm,
                        1.0
                    )
                ));
                break;
            }
            cast_step *= 0.5; // Changing this value can help... ish?
        }
    }
    
    gl_FragColor = vec4(clr, 1.0);
}