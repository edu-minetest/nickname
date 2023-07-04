-- LUALOCALS < ---------------------------------------------------------
local minetest, yaml, DIR_DELIM, nickname
    = minetest, yaml, DIR_DELIM, nickname
-- LUALOCALS > ---------------------------------------------------------

local S = nickname.get_translator
local DATA_PATH = nickname.DATA_PATH
local cache = {}

local function isFileExists(filename)
  local f = io.open(filename, 'r')
  if (f) then
    f:close()
    return true
  end
end

local function readNickFromConf(filename)
  filename = filename .. ".conf"
  local result = Settings(filename)
  if result:get('text') ~= nil then
    return result:to_table()
  end
end

local function readNickFromYaml(filename)
  filename = filename .. ".yml"
  return yaml.readFile(filename)
end

local function getNickInfo(playerName)
  local result = cache[playerName]
  if not result then
    local filename = DATA_PATH .. DIR_DELIM .. playerName
    result = readNickFromConf(filename)
    if (result == nil) then result = readNickFromYaml(filename) end
    cache[playerName] = result or {}
    if result then
      local text = result.text
      if text and not string.find(text, playerName) then
        result.text = text .. "(" .. playerName .. ")"
      end
    else
      local player = minetest.get_player_by_name(playerName)
      if player == nil then return false, S('No player named "@1" exists', playerName) end
      result = player:get_nametag_attributes()
    end
  end
  return result
end
nickname.getInfo = getNickInfo

local function getNickname(playerName)
  local result, msg = getNickInfo(playerName)
  if type(result) == "table" then result = result.text end
  return result, msg
end
nickname.get = getNickname

local function setNicknameInfo(playerName, info)
  if info == nil then return end
  local content = cache[playerName]
  if content then
    for k, v in pairs(info) do
      if k == 'text' or k == 'color' or k == 'bgcolor' then
        if k == 'text' then v = v .. "(" .. playerName .. ")" end
        content[k] = v
      end
    end
  else
    content = info
  end

  local player = minetest.get_player_by_name(playerName)
  if player ~= nil then player:set_nametag_attributes(content) end

  -- can write offline player
  local filename = DATA_PATH .. DIR_DELIM .. playerName
  local vSettings = Settings(filename .. '.conf')
  local result
  for k,v in pairs(content) do
    vSettings:set(k,v)
    result = true
  end
  if result then vSettings:write() end
  return result
end
nickname.set = setNicknameInfo
nickname.setInfo = setNicknameInfo

return {
  get = getNickname,
  getInfo = getNickInfo,
  set = getNickInfo,
  setInfo = setNicknameInfo,
}
