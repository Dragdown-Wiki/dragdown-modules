local thing = require("../framework/reference-lib")
local inspect = require("inspect")

thing(function(html, filePath, config)
	local file = io.open(filePath, "r")
	local reference = file:read("*a")

	if reference ~= html then
		local dumpFile = io.open("./dump.html", "w")
		dumpFile:write(html)
		dumpFile:close()
		error("mismatch at " .. inspect(config))
	end

	file:close()
end)

print("done :)")
