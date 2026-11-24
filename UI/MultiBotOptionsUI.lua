local MultiBot = _G.MultiBot
if not MultiBot then
  return
end

local OptionsUI = {}
MultiBot.OptionsUI = OptionsUI

function OptionsUI.Initialize(parentFrame)
  if OptionsUI.frame then
    return OptionsUI.frame
  end

  local frame = CreateFrame("Frame", "MultiBotOptionsUIPanel", parentFrame)
  frame:SetSize(MultiBot.BUTTON_SIZE, MultiBot.INSET_BUTTON_SIZE)
  frame:SetPoint("BOTTOM", parentFrame, "TOP", 0, 0)
  frame:EnableMouse(false)
  frame:Hide()

  local rewardsButton = MultiBot.CreateInsetIconButton(
    frame,
    "MultiBotOptionsRewardsButton",
    "achievement_quests_completed_07",
    function()
      MultiBot.Rewards.Toggle()
    end,
    nil,
    MultiBot.Locale.GetString("main.rewards.tip")
  )
  rewardsButton:SetPoint("BOTTOM", frame, "BOTTOM", 0, 0)

  OptionsUI.frame = frame
  OptionsUI.rewardsButton = rewardsButton

  return frame
end

function OptionsUI.Toggle()
  if not OptionsUI.frame then
    return
  end

  if OptionsUI.frame:IsShown() then
    OptionsUI.Hide()
  else
    OptionsUI.Show()
  end
end

function OptionsUI.Show()
  if not OptionsUI.frame then
    return
  end

  OptionsUI.frame:Show()
end

function OptionsUI.Hide()
  if OptionsUI.frame then
    OptionsUI.frame:Hide()
  end
end
