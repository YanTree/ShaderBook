// Shader Book - Uniform
// Chance color throgh time

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
	// gl_FragColor = vec4(0.1216, 1.0, 0.0, 1.0);
	/// pass time to chane single channel value
	/// r chanel waved from [0, 1] [1, 0]
	gl_FragColor = vec4(abs(sin(u_time * 2.1)), abs(sin(u_time * 0.1)), abs(sin(u_time * 1.1)), 1.0);
}