local eventListener = require('eventhandler')
local class = require('object')
local Quaternion = require('quaternion')
local Vector = require('vector')

local vec2, vec3, vec4 = Vector.vec2, Vector.vec3, Vector.vec4

local Trackball = class()

function Trackball:__init(canvas)
	self.rotation = Quaternion()
	self.translate = vec3()
	js.global.Trackball:register(canvas)
end

local up = vec3(0,0,1)
local pt = vec3(0,0,0)
function Trackball:mousePos()
	local mousepos = js.global.Trackball:mousePos()
	return vec3(mousepos[0], mousepos[1],0)
end
function Trackball:transform2D()
	local mousemotion = js.global.Trackball:motion()
	local dx,dy = -mousemotion[0], mousemotion[1]
	local usrdata = self.translate.usrdata
	usrdata[0] = dx
	usrdata[1] = dy
	js.global.Trackball:reset()
	return self.translate
end
function Trackball:transform()
	local mousemotion = js.global.Trackball:motion()
	local dx,dy = -mousemotion[0], mousemotion[1]
	if dx~=0 and dy~=0 then
		dx,dy = dx*-5, dy*5
		js.global.Trackball:reset()
		-- project this point onto unit sphere
		--local p = vec3(dx,dy,math.max(1-(dx*dx+dy*dy))):normalize()
		pt.usrdata[0] = dx
		pt.usrdata[1] = dy
		pt.usrdata[2] = math.max(0, 1-(dx*dx+dy*dy))
		pt:normalize()
		
		local angle = math.acos(pt:dot(up))
		local axis = pt:cross(up)
		local q = Quaternion.axisAngle(axis, angle)
		--self.rotation:mult(q,self.rotation):normalize()
		q:mult(self.rotation,self.rotation):normalize()
	end
	return self.rotation:matrix()
end

function Trackball:transformation()
end

return Trackball
