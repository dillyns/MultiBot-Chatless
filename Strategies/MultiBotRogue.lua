local MultiBot = _G.MultiBot
if not MultiBot then return end

local ROGUE_ROLE_COMBAT       = "dps"
local ROGUE_ROLE_ASSASSINATION = "melee"

local ROGUE_ROLE_ICONS = {
	[ROGUE_ROLE_COMBAT]       = "ability_backstab",
	[ROGUE_ROLE_ASSASSINATION] = "ability_rogue_eviscerate",
}

local ROGUE_STRAT_STEALTH   = "stealth"
local ROGUE_STRAT_STEALTHED = "stealthed"

local ROGUE_STRAT_ICONS = {
	[ROGUE_STRAT_STEALTH]   = "ability_stealth",
	[ROGUE_STRAT_STEALTHED] = "ability_rogue_ambush",
}

local PLAYBOOK_BUTTONS = { ROGUE_ROLE_COMBAT, ROGUE_ROLE_ASSASSINATION }

function MultiBot.addRogue(pFrame, pCombat, pNormal)
	MultiBot.AddNonCombatControl(pFrame, 0, pNormal)
	MultiBot.AddCombatControl(pFrame, -30, pCombat)

	-- PLAYBOOK --

	pFrame.addButton("Playbook", -60, 0, "inv_misc_book_06", MultiBot.L("tips.rogue.playbook.master"))
	.doLeft = function(pButton)
		MultiBot.ShowHideSwitch(pButton.getFrame("Playbook"))
	end

	local tPlaybookFrame = pFrame.addFrame("Playbook", -62, 30)
	tPlaybookFrame:Hide()

	MultiBot.AddExclusiveButton(tPlaybookFrame, "Playbook", ROGUE_ROLE_COMBAT,       0,  ROGUE_ROLE_ICONS[ROGUE_ROLE_COMBAT],       MultiBot.L("tips.rogue.playbook.combat"),       "co", ROGUE_ROLE_COMBAT,       PLAYBOOK_BUTTONS)
	MultiBot.AddExclusiveButton(tPlaybookFrame, "Playbook", ROGUE_ROLE_ASSASSINATION, 26, ROGUE_ROLE_ICONS[ROGUE_ROLE_ASSASSINATION], MultiBot.L("tips.rogue.playbook.assassination"), "co", ROGUE_ROLE_ASSASSINATION, PLAYBOOK_BUTTONS)

	-- ROGUE STRATEGIES --

	pFrame.addButton("RogueControl", -90, 0, "INV_Glyph_MajorRogue", MultiBot.L("tips.rogue.strategy.master"))
	.doLeft = function(pButton)
		MultiBot.ShowHideSwitch(pButton.getFrame("RogueControlFrame"))
	end

	local tControlFrame = pFrame.addFrame("RogueControlFrame", -92, 30)
	tControlFrame:Hide()

	local stealthOn  = "co +" .. ROGUE_STRAT_STEALTH
	local stealthOff = "co -" .. ROGUE_STRAT_STEALTH
	tControlFrame.addButton("Stealth", 0, 0, ROGUE_STRAT_ICONS[ROGUE_STRAT_STEALTH], MultiBot.L("tips.rogue.strategy.stealth")).setDisable()
	.doLeft = function(pButton)
		MultiBot.OnOffActionToTarget(pButton, stealthOn, stealthOff, pButton.getName())
	end

	local stealthedOn  = "co +" .. ROGUE_STRAT_STEALTHED
	local stealthedOff = "co -" .. ROGUE_STRAT_STEALTHED
	tControlFrame.addButton("Stealthed", 0, 26, ROGUE_STRAT_ICONS[ROGUE_STRAT_STEALTHED], MultiBot.L("tips.rogue.strategy.stealthed")).setDisable()
	.doLeft = function(pButton)
		MultiBot.OnOffActionToTarget(pButton, stealthedOn, stealthedOff, pButton.getName())
	end

	-- SET STRATS --

	local role = nil
	if     MultiBot.isInside(pCombat, ROGUE_ROLE_COMBAT)       then role = ROGUE_ROLE_COMBAT       tPlaybookFrame.getButton(ROGUE_ROLE_COMBAT).setEnable()
	elseif MultiBot.isInside(pCombat, ROGUE_ROLE_ASSASSINATION) then role = ROGUE_ROLE_ASSASSINATION tPlaybookFrame.getButton(ROGUE_ROLE_ASSASSINATION).setEnable()
	end
	if role then
		MultiBot.RestoreExclusiveGroup(pFrame, "Playbook", ROGUE_ROLE_ICONS[role], "co", role, PLAYBOOK_BUTTONS)
	end

	if MultiBot.isInside(pNormal, ROGUE_STRAT_STEALTH)   then tControlFrame.getButton("Stealth").setEnable() end
	if MultiBot.isInside(pCombat, ROGUE_STRAT_STEALTHED) then tControlFrame.getButton("Stealthed").setEnable() end
end