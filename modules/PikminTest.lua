local p = {}
local mArguments

function p.main(frame)
	mArguments = require( 'Arguments' )
	local args = mArguments.getArgs(frame)
	return p._main(args)
end
	
function p._main( args )

	local colour = args[1]
	local lowerColour = string.lower(colour)
	local outputText = mw.html.create("span")
	local iconStr = "[[File:Pikmin_"
	
	if colour == nil then
		colour = "red"
	end
	if string.match(lowerColour, "red") then
		outputText:css("color", "red")
		iconStr = iconStr .. "Red"
	elseif string.match(lowerColour, "blue") then
		outputText:css("color", "blue")
		iconStr = iconStr .. "Blue"
	elseif string.match(lowerColour, "yellow") then
		outputText:css("color", "yellow")
		iconStr = iconStr .. "Yellow"
	elseif string.match(lowerColour, "purple") then
		outputText:css("color", "purple")
		iconStr = iconStr .. "Purple"
	elseif string.match(lowerColour, "white") then
		outputText:css("color", "white")
		iconStr = iconStr .. "White"
	elseif (string.match(lowerColour, "winged") 
		or string.match(lowerColour, "pink")) then
		outputText:css("color", "pink")
		iconStr = iconStr .. "Winged"
	elseif (string.match(lowerColour, "captain")  
		or string.match(lowerColour, "olimar") 
		or string.match(lowerColour, "alph") 
		or string.match(lowerColour, "none") 
		or string.match(lowerColour, "no") 
		or string.match(lowerColour, "na") 
		or string.match(lowerColour, "n/a")) then
		outputText:css("color", "grey")
		iconStr = iconStr .. "Captain"
	else
		outputText:css("color", "black")
		iconStr = ""
	end
	if iconStr ~= "" then
		iconStr = iconStr .. ".png|inline|x30px|class=notpageimage]]"
		end
	outputText:wikitext(iconStr .. " " .. colour):done()
	return tostring(outputText)
end

return p