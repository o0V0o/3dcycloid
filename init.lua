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

local k = 10
--load models
local pitchSphere = SimpleObject( M.load("models/sphere.obj"))
local generatingSphere = SimpleObject( M.load("models/sphere.obj"))
--local generatingSphere = SimpleObject( M.load("drawlib/suzanne-cubemap.obj"))
--local outerSphere = SimpleObject( M.load("models/sphere.obj"))
--local innerSphere = SimpleObject( M.load("models/sphere.obj"))
print("loaded models")

local scene = {generatingSphere, pitchSphere}

local camera = Camera( 0.001, 100, 45 )
camera.position = vec3(5,-5,-5)
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
local theta, dtheta, ntheta = 0, 0.1, 300
local phi, dphi, nphi = 0, 0.002, 100

math.randomseed( platform.time() )

local ptCloud = require('pointcloud')()
local ptCloudRand = require('pointcloud')()

local cycloid = require("cycloid")(5)

local function rand()
	return (math.random()*2)-1
end
local axis = vec3(rand(), rand(), rand()):normalize()

gl.viewport(0,0,gl.canvas.width, gl.canvas.height)

local ptCloudRand = require('pointcloud')()
local lobeGen = require('lobegen')
local ptGen


local N, dn = 3*math.pi/4, 0.1
N=1.24
N=math.pi*70.53/180
--N=math.pi * 0.1
--N=math.pi*3/4
--N=3/4
require('eventhandler')("next", "click", function()
	print("click")
	ptGen = coroutine.create( lobeGen )
	ptCloudRand = require("pointcloud")()
	print("N=",N, N/math.pi)
	while coroutine.status(ptGen)~="dead" do
		assert(	coroutine.resume(ptGen,3, ptCloudRand, N))
	end
	N=N+dn
end)

rawset(_G, "white", ptCloud)
rawset(_G, "red", ptCloudRand)
rawset(_G, "Quaternion", Quaternion)
rawset(_G, "vec3", vec3)

local function render()
	--countFrames()

	gl.glClear(gl.GL_COLOR_BUFFER_BIT + gl.GL_DEPTH_BUFFER_BIT)
	--cycloid:rotate(axis, dtheta)
	--ptCloud:add( cycloid:point() )



	shader:use()
	shader.view = camera.view * trackball:transform()
	shader.perspective = camera.perspective
	--draw the pitch sphere
	shader.model = Matrix.identity(4)
	pitchSphere:draw(shader)
	--draw the generating sphere
	--shader.model = sphereTransform:matrix()
	--generatingSphere:draw(shader)

	ptShader:use()
	ptShader.view = camera.view * trackball:transform()
	ptShader.perspective = camera.perspective
	ptShader.model = Matrix.identity(4)
	ptShader.color = {1,1,1}
	ptCloud:draw(ptShader)

	ptShader.color = {1,0,0}
	ptCloudRand:draw(ptShader)

	js.global:requestAnimationFrame(render)
end
render()




