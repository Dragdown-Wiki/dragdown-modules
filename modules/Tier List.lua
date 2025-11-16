local p = {}

function p.drawTierList(frame)
  local wikitext = "<div class=\"tierList\">" -- initialize the wikitext with the container for the list
  local GAME = frame.args[1]:gsub("%s+", "") -- capture the target game from the first arg
  local character = "default"
  local numberOfTiers = tablelength(frame.args)
  local colors = {'b8ff89', 'fdff89', 'ffdf7f', 'ffbf7f', 'e98d87', 'ff7ff0', 'd17fff', '7fbfff', '7feeff', '7fffc3', '7fffc3'} -- an array of pre-defined colors

  for index=2,numberOfTiers do
    local currentTier = trim(frame.args[index]) -- use the argument at the current index as current tier data
    local tierLabel = string.match(currentTier, '(.*);') -- capture tier label from all characters before first ';'
    currentTier = string.match(currentTier, ";(.*)") -- remove the tier label from the current tier data

    --Inject tier label
    if index == 2 then -- first tier should have a rounded top corner
      wikitext = wikitext .. "<div class=\"tierHeader\" style=\"background-color: #" .. colors[1] .. "; border-top-left-radius: 4px;\">" .. tierLabel .. "</div>"
    elseif index == numberOfTiers then -- middle tiers are normal
      wikitext = wikitext .. "<div class=\"tierHeader\" style=\"background-color: #" .. colors[index-1] .. "; border-bottom-left-radius: 4px;\">" .. tierLabel .. "</div>"
    else -- final tier has a roudned bottom corner
      wikitext = wikitext .. "<div class=\"tierHeader\" style=\"background-color: #" .. colors[index-1] .. ";\">" .. tierLabel .. "</div>"
    end
    
    -- open a new tier container
    if index ~= numberOfTiers then 
      wikitext = wikitext .. "<div class=\"tierGroup tierUnderline\">"
    else -- final tier does not have an underline
      wikitext = wikitext .. "<div class=\"tierGroup\">"
    end

    -- iterate over tokens in current tier, sperrated by ',' character
    for token in string.gmatch(currentTier, '([^,]+)') do
      character = token
      -- inject character label
      local characterLabel = frame:expandTemplate{ title = 'StockIcon', args = { GAME, character, '32px' } }
      wikitext = wikitext .. "<div>" .. characterLabel .. "</div>"
    end
  
    -- close the current tier container
    wikitext = wikitext .. "</div>"

  end

  -- close the entire tier list
  wikitext = wikitext .. "</div>"

  return wikitext
end

-- Return the size of a table by iterating over it and counting
function tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

function trim(s)
  return (string.gsub(s, "^%s*(.-)%s*$", "%1"))
end

return p