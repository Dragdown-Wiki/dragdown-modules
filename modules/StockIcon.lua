return {
	main = function(frame)
		local args = require("Arguments").getArgs(frame)
		local chara = args[2] or args.chara or args[1] or ""
		local game = args.game or mw.title.getCurrentTitle().rootText or ""

		local icon = 
					"[[File:"
					.. game .. "_" .. chara .. "_Stock.png"
					.. "|link=" .. (args.linkOverride or (game .. "/" .. chara))
					.. "|x" .. (args[3] or 25) .. "px"
					.. "|alt="
					.. "]]"

		local link = 
					" [[" .. (args.linkOverride or (game .. "/" .. chara))
					.. "|'''" .. (args.label or chara) .. "'''"
					.. "]]"

		return icon .. (args.lineBreak and "<br/>" or "") .. link
	end
}