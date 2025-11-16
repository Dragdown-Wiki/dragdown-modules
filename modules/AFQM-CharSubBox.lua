local p = {}
local mArguments

function p.main(frame)
	mArguments = require( 'Module:Arguments' )
	local args = mArguments.getArgs(frame)
	return p._main(args)
end

local function dump(o)
	if type(o) == "table" then
		local s = "{ "
		for k, v in pairs(o) do
			if type(k) ~= "number" then
				k = '"' .. k .. '"'
			end
			s = s .. "[" .. k .. "] = " .. dump(v) .. ","
		end
		return s .. "} "
	else
		return tostring(o)
	end
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
	local portrait = "[[File:AFQM_" .. chara .. "_Portrait.png|300px]]"
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
	local tables = "AFQM_CharacterData"
	local fields = "chara, fastfall_speed, jumpsquat_time, max_fall_speed"
	local cargargs = { orderBy = "max_fall_speed"}
	local results = cargo.query(tables, fields, cargargs)
	
	local charaFF = 0
	local charaJS = 0
	local charaFS = 0
	for k, v in ipairs(results) do
		if v.chara == chara then
			charaFF = tonumber(v.fastfall_speed)
			charaJS = tonumber(v.jumpsquat_time)
			charaFS = tonumber(v.max_fall_speed)
		end
	end

	local charaFFRank = 1
	local charaJSRank = 1
	local charaFSRank = 1
	
	for k, v in ipairs(results) do
		if charaFF < tonumber(v.fastfall_speed) then
			charaFFRank = charaFFRank + 1
		end
		if charaJS < tonumber(v.jumpsquat_time) then
			charaJSRank = charaJSRank + 1
		end
		if charaFS < tonumber(v.max_fall_speed) then
			charaFSRank = charaFSRank + 1
		end
	end

	
	local row = mw.html.create("tr"):css("font-weight","bold")
		:tag("td"):attr("align", "center"):css("width", "30%"):wikitext("Fastfall Speed"):done()
		:tag("td"):attr("align", "center"):css("width", "30%"):wikitext("Jumpsquat"):done()
		:tag("td"):attr("align", "center"):css("width", "30%"):wikitext("Max Fall Speed"):done()
		
	table:node(row)

	
	local row = mw.html.create("tr")
		:tag("td"):attr("align", "center"):wikitext(charaFF .. addRank(charaFFRank)):done()
		:tag("td"):attr("align", "center"):wikitext(charaJS .. addRank(charaJSRank)):done()
		:tag("td"):attr("align", "center"):wikitext(charaFS .. addRank(charaFSRank)):done()
		
	table:node(row)
	
	return tostring(table)

end

return p