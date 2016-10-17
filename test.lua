function ratios(inputPlanet)
	local period = -1*math.pi/(inputPlanet-1)
	local inputCam = ((2*math.pi)-period)/-period
	local planetCam = inputCam / inputPlanet
	
	return inputPlanet, inputCam, planetCam, period
end

for i=-1, -2, -0.1 do
	print(ratios(i))
end
