local configs = {
	technicalinfo = { img = "Toa18_icon", text = "Technical Info" },
	advanced = { img = "Dark_future_loxodont_icon", text = "Advanced" },
	practice = { img = "Toa12_icon", text = "Practice" }
}

return {
	main = function(frame)
		local args = require("Arguments").getArgs(frame)
		local variant = args[1]:lower()
		local config = configs[variant]

		if config == nil then
			error("invalid type: " .. args[1])
		end

		local container = mw.html.create("div")
				:addClass("mw-collapsible")
				:addClass(variant == "practice" and "" or "mw-collapsed")
				:addClass("mod-infopanel-container")
				:css("width", "max(60%, 10em)") -- cant add this width value to template's style.css because the parser won't allow it

		container:tag("div"):addClass("mod-infopanel-heading"):wikitext("[[File:" .. config.img .. ".png|32px|left|link=]]"..config.text)
		container:tag("div"):addClass("mw-collapsible-content"):node(args[2])

		return tostring(container)
	end
}