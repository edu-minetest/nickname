-- LUALOCALS < ---------------------------------------------------------
local minetest, yaml, DIR_DELIM, nickname
    = minetest, yaml, DIR_DELIM, nickname
-- LUALOCALS > ---------------------------------------------------------

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
      result = player:get_nametag_attributes()
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
  local content = cache[playerName] or {}
  if color ~= nil then content.color = color end
  if bgcolor ~= nil then content.bgcolor = bgcolor end
  if nickName ~= nil then content.text = nickName .. "(" .. playerName .. ")" end
  local player = minetest.get_player_by_name(playerName)
  player:set_nametag_attributes(content)

  local filename = DATA_PATH .. DIR_DELIM .. playerName
  local isConf = isFileExists(filename .. '.conf')
  if (isConf) then
    local vSettings = Settings(filename .. '.conf')
    local result
    for k,v in pairs(content) do
      if v ~= nil then
        vSettings:set(k,v)
        result = true
      end
    end
    if result then vSettings:write() end
    return result
  else
    return yaml.writeFile(filename .. '.yml', content)
  end
end
nickname.set = setNickName

return {
  get = getNickname,
  getInfo = getNickInfo,
  set = setNickName,
}
