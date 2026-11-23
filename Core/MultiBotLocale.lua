local MultiBot = _G.MultiBot
if not MultiBot then
  return
end

local AceLocale = LibStub("AceLocale-3.0")
local Locale = {}

MultiBot.Locale = Locale

function Locale.RegisterStrings(locale, values)
  local isDefault = locale == "enUS"
  local localeTable = AceLocale:NewLocale("MultiBot", locale, isDefault)

  if not localeTable then
    return
  end

  for key, value in pairs(values) do
    localeTable[key] = value
  end
end

function Locale.GetString(key, fallback)
  local localeTable = AceLocale:GetLocale("MultiBot", true)

  return localeTable and rawget(localeTable, key) or fallback or key
end
