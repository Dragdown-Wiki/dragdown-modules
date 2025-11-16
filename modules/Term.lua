local p = {}
local namespaceMap = { pplus = "PPlus", roa2 = "RoA2", ssbu = "SSBU", nasb2 = "NASB2" }

function p.main(frame)
	local args = require("Arguments").getArgs(frame)
	local game = (args[2] and args[3]) and args[1] or mw.title.getCurrentTitle().rootText
	local namespace = namespaceMap[string.lower(game)] or "RoA2"
	local term = args[3] and args[2] or args[1]
	local tooltip = mw.html.create('span'):addClass('tooltip'):wikitext(args[3] or args[2] or args[1])
	local text = tooltip:tag("span"):addClass("tooltiptext noexcerpt")

	local results = mw.ext.cargo.query(
		"Glossary_" .. namespace,
		'term,summary,display,alias',
		{where = 'term="' .. term .. '" or alias HOLDS "' .. term .. '"'}
	)

	if results[1] == nil then
		text:wikitext('No matched term could be found in the [['.. namespace ..'/Glossary|Glossary]].[[Category:Missing Term]]')
	else
		text:tag("span"):addClass("mod-tooltip-title"):wikitext(results[1].term)
		-- summary may include inline elements! if the parent was flex-column (previous approach), that would mess it up!
		text:node(results[1].summary)
		-- the following must not be a <div> because even though it's always hidden (as all of this gets cloned by the tooltip JS)
		-- the mediawiki parsing will see a <div> and generate visible linebreaks into the page.
		text:tag("span"):addClass("mod-tooltip-link"):wikitext('[['.. namespace ..'/Glossary#' .. results[1].term ..'|See in Glossary]]')
	end
	
	return tostring(tooltip)
end

return p