local MultiBot = _G.MultiBot
if not MultiBot then return end

local DRUID_ROLE_RESTO   = "resto"
local DRUID_ROLE_BALANCE = "balance"
local DRUID_ROLE_CAT     = "cat"
local DRUID_ROLE_BEAR    = "bear"

local DRUID_ROLE_ICONS = {
	[DRUID_ROLE_RESTO]   = "spell_nature_healingtouch",
	[DRUID_ROLE_BALANCE] = "spell_nature_starfall",
	[DRUID_ROLE_CAT]     = "ability_druid_catform",
	[DRUID_ROLE_BEAR]    = "ability_racial_bearform",
}

local DRUID_STRAT_HEALER_DPS   = "healer dps"
local DRUID_STRAT_BLANKETING   = "blanketing"
local DRUID_STRAT_TRANQUILITY  = "tranquility"
local DRUID_STRAT_FERAL_CHARGE = "feral charge"
local DRUID_STRAT_OFFHEAL      = "offheal"

local DRUID_STRAT_ICONS = {
	[DRUID_STRAT_HEALER_DPS]   = "spell_nature_abolishmagic",
	[DRUID_STRAT_BLANKETING]   = "spell_nature_rejuvenation",
	[DRUID_STRAT_TRANQUILITY]  = "spell_nature_tranquility",
	[DRUID_STRAT_FERAL_CHARGE] = "Spell_Druid_feralchargecat",
	[DRUID_STRAT_OFFHEAL]      = "spell_nature_resistnature",
}

local PLAYBOOK_BUTTONS = { DRUID_ROLE_RESTO, DRUID_ROLE_BALANCE, DRUID_ROLE_CAT, DRUID_ROLE_BEAR }

function MultiBot.addDruid(pFrame, pCombat, pNormal)
	MultiBot.AddNonCombatControl(pFrame, 0, pNormal)
	MultiBot.AddCombatControl(pFrame, -30, pCombat)

	-- PLAYBOOK --

	pFrame.addButton("Playbook", -60, 0, "inv_misc_book_06", MultiBot.L("tips.druid.playbook.master"))
	.doLeft = function(pButton)
		MultiBot.ShowHideSwitch(pButton.getFrame("Playbook"))
	end

	local tPlaybookFrame = pFrame.addFrame("Playbook", -62, 30)
	tPlaybookFrame:Hide()

	MultiBot.AddExclusiveButton(tPlaybookFrame, "Playbook", DRUID_ROLE_RESTO,    0,  DRUID_ROLE_ICONS[DRUID_ROLE_RESTO],   MultiBot.L("tips.druid.playbook.resto"),  "co", DRUID_ROLE_RESTO,   PLAYBOOK_BUTTONS)
	MultiBot.AddExclusiveButton(tPlaybookFrame, "Playbook", DRUID_ROLE_BALANCE, 26,  DRUID_ROLE_ICONS[DRUID_ROLE_BALANCE], MultiBot.L("tips.druid.playbook.caster"), "co", DRUID_ROLE_BALANCE, PLAYBOOK_BUTTONS)
	MultiBot.AddExclusiveButton(tPlaybookFrame, "Playbook", DRUID_ROLE_CAT,     52,  DRUID_ROLE_ICONS[DRUID_ROLE_CAT],     MultiBot.L("tips.druid.playbook.cat"),    "co", DRUID_ROLE_CAT,     PLAYBOOK_BUTTONS)
	MultiBot.AddExclusiveButton(tPlaybookFrame, "Playbook", DRUID_ROLE_BEAR,    78,  DRUID_ROLE_ICONS[DRUID_ROLE_BEAR],    MultiBot.L("tips.druid.playbook.bear"),   "co", DRUID_ROLE_BEAR,    PLAYBOOK_BUTTONS)

	-- DRUID STRATEGIES --

	pFrame.addButton("DruidControl", -90, 0, "INV_Glyph_MajorDruid", MultiBot.L("tips.druid.strategy.master"))
	.doLeft = function(pButton)
		MultiBot.ShowHideSwitch(pButton.getFrame("DruidControlFrame"))
	end

	local tControlFrame = pFrame.addFrame("DruidControlFrame", -92, 30)
	tControlFrame:Hide()

	local healerdpson    = "co +" .. DRUID_STRAT_HEALER_DPS
	local healerdpsoff   = "co -" .. DRUID_STRAT_HEALER_DPS
	local blanketingon   = "co +" .. DRUID_STRAT_BLANKETING
	local blanketingoff  = "co -" .. DRUID_STRAT_BLANKETING
	local tranquilon     = "co +" .. DRUID_STRAT_TRANQUILITY
	local tranquiloff    = "co -" .. DRUID_STRAT_TRANQUILITY
	local feralchargeon  = "co +" .. DRUID_STRAT_FERAL_CHARGE
	local feralchargeoff = "co -" .. DRUID_STRAT_FERAL_CHARGE
	local offhealon      = "co +" .. DRUID_STRAT_OFFHEAL
	local offhealoff     = "co -" .. DRUID_STRAT_OFFHEAL

	tControlFrame.addButton("HealerDps",   0,   0, DRUID_STRAT_ICONS[DRUID_STRAT_HEALER_DPS],   MultiBot.L("tips.druid.strategy.healerdps")).setDisable()
	.doLeft = function(pButton)
		MultiBot.OnOffActionToTarget(pButton, healerdpson, healerdpsoff, pButton.getName())
	end

	tControlFrame.addButton(DRUID_STRAT_BLANKETING,  0,  26, DRUID_STRAT_ICONS[DRUID_STRAT_BLANKETING],   MultiBot.L("tips.druid.strategy.blanketing")).setDisable()
	.doLeft = function(pButton)
		MultiBot.OnOffActionToTarget(pButton, blanketingon, blanketingoff, pButton.getName())
	end

	tControlFrame.addButton(DRUID_STRAT_TRANQUILITY, 0,  52, DRUID_STRAT_ICONS[DRUID_STRAT_TRANQUILITY],  MultiBot.L("tips.druid.strategy.tranquility")).setDisable()
	.doLeft = function(pButton)
		MultiBot.OnOffActionToTarget(pButton, tranquilon, tranquiloff, pButton.getName())
	end

	tControlFrame.addButton("FeralCharge", 0,  78, DRUID_STRAT_ICONS[DRUID_STRAT_FERAL_CHARGE], MultiBot.L("tips.druid.strategy.feralCharge")).setDisable()
	.doLeft = function(pButton)
		MultiBot.OnOffActionToTarget(pButton, feralchargeon, feralchargeoff, pButton.getName())
	end

	tControlFrame.addButton(DRUID_STRAT_OFFHEAL,     0, 104, DRUID_STRAT_ICONS[DRUID_STRAT_OFFHEAL],      MultiBot.L("tips.druid.strategy.offheal")).setDisable()
	.doLeft = function(pButton)
		MultiBot.OnOffActionToTarget(pButton, offhealon, offhealoff, pButton.getName())
	end

	-- SET STRATS --

	local role = nil
	if     MultiBot.isInside(pCombat, DRUID_ROLE_RESTO)   then role = DRUID_ROLE_RESTO   tPlaybookFrame.getButton(DRUID_ROLE_RESTO).setEnable()
	elseif MultiBot.isInside(pCombat, DRUID_ROLE_BALANCE) then role = DRUID_ROLE_BALANCE tPlaybookFrame.getButton(DRUID_ROLE_BALANCE).setEnable()
	elseif MultiBot.isInside(pCombat, DRUID_ROLE_CAT)     then role = DRUID_ROLE_CAT     tPlaybookFrame.getButton(DRUID_ROLE_CAT).setEnable()
	elseif MultiBot.isInside(pCombat, DRUID_ROLE_BEAR)    then role = DRUID_ROLE_BEAR    tPlaybookFrame.getButton(DRUID_ROLE_BEAR).setEnable()
	end
	if role then
		MultiBot.RestoreExclusiveGroup(pFrame, "Playbook", DRUID_ROLE_ICONS[role], "co", role, PLAYBOOK_BUTTONS)
	end

	if MultiBot.isInside(pCombat, DRUID_STRAT_HEALER_DPS)   then tControlFrame.getButton("HealerDps").setEnable()               end
	if MultiBot.isInside(pCombat, DRUID_STRAT_BLANKETING)   then tControlFrame.getButton(DRUID_STRAT_BLANKETING).setEnable()    end
	if MultiBot.isInside(pCombat, DRUID_STRAT_TRANQUILITY)  then tControlFrame.getButton(DRUID_STRAT_TRANQUILITY).setEnable()   end
	if MultiBot.isInside(pCombat, DRUID_STRAT_FERAL_CHARGE) then tControlFrame.getButton("FeralCharge").setEnable()             end
	if MultiBot.isInside(pCombat, DRUID_STRAT_OFFHEAL)      then tControlFrame.getButton(DRUID_STRAT_OFFHEAL).setEnable()       end
end