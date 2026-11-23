local MultiBot = _G.MultiBot

local Bridge = {}
local PREFIX = "MBOT"
local ROSTER_REQUEST = "GET~ROSTER"
local STRATEGIES_REQUEST = "GET~STATES"
local STRATEGY_REQUEST = "GET~STATE~"

MultiBot.Bridge = Bridge

local function splitOnce(value, separator)
  local startIndex, endIndex = string.find(value, separator, 1, true)
  if not startIndex then
    return value, ""
  end

  return string.sub(value, 1, startIndex - 1), string.sub(value, endIndex + 1)
end

local function encodeField(value)
  return string.gsub(tostring(value or ""), "%%", "%%25")
end

function Bridge.RequestActiveRoster()
  SendAddonMessage(PREFIX, ROSTER_REQUEST, "WHISPER", UnitName("player"))
end

function Bridge.RequestActiveStrategies()
  SendAddonMessage(PREFIX, STRATEGIES_REQUEST, "WHISPER", UnitName("player"))
end

function Bridge.RequestBotStrategies(botName)
  SendAddonMessage(PREFIX, STRATEGY_REQUEST .. encodeField(botName), "WHISPER", UnitName("player"))
end

function Bridge.RunCombatCommand(botName, command)
  local token = tostring(GetTime())
  local payload = "RUN~COMBAT~BOT~" .. encodeField(botName) .. "~" .. token .. "~" .. encodeField(command)
  SendAddonMessage(PREFIX, payload, "WHISPER", UnitName("player"))
end

function Bridge.RunNonCombatCommand(botName, command)
  SendChatMessage(command, "WHISPER", nil, botName)
end

function Bridge.RunGroupCommand(command)
  SendChatMessage(command, "PARTY")
end

local OPCODE_HANDLERS = {
  ROSTER = function(payload)
    MultiBot.Roster.ApplyPayload(payload)
  end,
  STATE = function(payload)
    MultiBot.Strategies.ApplyState(payload)
  end,
}

function Bridge.OnAddonMessage(prefix, message)
  if prefix ~= PREFIX then
    return
  end

  local opcode, payload = splitOnce(message or "", "~")
  local handler = OPCODE_HANDLERS[opcode]
  if not handler then
    return
  end

  handler(payload)
end
