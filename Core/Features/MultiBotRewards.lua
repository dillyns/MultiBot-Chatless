local MultiBot = _G.MultiBot
if not MultiBot then
  return
end

local Rewards = {}
MultiBot.Rewards = Rewards

local AceGUI = LibStub("AceGUI-3.0")
local L = MultiBot.Locale.GetString

function Rewards.InitializeWindow()
  if Rewards.window then
    return Rewards.window
  end

  local window = AceGUI:Create("Frame")
  window:SetTitle(L("rewards.title"))
  window:SetLayout("Fill")
  window:SetWidth(600)
  window:SetHeight(400)
  window:SetCallback("OnClose", function()
    Rewards.window = nil
  end)

  -- Placeholder container for future content
  local container = AceGUI:Create("SimpleGroup")
  container:SetLayout("Fill")
  container:SetFullWidth(true)
  container:SetFullHeight(true)
  
  local scrollContainer = AceGUI:Create("ScrollFrame")
  scrollContainer:SetLayout("List")
  scrollContainer:SetFullWidth(true)
  scrollContainer:SetFullHeight(true)
  
  local placeholder = AceGUI:Create("Label")
  placeholder:SetText("Rewards feature coming soon...")
  placeholder:SetFullWidth(true)
  
  scrollContainer:AddChild(placeholder)
  container:AddChild(scrollContainer)
  window:AddChild(container)

  Rewards.window = window
  return window
end

function Rewards.Toggle()
  if Rewards.window then
    Rewards.window:Release()
    Rewards.window = nil
  else
    Rewards.InitializeWindow()
  end
end

function Rewards.Show()
  if not Rewards.window then
    Rewards.InitializeWindow()
  end
end

function Rewards.Hide()
  if Rewards.window then
    Rewards.window:Release()
    Rewards.window = nil
  end
end
