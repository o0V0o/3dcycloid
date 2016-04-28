precision highp float;

attribute vec3 position;

uniform mat4 perspective;
uniform mat4 model;
uniform mat4 view;

uniform float pointSize;

varying vec3 fPosition;


void main()
{
	mat4 MV = view * model;
	mat4 MVP = perspective * MV;

	vec4 pos = vec4(position.xyz, 1.0); //make sure position is augmented with 1
	fPosition = (MV * pos).xyz;

	gl_Position = MVP * pos;
	gl_PointSize = pointSize;

}

