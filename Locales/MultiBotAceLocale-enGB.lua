local register = MultiBot and MultiBot.RegisterLocaleStrings
if type(register) ~= "function" then
  return
end

local enGBValues = {
}

register("enGB", enGBValues)

if (GetLocale and GetLocale() == "enGB") and type(MultiBot.ApplyLocaleKeyValues) == "function" then
  MultiBot.ApplyLocaleKeyValues(enGBValues)
end