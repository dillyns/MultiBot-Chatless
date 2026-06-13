local MultiBot = _G.MultiBot
if not MultiBot then return end

local MAGE_SPEC_FROST     = "frost"
local MAGE_SPEC_FIRE      = "fire"
local MAGE_SPEC_FROSTFIRE = "frostfire"
local MAGE_SPEC_ARCANE    = "arcane"

local MAGE_PLAYBOOK_DEFAULT_ICON = "inv_misc_book_06"
local MAGE_SPEC_ICONS = {
	[MAGE_SPEC_FROST]     = "spell_frost_frostbolt02",
	[MAGE_SPEC_FIRE]      = "spell_fire_flamebolt",
	[MAGE_SPEC_FROSTFIRE] = "ability_mage_frostfirebolt",
	[MAGE_SPEC_ARCANE]    = "spell_holy_magicalsentry",
}

local MAGE_STRAT_FIRESTARTER = "firestarter"
local MAGE_STRAT_BMANA       = "bmana"
local MAGE_STRAT_BDPS        = "bdps"

local MAGE_STRAT_ICONS = {
	[MAGE_STRAT_FIRESTARTER] = "ability_mage_firestarter",
	[MAGE_STRAT_BMANA]       = "spell_magearmor",
	[MAGE_STRAT_BDPS]        = "ability_mage_moltenarmor",
}

local function setPlaybookIcon(pButton, spec)
	local btn = pButton.getButton("Playbook")
	if not btn then return end
	local icon = (spec and MAGE_SPEC_ICONS[spec]) or MAGE_PLAYBOOK_DEFAULT_ICON
	if btn.setTexture then btn.setTexture(icon) end
end

local PLAYBOOK_BUTTONS = { "Arcane", "Frost", "Fire", "FrostFire" }

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

MultiBot.addMage = function(pFrame, pCombat, pNormal)
	MultiBot.AddNonCombatControl(pFrame, 0, pNormal)
	MultiBot.AddCombatControl(pFrame, -30, pCombat)

	-- PLAYBOOK --

	pFrame.addButton("Playbook", -60, 0, MAGE_PLAYBOOK_DEFAULT_ICON, MultiBot.L("tips.mage.playbook.master"))
	.doLeft = function(pButton)
		MultiBot.ShowHideSwitch(pButton.getFrame("Playbook"))
	end

	local tPlaybookFrame = pFrame.addFrame("Playbook", -62, 30)
	tPlaybookFrame:Hide()

	addPlaybookButton(tPlaybookFrame, "Arcane",    0,  0, MAGE_SPEC_ICONS[MAGE_SPEC_ARCANE],    "tips.mage.playbook.arcane",    MAGE_SPEC_ARCANE)
	addPlaybookButton(tPlaybookFrame, "Frost",     0, 26, MAGE_SPEC_ICONS[MAGE_SPEC_FROST],     "tips.mage.playbook.frost",     MAGE_SPEC_FROST)
	addPlaybookButton(tPlaybookFrame, "Fire",      0, 52, MAGE_SPEC_ICONS[MAGE_SPEC_FIRE],      "tips.mage.playbook.fire",      MAGE_SPEC_FIRE)
	addPlaybookButton(tPlaybookFrame, "FrostFire", 0, 78, MAGE_SPEC_ICONS[MAGE_SPEC_FROSTFIRE], "tips.mage.playbook.frostfire", MAGE_SPEC_FROSTFIRE)

	-- MAGE STRATEGIES --

	pFrame.addButton("MageControl", -90, 0, "INV_Glyph_MajorMage", MultiBot.L("tips.mage.strategy.master"))
	.doLeft = function(pButton)
		MultiBot.ShowHideSwitch(pButton.getFrame("MageControlFrame"))
	end

	local tControlFrame = pFrame.addFrame("MageControlFrame", -92, 30)
	tControlFrame:Hide()

	tControlFrame.addButton("Firestarter", 0,  0, MAGE_STRAT_ICONS[MAGE_STRAT_FIRESTARTER], MultiBot.L("tips.mage.strategy.firestarter")).setDisable()
	.doLeft = function(pButton)
		MultiBot.OnOffActionToTarget(pButton, "co +" .. MAGE_STRAT_FIRESTARTER, "co -" .. MAGE_STRAT_FIRESTARTER, pButton.getName())
	end

	tControlFrame.addButton("BMana",       0, 26, MAGE_STRAT_ICONS[MAGE_STRAT_BMANA],       MultiBot.L("tips.mage.strategy.bmana")).setDisable()
	.doLeft = function(pButton)
		if MultiBot.OnOffActionToTarget(pButton, "nc +" .. MAGE_STRAT_BMANA, "nc -" .. MAGE_STRAT_BMANA, pButton.getName()) then
			pButton.getButton("BDps").setDisable()
		end
	end

	tControlFrame.addButton("BDps",        0, 52, MAGE_STRAT_ICONS[MAGE_STRAT_BDPS],        MultiBot.L("tips.mage.strategy.bdps")).setDisable()
	.doLeft = function(pButton)
		if MultiBot.OnOffActionToTarget(pButton, "nc +" .. MAGE_STRAT_BDPS, "nc -" .. MAGE_STRAT_BDPS, pButton.getName()) then
			pButton.getButton("BMana").setDisable()
		end
	end

	-- SET STRATS --

	local _spec = nil
	if     MultiBot.isInside(pCombat, MAGE_SPEC_ARCANE)    then _spec = MAGE_SPEC_ARCANE    pFrame.getButton("Arcane").setEnable()
	elseif MultiBot.isInside(pCombat, MAGE_SPEC_FROSTFIRE) then _spec = MAGE_SPEC_FROSTFIRE pFrame.getButton("FrostFire").setEnable()
	elseif MultiBot.isInside(pCombat, MAGE_SPEC_FROST)     then _spec = MAGE_SPEC_FROST     pFrame.getButton("Frost").setEnable()
	elseif MultiBot.isInside(pCombat, MAGE_SPEC_FIRE)      then _spec = MAGE_SPEC_FIRE      pFrame.getButton("Fire").setEnable()
	end
	setPlaybookIcon(pFrame, _spec)

	if MultiBot.isInside(pCombat, MAGE_STRAT_FIRESTARTER) then pFrame.getButton("Firestarter").setEnable() end
	if MultiBot.isInside(pNormal, MAGE_STRAT_BMANA)       then pFrame.getButton("BMana").setEnable()       end
	if MultiBot.isInside(pNormal, MAGE_STRAT_BDPS)        then pFrame.getButton("BDps").setEnable()        end
end