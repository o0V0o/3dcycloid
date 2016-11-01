print("starting")
-- need to add the path to our drawing library
package.path = "/drawlib/?.lua;?.lua"

-- and add a way to *load* said library.
require("httploader")


require('strict')
local gl = require("openGL")
local Quaternion = require("quaternion")
local Vector = require("vector")
local Camera = require("camera")
local Shader = require("shader")
local Matrix = require("matrix")
local Transformation = require('transformation')
local platform = require('platform')
local Functions = require'functions'

local vec2, vec3, vec4 = Vector.vec2, Vector.vec3, Vector.vec4
print("loaded modules")
local camera = Camera( 0.001, 100, 45 )
camera.position = vec3(0,0,-10)
camera:lookat(vec3(0,0,0))

--load shaders
local ptShader = Shader('shaders/points.vs', 'shaders/points.fs')
--keep track of fps and memory info
local countFrames = require("fpscounter")
--enable typical gl stuff
gl.glEnable(gl.GL_DEPTH_TEST)
gl.glClearColor(0,0,0,1)
gl.viewport(0,0,gl.canvas.width, gl.canvas.height)
--set one-time uniforms
ptShader.pointSize = 5
ptShader.color = {1,1,1}



local plot1 = require('polyline')()
local plot2 = require('polyline')()
local plot3 = require('polyline')()
local plot4 = require('polyline')()
local fast, slow = 2, 0.5

local ratio1 = Functions.Periodic(Functions.LinearSpline({vec2(0,fast), vec2(2*math.pi, slow)}), 2*math.pi)
local ratio2  = Functions.Periodic(Functions.LinearSpline({vec2(0,slow), vec2(2*math.pi, fast)}), 2*math.pi)

local function step(angle)
	local gear1 = ratio1:integrate(angle)
	local gear2 = ratio2:integrate(gear1)

	plot1:add( vec3(angle, angle, 0))
	plot2:add( vec3(angle, gear1, 0))
	plot3:add( vec3(angle, gear2, 0))
	plot4:add( vec3(angle, ratio2:get(gear1), 0))
	print( gear2/angle )
end

local i=0
local function render()
	collectgarbage() --by gc'ing every frame, we get (higer) more consistent framerates (23 vs 30 fps)
	countFrames()
	i=i+0.1

	step(i)

	gl.glClear(gl.GL_COLOR_BUFFER_BIT + gl.GL_DEPTH_BUFFER_BIT)

	ptShader:use()
	ptShader.view = camera.view
	ptShader.perspective = camera.perspective
	ptShader.model = Matrix.identity(4):scale(0.1)

	ptShader.color = {1,1,0}
	plot1:draw(ptShader)
	ptShader.color = {0,1,0}
	plot2:draw(ptShader)
	ptShader.color = {0,1,1}
	plot3:draw(ptShader)
	ptShader.color = {1,1,1}
	plot4:draw(ptShader)

	js.global:requestAnimationFrame(render)
end
render()




