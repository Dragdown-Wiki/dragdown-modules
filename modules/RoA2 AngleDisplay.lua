return {
	main = function(frame)
		local args = require("Arguments").getArgs(frame)
		local angle = tonumber(args[1]) or tonumber(args.angle)
		local flipper = args.flipper
		
		local n = mw.html.create("span"):addClass("tooltip")
		
		if(flipper ~= 'SpecifiedAngle' and flipper ~= nil) then
			n:wikitext('*')
			local display = mw.html.create("span"):addClass("tooltiptext"):wikitext('This move has a unique angle flipper of ' ..  flipper .. '.'):done()
			n:node(display)
			n:done()
		else
			n:wikitext(angle)
			if(angle <= 45 or angle >= 315) then
				n:css('color', '#1ba6ff')
			elseif(angle > 225) then
				n:css('color', '#ff6b6b')
			elseif(angle > 135) then
				n:css('color', '#de7cd1')
			elseif(angle > 45) then
				n:css('color', '#16df53')
			end
	
			local display = mw.html.create('span'):addClass("tooltiptext")
			local div1 = mw.html.create('div'):css('position', 'relative'):css('top', '0'):css('max-width', '256px')
				:tag('div'):css('transform', 'rotate(-'.. angle ..'deg)'):css('z-index', '0'):css('position', 'absolute'):css('top', '0'):css('left', '0'):css('transform-origin', 'center center'):wikitext('[[File:ROA2_AngleComplex_BG.png|256px|link=]]'):done()
				:tag('div'):css('z-index', '1'):css('position', 'relative'):css('top', '0'):css('left', '0'):wikitext('[[File:ROA2_AngleComplex_MG.png|256px|link=]]'):done()
				:tag('div'):css('transform', 'rotate(-'.. angle ..'deg)'):css('z-index', '2'):css('position', 'absolute'):css('top', '0'):css('left', '0'):css('transform-origin', 'center center'):wikitext('[[File:ROA2_AngleComplex_FG.png|256px|link=]]'):done()
			if args.reverse then
				div1:wikitext("This hit can reverse, sending depending on the attacker's position to the defender.")
			else
				div1:wikitext("This hit cannot reverse, sending depending on which way the attacker is facing.")
			end
			div1:done()
			display:node(div1):wikitext('[[File:ROA2_AngleComplex_Key.png|256px|link=]]')
			display:done()
			
			n:node(display):done()
			n:done()
			return tostring(n)
		end
	end
}