local MultiBot = _G.MultiBot

local ActiveRosterUI = {}
MultiBot.ActiveRosterUI = ActiveRosterUI

local ALLIANCE_BANNER_ICON = "inv_misc_tournaments_banner_human"
local SELFBOT_BUTTON_ICON = "inv_misc_head_clockworkgnome_01"
local FILTER_ROOT_ICON = "inv_helmet_44"
local ROSTER_PAGE_SIZE = 8

local FILTERS = {
  { classId = 6 },
  { classId = 11 },
  { classId = 3 },
  { classId = 8 },
  { classId = 2 },
  { classId = 5 },
  { classId = 4 },
  { classId = 7 },
  { classId = 9 },
  { classId = 1 },
}

local function getFilterIcon(filter)
  if filter.classId then
    return MultiBot.GetClassIcon(filter.classId)
  end

  return FILTER_ROOT_ICON
end

local function getBotEntries()
  local entries = {}
  local playerName = UnitName("player")

  for _, entry in ipairs(MultiBot.Roster.GetActive()) do
    if entry.name ~= playerName and (not ActiveRosterUI.classFilter or entry.classId == ActiveRosterUI.classFilter) then
      entries[#entries + 1] = entry
    end
  end

  return entries
end

local function getSelfbotEntry()
  local playerName = UnitName("player")

  for _, entry in ipairs(MultiBot.Roster.GetActive()) do
    if entry.name == playerName then
      return entry
    end
  end
end

function ActiveRosterUI.Initialize(parent)
  if ActiveRosterUI.frame then
    return ActiveRosterUI.frame
  end

  local frame = CreateFrame("Frame", "MultiBotActiveRosterUI", parent)
  frame:SetSize(MultiBot.INSET_BUTTON_SIZE, MultiBot.INSET_BUTTON_SIZE)
  frame:SetPoint("BOTTOM", MultiBot.MainUI.activeRosterButton, "TOP", 0, 0)
  frame:EnableMouse(false)
  frame:Hide()

  local allianceButton = MultiBot.CreateInsetIconButton(
    frame,
    "MultiBotActiveRosterControlButton",
    ALLIANCE_BANNER_ICON,
    function()
      SendChatMessage(".playerbots bot add *", "SAY")
    end,
    function()
      SendChatMessage(".playerbots bot remove *", "SAY")
    end,
    MultiBot.Locale.GetString("active_roster.control.tip")
  )
  allianceButton:SetPoint("TOPLEFT", frame, "TOPLEFT")

  local selfbotButton = MultiBot.CreateInsetIconButton(
    frame,
    "MultiBotSelfBotButton",
    SELFBOT_BUTTON_ICON,
    function(button)
      SendChatMessage(".playerbots bot self", "SAY")
      button:SetBorderShown(not button.border:IsShown())
      MultiBot.Roster.RequestRefresh()
    end,
    nil,
    MultiBot.Locale.GetString("active_roster.selfbot.tip")
  )
  selfbotButton:SetPoint("BOTTOMLEFT", allianceButton, "TOPLEFT")

  local nextButton = MultiBot.CreateInsetIconButton(
    frame,
    "MultiBotActiveRosterNextButton",
    "achievement_pvp_a_01",
    function()
      local maxPage = math.max(1, math.ceil(#getBotEntries() / ROSTER_PAGE_SIZE))
      if maxPage == 1 then
        return
      end

      ActiveRosterUI.page = ActiveRosterUI.page % maxPage + 1
      ActiveRosterUI.RefreshRoster()
    end
  )
  nextButton.icon:SetTexCoord(1, 1, 1, 0, 0, 1, 0, 0)
  nextButton:SetPoint("BOTTOMLEFT", selfbotButton, "TOPLEFT")

  local filterFrame = CreateFrame("Frame", nil, frame)
  filterFrame:SetSize(MultiBot.INSET_BUTTON_SIZE, MultiBot.INSET_BUTTON_SIZE)
  filterFrame:Hide()

  local filterButton
  filterButton = MultiBot.CreateInsetIconButton(
    frame,
    "MultiBotActiveRosterFilterButton",
    FILTER_ROOT_ICON,
    function()
      if filterFrame:IsShown() then
        filterFrame:Hide()
      else
        filterFrame:Show()
      end
    end,
    function()
      ActiveRosterUI.classFilter = nil
      filterButton.icon:SetTexture(MultiBot.GetIcon(FILTER_ROOT_ICON))
      for _, sibling in ipairs(filterFrame.buttons or {}) do
        sibling:SetBorderShown(false)
      end
      filterFrame:Hide()
      ActiveRosterUI.page = 1
      ActiveRosterUI.RefreshRoster()
    end,
    MultiBot.Locale.GetString("active_roster.filter.tip")
  )
  filterButton:SetPoint("BOTTOMLEFT", nextButton, "TOPLEFT")
  filterFrame:ClearAllPoints()
  filterFrame:SetPoint("BOTTOMRIGHT", filterButton, "BOTTOMLEFT")

  for index, filter in ipairs(FILTERS) do
    local filterOption
    filterOption = MultiBot.CreateInsetIconButton(
      filterFrame,
      nil,
      getFilterIcon(filter),
      function()
        ActiveRosterUI.classFilter = filter.classId
        filterButton.icon:SetTexture(getFilterIcon(filter))
        for _, sibling in ipairs(filterFrame.buttons or {}) do
          sibling:SetBorderShown(false)
        end
        filterOption:SetBorderShown(true)
        filterFrame:Hide()
        ActiveRosterUI.page = 1
        ActiveRosterUI.RefreshRoster()
      end,
      nil,
      MultiBot.GetClassName(filter.classId)
    )
    filterFrame.buttons = filterFrame.buttons or {}
    filterFrame.buttons[#filterFrame.buttons + 1] = filterOption
    filterOption:SetPoint("RIGHT", filterFrame, "RIGHT", -(index - 1) * MultiBot.INSET_BUTTON_SIZE, 0)
  end

  ActiveRosterUI.frame = frame
  ActiveRosterUI.botButtons = {}
  ActiveRosterUI.selfbotButton = selfbotButton
  ActiveRosterUI.selfbotClassUI = nil
  ActiveRosterUI.nextButton = nextButton
  ActiveRosterUI.filterButton = filterButton
  ActiveRosterUI.filterFrame = filterFrame
  ActiveRosterUI.page = 1
  return frame
end

function ActiveRosterUI.RefreshRoster()
  local entries = getBotEntries()
  local maxPage = math.max(1, math.ceil(#entries / ROSTER_PAGE_SIZE))
  ActiveRosterUI.page = math.min(ActiveRosterUI.page, maxPage)

  for _, button in ipairs(ActiveRosterUI.botButtons) do
    button:Hide()
  end

  ActiveRosterUI.botButtons = {}
  local selfbotEntry = getSelfbotEntry()
  if selfbotEntry and not ActiveRosterUI.selfbotClassUI then
    ActiveRosterUI.selfbotClassUI = MultiBot.ClassUI.Create(ActiveRosterUI.selfbotButton, selfbotEntry, false)
  end

  local firstIndex = (ActiveRosterUI.page - 1) * ROSTER_PAGE_SIZE + 1
  local lastIndex = math.min(#entries, firstIndex + ROSTER_PAGE_SIZE - 1)
  local previousButton = ActiveRosterUI.selfbotButton

  for index = firstIndex, lastIndex do
    local entry = entries[index]
    local button = MultiBot.CreateInsetIconButton(
      ActiveRosterUI.frame,
      nil,
      MultiBot.GetClassIcon(entry.classId),
      nil,
      nil,
      entry.name
    )
    button.classUI = MultiBot.ClassUI.Create(button, entry)
    button:SetPoint("BOTTOMLEFT", previousButton, "TOPLEFT")
    ActiveRosterUI.botButtons[#ActiveRosterUI.botButtons + 1] = button
    previousButton = button
  end

  ActiveRosterUI.nextButton:ClearAllPoints()
  ActiveRosterUI.nextButton:SetPoint("BOTTOMLEFT", previousButton, "TOPLEFT")

  ActiveRosterUI.filterButton:ClearAllPoints()
  ActiveRosterUI.filterButton:SetPoint("BOTTOMLEFT", ActiveRosterUI.nextButton, "TOPLEFT")

  ActiveRosterUI.nextButton:Show()
end

function ActiveRosterUI.RefreshSelfbot()
  local selfbotEntry = getSelfbotEntry()
  if selfbotEntry and not ActiveRosterUI.selfbotClassUI then
    ActiveRosterUI.selfbotClassUI = MultiBot.ClassUI.Create(ActiveRosterUI.selfbotButton, selfbotEntry, false)
  elseif not selfbotEntry and ActiveRosterUI.selfbotClassUI then
    ActiveRosterUI.selfbotClassUI:Hide()
    ActiveRosterUI.selfbotClassUI = nil
  end
end

function ActiveRosterUI.Show()
  ActiveRosterUI.frame:Show()
end

function ActiveRosterUI.Hide()
  ActiveRosterUI.frame:Hide()
end

function ActiveRosterUI.Toggle()
  if ActiveRosterUI.frame:IsShown() then
    ActiveRosterUI.Hide()
  else
    ActiveRosterUI.Show()
  end
end
