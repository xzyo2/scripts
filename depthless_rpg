--  
--  __  ___   _  ___  
--  \ \/ / | | |/ _ \ 
--   >  <| |_| | (_) |
--  /_/\_\\__, |\___/ 
--        |___/       
local A0_ = [[<BASE64_ENCODED_CODE>]]
local function A1_(str)
  local b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
  str = string.gsub(str, '[^'..b..'=]', '')
  return (str:gsub('.', function(x)
    if (x == '=') then return '' end
    local r, f = '', (b:find(x) - 1)
    for i = 6, 1, -1 do
      r = r .. (f % 2^i - f % 2^(i-1) > 0 and '1' or '0')
    end
    return r
  end):gsub('%d%d%d?%d?%d?%d?%d?%d', function(x)
    if (#x ~= 8) then return '' end
    local c = 0
    for i = 1, 8 do
      c = c + (string.sub(x, i, i) == '1' and 2^(8-i) or 0)
    end
    return string.char(c)
  end))
end
local A2_ = A1_(A0_)
loadstring(A2_)()
