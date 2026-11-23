local MultiBot = _G.MultiBot

local Config = {}
local DEFAULT_FRAME_STRATA = "HIGH"
local DEFAULT_MAIN_UI_POSITION = {
  point = "BOTTOMRIGHT",
  relativePoint = "BOTTOMRIGHT",
  x = -12,
  y = 12,
}
local VALID_FRAME_STRATA = {
  BACKGROUND = true,
  LOW = true,
  MEDIUM = true,
  HIGH = true,
  DIALOG = true,
  FULLSCREEN = true,
  FULLSCREEN_DIALOG = true,
  TOOLTIP = true,
}

MultiBot.Config = Config

-- Main UI Position

function Config.GetMainUIPosition()
  local profileStore = MultiBot.Storage.GetProfile()
  local position = profileStore and profileStore.mainUIPosition

  if type(position) ~= "table"
      or type(position.point) ~= "string"
      or type(position.relativePoint) ~= "string"
      or type(position.x) ~= "number"
      or type(position.y) ~= "number" then
    return DEFAULT_MAIN_UI_POSITION
  end

  return position
end

function Config.SetMainUIPosition(point, relativePoint, x, y)
  local profileStore = MultiBot.Storage.GetProfile()
  if profileStore then
    profileStore.mainUIPosition = {
      point = point,
      relativePoint = relativePoint,
      x = x,
      y = y,
    }
    return profileStore.mainUIPosition
  end
end

function Config.ApplyMainUIPosition()
  if MultiBot.MainUI and MultiBot.MainUI.frame then
    local pos = Config.GetMainUIPosition()
    MultiBot.MainUI.frame:ClearAllPoints()
    MultiBot.MainUI.frame:SetPoint(pos.point, UIParent, pos.relativePoint, pos.x, pos.y)
  end
end

-- Frame Strata

function Config.GetFrameStrata()
  local profileStore = MultiBot.Storage.GetProfile()
  local frameStrata = profileStore and profileStore.frameStrata

  if not VALID_FRAME_STRATA[frameStrata] then
    return DEFAULT_FRAME_STRATA
  end

  return frameStrata
end

function Config.SetFrameStrata(frameStrata)
  if not VALID_FRAME_STRATA[frameStrata] then
    return nil
  end

  local profileStore = MultiBot.Storage.GetProfile()
  if profileStore then
    profileStore.frameStrata = frameStrata
    return frameStrata
  end
end

function Config.ApplyFrameStrata()
  local frameStrata = Config.GetFrameStrata()
  MultiBot:SetFrameStrata(frameStrata)
  MultiBot.MainUI.ApplyFrameStrata(frameStrata)
  return frameStrata
end
