        vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords )
        {
            vec4 texcolor = Texel(texture, texture_coords);
            return vec4(color.rgb,texcolor.a*0.1*color.a);
        }
