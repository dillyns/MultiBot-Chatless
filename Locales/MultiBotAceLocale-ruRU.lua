local register = MultiBot and MultiBot.RegisterLocaleStrings
if type(register) ~= "function" then
  return
end

local ruRUValues = {
}

register("ruRU", ruRUValues)

if (GetLocale and GetLocale() == "ruRU") and type(MultiBot.ApplyLocaleKeyValues) == "function" then
  MultiBot.ApplyLocaleKeyValues(ruRUValues)
end