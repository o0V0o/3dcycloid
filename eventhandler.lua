local function err(msg)
	print(msg)
	print( debug.traceback() )
end
local function handle(id, event, func)
	local elem = js.global.document:getElementById(id)
	local f = function()
		xpcall(func, err)
	end
	elem:addEventListener(event, js.global:jsCallback(f))
end

return handle
