local p = {}
local cargo = mw.ext.cargo
local tabber = require( 'Tabber' ).renderTabber
local armor_etalus_weight = 180
local tooltip = require("Tooltip")

local function calcTumblePercent(bkb, kbg, weight, damage, crouch, angle, flipper, grounded, custom_kb_threshold)
	local tumbleThreshold = 26
	local crouchReduction = 0.8
	local realTumbleThreshold = tumbleThreshold
	if crouch then
		realTumbleThreshold = realTumbleThreshold / crouchReduction
	end

    local g_spike = 1

	if(flipper == 'SpecifiedAngle' and angle > 180 and angle < 360) then
        if grounded and custom_kb_threshold == nil then
            if math.abs(angle - 270) <= 30 then
                g_spike = 1.25
            elseif math.abs(angle - 270) >= 70 then
                g_spike = 1
            else
            	angle_diff_alpha = math.pow(1 - (math.abs(angle - 270) - 30) / 40, 2)
    			g_spike = 1 + 0.25 * angle_diff_alpha
            end
            realTumbleThreshold = realTumbleThreshold * (1 - (90 - math.abs(angle - 270)) / 90 * 0.125)
        else
            realTumbleThreshold = realTumbleThreshold * (1 - (90 - math.abs(angle - 270)) / 90 * 0.25)
        end
	end
	
	if (custom_kb_threshold ~= nil) then
		realTumbleThreshold = custom_kb_threshold	
		g_spike = 1
	end

	if tonumber(kbg) == 0 then
		if realTumbleThreshold > bkb * 3 then
			return nil
		else
			return 0
		end
	else
		local percent = (realTumbleThreshold / 3 - bkb) * (weight + 100) / (200 * 0.12 * kbg * g_spike) - damage
		if percent <= 0 then
			return 0
		else
			return math.ceil(percent)
		end
	end
	return 0
end

local function displayTumble(row, bkb, kbg, bIgnoresWeight, weight, d, crouch, angle, flipper, custom_kb_threshold, ForceTumble)
	local colour_num = nil
	local text = nil
	
    if(flipper == 'SpecifiedAngle' and angle > 180 and angle < 360 and custom_kb_threshold == nil) then
        if bIgnoresWeight == "True" then
            local t_g = calcTumblePercent(bkb, kbg, 100, d, crouch, angle, flipper, true, custom_kb_threshold)
            local t_a = calcTumblePercent(bkb, kbg, 100, d, crouch, angle, flipper, false, custom_kb_threshold)
            if t_g ~= nil then
            	if crouch then
					text = t_g .. '%'
					colour_num = t_g
				else
					text = tooltip('⛰️', 'When grounded.') .. t_g .. '%<br>' .. tooltip('☁️', 'When airborne.') .. t_a .. '%'
					colour_num = t_g
				end
            else
                text = "N/A"
            end
        else
            local t_g = calcTumblePercent(bkb, kbg, weight, d, crouch, angle, flipper, true, custom_kb_threshold)
            local t_a = calcTumblePercent(bkb, kbg, weight, d, crouch, angle, flipper, false, custom_kb_threshold)
            if t_g ~= nil then
            	if crouch then
					text = t_g .. '%'
					colour_num = t_g
				else
					text = tooltip('⛰️', 'When grounded.') .. t_g .. '%<br>' .. tooltip('☁️', 'When airborne.') .. t_a .. '%'
					colour_num = t_g
				end
            else
                text = "N/A"
            end
        end
    else
        if bIgnoresWeight == "True" then
            local t = calcTumblePercent(bkb, kbg, 100, d, crouch, angle, flipper, true, custom_kb_threshold)
            if t ~= nil then
                text = t .. '%'
                colour_num = t
            else
                text = "N/A"
            end
        else
            local t = calcTumblePercent(bkb, kbg, weight, d, crouch, angle, flipper, true, custom_kb_threshold)
            if t ~= nil then
                text = t .. '%'
                colour_num = t
            else
                text = "N/A"
            end
        end
    end
    if ForceTumble == 'True' and custom_kb_threshold == nil then
    	row:tag('td'):wikitext('0%')
    elseif colour_num == nil then
    	row:tag('td'):wikitext(text):addClass('ROA2-other-move')
    elseif colour_num < 20 then
    	row:tag('td'):wikitext(text)
    elseif colour_num < 50 then
    	row:tag('td'):wikitext(text)
    elseif colour_num < 100 then
    	row:tag('td'):wikitext(text)
    else
    	row:tag('td'):wikitext(text)
    end
    
    -- if ForceTumble == 'True' and custom_kb_threshold == nil then
    -- 	row:tag('td'):wikitext('0%'):addClass('ROA2-special-move')
    -- elseif colour_num == nil then
    -- 	row:tag('td'):wikitext(text):addClass('ROA2-other-move')
    -- elseif colour_num < 20 then
    -- 	row:tag('td'):wikitext(text):addClass('ROA2-special-move')
    -- elseif colour_num < 50 then
    -- 	row:tag('td'):wikitext(text):addClass('ROA2-strong-move')
    -- elseif colour_num < 100 then
    -- 	row:tag('td'):wikitext(text):addClass('ROA2-aerial-move')
    -- else
    -- 	row:tag('td'):wikitext(text):addClass('ROA2-tilt-move')
    -- end
    

	return row
end

local function makeRow(traits, hit, m, colour, alt_background)
	local ou = '\n\n' .. m .. ': '
	
	local total_string = {}
	
	local row = mw.html.create('tr')
	local row_class = 'roa2-alt-row-1'
	if alt_background then
		row_class = 'roa2-alt-row-2'
	end
	row:addClass(row_class)
	
	local count = 0
	for hit_key, hit_values in pairs(hit) do
		count = count + 1
	end
	
	
	local colour_class = nil
	if colour == 1 then
		colour_class = "ROA2-tilt-move"
	elseif colour == 2 then
		colour_class = "ROA2-strong-move"
	elseif colour == 3 then
		colour_class = "ROA2-aerial-move"
	elseif colour == 4 then
		colour_class = "ROA2-special-move"
	elseif colour == 5 then
		colour_class = "ROA2-grab-move"
	elseif colour == 6 then
		colour_class = "ROA2-other-move"
	end
	
	local cell = mw.html.create('td'):addClass(colour_class):wikitext(m):attr('rowspan', count):css("font-weight", "bold")
	row:node(cell)
	
	local new_row = false
	local temp_table = {}
	local temp_keys = {}
	for hit_key, hit_values in pairs(hit) do
		temp_table[hit_values['_ID']] = hit_values
		table.insert(temp_keys, hit_values['_ID'])
	end

	table.sort(temp_keys)
	
	table.sort(temp_table)
	for i = 1, #temp_keys do
		local hit_values = temp_table[temp_keys[i]]
		if(new_row) then
			row = mw.html.create('tr'):addClass(row_class)
		end
		row:tag('td'):wikitext(hit_values['nameID'])
		-- row:tag('td'):wikitext(hit_values['_ID'])
		row = displayTumble(row, hit_values['BaseKnockback'], hit_values['KnockbackScaling'], hit_values['bIgnoresWeight'], traits['Weight'], hit_values['Damage'], false, tonumber(hit_values['KnockbackAngle']), hit_values['KnockbackAngleMode'], nil, hit_values['ForceTumble'])
		row = displayTumble(row, hit_values['BaseKnockback'], hit_values['KnockbackScaling'], hit_values['bIgnoresWeight'], traits['Weight'], hit_values['Damage'], true, tonumber(hit_values['KnockbackAngle']), hit_values['KnockbackAngleMode'], nil, hit_values['ForceTumble'])		
		
		if(traits['chara'] == 'Etalus') then
			row = displayTumble(row, hit_values['BaseKnockback'], hit_values['KnockbackScaling'], hit_values['bIgnoresWeight'], traits['Weight'], hit_values['Damage'], false, tonumber(hit_values['KnockbackAngle']), hit_values['KnockbackAngleMode'], 34, hit_values['ForceTumble'])
			row = displayTumble(row, hit_values['BaseKnockback'], hit_values['KnockbackScaling'], hit_values['bIgnoresWeight'], armor_etalus_weight, hit_values['Damage'], false, tonumber(hit_values['KnockbackAngle']), hit_values['KnockbackAngleMode'], nil, hit_values['ForceTumble'])
			row = displayTumble(row, hit_values['BaseKnockback'], hit_values['KnockbackScaling'], hit_values['bIgnoresWeight'], armor_etalus_weight, hit_values['Damage'], true, tonumber(hit_values['KnockbackAngle']), hit_values['KnockbackAngleMode'], nil, hit_values['ForceTumble'])
			row = displayTumble(row, hit_values['BaseKnockback'], hit_values['KnockbackScaling'], hit_values['bIgnoresWeight'], armor_etalus_weight, hit_values['Damage'], false, tonumber(hit_values['KnockbackAngle']), hit_values['KnockbackAngleMode'], 34, hit_values['ForceTumble'])
		end
		
		row:done()
	
		table.insert(total_string, tostring(row))
		new_row = true
	end
	
	-- return dump(temp_table) .. "\n\n"
	return table.concat(total_string)
end

local function showTable(traits, hits)
	-- Goal: generate a table with knockdown percents for each hit
	local moveOrder = {"Jab","Ftilt","Utilt","Dtilt","Dattack","Fstrong","Ustrong","Dstrong","Nair","Fair","Fair2","Bair","Uair","Dair","Nspecial","NspecialAir","NspecialCloud","Uspecial","UspecialAir","Fspecial","Fspecial_Clone","Dspecial","DspecialAir","Dspecial_Clone","Grab","DashGrab","PivotGrab","Pummel","PummelSpecial","PummelSpecial_OLD","Fthrow","Bthrow","Uthrow","Dthrow","LedgeAttack","LedgeSpecial","LedgeSpecial_OLD","GetupAttack","GetupSpecial"}	
	local moveContains = {Jab=1,Ftilt=1,Utilt=1,Dtilt=1,Dattack=1,Fstrong=2,Ustrong=2,Dstrong=2,Nair=3,Fair=3,Fair2=3,Bair=3,Uair=3,Dair=3,Nspecial=4,NspecialAir=4,NspecialCloud=4,Uspecial=4,UspecialAir=4,Fspecial=4,Fspecial_Clone=4,Dspecial=4,DspecialAir=4,Dspecial_Clone=4,Grab=5,DashGrab=5,PivotGrab=5,Pummel=5,PummelSpecial=5,PummelSpecial_OLD=5,Fthrow=5,Bthrow=5,Uthrow=5,Dthrow=5,LedgeAttack=6,LedgeSpecial=6,LedgeSpecial_OLD=6,GetupAttack=6,GetupSpecial=6}	
	
	local total = {}
	
	
	local big_table = mw.html.create("table"):addClass('wikitable')
	
	local headers = mw.html.create('tr')
	headers:tag('th'):wikitext('Move')
	headers:tag('th'):wikitext('Hit')
	headers:tag('th'):wikitext('Knockdown %')
	headers:tag('th'):wikitext('CC %')
	if(traits['chara'] == 'Etalus') then
		headers:tag('th'):wikitext('Fair Break %')
		headers:tag('th'):wikitext('Armored Knockdown %')
		headers:tag('th'):wikitext('Armored CC %')
		headers:tag('th'):wikitext('Armored Fair Break %')
	end
	
	big_table:node(headers)
	local alt_background = true
	for k, v in ipairs(moveOrder) do
		if hits[v] then
			table.insert(total, makeRow(traits, hits[v], v, moveContains[v], alt_background))
			alt_background = not alt_background
		end
	end
	
	for m, _ in pairs(hits) do
		if not moveContains[m] then
			table.insert(total, makeRow(traits, hits[m], m, 7, alt_background))
			alt_background = not alt_background
		end
	end
	big_table:wikitext(table.concat(total))

	return mw.html.create("div"):addClass("roa2-percent-table"):node(big_table):done()
end

local function createPercents(notes,host,opp)
	
	local hittables = 'ROA2_HitData'
	local hitfields = '_ID, moveID, nameID, Damage, BaseKnockback, KnockbackScaling, KnockbackAngle, bIgnoresWeight, KnockbackAngleMode, FinalBaseKnockback, ForceTumble'
	local hostHits = {}
	
	local hitresults = cargo.query( hittables, hitfields, {orderBy = 'moveID, _ID', where = 'chara="' .. host .. '"'})
	for r=1, #hitresults do
		if not hostHits[hitresults[r]['moveID']] then
			hostHits[hitresults[r]['moveID']] = {}
		end
		hostHits[hitresults[r]['moveID']][hitresults[r]['nameID']] = hitresults[r]
	end
	
	local chartables = 'ROA2_CharacterData'
	local charfields = 'chara, Weight'
	local hostTraits = cargo.query(chartables, charfields, {where = 'chara="' .. host .. '"'})[1]
	
	local oppHits = {}
	local oppTraits = {}
	
	if opp ~= host then
		local hitresults = cargo.query( hittables, hitfields, {orderBy = 'moveID, _ID', where = 'chara="' .. opp .. '"'})
		for r=1, #hitresults do
			if not oppHits[hitresults[r]['moveID']] then
				oppHits[hitresults[r]['moveID']] = {}
			end
			oppHits[hitresults[r]['moveID']][hitresults[r]['nameID']] = hitresults[r]
		end
		oppTraits = cargo.query( chartables, charfields, {where = 'chara="' .. opp .. '"'})[1]
	end
	
	local outputNotes = notes
	if outputNotes == nil then
		outputNotes = "''The following matchup notes are blank. Perhaps you can help add some?''"
	end
	
	if(host == opp) then
		return tabber({
			label1 = "General Notes",
			content1 = outputNotes,
			label2 = 'Ditto Attacks',
			content2 = tostring(showTable(hostTraits, hostHits)),
		})
	else
		return tabber({
			label1 = "General Notes",
			content1 = outputNotes,
			label2 = host .. ' Attacks',
			content2 = tostring(showTable(oppTraits, hostHits)),
			label3 = opp .. ' Attacks',
			content3 = tostring(showTable(hostTraits, oppHits))
		})
	end
	
	-- return t
end

function p.main(frame)
	local args = require("Arguments").getArgs(frame)
	local titleObj = mw.title.getCurrentTitle()
	local subpage = titleObj.basePageTitle.subpageText
	local host = args['host'] or (titleObj.namespace == 10 and "Clairen" or subpage) -- 10 means Template:
	local opp = args['mu'] or "Zetterburn"
	
	local box = mw.html.create("div"):addClass("mu-box")
	
	local header = mw.html.create("div"):addClass("mw-heading")
		:tag("h1"):attr("id", opp):wikitext(opp)
		:tag("span"):addClass("mw-editsection")
		:done()
	
	local portrait = "[[File:RoA2_" .. opp .. "_Portrait.png"
					.. "|link=RoA2/" .. opp
					.. "|200px]]"
    local nav = mw.html.create("div"):addClass("roa2-mu-nav"):wikitext(portrait)
    nav:tag("div"):addClass("roa2-mu-oneliner"):wikitext(args["oneliner"]):done()
		:tag("div"):addClass("roa2-mu-button"):addClass("highlight-blue"):wikitext("[[RoA2/" .. opp .. "|Overview]]"):done()
		:tag("div"):addClass("roa2-mu-button"):addClass("highlight-red"):wikitext("[[RoA2/" .. opp .. "/Strategy|Counterstrategy]]"):done()
		:tag("div"):addClass("roa2-mu-button"):addClass("highlight-slate"):wikitext("[[RoA2/" .. opp .. "/Data#Character_Stats|Character Stats]]"):done()
		:tag("div"):addClass("roa2-mu-button"):addClass("highlight-yellow"):wikitext("[[RoA2/" .. opp .. "/Matchups#" .. host .. "|Inverse Matchup]]"):done()
box:node(nav)
	box:tag("div"):addClass("roa2-mu-main"):wikitext(tostring(createPercents(args["notes"],host, opp)))
	return tostring(header) .. tostring(box) .. mw.getCurrentFrame():extensionTag({
			name = "templatestyles",
			args = { src = "Template:RoA2-Matchup/styles.css" },
		})
end
return p