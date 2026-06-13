local MultiBot = _G.MultiBot
if not MultiBot then return end

local MAGE_SPEC_FROST     = "frost"
local MAGE_SPEC_FIRE      = "fire"
local MAGE_SPEC_FROSTFIRE = "frostfire"
local MAGE_SPEC_ARCANE    = "arcane"

local MAGE_SPEC_ICONS = {
	[MAGE_SPEC_FROST]     = "spell_frost_frostbolt02",
	[MAGE_SPEC_FIRE]      = "spell_fire_flamebolt",
	[MAGE_SPEC_FROSTFIRE] = "ability_mage_frostfirebolt",
	[MAGE_SPEC_ARCANE]    = "spell_holy_magicalsentry",
}

local MAGE_STRAT_FIRESTARTER = "firestarter"

local MAGE_STRAT_ICONS = {
	[MAGE_STRAT_FIRESTARTER] = "ability_mage_firestarter",
}

local MAGE_BUFF_BMANA = "bmana"
local MAGE_BUFF_BDPS  = "bdps"

local MAGE_BUFF_ICONS = {
	[MAGE_BUFF_BMANA] = "spell_magearmor",
	[MAGE_BUFF_BDPS]  = "ability_mage_moltenarmor",
}

local PLAYBOOK_BUTTONS = { MAGE_SPEC_ARCANE, MAGE_SPEC_FROST, MAGE_SPEC_FIRE, MAGE_SPEC_FROSTFIRE }
local BUFF_BUTTONS     = { MAGE_BUFF_BMANA, MAGE_BUFF_BDPS }

function MultiBot.addMage(pFrame, pCombat, pNormal)
	MultiBot.AddNonCombatControl(pFrame, 0, pNormal)
	MultiBot.AddCombatControl(pFrame, -30, pCombat)

	-- PLAYBOOK --

	pFrame.addButton("Playbook", -60, 0, "inv_misc_book_06", MultiBot.L("tips.mage.playbook.master"))
	.doLeft = function(pButton)
		MultiBot.ShowHideSwitch(pButton.getFrame("Playbook"))
	end

	local tPlaybookFrame = pFrame.addFrame("Playbook", -62, 30)
	tPlaybookFrame:Hide()

	MultiBot.AddExclusiveButton(tPlaybookFrame, "Playbook", MAGE_SPEC_ARCANE,     0,  MAGE_SPEC_ICONS[MAGE_SPEC_ARCANE],    MultiBot.L("tips.mage.playbook.arcane"),    "co", MAGE_SPEC_ARCANE,    PLAYBOOK_BUTTONS)
	MultiBot.AddExclusiveButton(tPlaybookFrame, "Playbook", MAGE_SPEC_FROST,     26,  MAGE_SPEC_ICONS[MAGE_SPEC_FROST],     MultiBot.L("tips.mage.playbook.frost"),     "co", MAGE_SPEC_FROST,     PLAYBOOK_BUTTONS)
	MultiBot.AddExclusiveButton(tPlaybookFrame, "Playbook", MAGE_SPEC_FIRE,      52,  MAGE_SPEC_ICONS[MAGE_SPEC_FIRE],      MultiBot.L("tips.mage.playbook.fire"),      "co", MAGE_SPEC_FIRE,      PLAYBOOK_BUTTONS)
	MultiBot.AddExclusiveButton(tPlaybookFrame, "Playbook", MAGE_SPEC_FROSTFIRE, 78,  MAGE_SPEC_ICONS[MAGE_SPEC_FROSTFIRE], MultiBot.L("tips.mage.playbook.frostfire"), "co", MAGE_SPEC_FROSTFIRE, PLAYBOOK_BUTTONS)

	-- MAGE STRATEGIES --

	pFrame.addButton("MageControl", -90, 0, "INV_Glyph_MajorMage", MultiBot.L("tips.mage.strategy.master"))
	.doLeft = function(pButton)
		MultiBot.ShowHideSwitch(pButton.getFrame("MageControlFrame"))
	end

	local tControlFrame = pFrame.addFrame("MageControlFrame", -92, 30)
	tControlFrame:Hide()

	local firestarteron  = "co +" .. MAGE_STRAT_FIRESTARTER
	local firestarteroff = "co -" .. MAGE_STRAT_FIRESTARTER
	tControlFrame.addButton(MAGE_STRAT_FIRESTARTER, 0, 0, MAGE_STRAT_ICONS[MAGE_STRAT_FIRESTARTER], MultiBot.L("tips.mage.strategy.firestarter")).setDisable()
	.doLeft = function(pButton)
		MultiBot.OnOffActionToTarget(pButton, firestarteron, firestarteroff, pButton.getName())
	end

	-- BUFFS --

	pFrame.addButton("MageBuffControl", -120, 0, MAGE_BUFF_ICONS[MAGE_BUFF_BDPS], MultiBot.L("tips.mage.buff.master"))
	.doLeft = function(pButton)
		MultiBot.ShowHideSwitch(pButton.getFrame("MageBuffControlFrame"))
	end

	local tBuffFrame = pFrame.addFrame("MageBuffControlFrame", -122, 30)
	tBuffFrame:Hide()

	MultiBot.AddExclusiveButton(tBuffFrame, "MageBuffControl", MAGE_BUFF_BMANA,  0,  MAGE_BUFF_ICONS[MAGE_BUFF_BMANA], MultiBot.L("tips.mage.buff.bmana"), "nc", MAGE_BUFF_BMANA, BUFF_BUTTONS)
	MultiBot.AddExclusiveButton(tBuffFrame, "MageBuffControl", MAGE_BUFF_BDPS,  26,  MAGE_BUFF_ICONS[MAGE_BUFF_BDPS],  MultiBot.L("tips.mage.buff.bdps"),  "nc", MAGE_BUFF_BDPS,  BUFF_BUTTONS)

	-- SET STRATS --

	local spec = nil
	if     MultiBot.isInside(pCombat, MAGE_SPEC_ARCANE)    then spec = MAGE_SPEC_ARCANE    tPlaybookFrame.getButton(MAGE_SPEC_ARCANE).setEnable()
	elseif MultiBot.isInside(pCombat, MAGE_SPEC_FROSTFIRE) then spec = MAGE_SPEC_FROSTFIRE tPlaybookFrame.getButton(MAGE_SPEC_FROSTFIRE).setEnable()
	elseif MultiBot.isInside(pCombat, MAGE_SPEC_FROST)     then spec = MAGE_SPEC_FROST     tPlaybookFrame.getButton(MAGE_SPEC_FROST).setEnable()
	elseif MultiBot.isInside(pCombat, MAGE_SPEC_FIRE)      then spec = MAGE_SPEC_FIRE      tPlaybookFrame.getButton(MAGE_SPEC_FIRE).setEnable()
	end
	if spec then
		MultiBot.RestoreExclusiveGroup(pFrame, "Playbook", MAGE_SPEC_ICONS[spec], "co", spec, PLAYBOOK_BUTTONS)
	end

	-- Buff state --
	local buff = nil
	if     MultiBot.isInside(pNormal, MAGE_BUFF_BMANA) then buff = MAGE_BUFF_BMANA tBuffFrame.getButton(MAGE_BUFF_BMANA).setEnable()
	elseif MultiBot.isInside(pNormal, MAGE_BUFF_BDPS)  then buff = MAGE_BUFF_BDPS  tBuffFrame.getButton(MAGE_BUFF_BDPS).setEnable()
	end
	if buff then
		MultiBot.RestoreExclusiveGroup(pFrame, "MageBuffControl", MAGE_BUFF_ICONS[buff], "nc", buff, BUFF_BUTTONS)
	end

	if MultiBot.isInside(pCombat, MAGE_STRAT_FIRESTARTER) then tControlFrame.getButton(MAGE_STRAT_FIRESTARTER).setEnable() end
end