local function handle(id, event, func)
	local elem = js.global.document:getElementById(id)
	elem:addEventListener(event, js.global:jsCallback(func))
end

return handle
