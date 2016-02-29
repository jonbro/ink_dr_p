extern vec2 mousePos;
extern float spawnOffset;
extern Image velTexture;
extern Image curlNoise;
extern float particleCount;
extern float particleCountSQRT;
float rand(vec2 co){
		return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

void effects(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
{
  float spawnCount = 100;
  float IspawnOffset = mod(spawnOffset*spawnCount, particleCount);
  float particleIndex = mod(texture_coords.x*particleCountSQRT+texture_coords.y*particleCount, particleCount);
  bool spawning = particleIndex>IspawnOffset && particleIndex < IspawnOffset+spawnCount;
  vec4 o = Texel(texture, texture_coords);
  if(!spawning && o.b < 0.001)
    discard;
  o.b *= 0.999;
  vec4 vTex = Texel(velTexture, texture_coords);
  o.xy += vTex.xy;
  // slow down the particles
  vTex.xy *= 0.5;
  // add gravity
  vTex.y += 0.0005;

  // get a velocity from the curl noise texture
  vTex.xy += Texel(curlNoise, o.xy*0.75+0.125).xy*0.002*(vTex.z);
  
  // alternate velocity lookup
  //float dist = length(mousePos-o.xy);
  //vTex.xy += (mousePos-o.xy)*(vTex.z+1)*(o.b+2)*0.002*(1/sqrt(dist));
  // add a velocity vector towards the mouse
  love_Canvases[0] = o;
  love_Canvases[1] = vTex;

  if(spawning){
    love_Canvases[0] = vec4(mousePos.x, mousePos.y, 1, 1); // 
    float pCount = (particleIndex-IspawnOffset)/spawnCount;
  	love_Canvases[1] = vec4(rand(vec2(particleIndex*7, particleIndex*3))*0.1, 0,pCount,1);
	}
}
