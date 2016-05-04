local Quaternion = require('quaternion')
local Vector = require('vector')
local vec3, vec4 = Vector.vec3, Vector.vec4


local function fillNode( node, predecessor, nodes, n )
	if n<=0 then return end

	local degree = nodes.degree
	local rPolar = Quaternion.axisAngle( node, math.pi*2/degree )

	local newnodes = {}
	for i=1,degree do
		local newnode = rPolar:mult(predecessor)
		nodes:add(newnode)
		coroutine.yield()
		table.insert(newnodes, newnode)
		predecessor = newnode
	end
	for _,newnode in pairs(newnodes) do
		fillNode( newnode, node, nodes, n-1)
	end
end

local function lobeGen( degree, nodes, N)
	N = N or math.pi/degree

	local node = vec3(0,1,0)
	nodes.degree = degree
	nodes:add( node )
	nodes:add( node )
	local r1 = Quaternion.axisAngle( vec3(1,0,0), N)
	fillNode(node , r1*node, nodes, degree+1)
	return nodes
end

return lobeGen
