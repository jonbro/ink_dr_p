extern Image posTexture;
attribute float SpriteCount;
attribute float PointCorner;
extern float particleCountSQRT;
vec3 hsv2rgb(vec3 c)
{
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}
vec4 position( mat4 transform_projection, vec4 vertex_position )
{
	// get the position of the current sprite out of the position texture
	vec4 lookup = Texel(posTexture, vec2(mod(SpriteCount,particleCountSQRT)*1.0/particleCountSQRT+1/512.0, floor(SpriteCount/particleCountSQRT)/particleCountSQRT+1/512.0));
	float size = lookup.b * 20;
	if(size < 0.01)
		return vec4(0,0,0,0);
	vertex_position = vec4(1,1,1,1);
	vertex_position.xy = lookup.rg*love_ScreenSize.rg - size*0.5;
	vertex_position.z = 1;
	vertex_position.a = 1;
	// build vert out into a sprite
	//VaryingColor = vec4(hsv2rgb(vec3(mod(SpriteCount*0.00001+lookup.b*0.8, 1), 1-(lookup.b*3-1.5), 1)), 1-lookup.b*0.8);
	VaryingColor = vec4(1-(lookup.b*3-1.5),(lookup.b*3-1.5),1,1-lookup.b*0.8);
	// build a point sprite
	int vertCount = int(PointCorner);
	if(vertCount == 1 || vertCount == 2){
		vertex_position.x += size;
		VaryingTexCoord.x = 1;
	}
	if(vertCount == 2 || vertCount == 3){
		vertex_position.y += size;
		VaryingTexCoord.y = 1;
	}

    return transform_projection * vertex_position;
}
