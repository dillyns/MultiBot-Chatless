local MultiBot = _G.MultiBot
if not MultiBot then
  return
end

local MainUI = {}
MultiBot.MainUI = MainUI

local MAIN_BUTTON_ICON = "inv_gizmo_02"
local SECONDARY_BUTTON_ICON = "inv_scroll_04"
local ATTACK_BUTTON_ICON = "Interface\\AddOns\\MultiBot\\Icons\\attack.blp"
local FOLLOW_BUTTON_ICON = "Interface\\AddOns\\MultiBot\\Icons\\command_follow.blp"
local STAY_BUTTON_ICON = "Interface\\AddOns\\MultiBot\\Icons\\command_stay.blp"
local FLEE_BUTTON_ICON = "Interface\\AddOns\\MultiBot\\Icons\\flee.blp"
local SUMMON_BUTTON_ICON = "ability_hunter_beastcall"

local function runGroupCommand(command)
  MultiBot.Bridge.RunGroupCommand(command)
end

local function getFrameStrata()
  return MultiBot.Config.GetFrameStrata()
end

function MainUI.ApplyFrameStrata(frameStrata)
  frameStrata = frameStrata or getFrameStrata()
  if MainUI.frame then
    MainUI.frame:SetFrameStrata(frameStrata)
  end
end

function MainUI.Initialize()
  if MainUI.frame then
    return MainUI.frame
  end

  local frame = CreateFrame("Frame", "MultiBotMainUI", UIParent)
  local position = MultiBot.Config.GetMainUIPosition()
  frame:SetSize(MultiBot.BUTTON_SIZE, MultiBot.BUTTON_SIZE)
  frame:SetPoint(position.point, UIParent, position.relativePoint, position.x, position.y)
  frame:SetFrameStrata(getFrameStrata())
  frame:EnableMouse(false)
  frame:SetMovable(true)
  frame:SetClampedToScreen(true)
  frame:Hide()

  local optionsButton = MultiBot.CreateIconButton(
    frame,
    "MultiBotOptionsButton",
    MAIN_BUTTON_ICON,
    nil,
    nil,
    MultiBot.Locale.GetString("main.options.tip")
  )
  optionsButton:SetPoint("TOPLEFT", frame, "TOPLEFT")
  optionsButton:RegisterForDrag("RightButton")
  optionsButton:SetScript("OnDragStart", function()
    MainUI.frame:StartMoving()
  end)
  optionsButton:SetScript("OnDragStop", function()
    MainUI.frame:StopMovingOrSizing()
    local point, _, relativePoint, x, y = MainUI.frame:GetPoint()
    MultiBot.Config.SetMainUIPosition(point, relativePoint, x, y)
  end)

  local activeRosterButton = MultiBot.CreateIconButton(
    frame,
    "MultiBotActiveRosterButton",
    SECONDARY_BUTTON_ICON,
    function()
      MultiBot.ActiveRosterUI.Toggle()
    end,
    nil,
    MultiBot.Locale.GetString("main.active.tip")
  )
  activeRosterButton:SetPoint("RIGHT", optionsButton, "LEFT")

  local attackButton = MultiBot.CreateIconButton(
    frame,
    "MultiBotAttackButton",
    ATTACK_BUTTON_ICON,
    function()
      runGroupCommand("do attack my target")
    end,
    nil,
    MultiBot.Locale.GetString("main.attack.tip")
  )

  local followButton = MultiBot.CreateIconButton(
    frame,
    "MultiBotFollowButton",
    FOLLOW_BUTTON_ICON,
    function()
      runGroupCommand("follow")
    end,
    nil,
    MultiBot.Locale.GetString("main.follow.tip")
  )

  local stayButton = MultiBot.CreateIconButton(
    frame,
    "MultiBotStayButton",
    STAY_BUTTON_ICON,
    function()
      runGroupCommand("stay")
    end,
    nil,
    MultiBot.Locale.GetString("main.stay.tip")
  )

  local fleeButton = MultiBot.CreateIconButton(
    frame,
    "MultiBotFleeButton",
    FLEE_BUTTON_ICON,
    function()
      runGroupCommand("flee")
    end,
    nil,
    MultiBot.Locale.GetString("main.flee.tip")
  )

  local summonButton = MultiBot.CreateIconButton(
    frame,
    "MultiBotSummonButton",
    SUMMON_BUTTON_ICON,
    function()
      runGroupCommand("summon")
    end,
    nil,
    MultiBot.Locale.GetString("main.summon.tip")
  )

  fleeButton:SetPoint("RIGHT", activeRosterButton, "LEFT")
  stayButton:SetPoint("RIGHT", fleeButton, "LEFT")
  followButton:SetPoint("RIGHT", stayButton, "LEFT")
  attackButton:SetPoint("RIGHT", followButton, "LEFT")
  summonButton:SetPoint("RIGHT", attackButton, "LEFT")

  MainUI.frame = frame
  MainUI.activeRosterButton = activeRosterButton

  MultiBot.ActiveRosterUI.Initialize(frame)

  MainUI.ApplyFrameStrata()

  return frame
end

function MainUI.Show()
  local frame = MainUI.Initialize()
  frame:Show()
end

function MainUI.Hide()
  if MainUI.frame then
    MainUI.frame:Hide()
  end
end
