uniform lowp vec4 fColor;
uniform lowp sampler2D fTexture;
uniform float fPos;
uniform float fStroke;
uniform vec2 fResolution;

uniform float FXAA_SPAN_MAX;
uniform float FXAA_REDUCE_D1;
uniform float FXAA_REDUCE_D2;

varying mediump vec2 fTexCoord;

vec3 tex(vec2 p)
{
    return texture2D(fTexture, p).rgb;
}

vec3 fxaa(vec2 p)
{
    //float FXAA_SPAN_MAX   = 8.0;
    //float FXAA_REDUCE_MUL = 1.0 / 4.0;
    //float FXAA_REDUCE_MIN = 1.0 / 128.0;
	
	float FXAA_REDUCE_MUL = 1.0 / FXAA_REDUCE_D1;
	float FXAA_REDUCE_MIN = 1.0 / FXAA_REDUCE_D2;

    // 1st stage - Find edge
    vec3 rgbNW = tex(p + (vec2(-1.,-1.) / fResolution));
    vec3 rgbNE = tex(p + (vec2( 1.,-1.) / fResolution));
    vec3 rgbSW = tex(p + (vec2(-1., 1.) / fResolution));
    vec3 rgbSE = tex(p + (vec2( 1., 1.) / fResolution));
    vec3 rgbM  = tex(p);

    vec3 luma = vec3(0.299, 0.587, 0.114);

    float lumaNW = dot(rgbNW, luma);
    float lumaNE = dot(rgbNE, luma);
    float lumaSW = dot(rgbSW, luma);
    float lumaSE = dot(rgbSE, luma);
    float lumaM  = dot(rgbM,  luma);

    vec2 dir;
    dir.x = -((lumaNW + lumaNE) - (lumaSW + lumaSE));
    dir.y =  ((lumaNW + lumaSW) - (lumaNE + lumaSE));
    
    float lumaSum   = lumaNW + lumaNE + lumaSW + lumaSE;
    float dirReduce = max(lumaSum * (0.25 * FXAA_REDUCE_MUL), FXAA_REDUCE_MIN);
    float rcpDirMin = 1. / (min(abs(dir.x), abs(dir.y)) + dirReduce);

    dir = min(vec2(FXAA_SPAN_MAX), max(vec2(-FXAA_SPAN_MAX), dir * rcpDirMin)) / fResolution;

    // 2nd stage - Blur
    vec3 rgbA = 0.5 * (tex(p + dir * (1./3. - .5)) +
                      tex(p + dir * (2./3. - .5)));
    vec3 rgbB = rgbA * .5 + .25 * (
                      tex(p + dir * (0./3. - .5)) +
                      tex(p + dir * (3./3. - .5)));
    
    float lumaB = dot(rgbB, luma);
    
    float lumaMin = min(lumaM, min(min(lumaNW, lumaNE), min(lumaSW, lumaSE)));
    float lumaMax = max(lumaM, max(max(lumaNW, lumaNE), max(lumaSW, lumaSE)));

    return ((lumaB < lumaMin) || (lumaB > lumaMax)) ? rgbA : rgbB;
}

void main() {
	vec4 col = texture2D(fTexture, fTexCoord);
    
	// line
    if (fTexCoord.x > fPos-fStroke && fTexCoord.x < fPos)
        gl_FragColor = vec4(1.);
	// FXAA
    else if (fTexCoord.x > fPos) {
        vec3 aa = fxaa(fTexCoord);
        gl_FragColor = vec4(aa, aa*col.a);
    }
	// Original
    else
        gl_FragColor = col;
}
