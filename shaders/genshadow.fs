#extension GL_EXT_draw_buffers : require
precision highp float;

varying vec3 fNormal;	//fragment normal direction
varying vec3 fPosition; //fragment position in *eye* space.

void main(){
	float d = length(fPosition);
	gl_FragColor = vec4(d,d,d, 1.0+(fNormal*fPosition)); //store depth value
}
