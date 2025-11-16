-- This module was created by Tarkus Lee from Dustloop Wiki

local p = {}

function p.drawDataNotes(frame)
  local name = frame.args[1]

  local wikitext = ""

  if (name ~= "")
  then
    wikitext = "'''" .. name .. ":'''\n"
  end
  
  for token in string.gmatch(frame.args[2], '([^;]+)') do
    note = token

    wikitext = wikitext .. "*" .. note .. "\n"

  end

  return wikitext
end

return p