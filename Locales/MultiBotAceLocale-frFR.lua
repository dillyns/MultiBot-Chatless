local register = MultiBot and MultiBot.RegisterLocaleStrings
if type(register) ~= "function" then
  return
end

local frFRValues = {
}

register("frFR", frFRValues)

if (GetLocale and GetLocale() == "frFR") and type(MultiBot.ApplyLocaleKeyValues) == "function" then
  MultiBot.ApplyLocaleKeyValues(frFRValues)
end