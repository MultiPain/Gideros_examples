uniform lowp vec4 fColor;
uniform lowp sampler2D fTexture;
uniform lowp float fGamma;

varying mediump vec2 fTexCoord;

void main(){
	vec4 col = texture2D(fTexture, fTexCoord);
    vec3 gammCorrection = pow(col.rgb, vec3(1.0/fGamma));
	
	gl_FragColor = vec4(gammCorrection, col.a);
}