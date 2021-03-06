
local class = require'object'
local F = {}

F.Periodic = class()
function F.Periodic:__init(func, period)
	self.func = func
	self.period = period
end
function F.Periodic:integrate(t)
	return self.func:integrate( t%self.period )
end

F.Constant = class()
function F.Constant:__init(c)
	self.c = c
end
function F.Constant:integrate(t)
	return self.c*t
end

F.Linear = class()
function F.Linear:__init(slope, intercept)
	self.slope = slope
	self.intercept = intercept
end
function F.Linear:integrate(t)
	return 0.5*self.slope*t*t  + self.intercept*t
end

F.LinearSpline = class()
function F.LinearSpline:__init(points)
	self.points = points
end
function F.LinearSpline:integrate(t)
	local lastPoint
	local sum = 0
	for i,point in ipairs(self.points) do
		if lastPoint then
			local dx = (point.x-lastPoint.x)
			local dy = (point.y-lastPoint.y)
			if t>= point.x then
				--sum = sum + 0.5*dx*dy + lastPoint.y*dx
				sum = sum + 0.5*(lastPoint.y + point.y)*dx
			elseif t>lastPoint.x then
				local x = t-lastPoint.x
				local slope, intercept = dy/dx, lastPoint.y
				sum = sum + 0.5*slope*x*x  + intercept*x
			end
		end
		lastPoint = point
	end
	if t>lastPoint.x then
		sum = sum + lastPoint.y*(t-lastPoint.x)
	end
	return sum
end

return F
