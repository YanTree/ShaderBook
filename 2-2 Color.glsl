// Shader Book - Color
// Mix color

#ifdef GL_ES
precision mediump float;
#endif

#define PI 3.14159265359
#define TAU 6.28318530718

uniform vec2 u_resolution;
uniform float u_time;
uniform vec2 u_mouse;

// Lerp 的逆函数
float InverseLerp(float a, float b, float t){
	return (t-a)/(b-a);
}
// rgb 转 hsv
vec3 rgb2hsb( in vec3 c ){
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz),
                 vec4(c.gb, K.xy),
                 step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r),
                 vec4(c.r, p.yzx),
                 step(p.x, c.r));
    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)),
                d / (q.x + e),
                q.x);
}
// hsv 转 rgb
vec3 hsb2rgb( in vec3 c ){
    vec3 rgb = clamp(abs(mod(c.x*6.0+vec3(0.0,4.0,2.0),
                             6.0)-3.0)-1.0,
                     0.0,
                     1.0 );
    rgb = rgb*rgb*(3.0-2.0*rgb);
    return c.z * mix(vec3(1.0), rgb, c.y);
}

// hsv 转 ryb

//
float easeInOutCubic(float x) {
    return x<0.5 ? 4.0*x*x*x : 1.0-pow(-2.0*x+2.0, 3.0)/2.0;
}

float integralSmoothstep( float x, float T )
{
    if( x>T ) return x - T/2.0;
    return x*x*x*(1.0-x*0.5/T)/T/T;
}

// return a circle area
float circle(vec2 uv, vec2 center, float radius){
    float sdf = distance(center, uv) * 2.0;
    sdf = clamp(sdf, 0.0, 1.0);
    sdf = 1.0 - step(radius, sdf);
    return sdf;
}

float plotx(vec2 st, float t){
    return smoothstep(st.x - 0.02, st.x, t) -
            smoothstep(st.x, st.x + 0.02, t);
}

float ploty(vec2 st, float t){
    return smoothstep(st.y - 0.02, st.y, t) -
            smoothstep(st.y, st.y + 0.02, t);
}

float sinc(float x, float k){
    float a = PI * ((k*x - 1.0));
    return sin(a)/a;
}

vec3 colorA = vec3(0.1725, 0.5686, 0.8941);
vec3 colorB = vec3(0.8275, 0.6196, 0.3059);
vec3 colorC = vec3(0.6275, 0.3882, 0.1922);
vec3 sunCenter = vec3(0.9, 0.4333, 0.1235);
vec3 sunGlow = vec3(0.9, 0.6333, 0.4535);
vec3 white = vec3(1.0, 1.0, 1.0);

void main() {

    float time_scale = 0.5;

    // 归一化屏幕坐标与鼠标位置
    vec2 st = gl_FragCoord.xy / u_resolution.xy;
    vec2 mouse = u_mouse.xy / u_resolution.xy;


    //
    /// 日出，日落动画

    float m_time = 0.5 + 0.5 * sin(u_time * time_scale);

    float sky_line = 0.32; // 水天交接线

    // 初始颜色设置
    vec4 bg_col = vec4(1.0,1.0,1.0,1.0);
    vec4 color = bg_col;

    // 太阳设置
    float radius = 0.12;
    vec2 sun_center = vec2(0.5 + 0.15 * m_time, 0.8 - 0.68 * m_time);
    float cir_mask = circle(st, sun_center, radius);
    vec4 sun_col = mix(vec4(1.0, 0.9, 0.5, 1.0), vec4(1.0, 0.1, 0.13, 1.0), m_time);

    // 天空设置
    float skyEdge = 0.01;
    float sky_mask = smoothstep(sky_line, sky_line + skyEdge, st.y);
    vec4 skyColor_up = mix(vec4(0.624, 0.774, 0.985, 1.0), vec4(0.135, 0.135,0.135,1),m_time);
    vec4 skyColor_down = mix(vec4(1.0, 0.868, 0.010, 1.0), vec4(1.0, 0.348,0.006,1.0),m_time);

    // 海洋设置
    float sea_mask = 1.0 - sky_mask;
    vec4 sea_col = mix(mix(vec4(0.02, 0.545, 0.985, 1.0), vec4(0.071, 0.195, 0.615, 1.0), m_time), 
                       mix(vec4(0.0, 0.985, 0.891, 1.0), vec4(0.022, 0.703, 0.830, 1.0), m_time),
                       (st.y - sky_line) * 1.0/(sky_line));

    // 反射设置
    vec4 ref_col = sun_col;
    float ref_width = 0.3 - 0.05 * m_time;
    float ref_mask = sea_mask * (smoothstep(sun_center.x + 0.5 * st.y - ref_width,
                                  sun_center.x, st.x) - 
                       smoothstep(sun_center.x, 
                                  sun_center.x - 0.5 * st.y + ref_width, st.x));
    
    // 绘制
    color = (1.0 - sky_mask) * color + sky_mask * mix(skyColor_down, skyColor_up, (st.y - sky_line) * 1.0/(1.0 - sky_line));
    color = (1.0 - cir_mask) * color + cir_mask * sun_col;
    color = (1.0 - sea_mask) * color + sea_mask * sea_col;
    color = (1.0 - ref_mask) * color + ref_mask * ref_col;
    

    //
    /// 通道混合

    //vec3 color = vec3(0.0);

    // dis = normalize(dis);

    // blend split channel
    // pct.r = smoothstep(0.0, 1.0, st.x);
    // pct.g = sin(st.x * PI);
    // pct.b = pow(st.x, 0.5);

    // float pct = abs(sin(u_time));
    // float pct = easeInOutCubic(abs(sin(u_time)));

    // Mix uses pct (a value from 0-1) to
    // mix the two colors


    //
    /// 彩虹

    // 彩虹曲线函数  st.x * 2.0 - 1.0 - [-1, 1] 重映射至 [0, 1]
    // float line_a = ploty(st, 0.88 * pow(cos(PI * (st.x * 2.0 - 1.0) / 2.0), 0.5) / 2.0);
    // float line_b = ploty(st, 0.68 * pow(cos(PI * (st.x * 2.0 - 1.0) / 1.8), 0.5) / 2.0);
    // float line_c = ploty(st, 0.48 * pow(cos(PI * (st.x * 2.0 - 1.0) / 1.6), 0.5) / 2.0);
    // float line = line_a + line_b + line_c;
    // float y = ploty(st, (sin(st.x * PI * 4.0 - u_time) + 1.0) / 2.0);
    // float dis = pow(st.x - 0.5, 2.0) + pow(st.y, 2.0) / (0.5 * 0.5 + 1.0);
    // color = vec4(hsb2rgb(vec3(dis,1.0, 1.0)), 1.0);

    vec4 pick_col = mix(vec4(1.000, 0.728, 0.806, 1.0), vec4(0.611, 0.490, 0.930, 1.0),
                         - 0.68 + st.x + 1.0 - st.y);
    float line_width = 0.5;
    float line_smooth = 0.05;
    float line_up = sqrt(0.9 * 0.9 - pow(st.x - 0.5, 2.0));
    float step_up = smoothstep(line_up, line_up + line_smooth, st.y);
    float line_down = line_up - line_width;
    float step_down = smoothstep(line_down - line_smooth, line_down, st.y);
    float line = step_down - step_up;

    float rainbow_scale = 1.5;
    float rainbow_width = line_width * rainbow_scale;
    float dis = (st.y - line_down)/rainbow_width;

    float alpha = 0.584;
    color = vec4(hsb2rgb(vec3(dis, 1.0, 1.0)), 1.0);
    color = line * mix(color, pick_col, 1.0 - alpha) + (1.0 - line) * pick_col;

    // 直接使用 SDF 快速制作
    // float alpha = 0.584;
    // vec4 pick_col = mix(vec4(1.000, 0.728, 0.806, 1.0), vec4(0.611, 0.490, 0.930, 1.0),
    //                     - 0.68 + st.x + 1.0 - st.y);
    // float dis_curve = pow(1.0 - 0.5, 2.0) + pow(1.0, 2.0);
    // float dis = pow(st.x - 0.5, 2.0) + pow(st.y, 2.0) / dis_curve;
    // dis = clamp(InverseLerp(0.1, 0.7, dis), 0.0, 1.0);
    // color = vec4(hsb2rgb(vec3(dis,1.0, 1.0)), 0.9);
    // dis = ceil(dis - 0.02) - floor(dis + 0.109);
    // color = mix(vec4(1.0, 1.0, 1.0, 1.0), color, dis);
    // color = dis * mix(color, pick_col, 1.0 - alpha) + (1.0 - dis) * pick_col;


    // 
    /// 彩旗
    vec4 flag_pick_col = mix(vec4(1.000, 0.728, 0.806, 1.0), vec4(0.611, 0.490, 0.930, 1.0),
                         - 0.68 + st.x + 1.0 - st.y);
    float flag_line_width = 0.5;
    float flag_line_smooth = 0.05;
    float flag_line_up = 0.5 + line_width / 2.0 + 0.032 * st.x * sin((0.5 - 0.368 * st.x) * st.x + (4.0  + 0.005 * st.x)* u_time);
    float flag_step_up = smoothstep(flag_line_up, flag_line_up + flag_line_smooth, st.y);
    float flag_line_down = flag_line_up - flag_line_width;
    float flag_step_down = smoothstep(flag_line_down - flag_line_smooth, flag_line_down, st.y);
    float flag_line = flag_step_down - flag_step_up;

    float flag_scale = 1.5;
    float flag_width = flag_line_width * flag_scale;
    float flag_dis = (st.y - flag_line_down)/flag_width;

    float flag_alpha = 0.584;
    color = vec4(hsb2rgb(vec3(flag_dis, 1.0, 1.0)), 1.0);
    color = flag_line * mix(color, flag_pick_col, 1.0 - flag_alpha) + (1.0 - flag_line) * flag_pick_col;

    //gl_FragColor = vec4(sea_col);
    //gl_FragColor = sea_mask * sea_col;
    //gl_FragColor = vec4(flag_line,flag_line,flag_line,1.0);
    //gl_FragColor = color;
    //gl_FragColor = vec4(ref_mask,ref_mask,ref_mask,1.0);



    // 这条彩虹为什么看起来观感很好？
    //
    // 1. 彩虹本身与背景之间有一个柔和过渡（如何计算？）
    // 2. 使用了透明度混合，彩虹颜色与背景颜色会通过一定程度的混合操作（如何计算？）
    // 3. 彩虹左上角使用了蓝色的补色，右下角使用了红色的补色（如何计算？）



    //
    /// 色环

    bg_col = vec4(0.847, 0.763, 0.88, 1.0);
    color = bg_col;

    // 参数
    vec2 to_center = (-st + vec2(0.5));
    float angle = atan(to_center.y, to_center.x);
    radius = length(to_center) * 2.0;
    float hue = angle/TAU + 0.5;

    // 构造圆环
    vec4 circle_col = vec4(hsb2rgb(vec3(angle/TAU + 0.5, radius, 1.0)), 1.0);
    float cir = sqrt(pow(to_center.x, 2.0) + pow(to_center.y, 2.0));
    float cir_up = smoothstep(0.38, 0.37, cir);
    float cir_down = smoothstep(0.309, 0.305, cir);
    cir = cir_up - cir_down;

    // 赋值
    color = cir * circle_col + (1.0 - cir) * color;


    //
    /// Shrink color

    hue =st.x;
    hue = integralSmoothstep(hue, 0.3); // 强化显示红色
    float line_height = step(0.3, st.y) - step(0.5, st.y);
    vec4 line_col = vec4(hsb2rgb(vec3(hue, 1.0, 1.0)), 1.0) * line_height;


    //
    /// 色轮(HSV)

    to_center *= 3.0;
    angle = atan(to_center.y, to_center.x);
    radius = length(to_center);
    hue = angle/TAU + 0.5;
    vec4 wheel = vec4(hsb2rgb(vec3(hue, radius, 1.0)), 1.0);
    float radius_shrink = smoothstep(1.0, 1.1, radius);
    float radius_mask = 1.0 - radius_shrink;
    color = wheel * 1.0 * radius_mask + bg_col * 0.9 * (1.0 - radius_mask);


    //
    /// 色轮(RYB)

    //float hue01 = 

    //hue = InverseLerp(0.0, 1.0, hue);
    //hsv_radius = 1.0 - step(1.0, hsv_radius);
    //vec4 hsv_col = vec4(hsb2rgb(vec3(hue,hsv_radius,1.0)), 1.0);
    //hsv_col += 0.3;
    //gl_FragColor = vec4(hsv_radius, hsv_radius, hsv_radius, 1.0);
    gl_FragColor = color;
    //gl_FragColor = vec4(radius_mask);
}
