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

local function display(chara)
	
	local tables = 'Patches_RoAII'
	local fields = '_pageName=page, date'
	local args = {orderBy = 'date DESC'}
    local results = cargo.query( tables, fields, args )
    
    local totalsum = ''
    
    for k, v in pairs(results) do
    	local newText = mw.getCurrentFrame():callParserFunction('#lsth', {v['page'], chara})
    	if(newText ~= '') then
    		local h = mw.title.new(v['page'], '')
    		totalsum = totalsum .. '==' .. h.subpageText .. ' (' .. v['date'] .. ')==\n'
    		totalsum = totalsum .. newText
    		totalsum = totalsum .. '\n'
		end
	end
	
-- 	{{#cargo_query:
-- table=Patches_RoAII
-- |format=template
-- |template=ROA2-Display{{#titleparts:{{PAGENAME}}|1|2}}PatchNotes
-- |order by=date DESC
-- }}
	
	return totalsum
end

function p.main(frame)
	mArguments = require( 'Module:Arguments' )
	local args = mArguments.getArgs(frame)
	return p._main(args)
end
	
function p._main( args )

	local chara = args[1]
	local html = display(chara)
	return tostring(html)
end

return p