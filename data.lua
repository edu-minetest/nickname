-- LUALOCALS < ---------------------------------------------------------
local minetest, yaml, DIR_DELIM, nickname
    = minetest, yaml, DIR_DELIM, nickname
-- LUALOCALS > ---------------------------------------------------------

local DATA_PATH = nickname.DATA_PATH
local cache = {}

local function getNickInfo(playerName)
  local result = cache[playerName]
  if not result then
    local filename = DATA_PATH .. DIR_DELIM .. playerName .. ".yml"
    result = yaml.readFile(filename)
    cache[playerName] = result or {}
    if result then
      local text = result.text
      if text and not string.find(text, playerName) then
        result.text = text .. "(" .. playerName .. ")"
      end
    else
      result = minetest.get_nametag_attributes(playerName)
    end
  end
  return result
end
nickname.getInfo = getNickInfo

local function getNickname(playerName)
  local result = getNickInfo(playerName)
  if type(result) == "table" then result = result.text end
  if result and #result then
    return result
  end
end
nickname.get = getNickname

local function setNickName(playerName, nickName, color, bgcolor)
  local filename = DATA_PATH .. DIR_DELIM .. playerName .. ".yml"
  local content = cache[playerName] or {}
  if color ~= nil then content.color = color end
  if bgcolor ~= nil then content.bgcolor = bgcolor end
  if nickName ~= nil then content.text = nickName .. "(" .. playerName .. ")" end
  local player = minetest.get_player_by_name(playerName)
  player:set_nametag_attributes(content)
  return yaml.writeFile(filename, content)
end
nickname.set = setNickName

return {
  get = getNickname,
  getInfo = getNickInfo,
  set = setNickName,
}
