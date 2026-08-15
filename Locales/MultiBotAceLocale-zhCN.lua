local register = MultiBot and MultiBot.RegisterLocaleStrings
if type(register) ~= "function" then
  return
end

local zhCNValues = {
}

register("zhCN", zhCNValues)

if (GetLocale and GetLocale() == "zhCN") and type(MultiBot.ApplyLocaleKeyValues) == "function" then
  MultiBot.ApplyLocaleKeyValues(zhCNValues)
end