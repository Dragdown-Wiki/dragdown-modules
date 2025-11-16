local p = {}
local mArguments
local cargo = mw.ext.cargo

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