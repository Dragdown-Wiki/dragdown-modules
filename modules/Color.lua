return {
	main = function(frame)
		local args = require('Arguments').getArgs(frame)
		local game = string.lower(args[3] or mw.title.getCurrentTitle().rootText)
		local color = string.lower(args[1])
		local text = args[2] or args[1]

		return frame:preprocess(
			tostring(
				mw.html.create('span')
				:addClass("mod-color-"..game.."-"..color)
				:addClass("mod-color-"..color)
				:wikitext(text):done()
			))
	end
}