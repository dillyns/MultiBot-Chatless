local MultiBot = _G.MultiBot
if not MultiBot then return end

local DRUID_ROLE_RESTO   = "resto"
local DRUID_ROLE_BALANCE = "balance"
local DRUID_ROLE_CAT     = "cat"
local DRUID_ROLE_BEAR    = "bear"

local DRUID_PLAYBOOK_DEFAULT_ICON = "inv_misc_book_06"
local DRUID_ROLE_ICONS = {
	[DRUID_ROLE_RESTO]   = "spell_nature_healingtouch",
	[DRUID_ROLE_BALANCE] = "spell_nature_starfall",
	[DRUID_ROLE_CAT]     = "ability_druid_catform",
	[DRUID_ROLE_BEAR]    = "ability_racial_bearform",
}

local DRUID_STRAT_HEALER_DPS   = "healer dps"
local DRUID_STRAT_BLANKETING   = "blanketing"
local DRUID_STRAT_TRANQUILITY  = "tranquility"
local DRUID_STRAT_FERAL_CHARGE = "feral charge"
local DRUID_STRAT_OFFHEAL      = "offheal"

local DRUID_STRAT_ICONS = {
	[DRUID_STRAT_HEALER_DPS]   = "spell_nature_abolishmagic",
	[DRUID_STRAT_BLANKETING]   = "spell_nature_rejuvenation",
	[DRUID_STRAT_TRANQUILITY]  = "spell_nature_tranquility",
	[DRUID_STRAT_FERAL_CHARGE] = "Spell_Druid_feralchargecat",
	[DRUID_STRAT_OFFHEAL]      = "spell_nature_resistnature",
}

local function setPlaybookIcon(pButton, role)
	local btn = pButton.getButton("Playbook")
	if not btn then return end
	local icon = (role and DRUID_ROLE_ICONS[role]) or DRUID_PLAYBOOK_DEFAULT_ICON
	if btn.setTexture then btn.setTexture(icon) end
end

local PLAYBOOK_BUTTONS = { "Resto", "Caster", "Cat", "Bear" }

local function addPlaybookButton(tFrame, name, x, y, icon, tipKey, role)
	tFrame.addButton(name, x, y, icon, MultiBot.L(tipKey)).setDisable()
	.doLeft = function(pButton)
		if MultiBot.OnOffActionToTarget(pButton, "co +" .. role, "co -" .. role, pButton.getName()) then
			setPlaybookIcon(pButton, role)
			for _, other in ipairs(PLAYBOOK_BUTTONS) do
				if other ~= name then pButton.getButton(other).setDisable() end
			end
		else
			setPlaybookIcon(pButton, nil)
		end
	end
end

MultiBot.addDruid = function(pFrame, pCombat, pNormal)

	MultiBot.AddNonCombatControl(pFrame, 0, pNormal)
	MultiBot.AddCombatControl(pFrame, -30, pCombat)

	-- PLAYBOOK --

	pFrame.addButton("Playbook", -60, 0, "inv_misc_book_06", MultiBot.L("tips.druid.playbook.master"))
	.doLeft = function(pButton)
		MultiBot.ShowHideSwitch(pButton.getFrame("Playbook"))
	end

	local tFrame = pFrame.addFrame("Playbook", -62, 30)
	tFrame:Hide()

	addPlaybookButton(tFrame, "Resto",  0,  0, DRUID_ROLE_ICONS[DRUID_ROLE_RESTO],   "tips.druid.playbook.resto",  DRUID_ROLE_RESTO)
	addPlaybookButton(tFrame, "Caster", 0, 26, DRUID_ROLE_ICONS[DRUID_ROLE_BALANCE], "tips.druid.playbook.caster", DRUID_ROLE_BALANCE)
	addPlaybookButton(tFrame, "Cat",    0, 52, DRUID_ROLE_ICONS[DRUID_ROLE_CAT],     "tips.druid.playbook.cat",    DRUID_ROLE_CAT)
	addPlaybookButton(tFrame, "Bear",   0, 78, DRUID_ROLE_ICONS[DRUID_ROLE_BEAR],    "tips.druid.playbook.bear",   DRUID_ROLE_BEAR)

	-- DRUID STRATEGIES --

	pFrame.addButton("DruidControl", -90, 0, "INV_Glyph_MajorDruid", MultiBot.L("tips.druid.strategy.master"))
	.doLeft = function(pButton)
		MultiBot.ShowHideSwitch(pButton.getFrame("DruidControlFrame"))
	end

	local tControlFrame = pFrame.addFrame("DruidControlFrame", -92, 30)
	tControlFrame:Hide()

	tControlFrame.addButton("HealerDps",  0,  0,  DRUID_STRAT_ICONS[DRUID_STRAT_HEALER_DPS],   MultiBot.L("tips.druid.strategy.healerdps")).setDisable()
	.doLeft = function(pButton)
		MultiBot.OnOffActionToTarget(pButton, "co +" .. DRUID_STRAT_HEALER_DPS, "co -" .. DRUID_STRAT_HEALER_DPS, pButton.getName())
	end

	tControlFrame.addButton("Blanketing", 0, 26,  DRUID_STRAT_ICONS[DRUID_STRAT_BLANKETING],   MultiBot.L("tips.druid.strategy.blanketing")).setDisable()
	.doLeft = function(pButton)
		MultiBot.OnOffActionToTarget(pButton, "co +" .. DRUID_STRAT_BLANKETING, "co -" .. DRUID_STRAT_BLANKETING, pButton.getName())
	end

	tControlFrame.addButton("Tranquility", 0, 52, DRUID_STRAT_ICONS[DRUID_STRAT_TRANQUILITY],  MultiBot.L("tips.druid.strategy.tranquility")).setDisable()
	.doLeft = function(pButton)
		MultiBot.OnOffActionToTarget(pButton, "co +" .. DRUID_STRAT_TRANQUILITY, "co -" .. DRUID_STRAT_TRANQUILITY, pButton.getName())
	end

	tControlFrame.addButton("FeralCharge", 0, 78, DRUID_STRAT_ICONS[DRUID_STRAT_FERAL_CHARGE], MultiBot.L("tips.druid.strategy.feralCharge")).setDisable()
	.doLeft = function(pButton)
		MultiBot.OnOffActionToTarget(pButton, "co +" .. DRUID_STRAT_FERAL_CHARGE, "co -" .. DRUID_STRAT_FERAL_CHARGE, pButton.getName())
	end

	tControlFrame.addButton("OffHeal",    0, 104, DRUID_STRAT_ICONS[DRUID_STRAT_OFFHEAL],      MultiBot.L("tips.druid.strategy.offheal")).setDisable()
	.doLeft = function(pButton)
		MultiBot.OnOffActionToTarget(pButton, "co +" .. DRUID_STRAT_OFFHEAL, "co -" .. DRUID_STRAT_OFFHEAL, pButton.getName())
	end

	-- SET STRATS --

	local _role = nil
	if     MultiBot.isInside(pCombat, DRUID_ROLE_RESTO)   then _role = DRUID_ROLE_RESTO   pFrame.getButton("Resto").setEnable()
	elseif MultiBot.isInside(pCombat, DRUID_ROLE_BALANCE) then _role = DRUID_ROLE_BALANCE pFrame.getButton("Caster").setEnable()
	elseif MultiBot.isInside(pCombat, DRUID_ROLE_CAT)     then _role = DRUID_ROLE_CAT     pFrame.getButton("Cat").setEnable()
	elseif MultiBot.isInside(pCombat, DRUID_ROLE_BEAR)    then _role = DRUID_ROLE_BEAR    pFrame.getButton("Bear").setEnable()
	end
	setPlaybookIcon(pFrame, _role)

	if(MultiBot.isInside(pCombat, DRUID_STRAT_HEALER_DPS)) then pFrame.getButton("HealerDps").setEnable() end
	if(MultiBot.isInside(pCombat, DRUID_STRAT_BLANKETING)) then pFrame.getButton("Blanketing").setEnable() end
	if(MultiBot.isInside(pCombat, DRUID_STRAT_TRANQUILITY)) then pFrame.getButton("Tranquility").setEnable() end
	if(MultiBot.isInside(pCombat, DRUID_STRAT_FERAL_CHARGE)) then pFrame.getButton("FeralCharge").setEnable() end
	if(MultiBot.isInside(pCombat, DRUID_STRAT_OFFHEAL)) then pFrame.getButton("OffHeal").setEnable() end
end