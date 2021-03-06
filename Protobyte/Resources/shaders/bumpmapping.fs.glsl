#version 430

in vec4 vertCol; // orig attribute color set in v. shader
out vec4 color;

// Texture maps
uniform bool shadowPassFlag;
uniform sampler2DShadow shadowMap;
uniform sampler2D diffuseMap;
uniform sampler2D bumpMap;

//uniform float bumpIntensity;

in vec4 shadowMapCoords;


// max 8 lt srcs (fer now...)
struct Light {
	vec3 position;
	vec3 intensity;
	//vec4 diffuse;
	//vec4 ambient;
	//vec4 specular;
};

// currently max 8 lts
uniform Light lights[8];

// global ambient light
uniform vec3 globalAmbientLight;

// materials
uniform vec4 diffuseMaterial;
uniform vec4 ambientMaterial;
uniform vec4 specularMaterial;
uniform vec4 emissiveMaterial;
uniform float shininess;

//uniform bool isShadowEnabled;

// multiplier to null out lighting factors for 2D rendering
// diffuse, specular, ambientMat, globalAmbientLight
// avoids need for conditional testing
// 3D default: (1,1,1,1)
// 2D default: (0,0,0,0)
uniform vec4 lightRenderingFactors;




in VS_OUT
{
    vec2 texcoord;
    vec3 eyeDir;
    vec3 lightDir[8];
    vec3 normal;
} fs_in;



void main(void)
{

	// check for shadow pass
	if(shadowPassFlag){
		return;
	}
	
	vec3 diffuse = vec3(0);
	vec3 specular = vec3(0);
	vec3 diffuse_color = vec3(0);
	vec3 N = vec3(0);

	for(int i=0; i<8; ++i){
		// Normalize our incomming view and light direction vectors.
		vec3 V = normalize(fs_in.eyeDir);
		vec3 L = normalize(fs_in.lightDir[i]); // ***********multi here
    
		// Calculate diffuse color with simple N dot L.
		// Read the normal from the normal map and normalize it.
		 N = normalize(texture(bumpMap, fs_in.texcoord).rgb * 2.0f - vec3(1.0));
    
		// Calculate R ready for use in Phong lighting.
		vec3 R = reflect(-L, N); 

		// Fetch the diffuse color from the texture.
		diffuse_color = texture(diffuseMap, fs_in.texcoord).rgb;
		diffuse += max(dot(N, L), 0.0) * diffuse_color * vec3(diffuseMaterial) * lights[i].intensity; 
		
		// Calculate Phong specular highlight
		specular += max(pow(dot(R, V), shininess), 0.0) * vec3(specularMaterial) * lights[i].intensity;
	}
	
	//check the shadow map texture to see if the fragment is in shadow
	if(shadowMapCoords.w>1.0f) {

		vec4 shadCoords = shadowMapCoords;
		//check the shadow map texture to see if the fragment is in shadow
		//shadCoords.z += 10.5f;
		float shadow = textureProj(shadowMap, shadCoords);
		//darken the diffuse component apprpriately

		//if(shadCoords.z > 1000.0){
			//shadow = 0.0;
		//}


		diffuse = mix(diffuse, diffuse*shadow, 0.33); 
	}

    // Final color is diffuse + specular + ambient with lightRendering Factors enabling/disabling lighting effects for 2D rendering

	color = vertCol*lightRenderingFactors.w + vec4(diffuse*lightRenderingFactors.x + specular*lightRenderingFactors.y + (vec3(ambientMaterial)*globalAmbientLight)*lightRenderingFactors.z, 1.0);

	//vec3 c = texture(bumpMap, fs_in.texcoord).rgb;
	//color = vec4(c, 1.0);
	//color = vec4(diffuse_color, 1.0);

	color.a = vertCol.a;


}
