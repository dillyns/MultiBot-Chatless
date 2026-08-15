local register = MultiBot and MultiBot.RegisterLocaleStrings
if type(register) ~= "function" then
  return
end

local esESValues = {
}

register("esES", esESValues)

if (GetLocale and GetLocale() == "esES") and type(MultiBot.ApplyLocaleKeyValues) == "function" then
  MultiBot.ApplyLocaleKeyValues(esESValues)
end