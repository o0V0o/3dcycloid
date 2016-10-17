local class = require('object')
local Quaternion = require'quaternion'
local Vector = require'vector'
local vec3 = Vector.vec3




local Cam = class()
function Cam:__init(n, ratio, outputRatio)
	--self.ratio = ratio or 1 --ratio from input to output
	--self.outputRatio = outputRatio or 1 --ratio from planet speed to output speed
	--self.planetRatio = ratio/outputRatio --ratio from input speed to planet speed
	self.inputPlanet = ratio or 1
	self.planetOutput = outputRatio or 1
	--self.planetCam = -(1 + self.inputPlanet)
	self.planetCam = self.planetCam or 0
	if self.inputPlanet < 0 then
		self.period = -1*math.pi/(self.inputPlanet-1)
	else
		self.period = 1*math.pi/(1-self.inputPlanet)
	end

	--self.dTheta = self.period
	--self.period =-2-> math.pi/4, -1->math.pi 0->math.pi*2, 1->0, 
	--self.period = math.pi*2
	--self.planetCam = self.period
	self.inputCam = ((2*math.pi)-self.period) / -self.period
	self.planetCam = 1/2
	self.planetCam = self.inputCam / self.inputPlanet
	print("period:", self.period/math.pi)
	print("input/cam",self.inputCam)
			

	self.eccentricity = 1/math.sin( math.pi/(2*n) )
	self.eccentricity = self.eccentricity / (self.eccentricity + 1)
	self.planetRadius = 1-self.eccentricity

	self.up = vec3( 0,0,1 )
	self.carrier = vec3( self.eccentricity, 0, 0)
	self.planet = vec3( self.planetRadius, 0, 0)

	self.theta = 0
	self.planetRot = Quaternion()
	self.carrierRot = Quaternion()
	self.camRot = Quaternion()
	self.camRotInv = Quaternion()
end

function Cam:rotate(a)
	self.theta = self.theta + a
	self.planetRot = Quaternion.axisAngle( self.up, self.theta*self.inputPlanet )
	self.carrierRot = Quaternion.axisAngle( self.up, self.theta)
	local r = self.theta*self.inputPlanet*self.planetCam
	self.camRot = Quaternion.axisAngle( self.up, r)
	self.camRotInv = Quaternion.axisAngle( self.up, -r)
end
--[[
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
--]]
function Cam:points()
	local carrier = self.carrierRot * self.carrier
	local planet = self.carrierRot*self.planetRot*self.planet
	planet = self.planetRot * self.planet
	return {self.camRotInv*(carrier+planet), self.camRotInv*(carrier-planet)}
end
function Cam:debugPoints()
	local carrier = self.carrierRot * self.carrier
	local planet = self.carrierRot*self.planetRot*self.planet
	planet = self.planetRot * self.planet
	return {carrier+planet, carrier-planet, carrier}
end

function Cam:transformation()
	return self.camRotInv:matrix()
end

return Cam
