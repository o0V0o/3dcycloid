local platform = require("platform")
--keep track of FPS
local last, frames = 0,0
local function countFrames()
	frames = frames+1
	local now = platform.time()
	if now-last >= 1000 then
		print(frames, "fps")
		frames=0
		last = now
		collectgarbage()
		print("memory used", collectgarbage('count'), "KiB")
	end
end

return countFrames
