local register = MultiBot and MultiBot.RegisterLocaleStrings
if type(register) ~= "function" then
  return
end

local koKRValues = {
}

register("koKR", koKRValues)

if (GetLocale and GetLocale() == "koKR") and type(MultiBot.ApplyLocaleKeyValues) == "function" then
  MultiBot.ApplyLocaleKeyValues(koKRValues)
end