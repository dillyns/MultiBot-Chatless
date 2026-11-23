local MultiBot = _G.MultiBot

local Roster = {
  active = {},
}

MultiBot.Roster = Roster

local function parseRosterEntry(entry)
  local fields = {}
  for value in string.gmatch(entry, "([^,]+)") do
    fields[#fields + 1] = value
  end

  return {
    name = fields[1],
    classId = tonumber(fields[2] or "0") or 0,
    level = tonumber(fields[3] or "0") or 0,
    mapId = tonumber(fields[4] or "0") or 0,
    alive = fields[5] == "1",
    hpPct = tonumber(fields[6] or "0") or 0,
    mpPct = tonumber(fields[7] or "0") or 0,
  }
end

local function parseRosterPayload(payload)
  local entries = {}
  if type(payload) ~= "string" or payload == "" then
    return entries
  end

  for entry in string.gmatch(payload, "([^;]+)") do
    entries[#entries + 1] = parseRosterEntry(entry)
  end

  return entries
end

function Roster.GetActive()
  return Roster.active
end

function Roster.RequestRefresh()
  if Roster.refreshTimer then
    return
  end

  Roster.refreshTimer = MultiBot.lifecycle:ScheduleTimer(function()
    Roster.RequestRefreshNow()
  end, 0.5)
end

function Roster.RequestRefreshNow()
  Roster.refreshTimer = nil
  MultiBot.Bridge.RequestActiveRoster()
end

function Roster.CancelRefresh()
  if Roster.refreshTimer then
    MultiBot.lifecycle:CancelTimer(Roster.refreshTimer)
    Roster.refreshTimer = nil
  end
end

function Roster.DumpActive()
  local entries = Roster.GetActive()
  DEFAULT_CHAT_FRAME:AddMessage("[MultiBot] Active roster: " .. tostring(#entries) .. " bot(s)")

  for index, entry in ipairs(entries) do
    DEFAULT_CHAT_FRAME:AddMessage(string.format(
      "[MultiBot] %d: %s class=%d level=%d map=%d alive=%s hp=%d mp=%d",
      index,
      tostring(entry.name),
      entry.classId,
      entry.level,
      entry.mapId,
      tostring(entry.alive),
      entry.hpPct,
      entry.mpPct
    ))
  end

  return entries
end

function Roster.SetActive(entries)
  Roster.active = entries
  Roster.DumpActive()

  if MultiBot.ActiveRosterUI then
    if MultiBot.ActiveRosterUI.RefreshRoster then
      MultiBot.ActiveRosterUI.RefreshRoster()
    end
    if MultiBot.ActiveRosterUI.RefreshSelfbot then
      MultiBot.ActiveRosterUI.RefreshSelfbot()
    end
  end

  MultiBot.Bridge.RequestActiveStrategies()

  return Roster.active
end

function Roster.ApplyPayload(payload)
  return Roster.SetActive(parseRosterPayload(payload))
end

function Roster.Clear()
  return Roster.SetActive({})
end
