if not MultiBot then return end

local AceUI = MultiBot.AceUI or {}
MultiBot.AceUI = AceUI

local escapeFrameIndex = 0
local questTooltipName = "MB_LocalizeQuestTooltip"

local function ensureHiddenTooltip(name, parent)
    local tooltip = _G[name]
    if tooltip then
        return tooltip
    end

    tooltip = CreateFrame("GameTooltip", name, parent or UIParent, "GameTooltipTemplate")
    tooltip:SetOwner(parent or UIParent, "ANCHOR_NONE")
    return tooltip
end

function AceUI.EnsureHiddenTooltip(name, parent)
    return ensureHiddenTooltip(name, parent)
end

function AceUI.GetLocalizedQuestName(questID)
    local tooltip = ensureHiddenTooltip(questTooltipName, UIParent)
    tooltip:ClearLines()
    tooltip:SetHyperlink("quest:" .. questID)

    local textObject = _G[questTooltipName .. "TextLeft1"]
    return (textObject and textObject:GetText()) or tostring(questID)
end

function AceUI.GetAceGUI()
    if type(LibStub) ~= "table" then
        return nil
    end

    local ok, aceGUI = pcall(LibStub.GetLibrary, LibStub, "AceGUI-3.0", true)
    if ok and type(aceGUI) == "table" and type(aceGUI.Create) == "function" then
        return aceGUI
    end

    return nil
end

function AceUI.ResolveAceGUI(missingDepMessage)
    local aceGUI = AceUI.GetAceGUI()
    if not aceGUI and missingDepMessage then
        UIErrorsFrame:AddMessage(missingDepMessage, 1, 0.2, 0.2, 1)
    end

    return aceGUI
end

function AceUI.SetWindowCloseToHide(window)
    if window and window.SetCallback then
        window:SetCallback("OnClose", function(widget)
            widget:Hide()
        end)
    end
end

function AceUI.RegisterWindowEscapeClose(window, namePrefix)
    if not window or not window.frame or type(UISpecialFrames) ~= "table" then
        return
    end

    if window.__mbEscapeName then
        return
    end

    escapeFrameIndex = escapeFrameIndex + 1
    local safePrefix = tostring(namePrefix or "Popup"):gsub("[^%w_]", "")
    local frameName = string.format("MultiBotAce%s_%d", safePrefix, escapeFrameIndex)

    window.__mbEscapeName = frameName
    _G[frameName] = window.frame

    for _, existing in ipairs(UISpecialFrames) do
        if existing == frameName then
            return
        end
    end

    table.insert(UISpecialFrames, frameName)
end

local function getUiProfileStore(createIfMissing)
    if MultiBot.Store then
        if createIfMissing and type(MultiBot.Store.EnsureUIStore) == "function" then
            return MultiBot.Store.EnsureUIStore()
        end
        if not createIfMissing and type(MultiBot.Store.GetUIStore) == "function" then
            return MultiBot.Store.GetUIStore()
        end
    end

    local profile = MultiBot.db and MultiBot.db.profile
    if not profile then
        return nil
    end
    if not createIfMissing then
        return type(profile.ui) == "table" and profile.ui or nil
    end
    profile.ui = profile.ui or {}
    return profile.ui
end

function AceUI.BindWindowPosition(window, persistenceKey)
    if not window or not window.frame or not persistenceKey then
        return
    end

    local uiStore = getUiProfileStore(false)
    local positions = (uiStore and type(uiStore.popupPositions) == "table") and uiStore.popupPositions or nil
    local saved = positions and positions[persistenceKey]
    if saved and saved.point then
        window.frame:ClearAllPoints()
        window.frame:SetPoint(saved.point, UIParent, saved.point, saved.x or 0, saved.y or 0)
    end

    if window.__mbPositionHooked then
        return
    end

    window.__mbPositionHooked = true
    window.frame:HookScript("OnDragStop", function(frame)
        local point, _, _, x, y = frame:GetPoint(1)
        if point then
            local writableUiStore = getUiProfileStore(true)
            if not writableUiStore then
                return
            end
            writableUiStore.popupPositions = writableUiStore.popupPositions or {}
            writableUiStore.popupPositions[persistenceKey] = { point = point, x = x or 0, y = y or 0 }
        end
    end)
end

-- Creates a standard MultiBot AceGUI Window with strata, escape-close, position binding,
-- and close-to-hide already wired up. Layout is NOT set — the caller sets it.
-- Returns the AceGUI window widget, or nil if AceGUI is unavailable.
function AceUI.CreateWindow(title, width, height, persistenceKey, escapePrefix)
    local aceGUI = AceUI.GetAceGUI()
    if not aceGUI then return nil end

    local window = aceGUI:Create("Window")
    if not window then return nil end

    window:SetTitle(title or "")
    window:SetWidth(width)
    window:SetHeight(height)
    window:EnableResize(false)

    local strataLevel = MultiBot.GetGlobalStrataLevel and MultiBot.GetGlobalStrataLevel()
    window.frame:SetFrameStrata(strataLevel or "DIALOG")

    AceUI.SetWindowCloseToHide(window)
    AceUI.RegisterWindowEscapeClose(window, escapePrefix or "Popup")
    AceUI.BindWindowPosition(window, persistenceKey)
    window:Hide()

    return window
end

function AceUI.CreatePopupHost(title, width, height, persistenceKey, escapePrefix)
    local window = AceUI.CreateWindow(title, width, height, persistenceKey, escapePrefix or "PopupHost")
    if not window then return nil end

    window:SetLayout("Fill")

    local host = CreateFrame("Frame", nil, window.content)
    host:SetAllPoints(window.content)
    host.window = window

    function host:Show()
        self.window:Show()
    end

    function host:Hide()
        self.window:Hide()
    end

    function host:IsShown()
        return self.window and self.window.frame and self.window.frame:IsShown()
    end

    return host
end

-- Creates any AceGUI widget as a manually-anchored child of parentWidget.
-- Layout automation is suppressed (noAutoHeight + LayoutFinished no-op) so the
-- parent's DoLayout never overwrites the manual SetPoint.
-- The parent's layout is forced to "None" automatically.
-- The anchor frame is parentWidget.content if it exists, otherwise parentWidget.frame.
--   anchor           : point string used on both sides of SetPoint; defaults to "TOPLEFT".
--   frameLevelOffset : added to anchorFrame:GetFrameLevel(); defaults to 1.
-- Widgets: Button, Label, CheckBox, Dropdown, EditBox, Slider, Icon, Heading,
--   InteractiveLabel, MultiLineEditBox, ColorPicker, Keybinding,
--   InlineGroup, SimpleGroup, DropdownGroup, TabGroup, TreeGroup, ScrollFrame.
function AceUI.AddFixedChild(parentWidget, widgetType, x, y, width, height, anchor, frameLevelOffset)
    local aceGUI = AceUI.GetAceGUI()
    if not aceGUI or not parentWidget then return nil end
    if not AceUI._noneLayoutRegistered then
        aceGUI:RegisterLayout("None", function() end)
        AceUI._noneLayoutRegistered = true
    end
    parentWidget:SetLayout("None")
    local widget = aceGUI:Create(widgetType)
    if not widget then return nil end
    widget.noAutoHeight = true
    widget.LayoutFinished = function() end
    widget:SetWidth(width)
    widget:SetHeight(height)
    parentWidget:AddChild(widget)
    local af = parentWidget.content or parentWidget.frame
    local pt = anchor or "TOPLEFT"
    widget.frame:ClearAllPoints()
    widget.frame:SetPoint(pt, af, pt, x, y)
    widget.frame:SetFrameLevel(af:GetFrameLevel() + (frameLevelOffset or 1))
    return widget
end

-- Creates a fixed-size AceGUI widget (InlineGroup, DropdownGroup, SimpleGroup, …)
-- as a manually-anchored child of any AceGUI container (Window, InlineGroup, SimpleGroup, …).
-- The widget is pinned to the parent's content frame BOTTOMRIGHT at the given offset.
-- title is optional; meaningful only for InlineGroup / DropdownGroup.
function AceUI.CreateFixedWidget(container, widgetType, x, y, width, height, title, frameLevelOffset)
    if not container or not container.content then return nil end
    local widget = AceUI.AddFixedChild(container, widgetType or "InlineGroup", x, y, width, height, "BOTTOMRIGHT", frameLevelOffset or 1)
    if widget and title and title ~= "" then widget:SetTitle(title) end
    return widget
end

-- Creates a fixed AceGUI Button as a child of containerWidget, anchored BOTTOMRIGHT.
-- height defaults to 20.
-- Callbacks: OnClick(widget, button)  OnEnter(widget)  OnLeave(widget)
function AceUI.CreateFixedButton(containerWidget, label, x, y, width, height, frameLevelOffset)
    if not containerWidget then return nil end
    local btn = AceUI.AddFixedChild(containerWidget, "Button", x, y, width or 80, height or 20, "BOTTOMRIGHT", frameLevelOffset)
    if btn and label then btn:SetText(label) end
    return btn
end

-- Creates a fixed AceGUI Icon (clickable image widget) as a child of containerWidget,
-- anchored BOTTOMRIGHT. width/height default to 36.
-- image       : texture path passed to widget:SetImage(image).
-- imageWidth/imageHeight : passed to widget:SetImageSize(); default to widget size.
-- label       : optional text shown below the icon via widget:SetLabel(label).
-- Callbacks: OnClick(widget, button)  OnEnter(widget)  OnLeave(widget)
function AceUI.CreateFixedIcon(containerWidget, image, x, y, width, height, imageWidth, imageHeight, label, frameLevelOffset)
    if not containerWidget then return nil end
    local w = width or 36
    local h = height or 36
    local icon = AceUI.AddFixedChild(containerWidget, "Icon", x, y, w, h, "BOTTOMRIGHT", frameLevelOffset)
    if icon then
        if image then icon:SetImage(image) end
        icon:SetImageSize(imageWidth or w, imageHeight or h)
        if label then icon:SetLabel(label) end
    end
    return icon
end

MultiBot.GetLocalizedQuestName = MultiBot.GetLocalizedQuestName or AceUI.GetLocalizedQuestName
MultiBot.GetAceGUI = MultiBot.GetAceGUI or AceUI.GetAceGUI
MultiBot.ResolveAceGUI = MultiBot.ResolveAceGUI or AceUI.ResolveAceGUI
MultiBot.SetAceWindowCloseToHide = MultiBot.SetAceWindowCloseToHide or AceUI.SetWindowCloseToHide
MultiBot.RegisterAceWindowEscapeClose = MultiBot.RegisterAceWindowEscapeClose or AceUI.RegisterWindowEscapeClose
MultiBot.BindAceWindowPosition = MultiBot.BindAceWindowPosition or AceUI.BindWindowPosition
MultiBot.CreateAceQuestPopupHost = MultiBot.CreateAceQuestPopupHost or function(title, width, height, persistenceKey)
    return AceUI.CreatePopupHost(title, width, height, persistenceKey, "QuestHost")
end