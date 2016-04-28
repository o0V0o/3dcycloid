precision highp float;

varying vec3 fPosition; //fragment position in *eye* space.

uniform vec3 color;

void main(){
	
	gl_FragColor = vec4( color, min(1.0, max(1.0,(1.0+fPosition.x))));
}
