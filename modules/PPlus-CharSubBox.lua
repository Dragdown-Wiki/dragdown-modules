local p = {}
local mArguments

function p.main(frame)
	mArguments = require( 'Arguments' )
	local args = mArguments.getArgs(frame)
	return p._main(args)
end

local function addRank(r)
	local element = mw.html.create("span"):css("color", "gray"):css('font-size', 'var(--font-size-small)')
	local lastDigit = math.fmod(r,10)
	local ord = 'th'
	if lastDigit == 1 and r ~= 11 then
		ord = 'st'
	elseif lastDigit == 2 and r ~= 12 then
		ord = 'nd'
	elseif lastDigit == 3 and r ~= 13 then
		ord = 'rd'
	end
	return tostring(element:wikitext(" (" .. r .. ord ..")"))
end
	
function p._main( args )
	
	-- return dump(args)
	
	local table = mw.html.create("table"):addClass("stripe"):css("width", "100%"):attr("cellspacing", "0")

	local chara = args["chara"]
	local portrait = "[[File:PPlus_" .. chara .. "_Portrait.png|300px]]"
	if args["portrait"] then
		portrait = args["portrait"]
	end
	
	local row = mw.html.create("tr"):tag("th"):attr("align", "center"):attr("colspan", "3")
		:tag("span"):css("font-size", "20px"):css("font-weight","bold"):wikitext(chara):done()
	table:node(row)
	local portrait_row = mw.html.create("tr")
	local portrait_tag = mw.html.create("td"):attr("align", "center"):attr("colspan", "3"):wikitext(portrait):done()
	portrait_row:node(portrait_tag)
	table:node(portrait_row)
	
	local cargo = mw.ext.cargo
	local tables = "PPlus_CharacterData"
	local fields = "chara, Weight, Gravity, TerminalVelocity"
	local cargargs = { orderBy = "Weight", where = 'not chara="Giga Bowser" and not chara="Wario-Man"' }
	local results = cargo.query(tables, fields, cargargs)
	
	local charaWeight = 0
	local charaGrav = 0
	local charaFS = 0
	for k, v in ipairs(results) do
		if v.chara == chara then
			charaWeight = tonumber(v.Weight)
			charaGrav = tonumber(v.Gravity)
			charaFS = tonumber(v.TerminalVelocity)
		end
	end

	local charaWeightRank = 1
	local charaGravRank = 1
	local charaFSRank = 1
	
	for k, v in ipairs(results) do
		if charaWeight < tonumber(v.Weight) then
			charaWeightRank = charaWeightRank + 1
		end
		if charaGrav < tonumber(v.Gravity) then
			charaGravRank = charaGravRank + 1
		end
		if charaFS < tonumber(v.TerminalVelocity) then
			charaFSRank = charaFSRank + 1
		end
	end

	
	local row = mw.html.create("tr"):css("font-weight","bold")
		:tag("td"):attr("align", "center"):css("width", "30%"):wikitext("Weight"):done()
		:tag("td"):attr("align", "center"):css("width", "30%"):wikitext("Gravity"):done()
		:tag("td"):attr("align", "center"):css("width", "30%"):wikitext("Fall Speed"):done()
		
	table:node(row)

	
	local row = mw.html.create("tr")
		:tag("td"):attr("align", "center"):wikitext(charaWeight .. addRank(charaWeightRank)):done()
		:tag("td"):attr("align", "center"):wikitext(charaGrav .. addRank(charaGravRank)):done()
		:tag("td"):attr("align", "center"):wikitext(charaFS .. addRank(charaFSRank)):done()
		
	table:node(row)
	
	return tostring(table)

end

return p