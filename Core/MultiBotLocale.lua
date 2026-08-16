local MultiBot = _G.MultiBot
if not MultiBot then return end

local aceLocale = LibStub and LibStub("AceLocale-3.0", true)
local cachedLocale

function MultiBot.RegisterLocaleStrings(locale, values)
  local isDefault = locale == "enUS"
  local localeTable = aceLocale:NewLocale("MultiBot", locale, isDefault)
  if not localeTable then
    return
  end

  for key, value in pairs(values) do
    localeTable[key] = value
  end
end

function MultiBot.GetLocaleString(key, fallback)
  if not cachedLocale then
    cachedLocale = aceLocale:GetLocale("MultiBot", true)
  end
  return cachedLocale and rawget(cachedLocale, key) or fallback or key
end

MultiBot.L = MultiBot.GetLocaleString