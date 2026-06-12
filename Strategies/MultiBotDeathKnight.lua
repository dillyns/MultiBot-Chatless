local MultiBot = _G.MultiBot
if not MultiBot then return end

local DK_PRESENCE_BLOOD  = "blood"
local DK_PRESENCE_FROST  = "frost"
local DK_PRESENCE_UNHOLY = "unholy"

local DK_STRAT_FROST_AOE  = "frost aoe"
local DK_STRAT_UNHOLY_AOE = "unholy aoe"

local DK_PLAYBOOK_DEFAULT_ICON = "spell_deathknight_bloodpresence"
local DK_PLAYBOOK_ICONS = {
	[DK_PRESENCE_BLOOD]  = "spell_deathknight_bloodpresence",
	[DK_PRESENCE_FROST]  = "spell_deathknight_frostpresence",
	[DK_PRESENCE_UNHOLY] = "spell_deathknight_unholypresence",
}

local function setPlaybookIcon(pButton, presence)
	local btn = pButton.getButton("Playbook")
	if not btn then return end
	local icon = (presence and DK_PLAYBOOK_ICONS[presence]) or DK_PLAYBOOK_DEFAULT_ICON
	if btn.setTexture then btn.setTexture(icon) end
end

local PLAYBOOK_BUTTONS = { "Blood", "Frost", "Unholy" }

local function addPlaybookButton(tFrame, name, x, y, icon, tipKey, presence)
	tFrame.addButton(name, x, y, icon, MultiBot.L(tipKey)).setDisable()
	.doLeft = function(pButton)
		if MultiBot.OnOffActionToTarget(pButton, "co +" .. presence, "co -" .. presence, pButton.getName()) then
			setPlaybookIcon(pButton, presence)
			for _, other in ipairs(PLAYBOOK_BUTTONS) do
				if other ~= name then pButton.getButton(other).setDisable() end
			end
		else
			setPlaybookIcon(pButton, nil)
		end
	end
end

MultiBot.addDeathKnight = function(pFrame, pCombat, pNormal)

	MultiBot.AddNonCombatControl(pFrame, 0, pNormal)
	MultiBot.AddCombatControl(pFrame, -30, pCombat)

	-- PLAYBOOK --

	pFrame.addButton("Playbook", -60, 0, DK_PLAYBOOK_DEFAULT_ICON, MultiBot.L("tips.deathknight.playbook.master"))
	.doLeft = function(pButton)
		MultiBot.ShowHideSwitch(pButton.getFrame("Playbook"))
	end

	local tPlaybookFrame = pFrame.addFrame("Playbook", -62, 30)
	tPlaybookFrame:Hide()

	addPlaybookButton(tPlaybookFrame, "Blood",  0,  0, DK_PLAYBOOK_ICONS[DK_PRESENCE_BLOOD],  "tips.deathknight.playbook.blood",  DK_PRESENCE_BLOOD)
	addPlaybookButton(tPlaybookFrame, "Frost",  0, 26, DK_PLAYBOOK_ICONS[DK_PRESENCE_FROST],  "tips.deathknight.playbook.frost",  DK_PRESENCE_FROST)
	addPlaybookButton(tPlaybookFrame, "Unholy", 0, 52, DK_PLAYBOOK_ICONS[DK_PRESENCE_UNHOLY], "tips.deathknight.playbook.unholy", DK_PRESENCE_UNHOLY)

	-- DK STRATEGIES --

	pFrame.addButton("DkControl", -90, 0, "ability_warrior_challange", MultiBot.L("tips.deathknight.strategy.master"))
	.doLeft = function(pButton)
		MultiBot.ShowHideSwitch(pButton.getFrame("DkControlFrame"))
	end

	local tControlFrame = pFrame.addFrame("DkControlFrame", -92, 30)
	tControlFrame:Hide()

	tControlFrame.addButton("FrostAoe", 0, 0, "spell_frost_frostbolt02", MultiBot.L("tips.deathknight.strategy.frostAoe")).setDisable()
	.doLeft = function(pButton)
		if MultiBot.OnOffActionToTarget(pButton, "co +" .. DK_STRAT_FROST_AOE, "co -" .. DK_STRAT_FROST_AOE, pButton.getName()) then
			pButton.getButton("UnholyAoe").setDisable()
		end
	end

	tControlFrame.addButton("UnholyAoe", 0, 26, "spell_fire_felflamering", MultiBot.L("tips.deathknight.strategy.unholyAoe")).setDisable()
	.doLeft = function(pButton)
		if MultiBot.OnOffActionToTarget(pButton, "co +" .. DK_STRAT_UNHOLY_AOE, "co -" .. DK_STRAT_UNHOLY_AOE, pButton.getName()) then
			pButton.getButton("FrostAoe").setDisable()
		end
	end

	-- SET STRATS --

	local _playbook = nil
	if     MultiBot.isInside(pCombat, DK_PRESENCE_BLOOD)  then _playbook = DK_PRESENCE_BLOOD  pFrame.getButton("Blood").setEnable()
	elseif MultiBot.isInside(pCombat, DK_PRESENCE_FROST)  then _playbook = DK_PRESENCE_FROST  pFrame.getButton("Frost").setEnable()
	elseif MultiBot.isInside(pCombat, DK_PRESENCE_UNHOLY) then _playbook = DK_PRESENCE_UNHOLY pFrame.getButton("Unholy").setEnable()
	end
	setPlaybookIcon(pFrame, _playbook)

	if MultiBot.isInside(pCombat, DK_STRAT_FROST_AOE)  then pFrame.getButton("FrostAoe").setEnable()  end
	if MultiBot.isInside(pCombat, DK_STRAT_UNHOLY_AOE) then pFrame.getButton("UnholyAoe").setEnable() end
end