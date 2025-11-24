local List = require("pl.List")

--- not meant to be `{{#invoked}}` on wiki pages directly (will throw error).
--- meant to be `required` in other modules.
---
--- @param input { file: string, caption: string? }[]
return function(input)
	local wikitextTable = List()

	for _, data in ipairs(input) do
		-- MediaWiki image syntax
		-- @see https://www.mediawiki.org/wiki/Help:Images/en#Rendering_a_single_image
		wikitextTable:append("[[File:" .. data.file .. "|thumb|center|210x210px]]")
		wikitextTable:append(tostring(
			mw.html.create("div"):addClass("gallerytext"):css("text-align", "center"):wikitext(data.caption or "")
		))
	end

	return wikitextTable
end
