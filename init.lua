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
local vec2, vec3, vec4 = Vector.vec2, Vector.vec3, Vector.vec4
print("loaded modules")

local k = 5
--load models
local pitchSphere = SimpleObject( M.load("models/sphere.obj"))
local generatingSphere = SimpleObject( M.load("models/sphere.obj"))
--local generatingSphere = SimpleObject( M.load("drawlib/suzanne-cubemap.obj"))
--local outerSphere = SimpleObject( M.load("models/sphere.obj"))
--local innerSphere = SimpleObject( M.load("models/sphere.obj"))
print("loaded models")

local scene = {generatingSphere, pitchSphere}

local camera = Camera( 0.001, 100, 45 )
camera.position = vec3(5,-5,-10)
camera:lookat(vec3(0,0,0))

--load shaders
local shader = Shader('shaders/simple.vs', 'shaders/phong.fs')
local ptShader = Shader('shaders/points.vs', 'shaders/points.fs')
--local shader = Shader('shaders/simple.vs', 'shaders/red.fs')
for _,obj in pairs(scene) do
	obj:recalculate(shader)
end

--keep track of fps and memory info
local countFrames = require("fpscounter")

gl.glEnable(gl.GL_DEPTH_TEST)
gl.glClearColor(0,0,0,1)
--show animation of sphere rolling in a sphere.

--set one-time uniforms
--shader.lightPosition = vec3(3,3,3.2)
shader.lightPosition = {3,3,3.2}
shader.lightColor = {1,1,1,10}
shader.materialProperties = {1,1,0.2,10}
shader.materialColor = {1,1,1}
shader.attenuation = {0.9, 0.8}

ptShader.pointSize = 5
ptShader.color = {1,1,1}

local transform = Matrix.identity(4)
local z, dz = -2, 0.15
local x, dx = 0, 0.1
local y, dy = 0,0.05
local function testPointCloud()
	local pts = require("pointcloud")()
	local function rand()
		return (math.random()*2)-1
	end
	print("generating points")
	for i=1,1 do
		local pt = vec3( rand(), rand(), rand() )
		pt:normalize()
		pt:scale(math.random()+1)
		pts:add( pt )
	end

	return pts
end
local ptCloud = testPointCloud()
local ptCloudTest = testPointCloud()
local sphereTransform = Transformation():scale(1/k)

local function epicycloid(theta, phi,k)
	local rTheta = Quaternion.axisAngle(vec3(0,1,0), theta)
	local rGenTheta = Quaternion.axisAngle(vec3(0,1,0), theta*k)

	--local origin = rPhiMat4*rThetaMat4*vec4(0,0,1+1/k, 0.0)
	local origin = rTheta:matrix()
	origin = origin.mult( vec4(0,0,1+1/k, 0), origin)
	origin = origin.xyz

	local v = rGenTheta:matrix()
	v = v.mult( vec4(0,0,1/k,0), v)
	v=v.xyz

	sphereTransform.position = origin
	sphereTransform.dirty = true

	return origin + v
end

local function testfunc(theta,phi)
	local transform = Quaternion.axisAngle(vec3(0,1,0), theta):matrix()
	local result = transform.mult( vec4(0,0,1.5,0), transform)
	result =  vec3(result.usrdata[0], result.usrdata[1], result.usrdata[2])
	return result, transform
end

local theta, dtheta = 0, 0.1
local phi, dphi = 0, 0.1
local function render()
	gl.viewport(0,0,gl.canvas.width, gl.canvas.height)
	countFrames()
	gl.glClear(gl.GL_COLOR_BUFFER_BIT + gl.GL_DEPTH_BUFFER_BIT)

	theta = theta + dtheta
	--ptCloudTest:add( testfunc(theta,phi) )
	--ptCloud:add( epicycloid(theta,phi,5) )
	epicycloid(theta, phi, k)


	shader:use()
	shader.view = camera.view
	shader.perspective = camera.perspective


	shader.model = Matrix.identity(4)
	pitchSphere:draw(shader)

	shader.model = sphereTransform:matrix()
	generatingSphere:draw(shader)

	--[[
	ptShader:use()
	ptShader.view = camera.view
	ptShader.perspective = camera.perspective
	ptShader.model = Matrix.identity(4)
	ptCloud:draw(ptShader)
	--]]

	js.global:requestAnimationFrame(render)
end
render()




