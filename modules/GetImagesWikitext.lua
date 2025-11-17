--- not meant to be `{{#invoked}}` on wiki pages directly (will throw error).
--- meant to be `required` in other modules.
--- 
--- @param t table
return function(t)
	local wikitextTable = {}

	for i, data in ipairs(t) do
		-- MediaWiki image syntax
		-- @see https://www.mediawiki.org/wiki/Help:Images/en#Rendering_a_single_image
		local image = string.format("[[File:%s|thumb|center|210x210px]]", data.file)
		local caption = tostring(
			mw.html.create("div"):addClass("gallerytext"):css("text-align", "center"):wikitext(data.caption or "")
		)
		table.insert(wikitextTable, image)
		table.insert(wikitextTable, caption)
	end

	return wikitextTable
end