local class = require('object')
local Quaternion = require'quaternion'
local Vector = require'vector'
local vec3 = Vector.vec3




local Cam = class()
function Cam:__init(eccentricity, inputPlanet, inputCarrier, inputCam)
	self.inputPlanet =  inputPlanet or 1
	self.inputCarrier = inputCarrier or 0
	self.inputCam = inputCam or 1

	self.eccentricity = eccentricity
	self.planetRadius = 1-self.eccentricity

	self.up = vec3( 0,0,1 )
	self.carrier = vec3( self.eccentricity, 0, 0)
	--self.planet = vec3( 0,self.planetRadius, 0)
	self.planet = vec3( -1,self.planetRadius, 0)

	self.theta = 0
	self.planetRot = Quaternion()
	self.carrierRot = Quaternion()
	self.camRot = Quaternion()
	self.camRotInv = Quaternion()
end

function Cam:rotate(a)
	self.theta = self.theta + a
	self.planetRot = Quaternion.axisAngle( self.up, self.theta*self.inputPlanet )
	self.carrierRot = Quaternion.axisAngle( self.up, self.theta*self.inputCarrier)
	self.camRot = Quaternion.axisAngle( self.up, self.theta*self.inputCam)
	self.camRotInv = Quaternion.axisAngle( self.up, -self.theta*self.inputCam)
end

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
	return {carrier+planet, carrier-planet, carrier, vec3(0,0,0)}
end

function Cam:transformation()
	return self.camRotInv:matrix()
end

return Cam
