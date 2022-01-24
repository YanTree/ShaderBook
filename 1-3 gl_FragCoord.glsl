// Shader Book - gl_FragCoord
// Chance color throgh space(UV)

#ifdef GL_ES
precision mediump float;
#endif

//
/// Uniform value

// CPU send input data through to GPU, these variable must
// keep same when CPU send to GPU
uniform vec2 u_resolution; // Canvas width/height
uniform vec2 u_mouse;      // mouse position(which pixel)
uniform float u_time;      // current time(start load)

// main function return final color
void main() {
	// normalize pixel [0, 1]
	vec2 st = gl_FragCoord.xy/u_resolution;
	vec2 mt = u_mouse.xy/u_resolution;
	// gl_FragColor = vec4(mt.x, mt.y, 0.0, 1.0);
	gl_FragColor = vec4(clamp(abs(sin(u_time)) + mt.x, 0.0, 1.0),clamp(abs(sin(u_time)) + mt.y, 0.0, 1.0) , 0.0, 1.0);
}