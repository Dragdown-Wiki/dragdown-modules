local thing = require("../framework/reference-lib")

thing(function(html, filePath)
  local file = io.open(filePath, "r")
  local reference = file:read("*a")

  if reference ~= html then
    local dumpFile = io.open("./dump.html", "w")
    dumpFile:write(html)
    dumpFile:close()
    error("mismatch at " .. inspect(v))
  end
  
  file:close()
end)

print("done :)")
