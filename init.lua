print("starting")
-- need to add the path to our drawing library
package.path = "/drawlib/?.lua;?.lua"

-- and add a way to *load* said library.
require("httploader")


require('strict')
local gl = require("openGL")
local SimpleObject = require("SimpleObject")
local Quaternion = require("quaternion")
local Vector = require("vector")
local Camera = require("camera")
local Shader = require("shader")
local Matrix = require("matrix")
local Transformation = require('transformation')
local M = require('mesh')
local Trackball = require("trackball")
local class = require('object')
local platform = require('platform')
local trackball = Trackball(gl.canvas)

local vec2, vec3, vec4 = Vector.vec2, Vector.vec3, Vector.vec4
print("loaded modules")
local camera = Camera( 0.001, 100, 45 )
camera.position = vec3(0,0,-10)
camera:lookat(vec3(0,0,0))

--load shaders
local shader = Shader('shaders/simple.vs', 'shaders/phong.fs')
local ptShader = Shader('shaders/points.vs', 'shaders/points.fs')
--keep track of fps and memory info
local countFrames = require("fpscounter")
--enable typical gl stuff
gl.glEnable(gl.GL_DEPTH_TEST)
gl.glClearColor(0,0,0,1)
gl.viewport(0,0,gl.canvas.width, gl.canvas.height)
--set one-time uniforms
shader.lightPosition = {3,3,3.2}
shader.lightColor = {1,1,1,10}
shader.materialProperties = {1,1,0.2,10}
shader.materialColor = {1,1,1}
shader.attenuation = {0.9, 0.8}

ptShader.pointSize = 5
ptShader.color = {1,1,1}
local ptCloud = require('pointcloud')()
local innerElement = require('polyline')()
local ptCloudRed = require('pointcloud')()
local ptCloudBlue = require('pointcloud')()
local outerCam = require('polyline')()
local outerCam2 = require('polyline')()
ptCloudRed:add(vec3(0,0,0))
ptCloudBlue:add(vec3(0,0,0))
local Cam = require'cam'
local VariableCam = require'variablecam'
local Functions = require'functions'


--local cam = Cam(0.5, -1, 0, 0)
local dt = 2*math.pi/3
local transfer = 0.3 --time to switch between fast and slow.
--local fast, slow = 1.75, 1.2
--local fast, slow = 1.5, 1
local fast, slow = 3,0.5
--local fast, slow = 1,1

--return a linear spline function that has been normalized
--so the integration over 1 period is set to **ratio**
local function Normalized(points, ratio)
	local func = Functions.LinearSpline(points)
	local integral = func:integrate(2*math.pi)/(2*math.pi)
	local factor = ratio/integral
	print("integral",integral, factor, ratio)

	local newpoints = {}
	for idx,pt in pairs(points) do
		--pt:scale(factor)
		newpoints[idx] = vec2(pt.x, pt.y*factor)
		print(pt, newpoints[idx])
		--points[idx] = pt*factor
	end
	func = Functions.LinearSpline(newpoints)
	print("new integral", func:integrate(2*math.pi)/(2*math.pi))
	return func
end
--local testSpline = Normalized({ vec2(0, slow), vec2(0+transfer, fast), vec2(2*dt, fast), vec2(2*dt + transfer, slow), vec2(3*dt, slow)}, 0.5)
local testSpline = Normalized({ vec2(0, slow), vec2(0+transfer, fast), vec2(0+transfer+0.1, fast), vec2(0+transfer+0.2+transfer, slow), vec2(3*dt, slow)}, 0.5)

--[[
--local testSpline = Functions.LinearSpline({ vec2(0,slow), vec2(dt, fast), vec2(2*dt, fast), vec2(3*dt, slow)})
local integral = testSpline:integrate(2*math.pi)/(2*math.pi)
print("integral", integral)

--adjust to integrate to exactly 1
local ratio = 0.5
fast, slow = ratio*fast/integral, ratio*slow/integral
print("fast", fast, "slow", slow)
--local testSpline = Functions.LinearSpline({ vec2(0,slow), vec2(dt, fast), vec2(2*dt, fast), vec2(3*dt, slow)})
--local testSpline = Functions.LinearSpline({ vec2(0,slow), vec2(dt, fast), vec2(2*dt, fast), vec2(3*dt, slow), vec2(4*dt, slow)})
local integral = testSpline:integrate(2*math.pi)/(2*math.pi)
print("integral", integral)


--local testspeeds = testSpline
local testspeeds = Functions.Periodic(Functions.LinearSpline({ vec2(0,reverse), vec2(dt, reverse), vec2(2*dt, forward), vec2(3*dt, forward), vec2(4*dt, reverse)}), 2*math.pi)

--local cam = Cam(0.1, 3/2, 0, 1)
--]]
local testspeeds = Functions.Periodic(testSpline, 2*math.pi)
local cam = VariableCam(0.2, testspeeds, 1, 0)

local transform = cam:transformation()

local steps, period = 200, math.pi*4
local stepsize = period/steps
local function step()
	cam:rotate(stepsize)
	--ptCloud:addPoints( cam:debugPoints() )
	innerElement = require('polyline')( cam:debugPoints() )
	ptCloudRed:add( cam:points()[2] )
	ptCloudBlue:add( cam:points()[1] )
	outerCam:add( cam:points()[1] )
	outerCam2:add( cam:points()[2] )
	transform = cam:transformation()
	--ptCloudRed:setPoints( table.insert(cam:points(), 0, vec3(0,0,0))
end

require("eventhandler")("next", "click", step)

--expose some things globally for debug
rawset(_G, "white", ptCloud)
rawset(_G, "red", ptCloudRed)
rawset(_G, "Quaternion", Quaternion)
rawset(_G, "vec3", vec3)

local i = 0
local function render()
	countFrames()
	i=i+1
	step()

	gl.glClear(gl.GL_COLOR_BUFFER_BIT + gl.GL_DEPTH_BUFFER_BIT)

	ptShader:use()
	ptShader.view = camera.view * trackball:transform()
	ptShader.perspective = camera.perspective
	ptShader.model = Matrix.identity(4)

	ptShader.color = {1,1,1}
	innerElement:draw(ptShader)

	ptShader.model = transform
	ptShader.color = {0.15,0.6,1}
	--ptCloudBlue:draw(ptShader)

	ptShader.color = {1,0,0}
	--ptCloudRed:draw(ptShader)

	ptShader.color = {1,0,0}
	outerCam:draw(ptShader)
	outerCam2:draw(ptShader)

	if i<steps then js.global:requestAnimationFrame(render) end

end
render()




