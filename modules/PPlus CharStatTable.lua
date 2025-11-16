local p = {}
local mArguments
local cargo = mw.ext.cargo
local cache = {}

local tabber = require( 'Module:Tabber' ).renderTabber
local splitString = require( 'Module:SplitStringToTable' ).splitStringIntoTable
local list = require( 'Module:List' ).makeList

local function createTable(search)
	
	local frame = mw.getCurrentFrame() 
	local tables = 'PPlus_CharacterData'
	local search_q = tostring(table.concat(search, ", "))
	local fields = 'chara, ' .. search_q
	local args = { where = 'not chara="Giga Bowser" and not chara="Wario-Man"'}
    local results = cargo.query( tables, fields, args)
    local total_string = {}
    for _, v in ipairs(results) do
    	local char_row = mw.html.create("tr")
    	local char_cell = mw.html.create("td")
    	char_cell:wikitext(frame:expandTemplate{ title = 'StockIcon', args = { 'PPlus', v.chara}})
		char_row:node(char_cell)
    	for _, trait in pairs(search) do
    		local char_cell = mw.html.create("td")
    		char_cell:wikitext(v[trait])
    		char_row:node(char_cell)
		end
    	table.insert(total_string, tostring(char_row))
    end
	return table.concat(total_string)
end

function p.main(frame)
	mArguments = require( 'Module:Arguments' )
	local args = mArguments.getArgs(frame)
	return p._main(args)
end
	
function p._main( args )
	local html = ''
	if args[5] then
		html = createTable({args[1], args[2], args[3], args[4], args[5]})
	elseif args[4] then
		html = createTable({args[1], args[2], args[3], args[4]})
	elseif args[3] then
		html = createTable({args[1], args[2], args[3]})
	elseif args[2] then
		html = createTable({args[1], args[2]})
	elseif args[1] then
		html = createTable({args[1]})
	end
	return tostring(html)
end

return p