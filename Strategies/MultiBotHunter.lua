local MultiBot = _G.MultiBot
if not MultiBot then return end

local HUNTER_SPEC_BM   = "bm"
local HUNTER_SPEC_MM   = "mm"
local HUNTER_SPEC_SURV = "surv"

local HUNTER_SPEC_ICONS = {
	[HUNTER_SPEC_BM]   = "ability_hunter_beasttaming",
	[HUNTER_SPEC_MM]   = "ability_marksmanship",
	[HUNTER_SPEC_SURV] = "ability_hunter_swiftstrike",
}

local HUNTER_STRAT_TRAP_WEAVE = "trap weave"

local HUNTER_STRAT_ICONS = {
	[HUNTER_STRAT_TRAP_WEAVE] = "ability_ensnare",
}

local HUNTER_BUFF_BSPEED  = "bspeed"
local HUNTER_BUFF_BDPS    = "bdps"
local HUNTER_BUFF_RNATURE = "rnature"

local HUNTER_BUFF_ICONS = {
	[HUNTER_BUFF_BSPEED]  = "ability_mount_whitetiger",
	[HUNTER_BUFF_BDPS]    = "ability_hunter_pet_dragonhawk",
	[HUNTER_BUFF_RNATURE] = "spell_nature_protectionformnature",
}

local PLAYBOOK_BUTTONS = { HUNTER_SPEC_BM, HUNTER_SPEC_MM, HUNTER_SPEC_SURV }
local BUFF_BUTTONS     = { HUNTER_BUFF_BSPEED, HUNTER_BUFF_BDPS, HUNTER_BUFF_RNATURE }

function MultiBot.addHunter(pFrame, pCombat, pNormal)
	MultiBot.AddNonCombatControl(pFrame, 0, pNormal)
	MultiBot.AddCombatControl(pFrame, -30, pCombat)

	-- PLAYBOOK --

	pFrame.addButton("Playbook", -60, 0, "inv_misc_book_06", MultiBot.L("tips.hunter.playbook.master"))
	.doLeft = function(pButton)
		MultiBot.ShowHideSwitch(pButton.getFrame("Playbook"))
	end

	local tPlaybookFrame = pFrame.addFrame("Playbook", -62, 30)
	tPlaybookFrame:Hide()

	MultiBot.AddExclusiveButton(tPlaybookFrame, "Playbook", HUNTER_SPEC_BM,    0,  HUNTER_SPEC_ICONS[HUNTER_SPEC_BM],   MultiBot.L("tips.hunter.playbook.bm"),   "co", HUNTER_SPEC_BM,   PLAYBOOK_BUTTONS)
	MultiBot.AddExclusiveButton(tPlaybookFrame, "Playbook", HUNTER_SPEC_MM,   26,  HUNTER_SPEC_ICONS[HUNTER_SPEC_MM],   MultiBot.L("tips.hunter.playbook.mm"),   "co", HUNTER_SPEC_MM,   PLAYBOOK_BUTTONS)
	MultiBot.AddExclusiveButton(tPlaybookFrame, "Playbook", HUNTER_SPEC_SURV, 52,  HUNTER_SPEC_ICONS[HUNTER_SPEC_SURV], MultiBot.L("tips.hunter.playbook.surv"), "co", HUNTER_SPEC_SURV, PLAYBOOK_BUTTONS)

	-- HUNTER STRATEGIES --

	pFrame.addButton("HunterControl", -90, 0, "INV_Glyph_MajorHunter", MultiBot.L("tips.hunter.strategy.master"))
	.doLeft = function(pButton)
		MultiBot.ShowHideSwitch(pButton.getFrame("HunterControlFrame"))
	end

	local tControlFrame = pFrame.addFrame("HunterControlFrame", -92, 30)
	tControlFrame:Hide()

	local trapweaveon  = "co +" .. HUNTER_STRAT_TRAP_WEAVE
	local trapweaveoff = "co -" .. HUNTER_STRAT_TRAP_WEAVE
	tControlFrame.addButton("TrapWeave", 0, 0, HUNTER_STRAT_ICONS[HUNTER_STRAT_TRAP_WEAVE], MultiBot.L("tips.hunter.strategy.trapweave")).setDisable()
	.doLeft = function(pButton)
		MultiBot.OnOffActionToTarget(pButton, trapweaveon, trapweaveoff, pButton.getName())
	end

	-- BUFFS --

	pFrame.addButton("HunterBuffControl", -120, 0, HUNTER_BUFF_ICONS[HUNTER_BUFF_BDPS], MultiBot.L("tips.hunter.buff.master"))
	.doLeft = function(pButton)
		MultiBot.ShowHideSwitch(pButton.getFrame("HunterBuffControlFrame"))
	end

	local tBuffFrame = pFrame.addFrame("HunterBuffControlFrame", -122, 30)
	tBuffFrame:Hide()

	MultiBot.AddExclusiveButton(tBuffFrame, "HunterBuffControl", HUNTER_BUFF_BSPEED,   0,  HUNTER_BUFF_ICONS[HUNTER_BUFF_BSPEED],  MultiBot.L("tips.hunter.buff.bspeed"),  "co", HUNTER_BUFF_BSPEED,  BUFF_BUTTONS)
	MultiBot.AddExclusiveButton(tBuffFrame, "HunterBuffControl", HUNTER_BUFF_BDPS,    26,  HUNTER_BUFF_ICONS[HUNTER_BUFF_BDPS],    MultiBot.L("tips.hunter.buff.bdps"),    "co", HUNTER_BUFF_BDPS,    BUFF_BUTTONS)
	MultiBot.AddExclusiveButton(tBuffFrame, "HunterBuffControl", HUNTER_BUFF_RNATURE, 52,  HUNTER_BUFF_ICONS[HUNTER_BUFF_RNATURE], MultiBot.L("tips.hunter.buff.rnature"), "co", HUNTER_BUFF_RNATURE, BUFF_BUTTONS)

	-- SET STRATS --

	local spec = nil
	if     MultiBot.isInside(pCombat, HUNTER_SPEC_BM)   then spec = HUNTER_SPEC_BM   tPlaybookFrame.getButton(HUNTER_SPEC_BM).setEnable()
	elseif MultiBot.isInside(pCombat, HUNTER_SPEC_MM)   then spec = HUNTER_SPEC_MM   tPlaybookFrame.getButton(HUNTER_SPEC_MM).setEnable()
	elseif MultiBot.isInside(pCombat, HUNTER_SPEC_SURV) then spec = HUNTER_SPEC_SURV tPlaybookFrame.getButton(HUNTER_SPEC_SURV).setEnable()
	end
	if spec then
		MultiBot.RestoreExclusiveGroup(pFrame, "Playbook", HUNTER_SPEC_ICONS[spec], "co", spec, PLAYBOOK_BUTTONS)
	end

	-- Buff state --
	local buff = nil
	if     MultiBot.isInside(pCombat, HUNTER_BUFF_BSPEED)  then buff = HUNTER_BUFF_BSPEED  tBuffFrame.getButton(HUNTER_BUFF_BSPEED).setEnable()
	elseif MultiBot.isInside(pCombat, HUNTER_BUFF_BDPS)    then buff = HUNTER_BUFF_BDPS    tBuffFrame.getButton(HUNTER_BUFF_BDPS).setEnable()
	elseif MultiBot.isInside(pCombat, HUNTER_BUFF_RNATURE) then buff = HUNTER_BUFF_RNATURE tBuffFrame.getButton(HUNTER_BUFF_RNATURE).setEnable()
	end
	if buff then
		MultiBot.RestoreExclusiveGroup(pFrame, "HunterBuffControl", HUNTER_BUFF_ICONS[buff], "co", buff, BUFF_BUTTONS)
	end

	if MultiBot.isInside(pCombat, HUNTER_STRAT_TRAP_WEAVE) then tControlFrame.getButton("TrapWeave").setEnable() end
end