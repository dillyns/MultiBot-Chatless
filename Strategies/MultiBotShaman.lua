local MultiBot = _G.MultiBot
if not MultiBot then return end

local SHAMAN_ROLE_ENH   = "enh"
local SHAMAN_ROLE_ELE   = "ele"
local SHAMAN_ROLE_RESTO = "resto"

local SHAMAN_ROLE_ICONS = {
	[SHAMAN_ROLE_ENH]   = "spell_nature_lightningshield",
	[SHAMAN_ROLE_ELE]   = "spell_nature_lightning",
	[SHAMAN_ROLE_RESTO] = "spell_nature_magicimmunity",
}

local SHAMAN_STRAT_HEALER_DPS = "healer dps"

local SHAMAN_STRAT_ICONS = {
	[SHAMAN_STRAT_HEALER_DPS] = "INV_Alchemy_Elixir_02",
}

local PLAYBOOK_BUTTONS = { SHAMAN_ROLE_ENH, SHAMAN_ROLE_ELE, SHAMAN_ROLE_RESTO }

function MultiBot.addShaman(pFrame, pCombat, pNormal)
	MultiBot.AddNonCombatControl(pFrame, 0, pNormal)
	MultiBot.AddCombatControl(pFrame, -30, pCombat)

	-- PLAYBOOK --

	pFrame.addButton("Playbook", -60, 0, "inv_misc_book_06", MultiBot.L("tips.shaman.playbook.master"))
	.doLeft = function(pButton)
		MultiBot.ShowHideSwitch(pButton.getFrame("Playbook"))
	end

	local tPlaybookFrame = pFrame.addFrame("Playbook", -62, 30)
	tPlaybookFrame:Hide()

	MultiBot.AddExclusiveButton(tPlaybookFrame, "Playbook", SHAMAN_ROLE_ENH,    0,  SHAMAN_ROLE_ICONS[SHAMAN_ROLE_ENH],   MultiBot.L("tips.shaman.playbook.enh"),   "co", SHAMAN_ROLE_ENH,   PLAYBOOK_BUTTONS)
	MultiBot.AddExclusiveButton(tPlaybookFrame, "Playbook", SHAMAN_ROLE_ELE,   26,  SHAMAN_ROLE_ICONS[SHAMAN_ROLE_ELE],   MultiBot.L("tips.shaman.playbook.ele"),   "co", SHAMAN_ROLE_ELE,   PLAYBOOK_BUTTONS)
	MultiBot.AddExclusiveButton(tPlaybookFrame, "Playbook", SHAMAN_ROLE_RESTO, 52,  SHAMAN_ROLE_ICONS[SHAMAN_ROLE_RESTO], MultiBot.L("tips.shaman.playbook.resto"), "co", SHAMAN_ROLE_RESTO, PLAYBOOK_BUTTONS)

	-- SHAMAN STRATEGIES --

	pFrame.addButton("ShamanControl", -90, 0, "INV_Glyph_MajorShaman", MultiBot.L("tips.shaman.strategy.master"))
	.doLeft = function(pButton)
		MultiBot.ShowHideSwitch(pButton.getFrame("ShamanControlFrame"))
	end

	local tControlFrame = pFrame.addFrame("ShamanControlFrame", -92, 30)
	tControlFrame:Hide()

	local healerDpsOn  = "co +" .. SHAMAN_STRAT_HEALER_DPS
	local healerDpsOff = "co -" .. SHAMAN_STRAT_HEALER_DPS
	tControlFrame.addButton("HealerDps", 0, 0, SHAMAN_STRAT_ICONS[SHAMAN_STRAT_HEALER_DPS], MultiBot.L("tips.shaman.strategy.healerdps")).setDisable()
	.doLeft = function(pButton)
		MultiBot.OnOffActionToTarget(pButton, healerDpsOn, healerDpsOff, pButton.getName())
	end

	-- SET STRATS --

	local role = nil
	if     MultiBot.isInside(pCombat, SHAMAN_ROLE_ENH)   then role = SHAMAN_ROLE_ENH   tPlaybookFrame.getButton(SHAMAN_ROLE_ENH).setEnable()
	elseif MultiBot.isInside(pCombat, SHAMAN_ROLE_ELE)   then role = SHAMAN_ROLE_ELE   tPlaybookFrame.getButton(SHAMAN_ROLE_ELE).setEnable()
	elseif MultiBot.isInside(pCombat, SHAMAN_ROLE_RESTO) then role = SHAMAN_ROLE_RESTO tPlaybookFrame.getButton(SHAMAN_ROLE_RESTO).setEnable()
	end
	if role then
		MultiBot.RestoreExclusiveGroup(pFrame, "Playbook", SHAMAN_ROLE_ICONS[role], "co", role, PLAYBOOK_BUTTONS)
	end

	if MultiBot.isInside(pCombat, SHAMAN_STRAT_HEALER_DPS) then tControlFrame.getButton("HealerDps").setEnable() end
end