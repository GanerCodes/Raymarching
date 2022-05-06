#ifdef GL_ES
precision lowp float;
#endif

uniform sampler2D image;
varying vec4 vertTexCoord;
uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform vec3 ball;
uniform float u_time;
uniform int count;
uniform vec3 vp_loc;
uniform vec2 vp_ang;

float MIN_DIST_THRESHOLD = 0.001;
float MAX_DIST_THRESHOLD = 400.0;
int   MAX_ITTERS         = 400;