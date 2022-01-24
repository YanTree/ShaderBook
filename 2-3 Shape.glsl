// Shader Book - Shape
// Draw basic shape use shader


#ifdef GL_ES
precision mediump float;
#endif

#define PI 3.14159265359
#define TAU 6.28318530718

uniform vec2 u_resolution;
uniform float u_time;
uniform vec2 u_mouse;

float rectangle(vec2 bl, vec2 tr, vec2 st){
    vec2 corner_bl = step(bl, st);
    vec2 corner_tr = step(tr, 1.0 - st);
    return corner_bl.x * corner_bl.y * corner_tr.x * corner_tr.y;
}

float rect(in vec2 st, in vec2 size){
    size = 0.25 - size*0.25;
    vec2 uv = smoothstep(size, size + size*vec2(0.002), st*(1.0 - st));
    return uv.x * uv.y;
}

float rectangle_outline(vec2 bl, vec2 tr, vec2 st, float thickness){
    float out_rectangle = rectangle(bl - vec2(thickness), tr - vec2(thickness), st);
    return 1.0 - out_rectangle + rectangle(bl, tr, st);
}

float circle_step(vec2 center, float radius, vec2 st){
    float dis = distance(center, st);
    return 1.0 - step(radius, dis * 2.0);
}

float circle(in vec2 center, in float _radius, in vec2 _st){
    vec2 dist = _st-center;
	return 1.-smoothstep(_radius-(_radius*0.01),
                         _radius+(_radius*0.01),
                         dot(dist,dist)*4.0);
}

// Plot a line on Y using a value between 0.0-1.0
float plot(vec2 st, float pct) {    
    return smoothstep(pct-0.02, pct, st.y)-
			smoothstep(pct, pct+0.02, st.y);
}

void main(){

    // 每一个像素都代表着有一个线程在为其计算并着色
    vec2 st = gl_FragCoord.xy / u_resolution.xy;
    vec3 color = vec3(0.0);
    vec3 bg_col = vec3(0.95, 0.94, 0.89);
    vec3 red = vec3(0.6745, 0.1216, 0.1216);
    vec3 yellow = vec3(0.9686, 0.7569, 0.0745);
    vec3 blue = vec3(0.0431, 0.2627, 0.5922);


    //
    /// Rectangle

    // Each result will return 1.0 (white) or 0.0 (black).
    float left = step(0.1,st.x);   // Similar to ( X greater than 0.1 )
    float bottom = step(0.1,st.y); // Similar to ( Y greater than 0.1 )

    // The multiplication of left*bottom will be similar to the logical AND.
    //color = vec3( left * bottom );
    
    
    // bottom-left
    vec2 bl = step(vec2(0.1),st);
    bl = smoothstep(vec2(0.1), vec2(0.18), st);
    bl = floor(st * 9.0);
    float pct = bl.x;

    // top-right
    vec2 tr = step(vec2(0.1),1.0-st);
    tr = smoothstep(vec2(0.1), vec2(0.18), 1.0 - st);
    //pct *= tr.x * tr.y;

    float red_mask = rectangle(vec2(0.0, 0.65), vec2(0.8, 0.0), st);
    color = mix(vec3(0,0,0), red, red_mask);
    float yellow_mask = rectangle(vec2(0.96, 0.65), vec2(0.0, 0.0), st);
    color += mix(vec3(0,0,0), yellow, yellow_mask);
    float blue_mask = rectangle(vec2(0.77, 0.0), vec2(0.0, 0.92), st);
    color += mix(vec3(0,0,0), blue, blue_mask);

    // bg color
    float step_bg_mask = 1.0 - red_mask - yellow_mask - blue_mask;
    color += step_bg_mask * bg_col;

    // rectangle_outline
    float draw = rectangle_outline(vec2(0.0, 0.65), vec2(0.8, 0.0), st, 0.015); // red
    draw *= rectangle_outline(vec2(0.96, 0.65), vec2(0.0, 0.0), st, 0.015); // yellow
    draw *= rectangle_outline(vec2(0.77, 0.0), vec2(0.0, 0.92), st, 0.015); // blue
    draw *= rectangle_outline(vec2(0.215, 0.0), vec2(0.245, 0.0), st, 0.015); // 竖线1
    draw *= rectangle_outline(vec2(0.0, 0.0), vec2(0.055, 0.0), st, 0.015); // 竖线2
    draw *= rectangle_outline(vec2(0.1, 0.65), vec2(0.0, 0.0), st, 0.015); // 竖线2
    draw *= rectangle_outline(vec2(0.0, 0.65), vec2(0.0, 0.2), st, 0.015); // 横线1
    draw *= rectangle_outline(vec2(0.215, 0.095), vec2(0.0, 0.2), st, 0.015); // 横线2
    //color = vec3(yellow_mask + red_mask + blue_mask) * bg_col;
    color *= vec3(draw); // 画图完成


    //
    /// Circle

    // a. The DISTANCE from the pixel to the center
    pct = distance(st,vec2(0.5));

    // b. The LENGTH of the vector
    //    from the pixel to the center
    vec2 toCenter = vec2(0.5)-st;
    pct = length(toCenter);

    // c. The SQUARE ROOT of the vector
    //    from the pixel to the center
    vec2 tC = vec2(0.5)-st;
    pct = sqrt(tC.x*tC.x+tC.y*tC.y);

    //pct = distance(st, vec2(0.6));
    pct = distance(st,vec2(0.4)) + distance(st,vec2(0.6));
    pct = distance(st,vec2(0.4)) * distance(st,vec2(0.6));
    pct = min(distance(st,vec2(0.4)),distance(st,vec2(0.6)));
    pct = max(distance(st,vec2(0.4)),distance(st,vec2(0.6)));
    pct = pow(distance(st,vec2(0.4)),distance(st,vec2(0.6)));

    color = vec3(pct) * 2.0;

    //
    // Distance field

    // color = step(0.5, color); // step 0.5
    // color = 1.0 - color;      // Inverse value
    // color = smoothstep(0.4, 0.5, color);
    // color =vec3 (circle(vec2(0.5, 0.5), abs(sin(u_time * 1.0 * TAU)), st)); // animation
    // color =vec3 (circle(vec2(0.5 + (sin(u_time * TAU / 4.0)), 0.5), 0.3, st));
    //color *= yellow;
    
    // caculate circle use dot() product improve performence
    color = vec3(circle(vec2(0.5), 0.9, st));

    // remap st to [-1, 1]
    vec2 st_center = st * 2.0 - 1.0;

    // make distance field
    float dis = length(abs(st_center) - 0.3);
    dis = length(min(abs(st_center) - 0.3, 0.0));
    dis = length(max(abs(st_center) - 0.3, 0.0));

    color = vec3(fract(dis * 10.0));

    gl_FragColor = vec4(color,1.0);
    gl_FragColor = vec4(vec3(step(0.3, dis)),1.0);
    gl_FragColor = vec4(vec3(step(0.3, dis) * step(0.4, dis)),1.0);
    gl_FragColor = vec4(vec3(smoothstep(0.3, 0.4, dis) * 
                             smoothstep(0.6, 0.5, dis)),1.0);

    
    //
    /// Polar shapes(极坐标系)

    vec2 pos = vec2(0.5)-st;

    float r = length(pos)*2.0; // + sin(u_time);
    float a = atan(pos.y,pos.x) + u_time;

    float f = cos(a*3.0);
    f = abs(cos(a*3.0));
    //f = abs(cos(a*2.5))*.5+.3;//flowers
    //f = abs(cos(a*12.)*sin(a*3.))*.8+.1;//snowflakes
    f = smoothstep(-.5,1., cos(a*10.))*0.2+0.5;//gear

    float h = 1.0 - step(0.2, r);

    float line = plot(vec2(r), f);

    color = vec3( 1.-smoothstep(f-h,f+0.02-h,r) );
    //color = vec3( f);

    gl_FragColor = vec4(color, 1.0);
    gl_FragColor = vec4(line, line, line, 1.0);



    //
    /// Combining powers

    vec2 st_com = st;
    st_com.x *= u_resolution.x/u_resolution.y;
    color = vec3(0.0);
    float d = 0.0;

    // Remap the space to -1. to 1.
    st_com = st_com *2.-1.;

    // Number of sides of your shape
    int N = 6;

    // Angle and radius from the current pixel
    a = atan(st_com.x,st_com.y)+PI;
    r = TAU/float(N);

    // Shaping function that modulate the distance
    d = cos(floor(.5+a/r)*r-a)*length(st_com);

    color = vec3(1.0-smoothstep(.4,.41,d));
    // color = vec3(d);

    gl_FragColor = vec4(color,1.0);

    //gl_FragColor = vec4(color,1.0);
}