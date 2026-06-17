-- weight: sort order. roles: talent-tree dominant role (tab 1/2/3, language-independent).
local MultiBotRaidusClassData = {
    DeathKnight = { weight = 1,  roles = { "Tank", "Tank", "DPS"  } }, -- Sang, Givre, Impie
    Druid       = { weight = 2,  roles = { "DPS",  "Tank", "Heal" } }, -- Equilibre, Farouche, Restauration
    Hunter      = { weight = 3,  roles = { "DPS",  "DPS",  "DPS"  } }, -- Maitrise des betes, Precision, Survie
    Mage        = { weight = 4,  roles = { "DPS",  "DPS",  "DPS"  } }, -- Arcanes, Feu, Givre
    Paladin     = { weight = 5,  roles = { "Heal", "Tank", "DPS"  } }, -- Sacre, Protection, Vindicte
    Priest      = { weight = 6,  roles = { "Heal", "Heal", "DPS"  } }, -- Discipline, Sacre, Ombre
    Rogue       = { weight = 7,  roles = { "DPS",  "DPS",  "DPS"  } }, -- Assassinat, Combat, Finesse
    Shaman      = { weight = 8,  roles = { "DPS",  "DPS",  "Heal" } }, -- Elementaire, Amelio, Restauration
    Warlock     = { weight = 9,  roles = { "DPS",  "DPS",  "DPS"  } }, -- Affliction, Demonologie, Destruction
    Warrior     = { weight = 10, roles = { "DPS",  "DPS",  "Tank" } }, -- Armes, Fureur, Protection
}

-- Détection de rôle indépendante de la langue :
--  On lit la répartition de talents "x/y/z"
--  On prend l'arbre dominant (1,2,3)
--  On mappe (classe, arbre) -> rôle TANK/HEAL/DPS
--  Retourne nil si le rôle ne peut pas être déterminé
local function MultiBotRaidusDetectRole(bot)
    if not bot or not bot.talents then
        return nil
    end

    -- Classe normalisée (MultiBot.toClass sait déjà gérer les noms de classes localisés)
    local class = MultiBot.toClass(bot.class)

    local parts = MultiBot.doSplit(bot.talents, "/")
    local t1, t2, t3 = tonumber(parts[1]), tonumber(parts[2]), tonumber(parts[3])

    if t1 and t2 and t3 and (t1 + t2 + t3) > 0 then
        local maxIndex = (t2 > t1 and t2 >= t3) and 2 or (t3 > t1 and t3 > t2) and 3 or 1
        local classData = MultiBotRaidusClassData[class]
        if classData and classData.roles and classData.roles[maxIndex] then
            return classData.roles[maxIndex]
        end
    end

    return nil
end

-- Retourne true si le bot (par son nom) est dans ton groupe ou raid
local function MultiBotRaidusIsBotGrouped(name)
    if not name or name == "" then
        return false
    end

    local numRaid = GetNumRaidMembers()
    if numRaid and numRaid > 0 then
        for i = 1, numRaid do
            local raidName, _, _, _, _, _, _, online = GetRaidRosterInfo(i)
            if raidName == name and online then
                return true
            end
        end
        return false
    end

    local numParty = GetNumPartyMembers()
    if numParty and numParty > 0 then
        for i = 1, numParty do
            local unit = "party" .. i
            local partyName = UnitName(unit)
            if partyName == name and UnitIsConnected(unit) then
                return true
            end
        end
    end

    return false
end

MultiBot.raidus = MultiBot.raidus or {}

local function requestMissingRaidusRosters()
    local bridge = MultiBot.bridge
    local comm = MultiBot.Comm
    if not comm or not bridge or not (bridge.connected or bridge.bootstrapPending) then
        return
    end

    local function hasEntries(list)
        return type(list) == "table" and #list > 0
    end

    local hasAccount = hasEntries(bridge.accountRoster)
    local hasGuild = hasEntries(bridge.guildRoster)
    local hasFriend = hasEntries(bridge.friendRoster)

    if not hasAccount and comm.RequestAccountRoster then
        comm.RequestAccountRoster()
    end
    if not hasGuild and comm.RequestGuildRoster then
        comm.RequestGuildRoster()
    end
    if not hasFriend and comm.RequestFriendRoster then
        comm.RequestFriendRoster()
    end
end


local function initRaidusWindow()
    local window = MultiBot.AceUI.CreateWindow("MultiBot - Raidus", 940, 610, "raidus_popup", "Raidus")
    if not window or not window.content then return end

    -- Action bar: AceGUI SimpleGroup spanning the bottom strip of the window.
    -- Layout and suppression flags are applied automatically by AddFixedChild when buttons are added.
    local aceGUI = MultiBot.ResolveAceGUI()
    if not aceGUI then return end
    local actionBar = aceGUI:Create("SimpleGroup")
    window:AddChild(actionBar)
    actionBar.frame:ClearAllPoints()
    actionBar.frame:SetPoint("BOTTOMLEFT", window.content, "BOTTOMLEFT", 0, 0)
    actionBar.frame:SetPoint("BOTTOMRIGHT", window.content, "BOTTOMRIGHT", 0, 0)
    actionBar.frame:SetHeight(37)
    actionBar.frame:SetFrameLevel(window.content:GetFrameLevel() + 3)
    MultiBot.raidus.actionBar = actionBar

    MultiBot.raidus.window        = window
    MultiBot.raidus.groups = {}
    MultiBot.raidus.Show          = function()
        window:Show()
        requestMissingRaidusRosters()
    end
    MultiBot.raidus.Hide    = function() window:Hide() end
    MultiBot.raidus.IsShown = function() return window.frame and window.frame:IsShown() end
end

initRaidusWindow()

local raiduLoginFrame = CreateFrame("Frame")
raiduLoginFrame:RegisterEvent("PLAYER_LOGIN")
raiduLoginFrame:SetScript("OnEvent", function(_, event)
    if event == "PLAYER_LOGIN" then
        requestMissingRaidusRosters()
    end
end)

-- RAID SCORE --

local function formatRaidusScoreLabel(score)
    return "|cffd4af37[|r |cffffcc00RaidScore|r |cffb8b8b8" .. tostring(score or 0) .. "|r |cffd4af37]|r"
end

local function updateRaidusScore()
    local tScore = 0
    local tSize = 0

    for _, tGroup in pairs(MultiBot.raidus.groups) do
        if tGroup ~= nil and tGroup.score ~= nil and tGroup.score > 0 then
            tScore = tScore + tGroup.score
            tSize = tSize + 1
        end
    end

    tScore = MultiBot.IF(tSize > 0, math.floor(tScore / tSize), 0)
    local sectGroups = MultiBot.raidus.sectGroups
    if sectGroups then
        sectGroups:SetTitle("|cffffcc00" .. MultiBot.L("info.managegroups") .. "|r " .. formatRaidusScoreLabel(tScore))
    end
end

-- GROUP MANAGEMENT --

local RAIDUS_GROUP_COUNT = 8
local RAIDUS_GROUP_SLOT_COUNT = 5
local RAIDUS_GROUP_PANEL_WIDTH = 160 -- Single group frame width
local RAIDUS_SLOT_TEXTURE_INSET_X = 6 -- grey background widht, minus this value
local RAIDUS_SLOT_TEXTURE_INSET_Y = 4 -- grey background height, minus this value
local RAIDUS_SLOT_BORDER_INSET_X = 4 -- occuped frame widht, minus this value
local RAIDUS_SLOT_BORDER_INSET_Y = 0 -- occuped frame height, minus this value

MultiBot.raidus.sectGroups = MultiBot.AceUI.CreateFixedWidget(MultiBot.raidus.window, "InlineGroup", -200, 37, 716, 506, "|cffffcc00" .. MultiBot.L("info.managegroups") .. "|r")

local function formatGroupScoreBadge(text)
    return "|cffd4af37[|r " .. tostring(text or "") .. " |cffd4af37]|r"
end

local function doGroupScore(pGroup)
	local widget = pGroup and pGroup._widget
	if not widget then return end
	local tScore = 0
	local tSize = 0

	for _, tSlot in pairs(widget._slots) do
		if tSlot ~= nil and tSlot.bot ~= nil then
			tScore = tScore + (tSlot.bot.score or 0)
			tSize = tSize + 1
		end
	end

	local score = tSize > 0 and math.floor(tScore / tSize) or 0
	widget.score = score
	widget:SetTitle("|cffffcc00" .. widget.group .. "|r " .. formatGroupScoreBadge(score))
end

local function applyRaidusSlotTextureInset(slotFrame, insetX, insetY)
    if not slotFrame or not slotFrame.texture then
        return
    end

    local x = insetX or RAIDUS_SLOT_TEXTURE_INSET_X
    local y = insetY or RAIDUS_SLOT_TEXTURE_INSET_Y

    slotFrame.texture:ClearAllPoints()
    slotFrame.texture:SetPoint("TOPLEFT", slotFrame, "TOPLEFT", x, -y)
    slotFrame.texture:SetPoint("BOTTOMRIGHT", slotFrame, "BOTTOMRIGHT", -x, y)
end

-- Top row: groups 1-4
for i = 1, 4 do
    local gc = MultiBot.AceUI.AddFixedChild(MultiBot.raidus.sectGroups, "InlineGroup", (i - 1) * 176, 0, RAIDUS_GROUP_PANEL_WIDTH, 240)
    gc._slots = {}
    gc.group = "Group" .. i
    gc.score = 0
    gc.content._widget = gc
    gc:SetTitle("|cffffcc00Group" .. i .. "|r " .. formatGroupScoreBadge(0))
    MultiBot.raidus.groups[i] = gc
end

-- Bottom row: groups 5-8
for i = 5, 8 do
    local gc = MultiBot.AceUI.AddFixedChild(MultiBot.raidus.sectGroups, "InlineGroup", (i - 5) * 176, -244, RAIDUS_GROUP_PANEL_WIDTH, 240)
    gc._slots = {}
    gc.group = "Group" .. i
    gc.score = 0
    gc.content._widget = gc
    gc:SetTitle("|cffffcc00Group" .. i .. "|r " .. formatGroupScoreBadge(0))
    MultiBot.raidus.groups[i] = gc
end

-- Pre-create empty slot frames for each group
for i = 1, RAIDUS_GROUP_COUNT do
    local tGroup = MultiBot.raidus.groups[i]
    tGroup.dropSlots = {}
    for j = 1, RAIDUS_GROUP_SLOT_COUNT do
        local slotY = -(j - 1) * 40
        local tFrame = MultiBot.newFrame(tGroup.content, -10, slotY, 28, RAIDUS_GROUP_PANEL_WIDTH, 36, "TOPLEFT")
        tFrame.isDropSlot = true
        tFrame.addTexture("Interface\\AddOns\\MultiBot\\Textures\\grey.blp")
        applyRaidusSlotTextureInset(tFrame)
        tFrame.slot = "Slot" .. j
        tGroup.dropSlots["Slot" .. j] = tFrame
    end
    tGroup._slots = {}
    for k, v in pairs(tGroup.dropSlots) do tGroup._slots[k] = v end
end

-- ROSTER POOL --

local RAIDUS_POOL_PAGE_SIZE = 11
MultiBot.raidus.save = ""
MultiBot.raidus.from = 1
MultiBot.raidus.to = RAIDUS_POOL_PAGE_SIZE
MultiBot.raidus.sortMode = "Score" -- "Score" | "Level" | "Class"

-- Pool section uses DropdownGroup for source filters
-- (account / guild / friends pool selection). Add OnGroupSelected handler when filters are wired up.
local sectPool = MultiBot.AceUI.CreateFixedWidget(MultiBot.raidus.window, "DropdownGroup", -10, 37, 180, 506)
sectPool:SetDropdownWidth(160)
sectPool:SetGroupList({ account = "Account", guild = "Guild", friends = "Friends" })
sectPool:SetGroup("account")
MultiBot.raidus.sectPool = sectPool
MultiBot.raidus.poolCanvas = MultiBot.newFrame(MultiBot.raidus.sectPool.content, 0, 0, 28, 160, 480, "TOPLEFT")

-- Update pool visibility according to current Raidus page window.
local function refreshRaidusPoolPageVisibility()
	local poolFrame = MultiBot.raidus.poolCanvas
	local poolFrames = poolFrame.frames
	for slotIndex = 1, MultiBot.raidus.slots, 1 do
		local poolSlot = poolFrames["Slot" .. slotIndex]
		if poolSlot and poolSlot.parent == poolFrame then
			if(slotIndex >= MultiBot.raidus.from and slotIndex <= MultiBot.raidus.to) then poolSlot:Show() else poolSlot:Hide() end
		end
	end
end

-- ROSTER SLOTS --
local RAIDUS_CLASS_SLOT_ALPHA = 0.35
local RAIDUS_DROP_ANIM_DURATION = 0.12


local RAIDUS_CLASS_SLOT_COLORS = {
	DeathKnight = { 0.77, 0.12, 0.23, hex = "ffc41f3b" },
	Druid       = { 1.00, 0.49, 0.04, hex = "ffff7d0a" },
	Hunter      = { 0.67, 0.83, 0.45, hex = "ffabd473" },
	Mage        = { 0.41, 0.80, 0.94, hex = "ff69ccf0" },
	Paladin     = { 0.96, 0.55, 0.73, hex = "fff58cba" },
	Priest      = { 1.00, 1.00, 1.00, hex = "ffffffff" },
	Rogue       = { 1.00, 0.96, 0.41, hex = "fffff569" },
	Shaman      = { 0.00, 0.44, 0.87, hex = "ff0070de" },
	Warlock     = { 0.58, 0.51, 0.79, hex = "ff9482c9" },
	Warrior     = { 0.78, 0.61, 0.43, hex = "ffc79c6e" },
}

local RAIDUS_ROLE_COLORS = {
    Tank = { 0.33, 0.61, 0.96, 1.00 },
    Heal = { 0.32, 0.84, 0.46, 1.00 },
    DPS  = { 0.92, 0.33, 0.33, 1.00 },
}

local function getRaidusClassHexColor(className)
    local color = RAIDUS_CLASS_SLOT_COLORS[className]
    return color and color.hex or "ffffffff"
end

local function ensureRaidusRoleBorder(slotFrame)
    if not slotFrame or slotFrame.roleBorder then
        return
    end

    local border = CreateFrame("Frame", nil, slotFrame)
    border:SetAllPoints(slotFrame)
    border:EnableMouse(false)
    border:SetFrameLevel(slotFrame:GetFrameLevel() + 2)

    local function edge(anchor, point, x, y, width, height)
        local tex = border:CreateTexture(nil, "OVERLAY")
        tex:SetTexture(MultiBot.SafeTexturePath("Interface\\Buttons\\WHITE8X8"))
        tex:SetPoint(anchor, border, point, x, y)
        tex:SetSize(width, height)
        return tex
    end

    border.top = edge("TOPLEFT", "TOPLEFT", 0, 0, 1, 1)
    border.bottom = edge("BOTTOMLEFT", "BOTTOMLEFT", 0, 0, 1, 1)
    border.left = edge("TOPLEFT", "TOPLEFT", 0, 0, 1, 1)
    border.right = edge("TOPRIGHT", "TOPRIGHT", 0, 0, 1, 1)

    slotFrame.roleBorder = border
end

local function setRaidusSlotRoleBorder(slotFrame, role, alpha)
    if not slotFrame then
        return
    end

    ensureRaidusRoleBorder(slotFrame)
    if not slotFrame.roleBorder then
        return
    end

    local border = slotFrame.roleBorder
    local color = RAIDUS_ROLE_COLORS[role or ""]
    local r, g, b = 0.45, 0.45, 0.45
    if color then
        r, g, b = color[1], color[2], color[3]
    end

    local width = math.max((slotFrame.width or slotFrame:GetWidth() or 0) - (RAIDUS_SLOT_BORDER_INSET_X * 2), 1)
    local height = math.max((slotFrame.height or slotFrame:GetHeight() or 0) - (RAIDUS_SLOT_BORDER_INSET_Y * 2), 1)
    border.top:SetPoint("TOPLEFT", border, "TOPLEFT", RAIDUS_SLOT_BORDER_INSET_X, -RAIDUS_SLOT_BORDER_INSET_Y)
    border.top:SetSize(width, 1)
    border.bottom:SetPoint("BOTTOMLEFT", border, "BOTTOMLEFT", RAIDUS_SLOT_BORDER_INSET_X, RAIDUS_SLOT_BORDER_INSET_Y)
    border.bottom:SetSize(width, 1)
    border.left:SetPoint("TOPLEFT", border, "TOPLEFT", RAIDUS_SLOT_BORDER_INSET_X, -RAIDUS_SLOT_BORDER_INSET_Y)
    border.left:SetSize(1, height)
    border.right:SetPoint("TOPRIGHT", border, "TOPRIGHT", -RAIDUS_SLOT_BORDER_INSET_X, -RAIDUS_SLOT_BORDER_INSET_Y)
    border.right:SetSize(1, height)

    local a = alpha or 0.25
    border.top:SetVertexColor(r, g, b, a)
    border.bottom:SetVertexColor(r, g, b, a)
    border.left:SetVertexColor(r, g, b, a)
    border.right:SetVertexColor(r, g, b, a)
end

local function playRaidusDropPulse(slotFrame)
    if not slotFrame then
        return
    end

    local driver = slotFrame._dropPulseDriver
    if not driver then
        driver = CreateFrame("Frame", nil, slotFrame)
        driver:SetAllPoints(slotFrame)
        slotFrame._dropPulseDriver = driver
    end

    driver.elapsed = 0
    driver:Show()
    -- M11 ownership: keep this OnUpdate local.
    -- Reason: pulse scale animation is frame-driven and intentionally not timer-based.
    driver:SetScript("OnUpdate", function(self, elapsed)
        self.elapsed = self.elapsed + elapsed
        local progress = self.elapsed / RAIDUS_DROP_ANIM_DURATION

        if progress >= 1 then
            slotFrame:SetScale(1)
            self:SetScript("OnUpdate", nil)
            self:Hide()
            return
        end

        local pulse = (progress < 0.5) and (progress * 2) or ((1 - progress) * 2)
        slotFrame:SetScale(1 + (0.03 * pulse))
    end)
end

local function getRaidusSlotColor(slotFrame)
	if not slotFrame or not slotFrame.bot or not slotFrame.bot.class then
		return nil
	end

	local className = MultiBot.toClass(slotFrame.bot.class)
	return RAIDUS_CLASS_SLOT_COLORS[className]
end

local function applyRaidusSlotTexture(slotFrame, useClassColor)
	if not slotFrame or not slotFrame.texture then
		return
	end

    if slotFrame.isDropSlot then
        slotFrame.texture:SetTexture(MultiBot.SafeTexturePath("Interface\\AddOns\\MultiBot\\Textures\\grey.blp"))
        slotFrame.texture:SetVertexColor(1, 1, 1, 1)
        return
    end

	if useClassColor then
		local color = getRaidusSlotColor(slotFrame)
		if color then
			slotFrame.texture:SetTexture(MultiBot.SafeTexturePath("Interface\\Buttons\\WHITE8X8"))
			slotFrame.texture:SetVertexColor(color[1], color[2], color[3], RAIDUS_CLASS_SLOT_ALPHA)
			return
		end
	end

	slotFrame.texture:SetTexture(MultiBot.SafeTexturePath("Interface\\AddOns\\MultiBot\\Textures\\grey.blp"))
	slotFrame.texture:SetVertexColor(1, 1, 1, 1)
end

local function getRaidusGroupSlotFrame(groupIndex, slotIndex)
    local gc = MultiBot.raidus.groups[groupIndex]
    local slots = gc and gc._slots
    if not slots then
        return nil
    end

    return slots["Slot" .. slotIndex]
end

local function forEachRaidusGroupSlot(visitor)
    for groupIndex = 1, RAIDUS_GROUP_COUNT do
        for slotIndex = 1, RAIDUS_GROUP_SLOT_COUNT do
            visitor(groupIndex, slotIndex, getRaidusGroupSlotFrame(groupIndex, slotIndex))
        end
    end
end

local function serializeRaidusLayoutFromFrames()
    local serializedGroups = {}

    for groupIndex = 1, RAIDUS_GROUP_COUNT do
        local serializedNames = {}
        for slotIndex = 1, RAIDUS_GROUP_SLOT_COUNT do
            local slotFrame = getRaidusGroupSlotFrame(groupIndex, slotIndex)
            local slotName = MultiBot.IF(slotFrame and slotFrame.name ~= nil, slotFrame.name, "-")
            table.insert(serializedNames, slotName)
        end
        table.insert(serializedGroups, table.concat(serializedNames, ","))
    end

    return table.concat(serializedGroups, ";")
end

local RAIDUS_LAYOUT_SLOT_MAX = 8
local RAIDUS_LAYOUT_MIGRATION_VERSION = 1
local RAIDUS_LAYOUT_MIGRATION_KEY = "raidusLayoutsVersion"

-- Forward declaration keeps a local upvalue even if helpers are reordered later.
local getRaidusLayoutKey
local getLegacyRaidusLayoutStore

local function getRaidusLayoutStore(createLegacyIfMissing)
    if MultiBot.Store and MultiBot.Store.EnsureUIChildStore then
        local store = MultiBot.Store.EnsureUIChildStore("raidusLayouts")
        if store then
            return store
        end
    end

    local profile = MultiBot.db and MultiBot.db.profile
    if profile then
        profile.ui = profile.ui or {}
        profile.ui.raidusLayouts = profile.ui.raidusLayouts or {}
        return profile.ui.raidusLayouts
    end

    return getLegacyRaidusLayoutStore(createLegacyIfMissing)
end

getRaidusLayoutKey = function(slot)
    return "Raidus" .. (slot or "")
end

getLegacyRaidusLayoutStore = function(createIfMissing)
    local store = _G.MultiBotSave
    if type(store) ~= "table" then
        if not createIfMissing then
            return nil
        end

        store = {}
        _G.MultiBotSave = store
    end

    return store
end

local function cleanupLegacyRaidusLayoutKeys(legacyStore)
    if type(legacyStore) ~= "table" then
        return
    end

    for slotIndex = 1, RAIDUS_LAYOUT_SLOT_MAX do
        local slot = (slotIndex == 1) and nil or slotIndex
        local key = getRaidusLayoutKey(slot)
        if legacyStore[key] == "" then
            legacyStore[key] = nil
        end
    end
end

local function migrateLegacyRaidusLayoutsIfNeeded(store)
    if not MultiBot.GetProfileMigrationStore() then
        return
    end

    if not MultiBot.ShouldSyncLegacyState(RAIDUS_LAYOUT_MIGRATION_KEY, RAIDUS_LAYOUT_MIGRATION_VERSION) then
        return
    end

    local legacyStore = getLegacyRaidusLayoutStore(false)
    for slotIndex = 1, RAIDUS_LAYOUT_SLOT_MAX do
        local slot = (slotIndex == 1) and nil or slotIndex
        local key = getRaidusLayoutKey(slot)
        if store[key] == nil and legacyStore and legacyStore[key] ~= nil then
            store[key] = legacyStore[key]
        end
    end

    MultiBot.MarkLegacyStateMigrated(RAIDUS_LAYOUT_MIGRATION_KEY, RAIDUS_LAYOUT_MIGRATION_VERSION)

    -- Purge migrated legacy Raidus layout keys to avoid stale duplicate persistence.
    if type(legacyStore) == "table" then
        for slotIndex = 1, RAIDUS_LAYOUT_SLOT_MAX do
            local slot = (slotIndex == 1) and nil or slotIndex
            legacyStore[getRaidusLayoutKey(slot)] = nil
        end

        cleanupLegacyRaidusLayoutKeys(legacyStore)
    end
end

local function getRaidusLayoutValue(slot)
    local key = getRaidusLayoutKey(slot)
    local hasProfileStore = MultiBot.db and MultiBot.db.profile
    local store = getRaidusLayoutStore(not hasProfileStore)
    migrateLegacyRaidusLayoutsIfNeeded(store)

    local value = store[key]
    if value ~= nil then
        return value
    end

    local shouldSyncLegacy = MultiBot.ShouldSyncLegacyState(RAIDUS_LAYOUT_MIGRATION_KEY, RAIDUS_LAYOUT_MIGRATION_VERSION)
    if shouldSyncLegacy then
        local legacyStore = getLegacyRaidusLayoutStore(false)
        value = legacyStore and legacyStore[key]
        if value ~= nil then
            store[key] = value
        end
    end

    return value
end

local function setRaidusLayoutValue(slot, value)
    local key = getRaidusLayoutKey(slot)
    local store = getRaidusLayoutStore(true)
    migrateLegacyRaidusLayoutsIfNeeded(store)
    store[key] = value

    local shouldSyncLegacy = MultiBot.ShouldSyncLegacyState(RAIDUS_LAYOUT_MIGRATION_KEY, RAIDUS_LAYOUT_MIGRATION_VERSION)
    if shouldSyncLegacy then
        local legacyStore = getLegacyRaidusLayoutStore(true)
        legacyStore[key] = value
    end
end

local function parseRaidusLayoutData(layoutData)
    if type(layoutData) ~= "string" or layoutData == "" then
        return nil
    end

    local layout = {}
    local serializedGroups = MultiBot.doSplit(layoutData, ";")
    for groupIndex = 1, RAIDUS_GROUP_COUNT do
        layout[groupIndex] = MultiBot.doSplit(serializedGroups[groupIndex], ",")
    end

    return layout
end

local function buildRaidusPoolFrameIndex(poolFrames)
    local index = {}
    if not poolFrames then
        return index
    end

    for _, dragFrame in pairs(poolFrames) do
        if dragFrame and dragFrame.name ~= nil and dragFrame.name ~= "" and dragFrame.name ~= "-" then
            index[dragFrame.name] = dragFrame
        end
    end

    return index
end

local function getRaidusPoolFrameByName(poolFrameIndex, name)
    if not poolFrameIndex or not name or name == "" or name == "-" then
        return nil
    end

    return poolFrameIndex[name]
end

local function swapRaidusFrameIntoSlot(dragFrame, dropFrame)
    if not dragFrame or not dropFrame then
        return
    end
    MultiBot.raidus.doDrop(dragFrame, dropFrame.parent, dropFrame.x, dropFrame.y, dropFrame.width, dropFrame.height, dropFrame.slot)
    dragFrame:Show()
end

local function applyRaidusLayout(layout)
    if type(layout) ~= "table" then
        return
    end

    local pool = MultiBot.raidus and MultiBot.raidus.poolCanvas
    local poolFrames = pool and pool.frames
    if not poolFrames then
        return
    end
    local poolFrameIndex = buildRaidusPoolFrameIndex(poolFrames)

    for groupIndex = 1, RAIDUS_GROUP_COUNT do
        local groupLayout = layout[groupIndex]

        if groupLayout then
            for slotIndex = 1, RAIDUS_GROUP_SLOT_COUNT do
                local botName = groupLayout[slotIndex]
                if botName and botName ~= "-" then
                    local dropFrame = getRaidusGroupSlotFrame(groupIndex, slotIndex)
                    local dragFrame = getRaidusPoolFrameByName(poolFrameIndex, botName)
                    if dropFrame and dragFrame then
                        swapRaidusFrameIntoSlot(dragFrame, dropFrame)
                    end
                end
            end
        end
    end
end

local RAIDUS_ACTION_BAR_Y = 10

-- Thin wrapper over AceUI.CreateFixedButton scoped to the Raidus action bar.
local function createRaidusActionBarButton(label, x, y, width)
    if not MultiBot.raidus.actionBar then return nil end
    return MultiBot.AceUI.CreateFixedButton(MultiBot.raidus.actionBar, label, x, y, width)
end

local function styleRaidusActionButton(button, isPrimary)
    if not button then return button end
    local normalTexture = button.frame:GetNormalTexture()
    local pushedTexture = button.frame:GetPushedTexture()
    local highlightTexture = button.frame:GetHighlightTexture()
    local disabledTexture = button.frame:GetDisabledTexture()

    if isPrimary then
        if normalTexture then normalTexture:SetVertexColor(1.00, 0.96, 0.78, 1.00) end
        if pushedTexture then pushedTexture:SetVertexColor(1.00, 0.90, 0.55, 1.00) end
        if highlightTexture then highlightTexture:SetVertexColor(1.00, 0.96, 0.72, 0.90) end
        if disabledTexture then disabledTexture:SetVertexColor(0.55, 0.55, 0.55, 1.00) end
    else
        if normalTexture then normalTexture:SetVertexColor(0.88, 0.88, 0.88, 1.00) end
        if pushedTexture then pushedTexture:SetVertexColor(0.74, 0.74, 0.74, 1.00) end
        if highlightTexture then highlightTexture:SetVertexColor(0.95, 0.95, 0.95, 0.85) end
        if disabledTexture then disabledTexture:SetVertexColor(0.50, 0.50, 0.50, 1.00) end
    end

    return button
end

local btnLoad = styleRaidusActionButton(createRaidusActionBarButton("Load", -782, RAIDUS_ACTION_BAR_Y, 80), false)
if btnLoad then
    btnLoad.frame:SetScript("OnClick", function(self, button)
        if button ~= "LeftButton" then return end
        local layoutData = getRaidusLayoutValue(MultiBot.raidus.save)
        if layoutData == nil or layoutData == "" then
            SendChatMessage(MultiBot.L("info.nothing"), "SAY")
            return
        end
        if MultiBot.raidus.setRaidus then
            MultiBot.raidus.setRaidus()
        end
        local layout = parseRaidusLayoutData(layoutData)
        applyRaidusLayout(layout)
    end)
end

local function UpdateRaidusSlotButtonText(button)
    local label = "Slot"
    if MultiBot.raidus.save ~= "" then
        label = "Slot " .. MultiBot.raidus.save
    end
    button:SetText("|cffffcc00" .. label .. "|r")
end

local slotButton = styleRaidusActionButton(createRaidusActionBarButton("Slot", -702, RAIDUS_ACTION_BAR_Y, 80), false)
local slotDropDown = CreateFrame("Frame", "MultiBotRaidusSlotDropDown", slotButton and slotButton.frame or UIParent, "UIDropDownMenuTemplate")
UIDropDownMenu_SetWidth(slotDropDown, 80)
UIDropDownMenu_Initialize(slotDropDown, function(self, level)
    for i = 1, 10 do
        local info = UIDropDownMenu_CreateInfo()
        info.text = tostring(i)
        info.value = tostring(i)
        info.func = function()
            MultiBot.raidus.save = tostring(i)
            UIDropDownMenu_SetSelectedValue(slotDropDown, tostring(i))
            if slotButton then UpdateRaidusSlotButtonText(slotButton) end
            MultiBot.raidus.setRaidus()
        end
        UIDropDownMenu_AddButton(info, level)
    end
end)
if slotButton then
    slotButton.tip = MultiBot.L("tips.raidus.slot")
    slotButton.frame:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:SetText(slotButton.tip or "", 1, 1, 1, true)
    end)
    slotButton.frame:SetScript("OnLeave", function() GameTooltip:Hide() end)
    slotButton.frame:SetScript("OnClick", function(self, button)
        if button ~= "LeftButton" then return end
        if MultiBot.raidus.save ~= "" then
            UIDropDownMenu_SetSelectedValue(slotDropDown, MultiBot.raidus.save)
        end
        ToggleDropDownMenu(1, nil, slotDropDown, self, 0, 0)
    end)
    UpdateRaidusSlotButtonText(slotButton)
end

local function styleRaidusSortButtonVisual(button, isActive)
    if not button then return end
    local normalTexture = button.frame:GetNormalTexture()
    local pushedTexture = button.frame:GetPushedTexture()
    local highlightTexture = button.frame:GetHighlightTexture()

    if isActive then
        if normalTexture then normalTexture:SetVertexColor(1.00, 0.92, 0.55, 1.00) end
        if pushedTexture then pushedTexture:SetVertexColor(1.00, 0.84, 0.35, 1.00) end
        if highlightTexture then highlightTexture:SetVertexColor(1.00, 0.95, 0.60, 0.90) end
        if button.text then button.text:SetTextColor(1.00, 0.95, 0.65) end
    else
        if normalTexture then normalTexture:SetVertexColor(0.74, 0.74, 0.74, 0.95) end
        if pushedTexture then pushedTexture:SetVertexColor(0.62, 0.62, 0.62, 0.95) end
        if highlightTexture then highlightTexture:SetVertexColor(0.85, 0.85, 0.85, 0.80) end
        if button.text then button.text:SetTextColor(0.86, 0.86, 0.86) end
    end
end

local function updateRaidusSortButtonsVisual(activeSortName)
    styleRaidusSortButtonVisual(MultiBot.raidus.btnScore, activeSortName == "Score")
    styleRaidusSortButtonVisual(MultiBot.raidus.btnLevel, activeSortName == "Level")
    styleRaidusSortButtonVisual(MultiBot.raidus.btnClass, activeSortName == "Class")
end

-- Contrôle du mode Tri, "Score / Level / Class"
local sortBaseX   = -355 -- position du bouton "Score", pour déplacer tout le groupe il faut modifier cette valeur
local sortY       = RAIDUS_ACTION_BAR_Y
local sortSpacing = 6    -- espace entre les boutons

local scoreWidth  = 60
local levelWidth  = 60
local classWidth  = 60

-- Bouton "Score"
local btnScore = createRaidusActionBarButton("Score", sortBaseX, sortY, scoreWidth)
MultiBot.raidus.btnScore = btnScore
updateRaidusSortButtonsVisual("Score")
if btnScore then
    btnScore.frame:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:SetText(MultiBot.L("tips.raidus.score"), 1, 1, 1, true)
    end)
    btnScore.frame:SetScript("OnLeave", function() GameTooltip:Hide() end)
    btnScore.frame:SetScript("OnClick", function(self, button)
        if button ~= "LeftButton" then return end
        MultiBot.raidus.sortMode = "Score"
        if MultiBot.raidus.btnScore then MultiBot.raidus.btnScore:SetDisabled(false) end
        if MultiBot.raidus.btnLevel then MultiBot.raidus.btnLevel:SetDisabled(true) end
        if MultiBot.raidus.btnClass then MultiBot.raidus.btnClass:SetDisabled(true) end
        updateRaidusSortButtonsVisual("Score")
        MultiBot.raidus.setRaidus()
    end)
end

-- Bouton "Level"
local btnLevel = createRaidusActionBarButton("Level", sortBaseX + scoreWidth + sortSpacing, sortY, levelWidth)
MultiBot.raidus.btnLevel = btnLevel
if btnLevel then
    btnLevel:SetDisabled(true)
    btnLevel.frame:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:SetText(MultiBot.L("tips.raidus.level"), 1, 1, 1, true)
    end)
    btnLevel.frame:SetScript("OnLeave", function() GameTooltip:Hide() end)
    btnLevel.frame:SetScript("OnClick", function(self, button)
        if button ~= "LeftButton" then return end
        MultiBot.raidus.sortMode = "Level"
        if MultiBot.raidus.btnScore then MultiBot.raidus.btnScore:SetDisabled(true) end
        if MultiBot.raidus.btnLevel then MultiBot.raidus.btnLevel:SetDisabled(false) end
        if MultiBot.raidus.btnClass then MultiBot.raidus.btnClass:SetDisabled(true) end
        updateRaidusSortButtonsVisual("Level")
        MultiBot.raidus.setRaidus()
    end)
end

-- Bouton "Class"
local btnClass = createRaidusActionBarButton("Class", sortBaseX + scoreWidth + sortSpacing + levelWidth + sortSpacing, sortY, classWidth)
MultiBot.raidus.btnClass = btnClass
if btnClass then
    btnClass:SetDisabled(true)
    btnClass.frame:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:SetText(MultiBot.L("tips.raidus.class"), 1, 1, 1, true)
    end)
    btnClass.frame:SetScript("OnLeave", function() GameTooltip:Hide() end)
    btnClass.frame:SetScript("OnClick", function(self, button)
        if button ~= "LeftButton" then return end
        MultiBot.raidus.sortMode = "Class"
        if MultiBot.raidus.btnScore then MultiBot.raidus.btnScore:SetDisabled(true) end
        if MultiBot.raidus.btnLevel then MultiBot.raidus.btnLevel:SetDisabled(true) end
        if MultiBot.raidus.btnClass then MultiBot.raidus.btnClass:SetDisabled(false) end
        updateRaidusSortButtonsVisual("Class")
        MultiBot.raidus.setRaidus()
    end)
end

local btnSave = styleRaidusActionButton(createRaidusActionBarButton("Save", -617, RAIDUS_ACTION_BAR_Y, 80), false)
if btnSave then
    btnSave.frame:SetScript("OnClick", function(self, button)
        if button ~= "LeftButton" then return end
        setRaidusLayoutValue(MultiBot.raidus.save, serializeRaidusLayoutFromFrames())
    end)
end

local function collectRaidusApplyInviteList(raidByName, selfName)
    local inviteList = {}
    local selectedCount = 0
    local selectedNames = {}

    for unitName, unitButton in pairs(MultiBot.frames["MultiBar"].frames["Units"].buttons) do
        if unitButton.state then
            selectedCount = selectedCount + 1
            selectedNames[unitName] = true
        elseif unitName ~= selfName and raidByName[unitName] ~= nil then
            table.insert(inviteList, unitName)
        end
    end

    local fallbackInviteList = {}
    local hasLayoutOnly = false
    for raidName, _ in pairs(raidByName) do
        if raidName ~= selfName then
            if not selectedNames[raidName] then
                hasLayoutOnly = true
            end
            if not MultiBot.isMember(raidName) then
                table.insert(fallbackInviteList, raidName)
            end
        end
    end

    local usedLayoutFallback = false
    if (selectedCount == 0 or hasLayoutOnly) and #fallbackInviteList > 0 then
        inviteList = fallbackInviteList
        usedLayoutFallback = true
    end

    return selectedCount, inviteList, usedLayoutFallback
end

local function removeRaidusMembersOutsideLayout(raidByMembers, raidByName, selfName)
    for raidMemberName, _ in pairs(raidByMembers) do
        if raidMemberName ~= selfName and raidByName[raidMemberName] == nil then
            if MultiBot.isMember(raidMemberName) then
                UninviteUnit(raidMemberName)
            end
            SendChatMessage(".playerbot bot remove " .. raidMemberName, "SAY")
        end
    end
end

local function startRaidusApplyInviteOrSort(inviteCount)
    if inviteCount > 0 then
        SendChatMessage(MultiBot.L("info.starting"), "SAY")
        MultiBot.timer.invite.roster = "raidus"
        MultiBot.timer.invite.needs = inviteCount
        MultiBot.timer.invite.index = 1
        MultiBot.auto.invite = true
    else
        MultiBot.timer.sort.elapsed = 0
        MultiBot.timer.sort.index = 1
        MultiBot.timer.sort.needs = 0
        MultiBot.auto.sort = true
    end
end

local btnApply = styleRaidusActionButton(createRaidusActionBarButton("Apply", -534, RAIDUS_ACTION_BAR_Y, 80), true)
if btnApply then
    btnApply.frame:SetScript("OnClick", function(self, button)
        if button ~= "LeftButton" then return end
        local tRaidByIndex, tRaidByName = MultiBot.raidus.getRaidTarget()
        if tRaidByIndex == nil or tRaidByName == nil then return end

        local tSelf = UnitName("player")
        local _, inviteList = collectRaidusApplyInviteList(tRaidByName, tSelf)

        MultiBot.index.raidus = inviteList
        local tNeeds = #inviteList

        local tRaidByMembers = MultiBot.raidus.getRaidState()
        removeRaidusMembersOutsideLayout(tRaidByMembers, tRaidByName, tSelf)

        startRaidusApplyInviteOrSort(tNeeds)
    end)
end


-- Bouton Auto-balance raid :
-- Clic gauche  : équilibrage simple par score
-- Clic droit   : équilibrage avancé Tank / Heal / DPS
local btnAuto = styleRaidusActionButton(createRaidusActionBarButton("Auto", -451, RAIDUS_ACTION_BAR_Y, 80), true)
if btnAuto then
    btnAuto.frame:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:SetText(MultiBot.L("tips.raidus.autobalance"), 1, 1, 1, true)
    end)
    btnAuto.frame:SetScript("OnLeave", function() GameTooltip:Hide() end)
    -- Clic gauche : simple / Clic droit : avancé Tank / Heal / DPS
    btnAuto.frame:SetScript("OnClick", function(self, button)
        if button == "LeftButton" then
            MultiBot.raidus.autoBalanceRaid("score")
        elseif button == "RightButton" then
            MultiBot.raidus.autoBalanceRaid("role")
        end
    end)
end

-- Pool paging buttons (< previous / > next page)
local btnPrev = createRaidusActionBarButton("<", -110, RAIDUS_ACTION_BAR_Y, 24)
if btnPrev then
    btnPrev:SetText("|cffffcc00<|r")
    btnPrev.frame:SetScript("OnClick", function(self, button)
        if button ~= "LeftButton" then return end
        MultiBot.raidus.from = MultiBot.raidus.from - RAIDUS_POOL_PAGE_SIZE
        MultiBot.raidus.to = MultiBot.raidus.to - RAIDUS_POOL_PAGE_SIZE
        if MultiBot.raidus.to < 1 then
            MultiBot.raidus.from = MultiBot.raidus.slots - (RAIDUS_POOL_PAGE_SIZE - 1)
            MultiBot.raidus.to = MultiBot.raidus.slots
        end
        refreshRaidusPoolPageVisibility()
    end)
end

local btnNext = createRaidusActionBarButton(">", -70, RAIDUS_ACTION_BAR_Y, 24)
if btnNext then
    btnNext:SetText("|cffffcc00>|r")
    btnNext.frame:SetScript("OnClick", function(self, button)
        if button ~= "LeftButton" then return end
        MultiBot.raidus.from = MultiBot.raidus.from + RAIDUS_POOL_PAGE_SIZE
        MultiBot.raidus.to = MultiBot.raidus.to + RAIDUS_POOL_PAGE_SIZE
        if MultiBot.raidus.from > MultiBot.raidus.slots then
            MultiBot.raidus.from = 1
            MultiBot.raidus.to = RAIDUS_POOL_PAGE_SIZE
        end
        refreshRaidusPoolPageVisibility()
    end)
end


MultiBot.raidus.getDrop = function()
	for i = 1, RAIDUS_GROUP_COUNT, 1 do
		local tGroup = MultiBot.raidus.groups[i]
		if tGroup and MouseIsOver(tGroup.frame) then
			for j = 1, RAIDUS_GROUP_SLOT_COUNT, 1 do
				local tSlot = tGroup._slots and tGroup._slots["Slot" .. j]
				if tSlot and MouseIsOver(tSlot) then return tSlot end
			end
		end
	end

	for i = 1, MultiBot.raidus.slots, 1 do
		local tSlot = MultiBot.raidus.poolCanvas.frames["Slot" .. i]
		if(MouseIsOver(tSlot)) then return tSlot end
	end

	return nil
end

-- SETTER --

local function getRaidusGlobalBotStore()
    if MultiBot.GetGlobalBotStore then
        return MultiBot.GetGlobalBotStore()
    end

    if type(_G.MultiBotGlobalSave) ~= "table" then
        _G.MultiBotGlobalSave = {}
    end

    return _G.MultiBotGlobalSave
end

local function buildRaidusBotFromGlobalSave(name, value)
    if not value then
        return nil
    end

    local details = MultiBot.doSplit(value, ",")
    local rawClass = details[5]
    if not rawClass or rawClass == "" then
        return nil
    end

    local bot = {}
    bot.name = name
    bot.race = details[1]
    bot.gender = details[2]
    bot.special = details[3]
    bot.talents = details[4]
    bot.class = rawClass
    bot.level = tonumber(details[6]) or 0
    bot.score = tonumber(details[7]) or 0
    bot.role = MultiBotRaidusDetectRole(bot)
    return bot
end

local function appendRaidusBotIfValid(bots, name, value)
    local bot = buildRaidusBotFromGlobalSave(name, value)
    if bot then
        table.insert(bots, bot)
    end
end

local RAIDUS_CLASS_ID_MAP = {
    [1] = "WARRIOR", [2] = "PALADIN",     [3] = "HUNTER",  [4] = "ROGUE",
    [5] = "PRIEST",  [6] = "DEATHKNIGHT", [7] = "SHAMAN",  [8] = "MAGE",
    [9] = "WARLOCK", [11] = "DRUID",
}

local function buildRaidusBotFromRosterEntry(entry)
    if not entry or not entry.name or entry.name == "" then
        return nil
    end

    local rawClass = RAIDUS_CLASS_ID_MAP[tonumber(entry.classId or 0) or 0]
    if not rawClass then
        return nil
    end

    local bot = {}
    bot.name    = entry.name
    bot.class   = MultiBot.toClass(rawClass)
    bot.level   = entry.level or 0
    bot.score   = 0
    bot.special = bot.class
    bot.talents = "0/0/0"
    bot.race    = ""
    bot.gender  = ""
    bot.role    = MultiBotRaidusDetectRole(bot)
    return bot
end

MultiBot.raidus.setRaidus = function()
	local tPool = MultiBot.raidus.poolCanvas
	local tSlot = 1
	local tY = 0

	for k,v in pairs(tPool.frames) do v:Hide() end

	local tBots = {}
	-- Mode de tri actuel ("Score", "Level", "Class")
	local sortMode = MultiBot.raidus.sortMode or "Score"

	local function appendBotWithSort(tBot)
		if not tBot then return end
		local tClass = MultiBot.toClass(tBot.class)
		local classWeight = (MultiBotRaidusClassData[tClass] and MultiBotRaidusClassData[tClass].weight) or 0
		local botLevel    = tBot.level or 0
		local botScore    = tBot.score or 0
		if sortMode == "Score" then
			tBot.sort = botScore * 1000000 + botLevel * 1000 + classWeight
		elseif sortMode == "Level" then
			tBot.sort = botLevel * 1000000 + botScore * 1000 + classWeight
		elseif sortMode == "Class" then
			tBot.sort = classWeight * 1000000 + botLevel * 1000 + botScore
		else
			tBot.sort = botScore * 1000000 + botLevel * 1000 + classWeight
		end
		table.insert(tBots, tBot)
	end

	local accountRoster = MultiBot.bridge and MultiBot.bridge.accountRoster
	local globalStore   = getRaidusGlobalBotStore()
	if accountRoster and #accountRoster > 0 then
		for _, entry in ipairs(accountRoster) do
			appendBotWithSort(buildRaidusBotFromRosterEntry(entry))
		end
	else
		for tName, tValue in pairs(globalStore) do
			appendBotWithSort(buildRaidusBotFromGlobalSave(tName, tValue))
		end
	end

	table.sort(tBots, function(a, b)
		return (a.sort or 0) > (b.sort or 0)
	end)

	local function formatRaidusSlotName(name, maxLen)
		local text = tostring(name or "")
		local limit = maxLen or 16
		if string.len(text) <= limit then
			return text
		end
		return string.sub(text, 1, limit - 1) .. "..."
	end

	for tIndex = 1, #tBots do
		local tBot = tBots[tIndex]

		if tPool.frames["Slot" .. tSlot] then tPool.frames["Slot" .. tSlot]:Hide() end
		local tFrame = MultiBot.newFrame(tPool, 0, tY, 28, 160, 36, "TOPLEFT")
		tPool.frames["Slot" .. tSlot] = tFrame
		tFrame.addTexture("Interface\\AddOns\\MultiBot\\Textures\\grey.blp")
		applyRaidusSlotTextureInset(tFrame)
		tFrame:SetResizable(false)
		tFrame:SetMovable(true)
		tFrame.class = MultiBot.toClass(tBot.class)
		tFrame.slot = "Slot" .. tSlot
		tFrame.name = tBot.name
		tFrame.bot = tBot
		setRaidusSlotRoleBorder(tFrame, nil, 0.22)

        local tButton = tFrame.addButton("Icon", -128, 3, "Interface\\AddOns\\MultiBot\\Icons\\class_" .. string.lower(tFrame.class) .. ".blp", "")

		tButton:SetScript("OnEnter", function(pButton)
			local bot = pButton.parent.bot
			if not bot then
				return
			end

			local botName    = bot.name or "?"
			local botGender  = bot.gender or "?"
			local botRace    = bot.race or "?"
			local botClass   = bot.class or "Unknown"
			local botTalents = bot.talents or "?"
			local botSpecial = bot.special or "?"
			local botLevel   = bot.level or 0
			local botScore   = bot.score or 0
			local botRole    = bot.role or MultiBotRaidusDetectRole(bot)
			local roleColor  = botRole and RAIDUS_ROLE_COLORS[botRole]
			local roleHex    = roleColor and string.format("ff%02x%02x%02x", math.floor(roleColor[1] * 255 + 0.5), math.floor(roleColor[2] * 255 + 0.5), math.floor(roleColor[3] * 255 + 0.5))
			local classHex   = getRaidusClassHexColor(MultiBot.toClass(botClass))

			local tReward = botLevel .. "." .. MultiBot.IF(botScore < 100, "0", MultiBot.IF(botScore < 10, "00", "")) .. botScore

			pButton.tip = MultiBot.newFrame(pButton, -pButton.size, 160, 28, 256, 512, "TOPRIGHT")
			pButton.tip.addTexture("Interface\\AddOns\\MultiBot\\Textures\\Raidus_Wanted.blp")
			pButton.tip.addModel(botName, 0, 64, 160, 240, 1.0)
			pButton.tip.addText("1", "|cff555555- WANTED -|h", "TOP", 0, -30, 24)
			pButton.tip.addText("2", "|cff555555-DEAD OR ALIVE-|h", "TOP", 0, -55, 24)
			pButton.tip.addText("3", "|cff333333" .. botName .. " - " .. botGender .. " - " .. botRace .. "|h", "BOTTOM", 0, 224, 15)
			pButton.tip.addText("4", "|c" .. classHex .. botClass .. "|r  |cff909090(" .. botSpecial .. ")|r", "BOTTOM", 0, 206, 15)
			local roleText = (botRole and roleHex) and ("|c" .. roleHex .. botRole .. "|r  ") or ""
			pButton.tip.addText("5", roleText .. "|cff333333Score:|r |cffffdd55" .. botScore .. "|r", "BOTTOM", 0, 188, 15)
			pButton.tip.addText("6", "|cff333333Talents:|r |cff505050" .. botTalents .. "|r", "BOTTOM", 0, 172, 14)
			pButton.tip.addText("7", "|cff555555CASH - " .. tReward .. " - GOLD|h", "BOTTOM", 0, 154, 20)
			pButton.tip:Show()
		end)

        -- Clic gauche : drag & drop dans les groupes
        -- Clic droit  : connecte / déconnecte le bot (add/remove)
        tButton:SetScript("OnMouseDown", function(pButton, button)
            if button == "LeftButton" then
                pButton.parent:StartMoving()
                pButton.parent.isMoving = true
            end
        end)

        tButton:SetScript("OnMouseUp", function(pButton, button)
            if button == "LeftButton" then
                -- Drag & drop (inchangé)
                pButton.parent:StopMovingOrSizing()
                pButton.parent.isMoving = false

                local tDrag = pButton.parent
                local tDrop = MultiBot.raidus.getDrop()

                if tDrop ~= nil then
                    local tOldParent = tDrag.parent
                    local tOldSlot   = tDrag.slot
                    local tOldX      = tDrag.x
                    local tOldY      = tDrag.y
                    local tOldWidth  = tDrag.width
                    local tOldHeight = tDrag.height

                    local dropWidget = tDrop.parent and tDrop.parent._widget
                    local oldWidget = tOldParent and tOldParent._widget
                    local isDropGroup = dropWidget ~= nil

                    if oldWidget then
                        local srcSlot = oldWidget._slots[tOldSlot]
                        if srcSlot then
                            srcSlot.name = nil
                            srcSlot.bot = nil
                            srcSlot.botFrame = nil
                            applyRaidusSlotTexture(srcSlot, false)
                            setRaidusSlotRoleBorder(srcSlot, nil, 0.20)
                        end
                    end

                    local existingBot = isDropGroup and tDrop.botFrame or nil
                    MultiBot.raidus.doDrop(tDrag, tDrop.parent, tDrop.x, tDrop.y, tDrop.width, tDrop.height, tDrop.slot)
                    tDrag:Show()
                    if existingBot and existingBot ~= tDrag then
                        MultiBot.raidus.doDrop(existingBot, tOldParent, tOldX, tOldY, tOldWidth, tOldHeight, tOldSlot)
                        existingBot:Show()
                    elseif not isDropGroup and tDrop.name then
                        MultiBot.raidus.doDrop(tDrop, tOldParent, tOldX, tOldY, tOldWidth, tOldHeight, tOldSlot)
                        tDrop:Show()
                    end

                    playRaidusDropPulse(tDrag)
                else
                    pButton.parent:ClearAllPoints()
                    pButton.parent:SetPoint(pButton.parent.align, pButton.parent.x, pButton.parent.y)
                    pButton.parent:SetSize(pButton.parent.width, pButton.parent.height)
                end

            elseif button == "RightButton" then
                local name = pButton.parent.name
                if not name or name == "" then
                    return
                end

                if MultiBotRaidusIsBotGrouped(name) then
                    -- Bot déjà dans le groupe/raid :
                    -- on laisse le core playerbots gérer leave + logout
                    SendChatMessage(".playerbot bot remove " .. name, "SAY")
                else
                    -- Bot pas dans le groupe/raid :
                    -- login + invite via playerbots
                    SendChatMessage(".playerbot bot add " .. name, "SAY")
                end
            end
        end)

		local displayLevel   = tBot.level or 0
		local displayScore   = tBot.score or 0
		local displaySpecial = tBot.special or ""
		local displayName    = formatRaidusSlotName(tBot.name, 14)

		tFrame.addText("Name", "|cfffff2c0" .. displayName .. "|r", "BOTTOMLEFT", 36, 18, 13) -- Display name in bot frame
		tFrame.addText("Meta", "|cffb8b8b8" .. displayLevel .. " - " .. displaySpecial .. "|r", "BOTTOMLEFT", 36, 6, 11) -- Display level and spec in bot frame
		tFrame.addText("ScoreBadge", "|cffd4af37[" .. displayScore .. "]|r", "BOTTOMRIGHT", -8, 16, 11) -- Display Score in bot frame

		if(tSlot > RAIDUS_POOL_PAGE_SIZE) then tFrame:Hide() else tFrame:Show() end
		tY = MultiBot.IF(tSlot % RAIDUS_POOL_PAGE_SIZE == 0, 0, tY - 40)
		tSlot = tSlot + 1
	end

	for i = tSlot % RAIDUS_POOL_PAGE_SIZE, RAIDUS_POOL_PAGE_SIZE, 1 do
		if tPool.frames["Slot" .. tSlot] then tPool.frames["Slot" .. tSlot]:Hide() end
		local tFrame = MultiBot.newFrame(tPool, 0, tY, 28, 160, 36, "TOPLEFT")
		tPool.frames["Slot" .. tSlot] = tFrame
		tFrame.addTexture("Interface\\AddOns\\MultiBot\\Textures\\grey.blp")
		applyRaidusSlotTextureInset(tFrame)
		tFrame.slot = "Slot" .. tSlot
		setRaidusSlotRoleBorder(tFrame, nil, 0.22)
		if(tSlot > RAIDUS_POOL_PAGE_SIZE) then tFrame:Hide() else tFrame:Show() end
		tSlot = tSlot + 1
		tY = tY - 40
	end

	MultiBot.raidus.slots = tSlot - 1

	for i = 1, RAIDUS_GROUP_COUNT, 1 do
		local tGroup = MultiBot.raidus.groups[i]

		tGroup.score = 0
		tGroup:SetTitle("|cffffcc00Group" .. i .. "|r " .. formatGroupScoreBadge(0))

		for _, dropSlot in pairs(tGroup.dropSlots) do
			if dropSlot.botFrame then
				dropSlot.botFrame:Hide()
				dropSlot.botFrame = nil
			end
			dropSlot.bot = nil
			dropSlot.name = nil
			setRaidusSlotRoleBorder(dropSlot, nil, 0.20)
			applyRaidusSlotTexture(dropSlot, false)
		end
		tGroup._slots = {}
		for k, v in pairs(tGroup.dropSlots) do tGroup._slots[k] = v end
	end
	updateRaidusScore()
end

-- GETTER --

local function buildRaidusCurrentRosterState()
	local raidByMembers = {}
	local raidByGroups = {}
	local raidCount = GetNumRaidMembers() or 0

	for raidIndex = 1, raidCount do
		local raidName, _, raidGroup = GetRaidRosterInfo(raidIndex)
		if raidName and raidGroup then
			raidByMembers[raidName] = { index = raidIndex, group = raidGroup }
			raidByGroups[raidGroup] = (raidByGroups[raidGroup] or 0) + 1
		end
	end

	return raidByMembers, raidByGroups
end

MultiBot.raidus.getRaidState = function()
	return buildRaidusCurrentRosterState()
end

MultiBot.raidus.getRaidTarget = function()
	local tRaidByIndex = {}
	local tRaidByName = {}
	local tIndex = 1

	local tSelf = UnitName("player")
	local tUser = true
	local tBots = true

	forEachRaidusGroupSlot(function(groupIndex, slotIndex, slotFrame)
		local slotName = slotFrame and slotFrame.name
		if(slotName ~= nil) then
			if(slotName == tSelf) then tUser = false end
			tRaidByIndex[tIndex] = { name = slotName, group = groupIndex }
			tRaidByName[slotName] = groupIndex
			tIndex = tIndex + 1
			tBots = false
		end
	end)

	if(tBots) then return SendChatMessage("There is no Bot in the Raid", "SAY") end
	if(tUser) then return SendChatMessage("Place me in a Raidus raid group slot before clicking Apply.", "SAY") end
	return tRaidByIndex, tRaidByName
end

local function getRaidusTargetAndState()
	local raidByIndex, raidByName = MultiBot.raidus.getRaidTarget()
	if not raidByIndex or not raidByName then
		return nil
	end

	local raidByMembers, raidByGroups = buildRaidusCurrentRosterState()
	return {
		raidByIndex = raidByIndex,
		raidByName = raidByName,
		raidByMembers = raidByMembers,
		raidByGroups = raidByGroups,
	}
end

local function findRaidusSwapCandidateIndex(raidByMembers, raidByName, expectedGroup)
	for memberName, memberData in pairs(raidByMembers) do
		if memberData.group == expectedGroup and raidByName[memberName] ~= expectedGroup then
			return memberData.index
		end
	end

	return nil
end

local function moveRaidusMemberToTargetGroup(memberData, expectedGroup, raidByGroups, raidByMembers, raidByName)
	if not memberData or memberData.group == expectedGroup then
		return false
	end

	local targetSize = raidByGroups[expectedGroup] or 0
	if targetSize < RAIDUS_GROUP_SLOT_COUNT then
		SetRaidSubgroup(memberData.index, expectedGroup)
		return true
	end

	local swapIndex = findRaidusSwapCandidateIndex(raidByMembers, raidByName, expectedGroup)
	if swapIndex then
		SwapRaidSubgroup(memberData.index, swapIndex)
		return true
	end

	return false
end

-- EVENTS --

MultiBot.raidus.doRaidSortCheck = function()
	local raidContext = getRaidusTargetAndState()
	if not raidContext then
		return nil
	end

	for targetName, targetGroup in pairs(raidContext.raidByName) do
		local memberData = raidContext.raidByMembers[targetName]
		if memberData and memberData.group ~= targetGroup then
			return 1
		end
	end

	return nil
end

MultiBot.raidus.doRaidSort = function(pIndex)
	local raidContext = getRaidusTargetAndState()
	if not raidContext then
		return nil
	end

	local targetEntry = raidContext.raidByIndex[pIndex]
	if not targetEntry then
		return nil
	end

	local memberData = raidContext.raidByMembers[targetEntry.name]
	moveRaidusMemberToTargetGroup(
		memberData,
		targetEntry.group,
		raidContext.raidByGroups,
		raidContext.raidByMembers,
		raidContext.raidByName
	)

	return pIndex + 1
end

MultiBot.raidus.doDrop = function(pObject, pParent, pX, pY, pWidth, pHeight, pSlot)
	local widget = pParent and pParent._widget
	local isGroupSlot = widget ~= nil
	pObject:ClearAllPoints()
	pObject:SetParent(pParent)
	pObject:SetPoint("TOPLEFT", pX, pY)
	pObject:SetSize(pWidth, pHeight)
	pObject.parent = pParent
	pObject.height = pHeight
	pObject.width = pWidth
	pObject.slot = pSlot
	pObject.x = pX
	pObject.y = pY
	if isGroupSlot then
		local dropSlot = widget._slots[pSlot]
		if dropSlot then
			dropSlot.name = pObject.name
			dropSlot.bot = pObject.bot
			dropSlot.botFrame = pObject
		end
		applyRaidusSlotTexture(pObject, true)
		applyRaidusSlotTextureInset(pObject)
	else
		pParent.frames[pSlot] = pObject
		applyRaidusSlotTexture(pObject, false)
		applyRaidusSlotTextureInset(pObject)
		setRaidusSlotRoleBorder(pObject, nil, 0.22)
	end
	doGroupScore(pParent)
	updateRaidusScore()
end

-- ---------------------------------------------------------------------------
--  AUTO BALANCE RAID
-- ---------------------------------------------------------------------------

-- Récupère la liste des bots candidats à l'auto-balance.
-- On prend d'abord les bots cochés dans MultiBar -> Units
-- Si aucun n'est coché, on prend tous les bots connus dans MultiBotGlobalSave
local function MultiBotRaidusCollectSelectedBots()
    local bots = {}

    local multiBar = MultiBot.frames and MultiBot.frames["MultiBar"]
    local unitsFrame = multiBar and multiBar.frames and multiBar.frames["Units"]
    local unitButtons = unitsFrame and unitsFrame.buttons

    local globalBots = getRaidusGlobalBotStore()

    if unitButtons then
        for name, button in pairs(unitButtons) do
            if button.state then
                appendRaidusBotIfValid(bots, name, globalBots[name])
            end
        end
    end

    -- Fallback : aucun bot sélectionné = on prend tout le monde
    if #bots == 0 then
        local accountRoster = MultiBot.bridge and MultiBot.bridge.accountRoster
        if accountRoster and #accountRoster > 0 then
            for _, entry in ipairs(accountRoster) do
                local bot = buildRaidusBotFromRosterEntry(entry)
                if bot then
                    table.insert(bots, bot)
                end
            end
        else
            for name, value in pairs(globalBots) do
                appendRaidusBotIfValid(bots, name, value)
            end
        end
    end

    return bots
end

-- Tri générique par score décroissant puis niveau décroissant
local function MultiBotRaidusSortByScore(list)
    table.sort(list, function(a, b)
        local sa = a.score or 0
        local sb = b.score or 0
        if sa ~= sb then
            return sa > sb
        end
        local la = a.level or 0
        local lb = b.level or 0
        return la > lb
    end)
end

local function createEmptyRaidusLayout()
    local layout = {}
    for groupIndex = 1, RAIDUS_GROUP_COUNT do
        layout[groupIndex] = {}
        for slotIndex = 1, RAIDUS_GROUP_SLOT_COUNT do
            layout[groupIndex][slotIndex] = "-"
        end
    end
    return layout
end

-- Auto balance :
--   mode == "score" : simple équilibrage par score
--   mode == "role"  : Tank / Heal / DPS
MultiBot.raidus.autoBalanceRaid = function(mode)
    -- On repart d'un état propre : pool reconstruite, groupes vidés
    if MultiBot.raidus.setRaidus then
        MultiBot.raidus.setRaidus()
    end

    local bots = MultiBotRaidusCollectSelectedBots()
    local botCount = #bots

    if botCount == 0 then
        SendChatMessage("Auto balance raid : No bots selectd", "SAY")
        return
    end

    local groupsUsed = math.min(RAIDUS_GROUP_COUNT, math.ceil(botCount / RAIDUS_GROUP_SLOT_COUNT))
    if groupsUsed <= 0 then
        return
    end

    -- Matrice [groupe][slot] initialisée à "-"
    local layout = createEmptyRaidusLayout()

    if mode == "role" then
        -- Mode avancé Tank / Heal / DPS
        local tanks = {}
        local heals = {}
        local dps = {}

        for _, bot in ipairs(bots) do
            local role = bot.role or MultiBotRaidusDetectRole(bot)
            if role == "Tank" then
                table.insert(tanks, bot)
            elseif role == "Heal" then
                table.insert(heals, bot)
            else
                table.insert(dps, bot)
            end
        end

        MultiBotRaidusSortByScore(tanks)
        MultiBotRaidusSortByScore(heals)
        MultiBotRaidusSortByScore(dps)

        local nextFreeSlot = {}
        for g = 1, groupsUsed do
            nextFreeSlot[g] = 1
        end

        local function placeListRoundRobin(list)
            local g = 1
            for _, bot in ipairs(list) do
                local tries = 0
                while tries < groupsUsed and nextFreeSlot[g] > RAIDUS_GROUP_SLOT_COUNT do
                    g = g + 1
                    if g > groupsUsed then
                        g = 1
                    end
                    tries = tries + 1
                end

                if nextFreeSlot[g] <= RAIDUS_GROUP_SLOT_COUNT then
                    layout[g][nextFreeSlot[g]] = bot.name
                    nextFreeSlot[g] = nextFreeSlot[g] + 1
                else
                    break
                end

                g = g + 1
                if g > groupsUsed then
                    g = 1
                end
            end
        end

        -- On commence par répartir les tanks, puis les heals, puis le reste
        placeListRoundRobin(tanks)
        placeListRoundRobin(heals)
        placeListRoundRobin(dps)
    else
        -- Mode score simple par défaut
        MultiBotRaidusSortByScore(bots)

        for index, bot in ipairs(bots) do
            local idx0 = index - 1
            local g = (idx0 % groupsUsed) + 1
            local s = math.floor(idx0 / groupsUsed) + 1
            if s <= RAIDUS_GROUP_SLOT_COUNT then
                layout[g][s] = bot.name
            end
        end
    end

     applyRaidusLayout(layout)
end

local function onRaidusRosterUpdate()
    requestMissingRaidusRosters()
    if MultiBot.raidus and MultiBot.raidus.IsShown and MultiBot.raidus.IsShown() and MultiBot.raidus.setRaidus then
        MultiBot.raidus.setRaidus()
    end
end

MultiBot.OnBridgeAccountRoster = onRaidusRosterUpdate
MultiBot.OnBridgeGuildRoster   = onRaidusRosterUpdate
MultiBot.OnBridgeFriendRoster  = onRaidusRosterUpdate