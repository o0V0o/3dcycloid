precision highp float;

varying vec3 fNormal;	//fragment normal direction
varying vec3 fPosition; //fragment position in *eye* space.

float lulz(){
	return 1.0 + (fNormal+fPosition).x;
	return max( 1.0, min(1.0, 1.0 + (fNormal+fPosition).x));
}
void main(){
	
	gl_FragColor = vec4( 1.0, 0.0, 0.0, lulz());
}
