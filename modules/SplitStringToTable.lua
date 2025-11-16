local p = {} --p stands for package

--- Escape pattern for regex

--- @param s string string to escape
--- @return string
local function escapePattern(s)
	return s:gsub("%W", "%%%1")
end

--- Split string by delimiter and return the table of string parts
---
--- @param str string String to split
--- @param delimiter string Delimiter used to split the string, default to %s
--- @param trim bool Trim spaces from beginning and end of split strings
--- @return table
function p.splitStringIntoTable( str, delimiter, trim )
    if delimiter == nil then
        delimiter = "%s"
    end
	if str == nil then
		return nil
	end
    local t = {}
    local pattern = '[^' .. escapePattern( delimiter ) .. ']+'
    for s in string.gmatch( str, pattern ) do
        table.insert( t, trim and s:match("^%s*(.-)%s*$") or s )
    end
    return t
end

return p