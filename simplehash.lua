local bit32 = require("bit32")

--- not a secure hashing algorithm (as you can tell from the length).
--- (it's also vibed up by AI)
--- this is only for making strings safe to be used as file names. (reference_output)
local function simpleHash(str)
  local h1, h2, h3, h4 = 2166136261, 2166136261, 2166136261, 2166136261
  for i = 1, #str do
    local b = str:byte(i)
    h1 = (bit32.bxor(h1, b) * 16777619) % 2 ^ 32
    h2 = (bit32.bxor(h2, b) * 2166136261) % 2 ^ 32
    h3 = (bit32.bxor(h3, b) * 374761393) % 2 ^ 32
    h4 = (bit32.bxor(h4, b) * 668265263) % 2 ^ 32
  end
  return string.format("%08x%08x%08x%08x", h1, h2, h3, h4)
end

return simpleHash
