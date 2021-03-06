precision highp float;

attribute vec3 position;
attribute vec3 normal;

uniform mat4 perspective;
uniform mat4 model;
uniform mat4 view;

varying vec3 fNormal;
varying vec3 fPosition;
varying vec3 fPositionWorld;

void main()
{
	mat4 MV = view * model;
	mat4 MVP = perspective * MV;

	vec4 pos = vec4(position.xyz, 1.0); //make sure position is augmented with 1

	gl_Position = MVP * pos;

	fNormal = (MV * vec4(normal, 0.0)).xyz; //normal is augmented with 0
	fPosition = (MV * pos).xyz;
	fPositionWorld = (model * pos).xyz;
}

