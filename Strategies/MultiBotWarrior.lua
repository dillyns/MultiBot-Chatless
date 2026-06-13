local MultiBot = _G.MultiBot
if not MultiBot then return end

local WARRIOR_ROLE_TANK = "tank"
local WARRIOR_ROLE_ARMS = "arms"
local WARRIOR_ROLE_FURY = "fury"

local WARRIOR_ROLE_ICONS = {
	[WARRIOR_ROLE_TANK] = "ability_warrior_shieldmastery",
	[WARRIOR_ROLE_ARMS] = "ability_warrior_savageblow",
	[WARRIOR_ROLE_FURY] = "ability_warrior_innerrage",
}

local PLAYBOOK_BUTTONS = { WARRIOR_ROLE_TANK, WARRIOR_ROLE_ARMS, WARRIOR_ROLE_FURY }

function MultiBot.addWarrior(pFrame, pCombat, pNormal)
	MultiBot.AddNonCombatControl(pFrame, 0, pNormal)
	MultiBot.AddCombatControl(pFrame, -30, pCombat)

	-- PLAYBOOK --

	pFrame.addButton("Playbook", -60, 0, "inv_misc_book_06", MultiBot.L("tips.warrior.playbook.master"))
	.doLeft = function(pButton)
		MultiBot.ShowHideSwitch(pButton.getFrame("Playbook"))
	end

	local tPlaybookFrame = pFrame.addFrame("Playbook", -62, 30)
	tPlaybookFrame:Hide()

	MultiBot.AddExclusiveButton(tPlaybookFrame, "Playbook", WARRIOR_ROLE_TANK,  0,  WARRIOR_ROLE_ICONS[WARRIOR_ROLE_TANK], MultiBot.L("tips.warrior.playbook.tank"), "co", WARRIOR_ROLE_TANK, PLAYBOOK_BUTTONS)
	MultiBot.AddExclusiveButton(tPlaybookFrame, "Playbook", WARRIOR_ROLE_ARMS, 26,  WARRIOR_ROLE_ICONS[WARRIOR_ROLE_ARMS], MultiBot.L("tips.warrior.playbook.arms"), "co", WARRIOR_ROLE_ARMS, PLAYBOOK_BUTTONS)
	MultiBot.AddExclusiveButton(tPlaybookFrame, "Playbook", WARRIOR_ROLE_FURY, 52,  WARRIOR_ROLE_ICONS[WARRIOR_ROLE_FURY], MultiBot.L("tips.warrior.playbook.fury"), "co", WARRIOR_ROLE_FURY, PLAYBOOK_BUTTONS)

	-- SET STRATS --

	local role = nil
	if     MultiBot.isInside(pCombat, WARRIOR_ROLE_TANK) then role = WARRIOR_ROLE_TANK tPlaybookFrame.getButton(WARRIOR_ROLE_TANK).setEnable()
	elseif MultiBot.isInside(pCombat, WARRIOR_ROLE_ARMS) then role = WARRIOR_ROLE_ARMS tPlaybookFrame.getButton(WARRIOR_ROLE_ARMS).setEnable()
	elseif MultiBot.isInside(pCombat, WARRIOR_ROLE_FURY) then role = WARRIOR_ROLE_FURY tPlaybookFrame.getButton(WARRIOR_ROLE_FURY).setEnable()
	end
	if role then
		MultiBot.RestoreExclusiveGroup(pFrame, "Playbook", WARRIOR_ROLE_ICONS[role], "co", role, PLAYBOOK_BUTTONS)
	end
end