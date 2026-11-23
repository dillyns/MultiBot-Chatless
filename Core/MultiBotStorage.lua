local MultiBot = _G.MultiBot
if not MultiBot then
  return
end

local AceDB = LibStub("AceDB-3.0")
local Storage = {}

local DEFAULTS = {
  profile = {
    mainUIPosition = {
      point = "BOTTOMRIGHT",
      relativePoint = "BOTTOMRIGHT",
      x = -12,
      y = 12,
    },
    frameStrata = "HIGH",
  },
}

MultiBot.Storage = Storage

function Storage.Initialize()
  Storage.db = AceDB:New("MultiBotDB", DEFAULTS, "Default")
  return Storage.db
end

function Storage.GetProfile()
  return Storage.db and Storage.db.profile
end

function Storage.GetGlobal()
  return Storage.db and Storage.db.global
end
