local class = require("object")
local SimpleObject = require("SimpleObject")
local Mesh = require("mesh").Mesh
local gl = require('openGL')

local PointCloud = class(SimpleObject)
function PointCloud:__init(points)
	self.inds = {}
	self.points = points or {}
	for i=1,#self.points do table.insert(self.inds,i-1) end
	self.mesh = Mesh(self.inds, {position=self.points})
	self.dirty = true
end
function PointCloud:addPoints(points)
	for _,p in ipairs(points) do
		self:add(p)
	end
end
function PointCloud:add(point)
	table.insert(self.points, point)
	table.insert(self.inds, #self.points-1)
	self.dirty = true
end
function PointCloud:recalculate(...)
	self.dirty = false
	PointCloud.parent.recalculate(self, ...)
end
function PointCloud:draw(shader)
	if self.dirty then self:recalculate(shader) end
	self.eab:bind()
	for name,attribute in pairs(shader.attributes) do
		local mesh_attrib = self.attributeMap[name]
		if self.vbos[mesh_attrib] then
			self.vbos[mesh_attrib]:useForAttribute(attribute)
		end
	end
	gl.glDrawElements( gl.GL_LINE_STRIP, #(self.inds), self.eab.datatype, 0)
	self.eab:unbind()
end
return PointCloud
