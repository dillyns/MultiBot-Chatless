local register = MultiBot and MultiBot.RegisterLocaleStrings
if type(register) ~= "function" then
  return
end

local deDEValues = {
}

register("deDE", deDEValues)

if (GetLocale and GetLocale() == "deDE") and type(MultiBot.ApplyLocaleKeyValues) == "function" then
  MultiBot.ApplyLocaleKeyValues(deDEValues)
end