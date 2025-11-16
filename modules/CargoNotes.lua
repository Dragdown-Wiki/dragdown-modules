-- This module was created by Tarkus Lee from Dustloop Wiki

return {
  drawDataNotes = function(frame)
    local name = frame.args[1]
    local wikitext = name ~= "" and "'''" .. name .. ":'''\n" or ""

    for token in frame.args[2]:gmatch('([^;]+)') do
      wikitext = wikitext .. "*" .. token .. "\n"
    end

    return wikitext
  end
}
