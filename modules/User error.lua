--------------------------------------------------------------------------------
-- A less intimidating version of the built-in "error()" function, to help
-- editors fix their mistakes when transcluding a template.
--
-- @see [[wikia:w:c:Dev:Module:User error]] for a similar module.
--------------------------------------------------------------------------------

local checkType = require("libraryUtil").checkType;

return function (message, ...)
	checkType("Module:User error", 1, message, "string");

	local result = mw.text.tag(
		"strong",
		{ class="error" },
		"Error: " .. message
	);

	local categories = {};
	for i = 1, select("#", ...) do
		local category = select(i, ...);
		checkType("Module:User error", 1 + i, category, "string", true);

		if (category and category ~= "") then
			table.insert(categories, "[[Category:" .. category .. "]]");
		end
	end

	return result .. table.concat(categories);
end;