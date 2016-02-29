# ink_dr_p

A GPU particle implementation for love2d.

# details

The meat of this project is in three parts.
* A set of position / velocity fbos, and the shader code that updates them (in physics_frag.glsl)
* A mesh which renders the contents of the position fbo to the screen, and the shader which builds out the contens of that mesh (in render_vert.glsl and render_frag.glsl)
* A shader which generates a field of curl noise into an fbo, which then drives the velocity of the particles

The things that are strange about this implementation are mostly based on the fact that love2d doesn't have a geometry shader to generate vertexs to pass on to the next shader stage. Because of that, we generate all the verts that we will need for displaying every particle, and store them in a mesh. Each frame, the mesh vert shader checks the associate pixel from the position fbo (which also contains information about the age of the particle), and updates the vert positions.

Curl Noise implementation contains code from https://github.com/cabbibo/glsl-curl-noise/blob/master/curl.glsl and https://github.com/ashima/webgl-noise/tree/master/src

# further work

Right now, the particle forces are pretty simple. You could also drive the particles from meshes or SDFs if you wanted to display objects with them. More potential work would be to add light and shadow to the particles, using techniques from https://directtovideo.wordpress.com/2009/10/06/a-thoroughly-modern-particle-system/
