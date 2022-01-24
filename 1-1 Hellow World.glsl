// Shader Book - "Hello WOrld!"

#ifdef GL_ES
precision mediump float;
#endif

//
/// CPU send input data through to GPU
uniform float u_time;
uniform samplerCube u_sc;
uniform sampler2D u_tex;
uniform mat4 u_m4;
uniform mat3 u_m3;
uniform mat2 u_m2;
uniform vec4 u_v4;
uniform vec3 u_v3;
uniform vec2 u_v2;

vec4 red()
{
	return vec4(1,0,0,1);
}
// main function return final color
void main() {
	gl_FragColor = red();
	// gl_FragColor = vec4(0.1216, 1.0, 0.0, 1.0);
}