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

local function createInfobox(chara)
	return 'This is a placeholder for the character ' ..  chara .. '. Please hold.'
end

function p.main(frame)
	mArguments = require( 'Module:Arguments' )
	local args = mArguments.getArgs(frame)
	return p._main(args)
end
	
function p._main( args )

	local chara = args[1]
	
	local html = createInfobox(chara)
	return tostring(html)
end

return p