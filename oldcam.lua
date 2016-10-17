local class = require('object')
local Quaternion = require'quaternion'
local Vector = require'vector'
local vec3 = Vector.vec3




local Cam = class()

function Cam:__init(eccentricity, nPeriod,ratio, crossbarslope)
	self.ratio = ratio or 0
	self.nPeriod = nPeriod
	self.eccentricity = eccentricity

	self.crossbarslope = crossbarslope
	
	self.period = (2*math.pi)/nPeriod
	--local offset = --how far the spoke travels after one period.
	--self.period = (2*math.pi-offset)/nPeriod

	self.crossbarLen = math.sin(math.acos(self.eccentricity))

	self.spoke = vec3( self.eccentricity, 0, 0)
	print("crossbarlen", self.crossbarLen)
	print("...", self.eccentricity, math.acos(self.eccentricity), math.sin(math.acos(self.eccentricity)))

	self.crossbar = vec3( 0, self.crossbarLen, 0)
	print(self.crossbar)
	self.up = vec3(0,0,1)

	self.theta = 0
	self.waveAngle = 0
	self.spokeAngle = 0

	self.waveRot = Quaternion()
	self.waveRotInv = Quaternion()
	self.spokeRot = Quaternion()
	self.crossbarRot = Quaternion()
end

function Cam:rotate(a)
	local function lerp(a,b,t)
		return a+(b-a)*t
	end
	local function angle(wave, spoke)
		local t = ((wave+spoke)%(self.period))/(self.period)
		if t > 0.5 then
			t=(t-0.5)*2
			print("t+",t)
			return lerp(0, self.crossbarslope, t)
			--return lerp(-self.crossbarslope, self.crossbarslope, t)
		else
			t=t*2
			print("t-",t)
			return lerp(self.crossbarslope, 0, t)
		end
	end

	self.waveAngle = self.waveAngle+a
	self.spokeAngle = self.spokeAngle + a*self.ratio


	self.waveRot = self.waveRot*Quaternion.axisAngle(self.up, a)
	self.waveRotInv = self.waveRot*Quaternion.axisAngle(self.up, -a)
	self.spokeRot = self.spokeRot*Quaternion.axisAngle(self.up, a*self.ratio)

	local crossbarAngle = angle(self.waveAngle, self.spokeAngle)
	print(crossbarAngle)
	self.crossbarRot = Quaternion.axisAngle(self.up, crossbarAngle)
end
function Cam:points()
	local spoke = self.spokeRot * self.spoke
	local crossbar = self.spokeRot*self.crossbarRot*self.crossbar
	return {self.waveRotInv*(spoke+crossbar), self.waveRotInv*(spoke-crossbar*0.3)}
end
function Cam:debugPoints()
	local spoke = self.spokeRot * self.spoke
	local crossbar = self.spokeRot*self.crossbarRot*self.crossbar
	return {spoke+crossbar, spoke-crossbar*0.3, spoke }
end

function Cam:transformation()
	return self.waveRotInv:matrix()
end

return Cam
