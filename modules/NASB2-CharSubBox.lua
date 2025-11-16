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

local function addRank(trait, info)
	local r = info[trait]["rank"]
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
	local portrait = "[[File:NASB2_" .. chara .. "_Portrait.png|300px]]"
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
	local tables = "NASB2_CharacterData"
	local fields = "chara, DefaultWeight, HitStunGravity, HitStunFallSpeed, RunSpeed, MaxSpeed, GroundFriction"
	local cargargs = {}
	local results = cargo.query(tables, fields, cargargs)
	
	local info = {
		DefaultWeight = {name="Weight"},
		HitStunGravity = {name="Hitstun Gravity"},
		HitStunFallSpeed = {name="Hitstun Fall Speed"},
		RunSpeed = {name="Dash Speed"},
		MaxSpeed = {name="Max Run Speed"},
		GroundFriction = {name="Ground Friction"},
	}
	for k, v in ipairs(results) do
		if v.chara == chara then
			for trait, _ in pairs(info) do
				info[trait]["val"] = tonumber(v[trait])
				info[trait]["rank"] = 1
			end
			break
		end
	end
	for k, v in ipairs(results) do
		for trait, _ in pairs(info) do
			if info[trait]["val"] < tonumber(v[trait]) then
				info[trait]["rank"] = info[trait]["rank"] + 1
			end
		end
	end

	local row = mw.html.create("tr"):css("font-weight","bold")
		:tag("td"):attr("align", "center"):css("width", "30%"):wikitext(info["DefaultWeight"]["name"]):done()
		:tag("td"):attr("align", "center"):css("width", "30%"):wikitext(info["HitStunGravity"]["name"]):done()
		:tag("td"):attr("align", "center"):css("width", "30%"):wikitext(info["HitStunFallSpeed"]["name"]):done()
	table:node(row)

	row = mw.html.create("tr")
		:tag("td"):attr("align", "center"):wikitext(info["DefaultWeight"]["val"] .. addRank("DefaultWeight", info)):done()
		:tag("td"):attr("align", "center"):wikitext(info["HitStunGravity"]["val"] .. addRank("HitStunGravity", info)):done()
		:tag("td"):attr("align", "center"):wikitext(info["HitStunFallSpeed"]["val"] .. addRank("HitStunFallSpeed", info)):done()
	table:node(row)
	
	row = mw.html.create("tr"):css("font-weight","bold")
		:tag("td"):attr("align", "center"):css("width", "30%"):wikitext(info["RunSpeed"]["name"]):done()
		:tag("td"):attr("align", "center"):css("width", "30%"):wikitext(info["MaxSpeed"]["name"]):done()
		:tag("td"):attr("align", "center"):css("width", "30%"):wikitext(info["GroundFriction"]["name"]):done()
	table:node(row)

	row = mw.html.create("tr")
		:tag("td"):attr("align", "center"):wikitext(info["RunSpeed"]["val"] .. addRank("RunSpeed", info)):done()
		:tag("td"):attr("align", "center"):wikitext(info["MaxSpeed"]["val"] .. addRank("MaxSpeed", info)):done()
		:tag("td"):attr("align", "center"):wikitext(info["GroundFriction"]["val"] .. addRank("GroundFriction", info)):done()
	table:node(row)
	
	return tostring(table)

end

return p