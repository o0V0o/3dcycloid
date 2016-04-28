precision highp float;

varying vec3 fNormal;	//fragment normal direction
varying vec3 fPosition; //fragment position in *eye* space.

#define NLIGHTS 10

uniform vec3 LightPosition[NLIGHTS];
uniform vec4 LightColor[NLIGHTS];

uniform mat4 cameraview;

uniform sampler2D textures[4];
uniform float canvasWidth;
uniform float canvasHeight;

uniform float aspectRatio;
uniform float cameraFOV;

uniform int bufferIdx;

uniform vec2 attenuation;

vec3 phong(vec3 lightPosition, vec4 lightColor, vec4 material, vec3 materialColor, vec3 position, vec3 normal, vec3 v, vec2 attenuationVals){
	
	//calculate attenuation
	float distanceLightToFragment = length(lightPosition - position);
	float attenuation = lightColor.w / ((attenuationVals.x * distanceLightToFragment) + (attenuationVals.y * pow(distanceLightToFragment, 2.0)));

	if (attenuation > 0.01){
		//transform light in world space ot eye space.
		vec3 light = lightPosition;

		//calculate all our direction vectors
		//vec3 v = -normalize(position);
		vec3 n = normalize( normal );
		vec3 l = normalize(light-position);// vector to light source
		vec3 r = normalize(reflect(l,n));

		//calculate diffuse/specular components based on view/normal/light vectors
		float diffuse = max( dot(l,n), 0.0 );
		float specular = max(dot(r,v), 0.0);
		specular = pow( specular, material.w);

		//mix all three comonents together
		vec3 lightContribColor = lightColor.rgb * materialColor.rgb;
		vec3 diffuseComponent = material.x*diffuse*lightContribColor;
		vec3 specularComponent = material.y*specular*lightContribColor;
			
		

		vec3 intensity = (diffuseComponent + specularComponent) * attenuation;
		return intensity;
	}
	return vec3(0.0, 0.0, 0.0);
}
vec3 depthTo3D(vec2 pos, float depth){
	pos = (pos*2.0)-1.0;
	float f = tan( cameraFOV/2.0  );
	vec3 xDir = vec3(f, 0.0 , 0.0);
	vec3 yDir = vec3(0.0, f/aspectRatio, 0.0);
	vec3 cameraDir = vec3(0.0, 0.0, -1.0);
	vec3 raydir = cameraDir + (pos.y * yDir) + (pos.x * xDir);
	raydir = normalize(raydir);
	return raydir * depth;
}

void main(){
	vec2 pos = vec2( gl_FragCoord.x/canvasWidth, gl_FragCoord.y/canvasHeight);
	//vec3 position = texture2D(textures[0], pos).xyz;
	//where texture[0].w = the depth at that pixel.
	vec3 position = vec3(0.0, 0.0, 0.0);
	if(bufferIdx==0){
		position = texture2D(textures[0], pos).xyz;
	}else{
		position = depthTo3D(pos, texture2D(textures[0], pos).w);
	}
	vec3 viewDir = -normalize(position);

	vec3 normal = texture2D(textures[1], pos).xyz;
	vec3 MaterialColor = texture2D(textures[2], pos).xyz;
	vec4 Material = texture2D(textures[3], pos);

	vec3 ambientComponent = Material.z*MaterialColor;
	vec3 sumColor = ambientComponent;

	for(int i = 0; i < NLIGHTS; i++){
		sumColor += phong(LightPosition[i] , LightColor[i], Material, MaterialColor, position, normal, viewDir, attenuation);
	}


	gl_FragColor = vec4( sumColor, 1.0+(fNormal*fPosition).x);
}
