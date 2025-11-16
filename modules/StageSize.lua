local defs = {
	XS = {
		name = 'Extra Small',
		color = '#953AFF',
		badge =
		"'''<u>Extra Small Stage</u>'''<br>Indicates that this measurement is Extra Small in size, relative to the typical stage."
	},
	S = {
		name = 'Small',
		color = '#FF4C3A',
		badge =
		"'''<u>Small Stage</u>'''<br>Indicates that this measurement is Small in size, relative to the typical stage."
	},
	M = {
		name = 'Medium',
		color = '#FFCC48',
		badge =
		"'''<u>Medium Stage</u>'''<br>Indicates that this measurement is Medium or Average in size, relative to the typical stage."
	},
	L = {
		name = 'Large',
		color = '#5EDE5C',
		badge =
		"'''<u>Large Stage</u>'''<br>Indicates that this measurement is Large in size, relative to the typical stage."
	},
	XL = {
		name = 'Extra Large',
		color = '#73ABFF',
		badge =
		"'''<u>Extra Large Stage</u>'''<br>Indicates that this measurement is Extra Large in size, relative to the typical stage."
	},
	NA = {
		name = 'None',
		color = '#FF7432',
		badge =
		"'''<u>No Stage Measurement</u>'''<br>Indicates that this measurement does not apply to the current situation, such as in the case of a walkoff blastzone or no platforms existing."
	}
}

return {
	main = function(frame)
		local args = require('Module:Arguments').getArgs(frame)
		local choice = args[1]
		local config = defs[string.upper(choice)]

		local tooltip = mw.html.create("span"):addClass("tooltip"):css("border-bottom", "0")

		if config then
			tooltip:tag("span"):css({
				color = config.color,
				["font-weight"] = "bold"
			}):wikitext(
				"[[File:StageSize_" .. choice .. ".png|inline|x25px|link=]] "..(args[2] or config.name)
			)
		else
			tooltip:wikitext('Invalid size selection [' .. choice .. '].')
		end

		tooltip:tag("span"):addClass("tooltiptext"):node(config.badge or "")

		return tostring(tooltip)
	end
}