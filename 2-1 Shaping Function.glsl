// Shader Book - Shaping Function
// Back to [0, 1]

#ifdef GL_ES
precision mediump float;
#endif

#define PI 3.14159265359

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

// Plot a line on Y using a value between 0.0-1.0
float plot(vec2 st, float pct) {    
    return smoothstep(pct-0.02, pct, st.y)-
			smoothstep(pct, pct+0.02, st.y);
}

float InverseLerp(float a, float b, float t){
	return (t-a)/(b-a);
}

void main() {

	vec2 st = gl_FragCoord.xy / u_resolution;

	//
	/// 直线
	//float y = st.y; // 从下至上的取值范围 [0, 1]
	//float y = st.x; // 从左至右的取值范围 [0, 1]
	//float y =st.y - st.x; // 对角分割域，(0, 1)点值为 1，(1，0)点值为 -1
	//float y = InverseLerp(0.1, 0.0, abs(st.y - st.x)); // 画一条对角线
	//float y = smoothstep(st.x - 0.1, st.x, st.y)-
	//smoothstep(st.x, st.x + 0.1, st.y); // 画一条对角线
	//float y = smoothstep(0.02, 0.0, abs(st.y - st.x)); // 画一条对角线(有平滑过渡)
	/// 指数曲线
    // float y = pow(st.x, 5.0);
	/// 开方曲线
    // float y = sqrt(st.x) * st.x;
	/// bool line (0 or 1) -> hard edge
	// float y = step(0.9, st.x);
	/// bool line (0 to 1 gradient) -> soft edge
	// float y = smoothstep(0.1, 0.9, st.x);
	/// 驼峰曲线
	// float y = smoothstep(0.2,0.5,st.x) - smoothstep(0.5,0.8,st.x);
	/// 三角函数线
	float y = plot(st, (sin(PI * st.x * 4.0 - u_time) + 1.0) / 2.0);

    // float pct = plot(st);
	float pct = plot(st, y);

    vec3 color = vec3(y);

    // Plot a line
    color = (1.0-pct)*color+pct*vec3(0.0,1.0,0.0);

	gl_FragColor = vec4(color,1.0);
	gl_FragColor = vec4(y,y,y,1.0);
}