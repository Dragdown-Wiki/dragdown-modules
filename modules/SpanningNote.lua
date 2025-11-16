return {
	main = function(frame)
		local args = require("Module:Arguments").getArgs(frame)
		local tr = mw.html.create("tr"):css("border-width", "0px")
		local td = tr:tag("td"):attr("colspan", "100")

		local div = td:tag("div"):cssText(args.boxcss or ""):css({
			padding = "0.2em 0.4em",
			border = "1px solid #303439",
			["border-radius"] = "0.5rem"
		})

		local span = div:tag("span")

		span:tag("span"):css({
			color = "#4855c9",
			["font-weight"] = "700"
		}):wikitext("ⓘ")

		span:wikitext(" " .. tostring(frame:preprocess(args.content)))

		return tostring(tr)
	end
}