#extension GL_EXT_draw_buffers : require
precision highp float;

varying vec3 fNormal;	//fragment normal direction
varying vec3 fPosition; //fragment position in *eye* space.

uniform vec4 Material;
uniform vec3 MaterialColor;

uniform float canvasWidth;
uniform float canvasHeight;

uniform mat4 view;

void main(){
	vec2 pos = vec2( gl_FragCoord.x/canvasWidth, gl_FragCoord.y/canvasHeight);
	vec3 position = fPosition;
	gl_FragData[0] = vec4(fPosition, length(position)); //Yes, we actually store the position, and recalculate the depth. Yes, this is expensive, and unnecessary. Yes, we could have attached some sort of buffer to the FBO's depth target. But we didn't.
	gl_FragData[1] = vec4(fNormal, 1.0);
	gl_FragData[2] = vec4(MaterialColor, 1.0);
	gl_FragData[3] = vec4(Material);
}
