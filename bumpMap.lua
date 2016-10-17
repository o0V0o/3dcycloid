local Matrix = require'matrix'
local Shader = require'shader'
local platform = require'platform'
local gl = require'openGL'
local vec3 = require'vector'.vec3
local G = require'drawlib'


local shader = Shader('shaders/tangent.vs', 'shaders/bumpMap.fs')

local obj
local tex
local bumpMap = {}
function bumpMap.setup(object, textures)
	-- set uniform values!
	shader:use()

	shader.color = {1,0,0}
	shader.specColor = {1,1,1}
	shader.shininess = 10
	shader.kDiffuse = 1
	shader.kSpecular = 1.5
	shader.kAmbient = 0.3
	shader.diffuseTexture = textures.color:bind()
	shader.normalTexture = textures.normalMap:bind()
	shader.U = {1,0,0}
	shader.V = {0,1,0}

	shader.view = Matrix.lookat( vec3(0,0,5), vec3(0,0,0), vec3(0,1,0) )
	shader.perspective = Matrix.perspective(0.1,100,gl.canvas.clientWidth/gl.canvas.clientHeight, 45)
	shader.model = Matrix.identity(4)
	shader.texture = Matrix.identity(4)

	--shader.perspective = Matrix.perspective(...)
	object:recalculate(shader)
	obj = object
	tex = textures.normalMap
	--drawtexture(displayShader, tex, nil, true)
	gl.glClearColor(1,1,1,1)
end

local last, frames = 0,0 --keep track of FPS
function bumpMap.render()
	frames = frames + 1
	local now = platform.time()
	if now-last >= 1000 then
		print(frames, "fps.")
		frames=0
		last = now
		collectgarbage()
		print("memory used",collectgarbage('count'), "KiB")
		gl.viewport(0,0,gl.canvas.width, gl.canvas.height)
	end
	shader.depthScale = math.max(math.pow(js.global.document:getElementById("diff").value, 2)/10000, 0.000000001)
	shader.overlay = js.global.document:getElementById("opq").value/100
	G:clear()
	shader.model = trackball:transform()
	obj:draw(shader)
end

return bumpMap
