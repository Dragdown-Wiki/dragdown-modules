local p = {}
local cargo = mw.ext.cargo

local tabber = require( 'Tabber' ).renderTabber

local function calcTumblePercent(bkb, kbg, weight, damage, crouch, angle, flipper)
	damage = tonumber(damage)
	angle = tonumber(angle)
	
	local tumbleThreshold = 26
	local crouchReduction = 0.8
	local realTumbleThreshold = tumbleThreshold
	if crouch then
		realTumbleThreshold = realTumbleThreshold / crouchReduction
	end

	if(flipper == 'SpecifiedAngle' and angle > 180 and angle < 360) then
		realTumbleThreshold = realTumbleThreshold * (1 - (90 - math.abs(angle - 270)) / 90 * 0.25)
	end

	if tonumber(kbg) == 0 then
		if realTumbleThreshold > bkb * 3 then
			return "N/A"
		else
			return 0
		end
	else
		local percent = (realTumbleThreshold / 3 - bkb) * (weight + 100) / (200 * 0.12 * kbg) - damage
		if percent <= 0 then
			return 0
		-- elseif percent > 999 then
		-- 	return "N/A"
		else
			return math.ceil(percent)
		end
	end
	return 0
end

local function makeRow(traits, hit, m)
	local ou = '\n\n' .. m .. ': '
	
	local total_string = {}
	
	local row = mw.html.create('tr')
	local count = 0
	for hit_key, hit_values in pairs(hit) do
		count = count + 1
	end
	local cell = mw.html.create('td'):wikitext(m):attr('rowspan', count)
	row:node(cell)
	
	local new_row = false
	for hit_key, hit_values in pairs(hit) do
		if(new_row) then
			row = mw.html.create('tr')
		end
		row:tag('td'):wikitext(hit_key)
		-- row:tag('td'):wikitext(hit_values['Damage'] .. '%')
		row:tag('td'):wikitext(calcTumblePercent(hit_values['BaseKnockback'], hit_values['KnockbackScaling'], traits['Weight'], hit_values['Damage'], false, hit_values['KnockbackAngle'], hit_values['KnockbackAngleMode']) .. '%')
		row:tag('td'):wikitext(calcTumblePercent(hit_values['BaseKnockback'], hit_values['KnockbackScaling'], traits['Weight'], hit_values['Damage'], true, hit_values['KnockbackAngle'], hit_values['KnockbackAngleMode']) .. '%')
		row:done()
	
		table.insert(total_string, tostring(row))
		new_row = true
	end
	
	-- return #pairs(hit)
	return table.concat(total_string)
end

local function showTable(traits, hits)
	-- Goal: generate a table with knockdown percents for each hit
	local moveOrder = {"Jab","Ftilt","Utilt","Dtilt","Dattack","Fstrong","Ustrong","Dstrong","Nair","Fair","Fair2","Bair","Uair","Dair","Nspecial","NspecialAir","NspecialCloud","Uspecial","UspecialAir","Fspecial","Fspecial_Clone","Dspecial","DspecialAir","Dspecial_Clone","Grab","DashGrab","PivotGrab","Pummel","PummelSpecial","PummelSpecial_OLD","Fthrow","Bthrow","Uthrow","Dthrow","LedgeAttack","LedgeSpecial","LedgeSpecial_OLD","GetupAttack","GetupSpecial"}	
	local moveContains = {Jab=1,Ftilt=1,Utilt=1,Dtilt=1,Dattack=1,Fstrong=1,Ustrong=1,Dstrong=1,Nair=1,Fair=1,Fair2=1,Bair=1,Uair=1,Dair=1,Nspecial=1,NspecialAir=1,NspecialCloud=1,Uspecial=1,UspecialAir=1,Fspecial=1,Fspecial_Clone=1,Dspecial=1,DspecialAir=1,Dspecial_Clone=1,Grab=1,DashGrab=1,PivotGrab=1,Pummel=1,PummelSpecial=1,PummelSpecial_OLD=1,Fthrow=1,Bthrow=1,Uthrow=1,Dthrow=1,LedgeAttack=1,LedgeSpecial=1,LedgeSpecial_OLD=1,GetupAttack=1,GetupSpecial=1}	
	
	local total = {}
	
	
	local big_table = mw.html.create("table"):addClass('wikitable')
	
	local headers = mw.html.create('tr')
	headers:tag('th'):wikitext('Move')
	headers:tag('th'):wikitext('Hit')
	-- headers:tag('th'):wikitext('Damage')
	headers:tag('th'):wikitext('Knockdown %')
	headers:tag('th'):wikitext('CC %')
	-- if()
	-- headers:tag('th'):wikitext('Pops up at...')
	-- headers:tag('th'):wikitext('Pops up on CC at...')
	big_table:node(headers)
	
	for k, v in ipairs(moveOrder) do
		if hits[v] then
			table.insert(total, makeRow(traits, hits[v], v))
		end
	end
	
	for m, _ in pairs(hits) do
		if not moveContains[m] then
			table.insert(total, makeRow(traits, hits[m], m))
		end
	end
	big_table:wikitext(table.concat(total))

	return big_table
end

function p.main(frame)
	local args = require("Arguments").getArgs(frame)
	local host = args['host']
	local opp = args['opp']

	local tables = 'ROA2_HitData'
	local fields = 'moveID, nameID, Damage, BaseKnockback, KnockbackScaling, KnockbackAngle, bIgnoresWeight, KnockbackAngleMode, FinalBaseKnockback, ForceTumble'
	
	local hostHits = {}
	local results = cargo.query( tables, fields, {orderBy = 'moveID', where = 'chara="' .. host .. '"'})
	for r=1, #results do
		if not hostHits[results[r]['moveID']] then
			hostHits[results[r]['moveID']] = {}
		end
		hostHits[results[r]['moveID']][results[r]['nameID']] = results[r]
	end
	
	local oppHits = {}
	local results = cargo.query( tables, fields, {orderBy = 'moveID', where = 'chara="' .. opp .. '"'})
	for r=1, #results do
		if not oppHits[results[r]['moveID']] then
			oppHits[results[r]['moveID']] = {}
		end
		oppHits[results[r]['moveID']][results[r]['nameID']] = results[r]
	end
	
	local tables = 'ROA2_CharacterData'
	local fields = 'Weight'
	local hostTraits = cargo.query( tables, fields, {where = 'chara="' .. host .. '"'})[1]
	local oppTraits = cargo.query( tables, fields, {where = 'chara="' .. opp .. '"'})[1]
	
	local t = tabber({
		label1 = host .. ' vs ' .. opp,
		content1 = tostring(showTable(oppTraits, hostHits)),
		label2 = opp .. ' vs ' .. host,
		content2 = tostring(showTable(hostTraits, oppHits))
	})
	
	return t
	
end
	

return p