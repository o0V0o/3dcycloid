local Quaternion = require("quaternion")
local Vector = require("vector")
local Matrix = require("matrix")
local class = require('object')
local vec2, vec3, vec4 = Vector.vec2, Vector.vec3, Vector.vec4

local Hypocycloid = class()
function Hypocycloid:__init(k)
	self.k = k
end
function Hypocycloid:rotate(axis, angle)
	local k = self.k
	if self.rotation and self.genRotation then
		self.rotation = self.rotation * Quaternion.axisAngle( axis, angle)
		self.genRotation = self.genRotation * Quaternion.axisAngle(axis, angle*k)
	else
		self.rotation = Quaternion.axisAngle(axis, angle)
		self.genRotation = Quaternion.axisAngle(axis, angle*k)
	end
end
function Hypocycloid:point()
	local k = self.k
	local origin = self.rotation:mult(vec3(0,0,1+1/k))
	local v = self.genRotation:mult(vec3(0,0,1/k))
	return origin+v
end
function Hypocycloid:reset()
	self.rotation = nil
	self.genRotation = nil
end

local Epicycloid = class(Hypocycloid)
function Epicycloid:rotate(axis, angle)
	local k = self.k
	if self.rotation and self.genRotation then
		self.rotation = self.rotation * Quaternion.axisAngle( axis, angle)
		self.genRotation = self.genRotation * Quaternion.axisAngle(axis, -angle*k)
	else
		self.rotation = Quaternion.axisAngle(axis, angle)
		self.genRotation = Quaternion.axisAngle(axis, -angle*k)
	end
end

return Hypocycloid, Epicycloid
