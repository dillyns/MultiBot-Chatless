local MultiBot = _G.MultiBot
if not MultiBot then return end

-- Minimap config is resolved through MultiBot.GetMinimapConfig().

local LDB_NAME = "MultiBot"
local ICON_PATH = "Interface\\Icons\\Achievement_PVP_A_15"

local ldb = LibStub and LibStub("LibDataBroker-1.1", true)
local dbIcon = LibStub and LibStub("LibDBIcon-1.0", true)
local launcher = nil

local function handleClick(_, mouseButton)
    if mouseButton == "RightButton" then
        MultiBot.ToggleOptionsPanel()
        return
    end

    MultiBot.ToggleMainUIVisibility()
end

local function handleTooltip(tooltip)
    tooltip:ClearLines()
    tooltip:AddLine(MultiBot.L("info.butttitle"), 1, 1, 1)
    tooltip:AddLine(MultiBot.L("info.buttontoggle"), 0.9, 0.9, 0.9)
    tooltip:AddLine(MultiBot.L("info.buttonoptions"), 0.9, 0.9, 0.9)
end

local function ensureRegistered(minimapConfig)
    if not ldb or not dbIcon then
        return false
    end

    if not launcher then
        launcher = ldb:NewDataObject(LDB_NAME, {
            type = "launcher",
            icon = ICON_PATH,
            OnClick = handleClick,
            OnTooltipShow = handleTooltip,
        })
    end

    if not dbIcon:IsRegistered(LDB_NAME) then
        dbIcon:Register(LDB_NAME, launcher, minimapConfig)
    end

    return dbIcon:IsRegistered(LDB_NAME)
end

function MultiBot.RefreshMinimap()
    local minimapConfig = MultiBot.GetMinimapConfig()
    if not ensureRegistered(minimapConfig) then
        return
    end

    dbIcon:Refresh(LDB_NAME, minimapConfig)

    if minimapConfig.hide then
        dbIcon:Hide(LDB_NAME)
    else
        dbIcon:Show(LDB_NAME)
    end
end
