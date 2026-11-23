local MultiBot = _G.MultiBot

local ClassUI = {
  instances = {},
}
MultiBot.ClassUI = ClassUI

-- Survives button recreation from paging and filtering.
local hiddenByBot = {}

local function isActive(state, definition)
  local stateKey = definition.prefix == "nc" and "nonCombat" or "combat"
  for _, strategy in ipairs(state[stateKey] or {}) do
    if strategy == definition.name or strategy == definition.alias then
      return true
    end
  end

  return false
end

local function getActiveDefinition(state, group)
  if group.definition.mode ~= "exclusive" then
    return nil
  end

  for _, definition in ipairs(group.definition.entries) do
    if isActive(state, definition) then
      return definition
    end
  end

  return nil
end

local function sendStrategyCommand(instance, definition, enabled)
  local command = definition.prefix .. (enabled and " +" or " -") .. definition.name
  if definition.prefix == "co" then
    MultiBot.Bridge.RunCombatCommand(instance.entry.name, command)
  else
    MultiBot.Bridge.RunNonCombatCommand(instance.entry.name, command)
  end

  -- Bots apply the command on their next tick, so let it land before reading state back.
  MultiBot.lifecycle:ScheduleTimer(function()
    MultiBot.Bridge.RequestBotStrategies(instance.entry.name)
  end, 0.5)
end

local function hideButtons(buttons)
  for _, button in ipairs(buttons) do
    button:Hide()
  end
end

function ClassUI.Create(button, entry, openOnClick)
  local instance = {
    button = button,
    entry = entry,
    groups = {},
  }

  local frame = CreateFrame("Frame", nil, button)
  frame:SetPoint("RIGHT", button, "LEFT")
  frame:SetSize(1, MultiBot.BUTTON_SIZE)
  frame:Hide()
  instance.frame = frame

  local definitions = {}
  for _, definition in ipairs(MultiBot.ClassStrategies.shared) do
    definitions[#definitions + 1] = definition
  end
  for _, definition in ipairs(MultiBot.ClassStrategies[entry.classId] or {}) do
    definitions[#definitions + 1] = definition
  end

  local previousGroupButton
  for _, definition in ipairs(definitions) do
    local group = {
      definition = definition,
      buttons = {},
    }
    local groupButton = MultiBot.CreateInsetIconButton(
      frame,
      nil,
      definition.masterIcon,
      function()
        if group.frame:IsShown() then
          group.frame:Hide()
        else
          group.frame:Show()
          instance:Refresh()
        end
      end,
      nil,
      definition.key
    )
    if previousGroupButton then
      groupButton:SetPoint("RIGHT", previousGroupButton, "LEFT")
    else
      groupButton:SetPoint("RIGHT", frame, "RIGHT")
    end

    local groupFrame = CreateFrame("Frame", nil, frame)
    groupFrame:SetPoint("BOTTOMRIGHT", groupButton, "TOPRIGHT", 2, 0)
    groupFrame:SetSize(MultiBot.BUTTON_SIZE, MultiBot.BUTTON_SIZE)
    groupFrame:Hide()
    group.button = groupButton
    group.frame = groupFrame
    instance.groups[#instance.groups + 1] = group
    previousGroupButton = groupButton
  end

  function instance:Refresh()
    local state = MultiBot.Strategies.GetForBot(self.entry.name) or {
      combat = {},
      nonCombat = {},
    }

    for _, group in ipairs(self.groups) do
      local activeDefinition = getActiveDefinition(state, group)
      group.button.icon:SetTexture(MultiBot.GetIcon(activeDefinition and activeDefinition.icon or group.definition.masterIcon))

      hideButtons(group.buttons)
      group.buttons = {}
      local previousButton
      for index, definition in ipairs(group.definition.entries) do
        local strategyButton
        strategyButton = MultiBot.CreateInsetIconButton(
          group.frame,
          nil,
          definition.icon,
          function()
            sendStrategyCommand(self, definition, not isActive(state, definition))
          end,
          nil,
          definition.name
        )
        if previousButton then
          strategyButton:SetPoint("BOTTOMRIGHT", previousButton, "TOPRIGHT")
        else
          strategyButton:SetPoint("BOTTOMRIGHT", group.frame, "BOTTOMRIGHT")
        end
        strategyButton:SetState(
          isActive(state, definition) and MultiBot.IconState.Active or MultiBot.IconState.Inactive
        )
        group.buttons[index] = strategyButton
        previousButton = strategyButton
      end
      group.frame:SetHeight(math.max(1, #group.definition.entries * MultiBot.BUTTON_SIZE))
    end
  end

  function instance:Show()
    hiddenByBot[self.entry.name] = nil
    self:Refresh()
    self.frame:Show()
  end

  function instance:Hide()
    hiddenByBot[self.entry.name] = true
    self.frame:Hide()
  end

  function instance:Toggle()
    if self.frame:IsShown() then
      self:Hide()
    else
      self:Show()
      MultiBot.Bridge.RequestActiveStrategies()
    end
  end

  ClassUI.instances[entry.name] = instance
  if openOnClick ~= false then
    button:SetScript("OnClick", function()
      instance:Toggle()
    end)
  end

  if not hiddenByBot[entry.name] then
    instance:Refresh()
    frame:Show()
  end

  return instance
end

function ClassUI.RefreshForBot(name)
  local instance = ClassUI.instances[name]
  if instance then
    instance:Refresh()
    if not hiddenByBot[name] then
      instance.frame:Show()
    end
  end
end

return ClassUI
