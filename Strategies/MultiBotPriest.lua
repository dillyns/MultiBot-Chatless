local MultiBot = _G.MultiBot
if not MultiBot then return end

local PRIEST_ROLE_HEAL      = "heal"
local PRIEST_ROLE_DPS       = "dps"
local PRIEST_ROLE_HOLY_DPS  = "holy dps"
local PRIEST_ROLE_HOLY_HEAL = "holy heal"

local PRIEST_ROLE_ICONS = {
	[PRIEST_ROLE_HEAL]      = "spell_holy_wordfortitude",
	[PRIEST_ROLE_DPS]       = "spell_shadow_shadowwordpain",
	[PRIEST_ROLE_HOLY_DPS]  = "spell_holy_searinglight",
	[PRIEST_ROLE_HOLY_HEAL] = "spell_holy_holybolt",
}

local PRIEST_STRAT_SHADOW_DEBUFF = "shadow debuff"
local PRIEST_STRAT_SHADOW_AOE    = "shadow aoe"
local PRIEST_STRAT_RSHADOW       = "rshadow"
local PRIEST_STRAT_HEALER_DPS    = "healer dps"

local PRIEST_STRAT_ICONS = {
	[PRIEST_STRAT_SHADOW_DEBUFF] = "spell_holy_stoicism",
	[PRIEST_STRAT_SHADOW_AOE]    = "spell_shadow_mindshear",
	[PRIEST_STRAT_RSHADOW]       = "spell_shadow_antishadow",
	[PRIEST_STRAT_HEALER_DPS]    = "spell_holy_holysmite",
}

local PLAYBOOK_BUTTONS = { PRIEST_ROLE_HEAL, PRIEST_ROLE_DPS, PRIEST_ROLE_HOLY_DPS, PRIEST_ROLE_HOLY_HEAL }

function MultiBot.addPriest(pFrame, pCombat, pNormal)
	MultiBot.AddNonCombatControl(pFrame, 0, pNormal)
	MultiBot.AddCombatControl(pFrame, -30, pCombat)

	-- PLAYBOOK --

	pFrame.addButton("Playbook", -60, 0, "inv_misc_book_06", MultiBot.L("tips.priest.playbook.master"))
	.doLeft = function(pButton)
		MultiBot.ShowHideSwitch(pButton.getFrame("Playbook"))
	end

	local tPlaybookFrame = pFrame.addFrame("Playbook", -62, 30)
	tPlaybookFrame:Hide()

	MultiBot.AddExclusiveButton(tPlaybookFrame, "Playbook", PRIEST_ROLE_HEAL,      0,  PRIEST_ROLE_ICONS[PRIEST_ROLE_HEAL],      MultiBot.L("tips.priest.playbook.heal"),     "co", PRIEST_ROLE_HEAL,      PLAYBOOK_BUTTONS)
	MultiBot.AddExclusiveButton(tPlaybookFrame, "Playbook", PRIEST_ROLE_DPS,       26, PRIEST_ROLE_ICONS[PRIEST_ROLE_DPS],       MultiBot.L("tips.priest.playbook.dps"),      "co", PRIEST_ROLE_DPS,       PLAYBOOK_BUTTONS)
	MultiBot.AddExclusiveButton(tPlaybookFrame, "Playbook", PRIEST_ROLE_HOLY_DPS,  52, PRIEST_ROLE_ICONS[PRIEST_ROLE_HOLY_DPS],  MultiBot.L("tips.priest.playbook.holydps"),  "co", PRIEST_ROLE_HOLY_DPS,  PLAYBOOK_BUTTONS)
	MultiBot.AddExclusiveButton(tPlaybookFrame, "Playbook", PRIEST_ROLE_HOLY_HEAL, 78, PRIEST_ROLE_ICONS[PRIEST_ROLE_HOLY_HEAL], MultiBot.L("tips.priest.playbook.holyheal"), "co", PRIEST_ROLE_HOLY_HEAL, PLAYBOOK_BUTTONS)

	-- PRIEST STRATEGIES --

	pFrame.addButton("PriestControl", -90, 0, "INV_Glyph_MajorPriest", MultiBot.L("tips.priest.strategy.master"))
	.doLeft = function(pButton)
		MultiBot.ShowHideSwitch(pButton.getFrame("PriestControlFrame"))
	end

	local tControlFrame = pFrame.addFrame("PriestControlFrame", -92, 30)
	tControlFrame:Hide()

	local shadowDebuffOn  = "co +" .. PRIEST_STRAT_SHADOW_DEBUFF
	local shadowDebuffOff = "co -" .. PRIEST_STRAT_SHADOW_DEBUFF
	tControlFrame.addButton("ShadowDebuff", 0, 0, PRIEST_STRAT_ICONS[PRIEST_STRAT_SHADOW_DEBUFF], MultiBot.L("tips.priest.strategy.shadowdebuff")).setDisable()
	.doLeft = function(pButton)
		MultiBot.OnOffActionToTarget(pButton, shadowDebuffOn, shadowDebuffOff, pButton.getName())
	end

	local shadowAoeOn  = "co +" .. PRIEST_STRAT_SHADOW_AOE
	local shadowAoeOff = "co -" .. PRIEST_STRAT_SHADOW_AOE
	tControlFrame.addButton("ShadowAoe", 0, 26, PRIEST_STRAT_ICONS[PRIEST_STRAT_SHADOW_AOE], MultiBot.L("tips.priest.strategy.shadowaoe")).setDisable()
	.doLeft = function(pButton)
		MultiBot.OnOffActionToTarget(pButton, shadowAoeOn, shadowAoeOff, pButton.getName())
	end

	local rshadowOn  = "co +" .. PRIEST_STRAT_RSHADOW
	local rshadowOff = "co -" .. PRIEST_STRAT_RSHADOW
	tControlFrame.addButton("RShadow", 0, 52, PRIEST_STRAT_ICONS[PRIEST_STRAT_RSHADOW], MultiBot.L("tips.priest.strategy.rshadow")).setDisable()
	.doLeft = function(pButton)
		MultiBot.OnOffActionToTarget(pButton, rshadowOn, rshadowOff, pButton.getName())
	end

	local healerDpsOn  = "co +" .. PRIEST_STRAT_HEALER_DPS
	local healerDpsOff = "co -" .. PRIEST_STRAT_HEALER_DPS
	tControlFrame.addButton("HealerDps", 0, 78, PRIEST_STRAT_ICONS[PRIEST_STRAT_HEALER_DPS], MultiBot.L("tips.priest.strategy.healerdps")).setDisable()
	.doLeft = function(pButton)
		MultiBot.OnOffActionToTarget(pButton, healerDpsOn, healerDpsOff, pButton.getName())
	end

	-- SET STRATS --

	-- Check most specific roles first to avoid substring false-matches ("heal" inside "holy heal", "dps" inside "holy dps")
	local role = nil
	if     MultiBot.isInside(pCombat, PRIEST_ROLE_HOLY_HEAL) then role = PRIEST_ROLE_HOLY_HEAL tPlaybookFrame.getButton(PRIEST_ROLE_HOLY_HEAL).setEnable()
	elseif MultiBot.isInside(pCombat, PRIEST_ROLE_HOLY_DPS)  then role = PRIEST_ROLE_HOLY_DPS  tPlaybookFrame.getButton(PRIEST_ROLE_HOLY_DPS).setEnable()
	elseif MultiBot.isInside(pCombat, PRIEST_ROLE_HEAL)      then role = PRIEST_ROLE_HEAL      tPlaybookFrame.getButton(PRIEST_ROLE_HEAL).setEnable()
	elseif MultiBot.isInside(pCombat, PRIEST_ROLE_DPS)       then role = PRIEST_ROLE_DPS       tPlaybookFrame.getButton(PRIEST_ROLE_DPS).setEnable()
	end
	if role then
		MultiBot.RestoreExclusiveGroup(pFrame, "Playbook", PRIEST_ROLE_ICONS[role], "co", role, PLAYBOOK_BUTTONS)
	end

	if MultiBot.isInside(pCombat, PRIEST_STRAT_SHADOW_DEBUFF) then tControlFrame.getButton("ShadowDebuff").setEnable() end
	if MultiBot.isInside(pCombat, PRIEST_STRAT_SHADOW_AOE)    then tControlFrame.getButton("ShadowAoe").setEnable() end
	if MultiBot.isInside(pCombat, PRIEST_STRAT_RSHADOW)       then tControlFrame.getButton("RShadow").setEnable() end
	if MultiBot.isInside(pCombat, PRIEST_STRAT_HEALER_DPS)    then tControlFrame.getButton("HealerDps").setEnable() end
end