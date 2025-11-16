local winged = { color = "#FF7DD0", icon = "Winged" }
local grey = { color = "grey", icon = "Captain" }

local pikmin = {
	red = { color = "#EF0C18", icon = "Red" },
	blue = { color = "#1E71E7", icon = "Blue" },
	yellow = { color = "#EEDC12", icon = "Yellow" },
	purple = { color = "#962B91", icon = "Purple" },
	white = { color = "#E4DDD8", icon = "White" },
	pink = winged,
	winged = winged,
	captain = grey,
	olimar = grey,
	alph = grey,
	none = grey,
	no = grey,
	na = grey,
	["n/a"] = grey,
}

function removeTrailingS(str)
  if #str > 0 and str:sub(-1) == 's' then
    return str:sub(1, -2)
  else
    return str
  end
end

return {
	main = function(frame)
		local args = require('Module:Arguments').getArgs(frame)
		local colour = args[1]
		local config = pikmin[removeTrailingS(string.lower(colour))]
		local icon = config.icon and ("[[File:Pikmin_" .. config.icon .. ".png|x25px|link=]] ") or ""
		return icon .. tostring(mw.html.create("span"):css("color", config.color):wikitext(colour))
	end
}