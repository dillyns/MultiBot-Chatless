local MultiBot = _G.MultiBot

local Strategies = {
  active = {},
}

MultiBot.Strategies = Strategies

local function splitList(value)
  local result = {}

  for strategy in string.gmatch(value or "", "[^,]+") do
    result[#result + 1] = string.gsub(strategy, "^%s*(.-)%s*$", "%1")
  end

  return result
end

local function parseStatePayload(payload)
  local fields = {}
  local startIndex = 1

  for index = 1, 2 do
    local separator = string.find(payload, "~", startIndex, true)
    if not separator then
      fields[index] = string.sub(payload, startIndex)
      startIndex = #payload + 1
    else
      fields[index] = string.sub(payload, startIndex, separator - 1)
      startIndex = separator + 1
    end
  end

  fields[3] = string.sub(payload, startIndex)

  return {
    name = fields[1],
    combat = splitList(fields[2]),
    nonCombat = splitList(fields[3]),
  }
end

function Strategies.GetActive()
  return Strategies.active
end

function Strategies.GetForBot(name)
  return Strategies.active[name]
end

function Strategies.SetActive(entries)
  Strategies.active = entries
  return Strategies.active
end

function Strategies.ApplyState(payload)
  local state = parseStatePayload(payload or "")
  Strategies.active[state.name] = state

  if MultiBot.ClassUI and MultiBot.ClassUI.RefreshForBot then
    MultiBot.ClassUI.RefreshForBot(state.name)
  end

  return state
end

function Strategies.Clear()
  Strategies.active = {}
  return Strategies.active
end
