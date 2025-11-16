return {
	main = function(frame)
		local args = require("Arguments").getArgs(frame)
		return 'This is a placeholder for the character ' .. args[1] .. '. Please hold.'
	end
}
