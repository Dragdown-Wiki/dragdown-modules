--- @param inputstr string?
--- @param sep string
--- @return table|nil
return function(inputstr, sep)
	if sep == nil then
		sep = "%s"
	end

	if inputstr == nil then
		return nil
	end

	local t = {}

	for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
		table.insert(t, str)
	end

	return t
end