local p = {}
local mArguments
local cargo = mw.ext.cargo
local cache = {}

local tabber = require( 'Module:Tabber' ).renderTabber
local splitString = require( 'Module:SplitStringToTable' ).splitStringIntoTable
local list = require( 'Module:List' ).makeList

function dump(o)
	if type(o) == 'table' then
	   local s = '{ '
	   for k,v in pairs(o) do
		  if type(k) ~= 'number' then k = '"'..k..'"' end
		  s = s .. '['..k..'] = ' .. dump(v) .. ','
	   end
	   return s .. '} '
	else
	   return tostring(o)
	end
 end

function tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

local function tooltip(text, hover)
	local n = mw.html.create('span'):addClass('tooltip')
	n:wikitext(text)
	:node(mw.html.create('span'):addClass('tooltiptext'):node(hover):done()):done()
	return tostring(n)
end

local function createOoSGraphic(chara, aerial, grounded)
	local totalMoves = {}
	local airs = {}
	for k, i in ipairs(splitString(aerial, ';')) do
		local count = #splitString(i, '/')
		if count > 1 then
			table.insert(airs, splitString(i, '/'))
			table.insert(totalMoves, splitString(i, '/'))
		else
			table.insert(airs, i)
			table.insert(totalMoves, i)
		end
	end
	local grounds = {}
	for k, i in ipairs(splitString(grounded, ';')) do
		local count = #splitString(i, '/')
		if count > 1 then
			table.insert(grounds, splitString(i, '/'))
			table.insert(totalMoves, splitString(i, '/'))
		else
			table.insert(grounds, i)
			table.insert(totalMoves, i)
		end
	end
	local cargo = mw.ext.cargo
	local tables = "ROA2_MoveMode"
	local fields = "chara, attack, startup, image"
	local whereflag = {}
	for k, item in ipairs(totalMoves) do
		if type(item) == 'table' then
			table.insert(whereflag, '(attack="' .. item[0] .. '" and mode="'.. item[1] '")')
		else
			table.insert(whereflag, '(attack="' .. item .. '")')
		end
	end
	local args = { orderBy = "startup", where = "chara=\"" .. chara .. "\" and (" .. table.concat(whereflag, ' or ') .. ")"}
	local options = cargo.query(tables, fields, args)
	
	-- determine 
	
	return tostring(dump(options))
end

function p.main(frame)
	mArguments = require( 'Module:Arguments' )
	local args = mArguments.getArgs(frame)
	return p._main(args)
end
	
function p._main( args )

	local chara = args['chara']
	local aerials = args['aerials']
	local groundeds = args['groundeds']
	
	local html = createOoSGraphic(chara, aerials, groundeds)
	return tostring(html)
end

return p