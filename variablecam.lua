local class = require('object')
local Quaternion = require'quaternion'
local Vector = require'vector'
local vec3 = Vector.vec3
local Functions = require'functions'




local Cam = class()
function Cam:__init(eccentricity, planetSpeed, carrierSpeed, camSpeed)
	if type(planetSpeed) == 'number' then planetSpeed = Functions.Constant(planetSpeed) end
	if type(carrierSpeed) == 'number' then carrierSpeed = Functions.Constant(carrierSpeed) end
	if type(camSpeed) == 'number' then camSpeed = Functions.Constant(camSpeed) end

	self.planetSpeed = planetSpeed
	self.carrierSpeed = carrierSpeed
	self.camSpeed = camSpeed

	self.eccentricity = eccentricity
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
	local planetTheta = self.planetSpeed:integrate( self.theta )
	local carrierTheta = self.carrierSpeed:integrate( self.theta )
	local camTheta = self.camSpeed:integrate( self.theta )
	self.planetRot = Quaternion.axisAngle( self.up, planetTheta)
	self.carrierRot = Quaternion.axisAngle( self.up, carrierTheta)
	self.camRot = Quaternion.axisAngle( self.up, camTheta)
	self.camRotInv = Quaternion.axisAngle( self.up, -camTheta)
end

function Cam:points()
	local carrier = self.carrierRot * self.carrier
	local planet = self.carrierRot*self.planetRot*self.planet
	planet = self.planetRot * self.planet

	--due to the periodic function, the cam points swap places when we have a
	--ratio of 0.5 (other adjustments needed for other ratios)
	if((self.theta/math.pi)%4)>=2 then
		return {self.camRotInv*(carrier+planet), self.camRotInv*(carrier-planet)}
	else
		return {self.camRotInv*(carrier-planet), self.camRotInv*(carrier+planet)}
	end
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
