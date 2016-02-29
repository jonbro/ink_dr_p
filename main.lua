local brush;
local mesh, mainShader, physicsShader, curlShader;
local cnvs_posA, cnvs_posB, cnvs_velA, cnvs_velB;
local particleCountSQRT = 512
local particleCount = particleCountSQRT*particleCountSQRT
local debug = false

function love.load()
  brush = love.graphics.newImage("particle.png")
	physicsShader = love.graphics.newShader("physics_frag.glsl")
  curlShader = love.graphics.newShader("curl_frag.glsl")
  mainShader = love.graphics.newShader("render_frag.glsl", "render_vert.glsl")

  -- generate the mesh data that will draw the particles out of the fbo
  local meshData = {}
  local vertMap = {}
  local numVerts = particleCount
  for i=0,(numVerts*4)-1 do
  	table.insert(meshData,{0,0, 0,0, i%4, math.floor(i/4)})
  end
  for i=0,numVerts-1 do
  	table.insert(vertMap, i*4+2)
  	table.insert(vertMap, i*4+2)
  	table.insert(vertMap, i*4+1)
  	table.insert(vertMap, i*4+3)
  	table.insert(vertMap, i*4+4)
  	table.insert(vertMap, i*4+4)
  end
  mesh = love.graphics.newMesh({{"VertexPosition", "float", 2}, {"VertexTexCoord", "float", 2}, {"PointCorner", "float", 1}, {"SpriteCount", "float", 1}}, meshData, "strip")
  mesh:setVertexMap(vertMap)

  -- nil these out so they can be gc'd
  meshData = nil
  vertMap = nil

  -- generate the fbos
  cnvs_posA = createCanvas()
  cnvs_posB = createCanvas()
  cnvs_velA = createCanvas()
  cnvs_velB = createCanvas()
  cnvs_curl = createCanvas(64,64, "linear")
  cnvs_curl:setWrap("repeat", "repeat")
  if not debug then
    -- success = love.window.setMode( 0,0, {fullscreen=true} )
  end

end
function createCanvas(x,y,scale)
	local c = love.graphics.newCanvas(x or particleCountSQRT,y or particleCountSQRT,"rgba16f")
	c:setFilter(scale or "nearest", scale or "nearest")
	return c
end
 local drawCount = 0
function love.draw()
	love.graphics.setBlendMode("alpha")
  -- draw the curl noise into a canvas
  love.graphics.setCanvas(cnvs_curl)
  love.graphics.setShader(curlShader)
  curlShader:send("count", drawCount)
  love.graphics.draw(brush, 0,0)

  -- setup the physics drawing pass
  -- need to use ping pong fbos, because fbos cant draw into themselves
	cnvs_ping, cnvs_pong, cnvs_ping_v, cnvs_pong_v = cnvs_posA, cnvs_posB, cnvs_velA, cnvs_velB
	if drawCount%2 == 1 then
		cnvs_ping, cnvs_pong, cnvs_ping_v, cnvs_pong_v = cnvs_posB, cnvs_posA, cnvs_velB, cnvs_velA
	end
	
	love.graphics.setCanvas(cnvs_ping, cnvs_ping_v)
	love.graphics.setShader(physicsShader)
	physicsShader:send("spawnOffset", drawCount)
  -- if you want to have the mouse provide gravity, use this
	-- physicsShader:send("mousePos", {love.mouse.getX()/love.graphics.getWidth(), love.mouse.getY()/love.graphics.getHeight()})
	physicsShader:send("mousePos", {0.5, 0})
	physicsShader:send("velTexture", cnvs_pong_v)
	physicsShader:send("particleCount", particleCount)
	physicsShader:send("particleCountSQRT", particleCountSQRT)
  physicsShader:send("curlNoise", cnvs_curl)
	love.graphics.draw(cnvs_pong, 0,0,0,1,1)
	drawCount = drawCount+1
	
  -- draw the main mesh
	love.graphics.setCanvas()
  love.graphics.setShader(mainShader)
  mainShader:send("posTexture", cnvs_ping)
  mainShader:send("particleCountSQRT", particleCountSQRT)
  mesh:setTexture(brush)
  love.graphics.setBlendMode("add")
	love.graphics.draw(mesh)
	if debug then
    love.graphics.setShader()
    love.graphics.setBlendMode("alpha")
		love.graphics.draw(cnvs_ping, 0,0, 0, 1, 1)
		love.graphics.draw(cnvs_ping_v, 0,particleCountSQRT, 0, 1, 1)
    love.graphics.draw(cnvs_curl, 256, 0, 0, 1, 1)
		love.graphics.print((drawCount-1)%particleCountSQRT, 10, 10)
    love.graphics.print("Current FPS: "..tostring(love.timer.getFPS( )), 10, 30)
	end
   
end
function love.keypressed()
  -- love.event.push ("quit")
end

