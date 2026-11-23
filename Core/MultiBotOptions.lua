local MultiBot = _G.MultiBot
if not MultiBot then
  return
end

local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local Options = {}
local L = MultiBot.Locale.GetString

local FRAME_STRATA_VALUES = {
  BACKGROUND = L("options.frame_strata.background"),
  LOW = L("options.frame_strata.low"),
  MEDIUM = L("options.frame_strata.medium"),
  HIGH = L("options.frame_strata.high"),
  DIALOG = L("options.frame_strata.dialog"),
  FULLSCREEN = L("options.frame_strata.fullscreen"),
  FULLSCREEN_DIALOG = L("options.frame_strata.fullscreen_dialog"),
  TOOLTIP = L("options.frame_strata.tooltip"),
}

local function getProfileList()
  local db = MultiBot.Storage and MultiBot.Storage.db
  if not db then
    return {}
  end

  local profiles = db:GetProfiles()
  local list = {}
  for _, name in ipairs(profiles or {}) do
    list[name] = name
  end

  return list
end

local function getDeleteProfileList()
  local db = MultiBot.Storage and MultiBot.Storage.db
  if not db then
    return {}
  end

  local current = db:GetCurrentProfile()
  local profiles = db:GetProfiles()
  local list = {}
  for _, name in ipairs(profiles or {}) do
    if name ~= current then
      list[name] = name
    end
  end

  return list
end

local OPTIONS = {
  type = "group",
  name = L("options.name"),
  args = {
    frameStrata = {
      type = "select",
      name = L("options.frame_strata.name"),
      desc = L("options.frame_strata.description"),
      order = 1,
      values = FRAME_STRATA_VALUES,
      get = function()
        return MultiBot.Config.GetFrameStrata()
      end,
      set = function(_, value)
        MultiBot.Config.SetFrameStrata(value)
        MultiBot.Config.ApplyFrameStrata()
      end,
    },
    profileHeader = {
      type = "header",
      name = L("options.profile.header"),
      order = 10,
    },
    currentProfile = {
      type = "select",
      name = L("options.profile.current.name"),
      desc = L("options.profile.current.description"),
      order = 11,
      values = getProfileList,
      get = function()
        local db = MultiBot.Storage and MultiBot.Storage.db
        return db and db:GetCurrentProfile()
      end,
      set = function(_, value)
        local db = MultiBot.Storage and MultiBot.Storage.db
        if db and value then
          db:SetProfile(value)
          MultiBot.Config.ApplyFrameStrata()
          MultiBot.Config.ApplyMainUIPosition()
        end
      end,
    },
    deleteProfile = {
      type = "select",
      name = L("options.profile.delete.name"),
      desc = L("options.profile.delete.description"),
      order = 12,
      values = getDeleteProfileList,
      confirm = function(_, value)
        return L("options.profile.delete.confirm") .. "\n(" .. tostring(value) .. ")"
      end,
      get = function()
        return nil
      end,
      set = function(_, value)
        local db = MultiBot.Storage and MultiBot.Storage.db
        if db and value then
          db:DeleteProfile(value)
        end
      end,
      disabled = function()
        local list = getDeleteProfileList()
        return next(list) == nil
      end,
    },
  },
}

Options.Definition = OPTIONS
MultiBot.Options = Options

function Options.Register()
  AceConfig:RegisterOptionsTable("MultiBot", OPTIONS)
  AceConfigDialog:AddToBlizOptions("MultiBot", "MultiBot")
end
