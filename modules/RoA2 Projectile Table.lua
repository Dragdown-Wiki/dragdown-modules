local p = {}
local cargo = mw.ext.cargo

function p.main(frame)
	local frame = mw.getCurrentFrame() 
	local tables = 'ROA2_Articles'
	local fields = 'chara, ArticleName, bIsProjectile'
	local args = {orderBy = 'chara'}
	local results = cargo.query( tables, fields, args)
	
	local current_char = results[1]['chara']
	local tally_table = {}
		
	for r = 1, #results do
		local result = results[r]
		if tally_table[result.chara] then
			tally_table[result.chara][result.ArticleName] = result.bIsProjectile
		else
			tally_table[result.chara] = {}
			tally_table[result.chara][result.ArticleName] = result.bIsProjectile
		end
	end

	local total_string = {}
    for k, v in pairs(tally_table) do
    	local char_row = mw.html.create("tr")
    	char_row:tag('td'):wikitext(frame:expandTemplate{ title = 'StockIcon', args = { game='RoA2', k}})
    	
    	local projectiles = {}
    	local not_projectiles = {}
    	
		for article, proj in pairs(v) do
			if proj == 'true' then
				table.insert(projectiles, tostring(article))
			else
				table.insert(not_projectiles, tostring(article))
			end
		end
		if #projectiles == 0 then
			table.insert(projectiles, 'N/A')
		end
		if #not_projectiles == 0 then
			table.insert(not_projectiles, 'N/A')
		end
		
		
    	char_row:tag('td'):wikitext(table.concat(projectiles, ', '))
    	char_row:tag('td'):wikitext(table.concat(not_projectiles, ', ')):done()
    	table.insert(total_string, tostring(char_row))
    end
	return table.concat(total_string)

end
	

return p