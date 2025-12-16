--- not meant to be `{{#invoked}}` on wiki pages directly (will throw error).
--- meant to be `required` in other modules.
---
--- @param text string|number wikitext
--- @param hover string wikitext
--- @return string html
return function(text, hover)
	local n = mw.html.create("span"):addClass("tooltip")
	n:wikitext(text):node(mw.html.create("span"):addClass("tooltiptext"):wikitext(hover):done()):done()
	return tostring(n)
end
