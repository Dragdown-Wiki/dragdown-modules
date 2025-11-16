-- this was my attempt on improving PPlus/Glossary performance by using a module to generate the template content,
-- but my tests resulted in WORSE page load times with this instead of not using a module in the glossary template.
-- so this module is currently unused but i'll keep it around for a little bit.

return {
	main = function(frame)
		local args = require("Arguments").getArgs(frame)

		local tableElem = mw.html.create("table"):addClass("wikitable")

		local function optionalRow(argName, firstCol)
			if args[argName] then
				tableElem:tag("tr")
						:tag("td"):css("font-weight", "bold"):wikitext(firstCol .. ":"):done()
						:tag("td"):wikitext(args[argName])
			end
		end

		optionalRow("alias", "AKA")

		tableElem:tag("tr")
				:tag("td"):css("font-weight", "bold"):wikitext("Summary"):done()
				:tag("td"):wikitext(args.summary)

		optionalRow("definition", "Definition")

		if args.display then
			tableElem:tag("tr")
					:tag("td"):attr("colspan", "2")
					:wikitext("[[File:"..args.display.."|300px]]")
		end

		optionalRow("altLink", "See Also")

		return "==="..args.term.."===\n" .. tostring(tableElem)
	end
}