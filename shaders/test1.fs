#extension GL_EXT_draw_buffers : require
precision highp float;

varying vec3 fNormal;	//fragment normal direction
varying vec3 fPosition; //fragment position in *eye* space.

uniform vec4 Material;
uniform vec3 MaterialColor;

uniform float canvasWidth;
uniform float canvasHeight;

void main(){
	vec2 pos = vec2( gl_FragCoord.x/canvasWidth, gl_FragCoord.y/canvasHeight);
	gl_FragData[0] = vec4(1.0, 0.0, 0.0, 1.0);
	gl_FragData[1] = vec4(0.0, 1.0, 0.0, 1.0);
	gl_FragData[2] = vec4(pos.x, pos.y, 1.0, 1.0);
	gl_FragData[3] = vec4(vec3(1.0,0.0,1.0)+fNormal*fPosition*MaterialColor, Material.z + 1.0);
}
