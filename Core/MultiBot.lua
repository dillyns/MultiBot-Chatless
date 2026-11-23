local MultiBot = CreateFrame("Frame", nil, UIParent)
_G.MultiBot = MultiBot

MultiBot.BUTTON_SIZE = 36
MultiBot.INSET_BUTTON_SIZE = 32

MultiBot.IconState = {
	Default = "default",
	Active = "active",
	Inactive = "inactive",
}

function MultiBot.Debug(message)
	DEFAULT_CHAT_FRAME:AddMessage("[MultiBot] " .. message)
end

function MultiBot.GetTexture(path)
	if type(path) ~= "string" or path == "" then
		return "Interface\\Icons\\INV_Misc_QuestionMark"
	end

	local normalizedPath = path:gsub("/", "\\")
	return normalizedPath
end

function MultiBot.GetIcon(name)
	if type(name) ~= "string" or name == "" then
		return MultiBot.GetTexture(nil)
	end

	if name:find("\\", 1, true) or name:find("/", 1, true) then
		return MultiBot.GetTexture(name)
	end

	return MultiBot.GetTexture("Interface\\Icons\\" .. name)
end

local CLASS_ICONS = {
	[1] = "inv_sword_27",
	[2] = "ability_thunderbolt",
	[3] = "inv_weapon_bow_07",
	[4] = "inv_throwingknife_04",
	[5] = "inv_staff_30",
	[6] = "spell_deathknight_classicon",
	[7] = "spell_nature_bloodlust",
	[8] = "inv_staff_13",
	[9] = "spell_nature_drowsy",
	[11] = "ability_druid_maul",
}

function MultiBot.GetClassIcon(classId)
	return MultiBot.GetIcon(CLASS_ICONS[tonumber(classId)])
end

local CLASS_NAME_KEYS = {
	[1] = "class.warrior",
	[2] = "class.paladin",
	[3] = "class.hunter",
	[4] = "class.rogue",
	[5] = "class.priest",
	[6] = "class.deathknight",
	[7] = "class.shaman",
	[8] = "class.mage",
	[9] = "class.warlock",
	[11] = "class.druid",
}

function MultiBot.GetClassName(classId)
	local key = CLASS_NAME_KEYS[tonumber(classId)]
	if not key then
		return UNKNOWN
	end

	return MultiBot.Locale.GetString(key)
end

function MultiBot.CreateIconButton(parent, name, icon, onLeftClick, onRightClick, tooltipText)
	local button = CreateFrame("Button", name, parent)
	button:SetSize(MultiBot.BUTTON_SIZE, MultiBot.BUTTON_SIZE)
	button:RegisterForClicks("LeftButtonUp", "RightButtonUp")

	button.icon = button:CreateTexture(nil, "BACKGROUND")
	button.icon:SetTexture(MultiBot.GetIcon(icon))
	button.icon:SetAllPoints(button)

	button:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")
	button:SetPushedTexture("Interface\\Buttons\\UI-Quickslot-Depress")
	if onLeftClick or onRightClick then
		button:SetScript("OnClick", function(self, mouseButton)
			if mouseButton == "LeftButton" and onLeftClick then
				onLeftClick(self)
			elseif mouseButton == "RightButton" and onRightClick then
				onRightClick(self)
			end
		end)
	end
	if tooltipText then
		button:SetScript("OnEnter", function(self)
			GameTooltip:SetOwner(self, "ANCHOR_NONE")
			GameTooltip:ClearAllPoints()
			GameTooltip:SetPoint("TOPLEFT", self, "BOTTOMLEFT")
			GameTooltip:SetText(tooltipText)
			GameTooltip:Show()
		end)
		button:SetScript("OnLeave", function()
			GameTooltip:Hide()
		end)
	end

	return button
end

function MultiBot.CreateInsetIconButton(parent, name, icon, onLeftClick, onRightClick, tooltipText)
	local button = MultiBot.CreateIconButton(parent, name, icon, onLeftClick, onRightClick, tooltipText)
	button:SetSize(MultiBot.INSET_BUTTON_SIZE, MultiBot.INSET_BUTTON_SIZE)
	button.icon:ClearAllPoints()
	button.icon:SetPoint("CENTER", button, "CENTER", 0, 0)
	button.icon:SetSize(MultiBot.BUTTON_SIZE - 6, MultiBot.BUTTON_SIZE - 6)

	button.border = button:CreateTexture(nil, "ARTWORK")
	button.border:SetTexture(MultiBot.GetTexture("Interface\\AddOns\\MultiBot\\Icons\\border.blp"))
	button.border:SetPoint("CENTER", button, "CENTER", 0, 0)
	button.border:SetSize(MultiBot.INSET_BUTTON_SIZE, MultiBot.INSET_BUTTON_SIZE)
	button.border:Hide()

	function button:SetBorderShown(shown)
		if shown then
			self.border:Show()
		else
			self.border:Hide()
		end
	end

	function button:SetState(state)
		local inactive = state == MultiBot.IconState.Inactive
		self:SetBorderShown(state == MultiBot.IconState.Active)
		self.icon:SetDesaturated(inactive)
		if inactive then
			self.icon:SetVertexColor(0.45, 0.45, 0.45, 0.9)
		else
			self.icon:SetVertexColor(1, 1, 1, 1)
		end
	end
	button:SetState(MultiBot.IconState.Default)

	return button
end

MultiBot:SetPoint("BOTTOMRIGHT", 0, 0)
MultiBot:SetSize(1, 1)
MultiBot:Hide()
