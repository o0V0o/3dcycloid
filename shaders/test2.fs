#extension GL_EXT_draw_buffers : require
precision highp float;

varying vec3 fNormal;	//fragment normal direction
varying vec3 fPosition; //fragment position in *eye* space.

uniform sampler2D textures[5];

uniform float canvasWidth;
uniform float canvasHeight;

uniform int bufferIdx;


void main(){
	//calculate this fragment's position in the 0-1 range for
	//texture lookups.
	vec2 pos = vec2(gl_FragCoord.x/canvasWidth, gl_FragCoord.y/canvasHeight);

	vec4 V; //note that V=texture2D(textures[bufferIdx]), pos) is an error
			//we can't index array's by non-constant expressions
	if(bufferIdx==0){ V=texture2D(textures[0], pos);}
	else if(bufferIdx==1){ V=texture2D(textures[1], pos);}
	else if(bufferIdx==2){ V=texture2D(textures[2], pos);}
	else if(bufferIdx==3){ V=texture2D(textures[3], pos);}
	else if(bufferIdx==4){ V=texture2D(textures[4], pos)/30.0;}
	//and now some special cases..
	else if(bufferIdx==5){ V=vec4(texture2D(textures[0], pos).w/100.0);}

	/* alternatively, use a weird loop??
	//for some reason we have to access this in
	//a for loop to avoid not indexing the value
	//array by a "non-constant" expression....
	//vec4 V=values[bufferIdx]; //this is an error??
	vec4 V;
	for(int i=0;i<4;i++){
		 V = texture2D(textures[i],pos);//but this isn't an error. 
										//I assume it's some sort of
										//loop unrolling going on to make
										//this a constant expression.
		 if(i == bufferIdx){break;}
	}
	*/

	//note that we *have* to use fNormal and fPosition or the attributes
	//won't be used, and we get index out of bounds problems when
	//we render.

	gl_FragColor = vec4(V.xyz,1.0 + (fNormal*fPosition).z);
}
