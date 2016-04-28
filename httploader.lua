local function packagepaths(path, mod)
	local paths = {}
	for p in path:gmatch("[^;]+") do
		local modpath = p:gsub('?', mod)
		table.insert(paths, modpath)
	end
	return paths
end
-- Set up require paths to be sensible for the browser
local function load_lua_over_http(url)
	local xhr = js.new(window.XMLHttpRequest)
	xhr:open("GET", url, false) -- Synchronous
	-- Need to pcall xhr:send(), as it can throw a NetworkError if CORS fails
	local ok, err = pcall(xhr.send, xhr)
	if not ok then
		return nil, tostring(err)
	elseif xhr.status ~= 200 then
		return nil, "HTTP GET " .. xhr.statusText .. ": " .. url
	end
	return load(xhr.responseText, url)
end
--table.remove(package.searchers, 4)
--table.remove(package.searchers, 5)
--table.remove(package.searchers, 6)
table.insert(package.searchers, 1, function (mod_name)
	local modnames = packagepaths(package.path, mod_name)
	local reason = ''
	for _,name in ipairs(modnames) do
		local func, err = load_lua_over_http(name)
		if func ~= nil then
			return func
		else
			reason = reason .. err .. '\n'
		end
	end
	if reason then 
		error(reason)
	end
	return nil, reason
end)
