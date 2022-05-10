float angle(vec2 p) { return atan(p.y,p.x); }
vec2 reflect_norm(vec2 p, vec2 n) { return p - 2.0 * n * dot(p, n); }
vec3 reflect_norm(vec3 p, vec3 n) { return p - 2.0 * n * dot(p, n); }
vec4 reflect_norm(vec4 p, vec4 n) { return p - 2.0 * n * dot(p, n); }

vec2 rotCentered(vec2 p, vec2 a, float r) {
    vec2 adj = p - a;
    vec2 sc = vec2(sin(r), cos(r));
    return vec2(
        adj.x*sc.y - adj.y*sc.x,
        adj.x*sc.x + adj.y*sc.y
    ) + a;
}
mat2 rotMatrix(vec2 p, float r) {
    vec2 s = spl(r);
    return mat2(
        s.x, -s.y,
        s.y,  s.x
    );
}
vec3 rot_XY(vec3 p, float r){
    vec2 m = p.xy * rotMatrix(p.xy, r);
    return vec3(m, p.z);
}
vec3 rot_XZ(vec3 p, float r){
    vec2 m = p.xz * rotMatrix(p.xz, r);
    return vec3(m.x, p.y, m.y);
}
vec3 rot_YZ(vec3 p, float r){
    vec2 m = p.yz * rotMatrix(p.yz, r);
    return vec3(p.x, m);
}
vec3 rot_XZ_YZ(vec3 p, float r1, float r2) {
    return rot_XZ(rot_YZ(p, r1), r2);
}

vec3 angsToDir(float rot1, float rot2) {
    return rot_XZ(rot_XY(vec3(1.0, 0.0, 0.0), rot2  ), rot1  );
}
vec3 angsToDir(vec2 rots) {
    return rot_XZ(rot_XY(vec3(1.0, 0.0, 0.0), rots.y), rots.x);
}
vec2 dirToAng(vec3 p) {
    return vec2(atan(p.z, p.x), atan(p.y, length(p.xz)));
}

vec3 nearest_point_line(vec3 p, vec3 dir, vec3 orig) {
    return orig + dir * dot(p - orig, normalize(dir));
}
vec3 nearest_point_line(vec3 p, vec3 dir) {
    return dir * dot(p, normalize(dir));
}

vec3 rotate3(vec3 p, vec3 rot) {
    p = rot_XZ(p, -rot.x);
    p = rot_XY(p, -rot.y);
    p = rot_YZ(p, rot.z);
    p = rot_XY(p, rot.y);
    p = rot_XZ(p, rot.x);
    return p;
}
vec3 rotateAxis(vec3 p, vec3 V, float a) {
    return rotate3(p, vec3(dirToAng(V), a));
}