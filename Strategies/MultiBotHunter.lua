local MultiBot = _G.MultiBot
if not MultiBot then return end

local HUNTER_SPEC_BM   = "bm"
local HUNTER_SPEC_MM   = "mm"
local HUNTER_SPEC_SURV = "surv"

local HUNTER_STRAT_BSPEED    = "bspeed"
local HUNTER_STRAT_BDPS      = "bdps"
local HUNTER_STRAT_RNATURE   = "rnature"
local HUNTER_STRAT_TRAP_WEAVE = "trap weave"

local HUNTER_PLAYBOOK_DEFAULT_ICON = "inv_misc_book_06"
local HUNTER_SPEC_ICONS = {
	[HUNTER_SPEC_BM]   = "ability_hunter_beastmastery",
	[HUNTER_SPEC_MM]   = "ability_hunter_mastermarksman",
	[HUNTER_SPEC_SURV] = "ability_hunter_explosiveshot",
}

local function setPlaybookIcon(pButton, spec)
	local btn = pButton.getButton("Playbook")
	if not btn then return end
	local icon = (spec and HUNTER_SPEC_ICONS[spec]) or HUNTER_PLAYBOOK_DEFAULT_ICON
	if btn.setTexture then btn.setTexture(icon) end
end

local PLAYBOOK_BUTTONS = { "BeastMastery", "Marksmanship", "Survival" }

local function addPlaybookButton(tFrame, name, x, y, icon, tipKey, spec)
	tFrame.addButton(name, x, y, icon, MultiBot.L(tipKey)).setDisable()
	.doLeft = function(pButton)
		if MultiBot.OnOffActionToTarget(pButton, "co +" .. spec, "co -" .. spec, pButton.getName()) then
			setPlaybookIcon(pButton, spec)
			for _, other in ipairs(PLAYBOOK_BUTTONS) do
				if other ~= name then pButton.getButton(other).setDisable() end
			end
		else
			setPlaybookIcon(pButton, nil)
		end
	end
end

MultiBot.addHunter = function(pFrame, pCombat, pNormal)
	MultiBot.AddNonCombatControl(pFrame, 0, pNormal)
	MultiBot.AddCombatControl(pFrame, -30, pCombat)

	-- PLAYBOOK --

	pFrame.addButton("Playbook", -60, 0, HUNTER_PLAYBOOK_DEFAULT_ICON, MultiBot.L("tips.hunter.playbook.master"))
	.doLeft = function(pButton)
		MultiBot.ShowHideSwitch(pButton.getFrame("Playbook"))
	end

	local tPlaybookFrame = pFrame.addFrame("Playbook", -62, 30)
	tPlaybookFrame:Hide()

	addPlaybookButton(tPlaybookFrame, "BeastMastery", 0,  0, HUNTER_SPEC_ICONS[HUNTER_SPEC_BM],   "tips.hunter.playbook.bm",   HUNTER_SPEC_BM)
	addPlaybookButton(tPlaybookFrame, "Marksmanship", 0, 26, HUNTER_SPEC_ICONS[HUNTER_SPEC_MM],   "tips.hunter.playbook.mm",   HUNTER_SPEC_MM)
	addPlaybookButton(tPlaybookFrame, "Survival",     0, 52, HUNTER_SPEC_ICONS[HUNTER_SPEC_SURV], "tips.hunter.playbook.surv", HUNTER_SPEC_SURV)

	-- HUNTER STRATEGIES --

	pFrame.addButton("HunterControl", -90, 0, "INV_Glyph_MajorHunter", MultiBot.L("tips.hunter.strategy.master"))
	.doLeft = function(pButton)
		MultiBot.ShowHideSwitch(pButton.getFrame("HunterControlFrame"))
	end

	local tControlFrame = pFrame.addFrame("HunterControlFrame", -92, 30)
	tControlFrame:Hide()

	tControlFrame.addButton("TrapWeave", 0,  0, "ability_ensnare",                 MultiBot.L("tips.hunter.strategy.trapweave")).setDisable()
	.doLeft = function(pButton)
		MultiBot.OnOffActionToTarget(pButton, "co +" .. HUNTER_STRAT_TRAP_WEAVE, "co -" .. HUNTER_STRAT_TRAP_WEAVE, pButton.getName())
	end

	tControlFrame.addButton("BSpeed",   0, 26, "ability_mount_whitetiger",          MultiBot.L("tips.hunter.strategy.bspeed")).setDisable()
	.doLeft = function(pButton)
		if MultiBot.OnOffActionToTarget(pButton, "co +" .. HUNTER_STRAT_BSPEED, "co -" .. HUNTER_STRAT_BSPEED, pButton.getName()) then
			pButton.getButton("BDps").setDisable()
			pButton.getButton("RNature").setDisable()
		end
	end

	tControlFrame.addButton("BDps",     0, 52, "ability_hunter_pet_dragonhawk",     MultiBot.L("tips.hunter.strategy.bdps")).setDisable()
	.doLeft = function(pButton)
		if MultiBot.OnOffActionToTarget(pButton, "co +" .. HUNTER_STRAT_BDPS, "co -" .. HUNTER_STRAT_BDPS, pButton.getName()) then
			pButton.getButton("BSpeed").setDisable()
			pButton.getButton("RNature").setDisable()
		end
	end

	tControlFrame.addButton("RNature",  0, 78, "spell_nature_protectionformnature", MultiBot.L("tips.hunter.strategy.rnature")).setDisable()
	.doLeft = function(pButton)
		if MultiBot.OnOffActionToTarget(pButton, "co +" .. HUNTER_STRAT_RNATURE, "co -" .. HUNTER_STRAT_RNATURE, pButton.getName()) then
			pButton.getButton("BSpeed").setDisable()
			pButton.getButton("BDps").setDisable()
		end
	end

	-- SET STRATS --

	local _spec = nil
	if     MultiBot.isInside(pCombat, HUNTER_SPEC_BM)   then _spec = HUNTER_SPEC_BM   pFrame.getButton("BeastMastery").setEnable()
	elseif MultiBot.isInside(pCombat, HUNTER_SPEC_MM)   then _spec = HUNTER_SPEC_MM   pFrame.getButton("Marksmanship").setEnable()
	elseif MultiBot.isInside(pCombat, HUNTER_SPEC_SURV) then _spec = HUNTER_SPEC_SURV pFrame.getButton("Survival").setEnable()
	end
	setPlaybookIcon(pFrame, _spec)

	if MultiBot.isInside(pCombat, HUNTER_STRAT_TRAP_WEAVE) then pFrame.getButton("TrapWeave").setEnable() end
	if MultiBot.isInside(pCombat, HUNTER_STRAT_BSPEED)     then pFrame.getButton("BSpeed").setEnable()   end
	if MultiBot.isInside(pCombat, HUNTER_STRAT_BDPS)       then pFrame.getButton("BDps").setEnable()     end
	if MultiBot.isInside(pCombat, HUNTER_STRAT_RNATURE)    then pFrame.getButton("RNature").setEnable()  end
end