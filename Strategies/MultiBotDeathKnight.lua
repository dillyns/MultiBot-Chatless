local MultiBot = _G.MultiBot
if not MultiBot then return end

local DK_PRESENCE_BLOOD  = "blood"
local DK_PRESENCE_FROST  = "frost"
local DK_PRESENCE_UNHOLY = "unholy"

local DK_PLAYBOOK_ICONS = {
	[DK_PRESENCE_BLOOD]  = "spell_deathknight_bloodpresence",
	[DK_PRESENCE_FROST]  = "spell_deathknight_frostpresence",
	[DK_PRESENCE_UNHOLY] = "spell_deathknight_unholypresence",
}

local DK_STRAT_FROST_AOE  = "frost aoe"
local DK_STRAT_UNHOLY_AOE = "unholy aoe"

local DK_STRAT_ICONS = {
	[DK_STRAT_FROST_AOE]  = "spell_frost_arcticwinds",
	[DK_STRAT_UNHOLY_AOE] = "spell_shadow_plaguecloud",
}

local PLAYBOOK_BUTTONS = { DK_PRESENCE_BLOOD, DK_PRESENCE_FROST, DK_PRESENCE_UNHOLY }

function MultiBot.addDeathKnight(pFrame, pCombat, pNormal)
	MultiBot.AddNonCombatControl(pFrame, 0, pNormal)
	MultiBot.AddCombatControl(pFrame, -30, pCombat)

	-- PLAYBOOK --

	pFrame.addButton("Playbook", -60, 0, DK_PLAYBOOK_ICONS[DK_PRESENCE_BLOOD], MultiBot.L("tips.deathknight.playbook.master"))
	.doLeft = function(pButton)
		MultiBot.ShowHideSwitch(pButton.getFrame("Playbook"))
	end

	local tPlaybookFrame = pFrame.addFrame("Playbook", -62, 30)
	tPlaybookFrame:Hide()

	MultiBot.AddExclusiveButton(tPlaybookFrame, "Playbook", DK_PRESENCE_BLOOD,    0,  DK_PLAYBOOK_ICONS[DK_PRESENCE_BLOOD],  MultiBot.L("tips.deathknight.playbook.blood"),  "co", DK_PRESENCE_BLOOD,  PLAYBOOK_BUTTONS)
	MultiBot.AddExclusiveButton(tPlaybookFrame, "Playbook", DK_PRESENCE_FROST,   26,  DK_PLAYBOOK_ICONS[DK_PRESENCE_FROST],  MultiBot.L("tips.deathknight.playbook.frost"),  "co", DK_PRESENCE_FROST,  PLAYBOOK_BUTTONS)
	MultiBot.AddExclusiveButton(tPlaybookFrame, "Playbook", DK_PRESENCE_UNHOLY,  52,  DK_PLAYBOOK_ICONS[DK_PRESENCE_UNHOLY], MultiBot.L("tips.deathknight.playbook.unholy"), "co", DK_PRESENCE_UNHOLY, PLAYBOOK_BUTTONS)

	-- DK STRATEGIES --

	pFrame.addButton("DkControl", -90, 0, "INV_Glyph_MajorDeathKnight", MultiBot.L("tips.deathknight.strategy.master"))
	.doLeft = function(pButton)
		MultiBot.ShowHideSwitch(pButton.getFrame("DkControlFrame"))
	end

	local tControlFrame = pFrame.addFrame("DkControlFrame", -92, 30)
	tControlFrame:Hide()

	local frostaoeOn  = "co +" .. DK_STRAT_FROST_AOE
	local frostaoeOff = "co -" .. DK_STRAT_FROST_AOE
	tControlFrame.addButton("FrostAoe",  0,  0, DK_STRAT_ICONS[DK_STRAT_FROST_AOE],  MultiBot.L("tips.deathknight.strategy.frostAoe")).setDisable()
	.doLeft = function(pButton)
		MultiBot.OnOffActionToTarget(pButton, frostaoeOn, frostaoeOff, pButton.getName())
	end

	local unholyadoeOn  = "co +" .. DK_STRAT_UNHOLY_AOE
	local unholyadoeOff = "co -" .. DK_STRAT_UNHOLY_AOE
	tControlFrame.addButton("UnholyAoe", 0, 26, DK_STRAT_ICONS[DK_STRAT_UNHOLY_AOE], MultiBot.L("tips.deathknight.strategy.unholyAoe")).setDisable()
	.doLeft = function(pButton)
		MultiBot.OnOffActionToTarget(pButton, unholyadoeOn, unholyadoeOff, pButton.getName())
	end

	-- SET STRATS --

	local playbook = nil
	if     MultiBot.isInside(pCombat, DK_PRESENCE_BLOOD)  then playbook = DK_PRESENCE_BLOOD  tPlaybookFrame.getButton(DK_PRESENCE_BLOOD).setEnable()
	elseif MultiBot.isInside(pCombat, DK_PRESENCE_FROST)  then playbook = DK_PRESENCE_FROST  tPlaybookFrame.getButton(DK_PRESENCE_FROST).setEnable()
	elseif MultiBot.isInside(pCombat, DK_PRESENCE_UNHOLY) then playbook = DK_PRESENCE_UNHOLY tPlaybookFrame.getButton(DK_PRESENCE_UNHOLY).setEnable()
	end
	if playbook then
		MultiBot.RestoreExclusiveGroup(pFrame, "Playbook", DK_PLAYBOOK_ICONS[playbook], "co", playbook, PLAYBOOK_BUTTONS)
	end

	if MultiBot.isInside(pCombat, DK_STRAT_FROST_AOE)  then tControlFrame.getButton("FrostAoe").setEnable()  end
	if MultiBot.isInside(pCombat, DK_STRAT_UNHOLY_AOE) then tControlFrame.getButton("UnholyAoe").setEnable() end
end