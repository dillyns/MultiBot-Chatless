local MultiBot = _G.MultiBot
if not MultiBot then return end

local PALADIN_ROLE_HEAL    = "heal"
local PALADIN_ROLE_DPS     = "dps"
local PALADIN_ROLE_TANK    = "tank"
local PALADIN_ROLE_OFFHEAL = "offheal"

local PALADIN_ROLE_ICONS = {
	[PALADIN_ROLE_HEAL]    = "spell_holy_holybolt",
	[PALADIN_ROLE_DPS]     = "spell_holy_auraoflight",
	[PALADIN_ROLE_TANK]    = "spell_holy_devotionaura",
	[PALADIN_ROLE_OFFHEAL] = "spell_holy_flashheal",
}

local PALADIN_BUFF_BHEALTH = "bsanc"
local PALADIN_BUFF_BMANA   = "bwisdom"
local PALADIN_BUFF_BSTATS  = "bkings"
local PALADIN_BUFF_BDPS    = "bmight"

local PALADIN_BUFF_ICONS = {
	[PALADIN_BUFF_BHEALTH] = "spell_nature_lightningshield",
	[PALADIN_BUFF_BMANA]   = "spell_holy_sealofwisdom",
	[PALADIN_BUFF_BSTATS]  = "spell_magic_magearmor",
	[PALADIN_BUFF_BDPS]    = "spell_holy_fistofjustice",
}

local PALADIN_STRAT_HEALER_DPS = "healer dps"

local PALADIN_STRAT_ICONS = {
	[PALADIN_STRAT_HEALER_DPS] = "spell_holy_healingaura",
}

local PALADIN_AURA_BSPEED  = "bspeed"
local PALADIN_AURA_RFIRE   = "rfire"
local PALADIN_AURA_RFROST  = "rfrost"
local PALADIN_AURA_RSHADOW = "rshadow"
local PALADIN_AURA_BAOE    = "baoe"
local PALADIN_AURA_BARMOR  = "barmor"
local PALADIN_AURA_BCAST   = "bcast"

local PALADIN_AURA_ICONS = {
	[PALADIN_AURA_BSPEED]  = "spell_holy_crusaderaura",
	[PALADIN_AURA_RFIRE]   = "spell_fire_sealoffire",
	[PALADIN_AURA_RFROST]  = "spell_frost_wizardmark",
	[PALADIN_AURA_RSHADOW] = "spell_shadow_sealofkings",
	[PALADIN_AURA_BAOE]    = "spell_holy_auraoflight",
	[PALADIN_AURA_BARMOR]  = "spell_holy_devotionaura",
	[PALADIN_AURA_BCAST]   = "spell_holy_mindsooth",
}

local PLAYBOOK_BUTTONS  = { PALADIN_ROLE_HEAL, PALADIN_ROLE_DPS, PALADIN_ROLE_TANK, PALADIN_ROLE_OFFHEAL }
local BLESSING_BUTTONS  = { PALADIN_BUFF_BHEALTH, PALADIN_BUFF_BMANA, PALADIN_BUFF_BSTATS, PALADIN_BUFF_BDPS }
local AURA_BUTTONS      = { PALADIN_AURA_BSPEED, PALADIN_AURA_RFIRE, PALADIN_AURA_RFROST, PALADIN_AURA_RSHADOW, PALADIN_AURA_BAOE, PALADIN_AURA_BARMOR, PALADIN_AURA_BCAST }

function MultiBot.addPaladin(pFrame, pCombat, pNormal)
	MultiBot.AddNonCombatControl(pFrame, 0, pNormal)
	MultiBot.AddCombatControl(pFrame, -30, pCombat)

	-- PLAYBOOK --

	pFrame.addButton("Playbook", -60, 0, "inv_misc_book_06", MultiBot.L("tips.paladin.playbook.master"))
	.doLeft = function(pButton)
		MultiBot.ShowHideSwitch(pButton.getFrame("Playbook"))
	end

	local tPlaybookFrame = pFrame.addFrame("Playbook", -62, 30)
	tPlaybookFrame:Hide()

	MultiBot.AddExclusiveButton(tPlaybookFrame, "Playbook", PALADIN_ROLE_HEAL,     0,  PALADIN_ROLE_ICONS[PALADIN_ROLE_HEAL],    MultiBot.L("tips.paladin.playbook.heal"),        "co", PALADIN_ROLE_HEAL,    PLAYBOOK_BUTTONS)
	MultiBot.AddExclusiveButton(tPlaybookFrame, "Playbook", PALADIN_ROLE_DPS,     26,  PALADIN_ROLE_ICONS[PALADIN_ROLE_DPS],     MultiBot.L("tips.paladin.playbook.dps"),     "co", PALADIN_ROLE_DPS,     PLAYBOOK_BUTTONS)
	MultiBot.AddExclusiveButton(tPlaybookFrame, "Playbook", PALADIN_ROLE_TANK,    52,  PALADIN_ROLE_ICONS[PALADIN_ROLE_TANK],    MultiBot.L("tips.paladin.playbook.tank"),        "co", PALADIN_ROLE_TANK,    PLAYBOOK_BUTTONS)
	MultiBot.AddExclusiveButton(tPlaybookFrame, "Playbook", PALADIN_ROLE_OFFHEAL, 78,  PALADIN_ROLE_ICONS[PALADIN_ROLE_OFFHEAL], MultiBot.L("tips.paladin.playbook.offheal"), "co", PALADIN_ROLE_OFFHEAL, PLAYBOOK_BUTTONS)

	-- PALADIN STRATEGIES --

	pFrame.addButton("PaladinControl", -90, 0, "INV_Glyph_MajorPaladin", MultiBot.L("tips.paladin.strategy.master"))
	.doLeft = function(pButton)
		MultiBot.ShowHideSwitch(pButton.getFrame("PaladinControlFrame"))
	end

	local tControlFrame = pFrame.addFrame("PaladinControlFrame", -92, 30)
	tControlFrame:Hide()

	local healerDpsOn  = "co +" .. PALADIN_STRAT_HEALER_DPS
	local healerDpsOff = "co -" .. PALADIN_STRAT_HEALER_DPS
	tControlFrame.addButton("HealerDps", 0, 0, PALADIN_STRAT_ICONS[PALADIN_STRAT_HEALER_DPS], MultiBot.L("tips.paladin.strategy.healerdps")).setDisable()
	.doLeft = function(pButton)
		MultiBot.OnOffActionToTarget(pButton, healerDpsOn, healerDpsOff, pButton.getName())
	end

	-- NON-COMBAT AURA --

	local nonCombatAuraButton = pFrame.addButton("NonCombatAura", -120, 0, PALADIN_AURA_ICONS[PALADIN_AURA_BARMOR], MultiBot.L("tips.paladin.aura.noncombat"))
	nonCombatAuraButton.doLeft = function(pButton)
		MultiBot.ShowHideSwitch(pButton.getFrame("NonCombatAura"))
	end

	local nonCombatAuraFrame = pFrame.addFrame("NonCombatAura", -122, 30)
	nonCombatAuraFrame:Hide()

	MultiBot.AddExclusiveButton(nonCombatAuraFrame, "NonCombatAura", PALADIN_AURA_BSPEED,  0,   PALADIN_AURA_ICONS[PALADIN_AURA_BSPEED],  MultiBot.L("tips.paladin.aura.bspeed"),  "nc", PALADIN_AURA_BSPEED,  AURA_BUTTONS)
	MultiBot.AddExclusiveButton(nonCombatAuraFrame, "NonCombatAura", PALADIN_AURA_RFIRE,   26,  PALADIN_AURA_ICONS[PALADIN_AURA_RFIRE],   MultiBot.L("tips.paladin.aura.rfire"),   "nc", PALADIN_AURA_RFIRE,   AURA_BUTTONS)
	MultiBot.AddExclusiveButton(nonCombatAuraFrame, "NonCombatAura", PALADIN_AURA_RFROST,  52,  PALADIN_AURA_ICONS[PALADIN_AURA_RFROST],  MultiBot.L("tips.paladin.aura.rfrost"),  "nc", PALADIN_AURA_RFROST,  AURA_BUTTONS)
	MultiBot.AddExclusiveButton(nonCombatAuraFrame, "NonCombatAura", PALADIN_AURA_RSHADOW, 78,  PALADIN_AURA_ICONS[PALADIN_AURA_RSHADOW], MultiBot.L("tips.paladin.aura.rshadow"), "nc", PALADIN_AURA_RSHADOW, AURA_BUTTONS)
	MultiBot.AddExclusiveButton(nonCombatAuraFrame, "NonCombatAura", PALADIN_AURA_BAOE,    104, PALADIN_AURA_ICONS[PALADIN_AURA_BAOE],    MultiBot.L("tips.paladin.aura.baoe"),    "nc", PALADIN_AURA_BAOE,    AURA_BUTTONS)
	MultiBot.AddExclusiveButton(nonCombatAuraFrame, "NonCombatAura", PALADIN_AURA_BARMOR,  130, PALADIN_AURA_ICONS[PALADIN_AURA_BARMOR],  MultiBot.L("tips.paladin.aura.barmor"),  "nc", PALADIN_AURA_BARMOR,  AURA_BUTTONS)
	MultiBot.AddExclusiveButton(nonCombatAuraFrame, "NonCombatAura", PALADIN_AURA_BCAST,   156, PALADIN_AURA_ICONS[PALADIN_AURA_BCAST],   MultiBot.L("tips.paladin.aura.bcast"),   "nc", PALADIN_AURA_BCAST,   AURA_BUTTONS)

	-- COMBAT AURA --

	local combatAuraButton = pFrame.addButton("CombatAura", -150, 0, PALADIN_AURA_ICONS[PALADIN_AURA_BARMOR], MultiBot.L("tips.paladin.aura.combat"))
	combatAuraButton.doLeft = function(pButton)
		MultiBot.ShowHideSwitch(pButton.getFrame("CombatAura"))
	end

	local combatAuraFrame = pFrame.addFrame("CombatAura", -152, 30)
	combatAuraFrame:Hide()

	MultiBot.AddExclusiveButton(combatAuraFrame, "CombatAura", PALADIN_AURA_BSPEED,  0,   PALADIN_AURA_ICONS[PALADIN_AURA_BSPEED],  MultiBot.L("tips.paladin.aura.bspeed"),  "co", PALADIN_AURA_BSPEED,  AURA_BUTTONS)
	MultiBot.AddExclusiveButton(combatAuraFrame, "CombatAura", PALADIN_AURA_RFIRE,   26,  PALADIN_AURA_ICONS[PALADIN_AURA_RFIRE],   MultiBot.L("tips.paladin.aura.rfire"),   "co", PALADIN_AURA_RFIRE,   AURA_BUTTONS)
	MultiBot.AddExclusiveButton(combatAuraFrame, "CombatAura", PALADIN_AURA_RFROST,  52,  PALADIN_AURA_ICONS[PALADIN_AURA_RFROST],  MultiBot.L("tips.paladin.aura.rfrost"),  "co", PALADIN_AURA_RFROST,  AURA_BUTTONS)
	MultiBot.AddExclusiveButton(combatAuraFrame, "CombatAura", PALADIN_AURA_RSHADOW, 78,  PALADIN_AURA_ICONS[PALADIN_AURA_RSHADOW], MultiBot.L("tips.paladin.aura.rshadow"), "co", PALADIN_AURA_RSHADOW, AURA_BUTTONS)
	MultiBot.AddExclusiveButton(combatAuraFrame, "CombatAura", PALADIN_AURA_BAOE,    104, PALADIN_AURA_ICONS[PALADIN_AURA_BAOE],    MultiBot.L("tips.paladin.aura.baoe"),    "co", PALADIN_AURA_BAOE,    AURA_BUTTONS)
	MultiBot.AddExclusiveButton(combatAuraFrame, "CombatAura", PALADIN_AURA_BARMOR,  130, PALADIN_AURA_ICONS[PALADIN_AURA_BARMOR],  MultiBot.L("tips.paladin.aura.barmor"),  "co", PALADIN_AURA_BARMOR,  AURA_BUTTONS)
	MultiBot.AddExclusiveButton(combatAuraFrame, "CombatAura", PALADIN_AURA_BCAST,   156, PALADIN_AURA_ICONS[PALADIN_AURA_BCAST],   MultiBot.L("tips.paladin.aura.bcast"),   "co", PALADIN_AURA_BCAST,   AURA_BUTTONS)

	-- BLESSINGS --

	pFrame.addButton("BlessingControl", -180, 0, PALADIN_BUFF_ICONS[PALADIN_BUFF_BDPS], MultiBot.L("tips.paladin.buff.master"))
	.doLeft = function(pButton)
		MultiBot.ShowHideSwitch(pButton.getFrame("BlessingControlFrame"))
	end

	local tBlessingFrame = pFrame.addFrame("BlessingControlFrame", -182, 30)
	tBlessingFrame:Hide()

	MultiBot.AddExclusiveButton(tBlessingFrame, "BlessingControl", PALADIN_BUFF_BHEALTH,  0,  PALADIN_BUFF_ICONS[PALADIN_BUFF_BHEALTH], MultiBot.L("tips.paladin.buff.bhealth"), "nc", PALADIN_BUFF_BHEALTH, BLESSING_BUTTONS)
	MultiBot.AddExclusiveButton(tBlessingFrame, "BlessingControl", PALADIN_BUFF_BMANA,   26,  PALADIN_BUFF_ICONS[PALADIN_BUFF_BMANA],   MultiBot.L("tips.paladin.buff.bmana"),   "nc", PALADIN_BUFF_BMANA,   BLESSING_BUTTONS)
	MultiBot.AddExclusiveButton(tBlessingFrame, "BlessingControl", PALADIN_BUFF_BSTATS,  52,  PALADIN_BUFF_ICONS[PALADIN_BUFF_BSTATS],  MultiBot.L("tips.paladin.buff.bstats"),  "nc", PALADIN_BUFF_BSTATS,  BLESSING_BUTTONS)
	MultiBot.AddExclusiveButton(tBlessingFrame, "BlessingControl", PALADIN_BUFF_BDPS,    78,  PALADIN_BUFF_ICONS[PALADIN_BUFF_BDPS],    MultiBot.L("tips.paladin.buff.bdps"),    "nc", PALADIN_BUFF_BDPS,    BLESSING_BUTTONS)

	-- SET STRATS --

	local _role = nil
	if     MultiBot.isInside(pCombat, PALADIN_ROLE_HEAL)    then _role = PALADIN_ROLE_HEAL    tPlaybookFrame.getButton(PALADIN_ROLE_HEAL).setEnable()
	elseif MultiBot.isInside(pCombat, PALADIN_ROLE_TANK)    then _role = PALADIN_ROLE_TANK    tPlaybookFrame.getButton(PALADIN_ROLE_TANK).setEnable()
	elseif MultiBot.isInside(pCombat, PALADIN_ROLE_DPS)     then _role = PALADIN_ROLE_DPS     tPlaybookFrame.getButton(PALADIN_ROLE_DPS).setEnable()
	elseif MultiBot.isInside(pCombat, PALADIN_ROLE_OFFHEAL) then _role = PALADIN_ROLE_OFFHEAL tPlaybookFrame.getButton(PALADIN_ROLE_OFFHEAL).setEnable()
	end
	if _role then
		MultiBot.RestoreExclusiveGroup(pFrame, "Playbook", PALADIN_ROLE_ICONS[_role], "co", _role, PLAYBOOK_BUTTONS)
	end

	-- Buff state --
	local _buff = nil
	if     MultiBot.isInside(pNormal, PALADIN_BUFF_BHEALTH) then _buff = PALADIN_BUFF_BHEALTH tBlessingFrame.getButton(PALADIN_BUFF_BHEALTH).setEnable()
	elseif MultiBot.isInside(pNormal, PALADIN_BUFF_BMANA)   then _buff = PALADIN_BUFF_BMANA   tBlessingFrame.getButton(PALADIN_BUFF_BMANA).setEnable()
	elseif MultiBot.isInside(pNormal, PALADIN_BUFF_BSTATS)  then _buff = PALADIN_BUFF_BSTATS  tBlessingFrame.getButton(PALADIN_BUFF_BSTATS).setEnable()
	elseif MultiBot.isInside(pNormal, PALADIN_BUFF_BDPS)    then _buff = PALADIN_BUFF_BDPS    tBlessingFrame.getButton(PALADIN_BUFF_BDPS).setEnable()
	end
	if _buff then
		MultiBot.RestoreExclusiveGroup(pFrame, "BlessingControl", PALADIN_BUFF_ICONS[_buff], "nc", _buff, BLESSING_BUTTONS)
	end

	-- NonCombatAura state --
	local _naura = nil
	if     MultiBot.isInside(pNormal, PALADIN_AURA_BSPEED)  then _naura = PALADIN_AURA_BSPEED  nonCombatAuraFrame.getButton(PALADIN_AURA_BSPEED).setEnable()
	elseif MultiBot.isInside(pNormal, PALADIN_AURA_RFIRE)   then _naura = PALADIN_AURA_RFIRE   nonCombatAuraFrame.getButton(PALADIN_AURA_RFIRE).setEnable()
	elseif MultiBot.isInside(pNormal, PALADIN_AURA_RFROST)  then _naura = PALADIN_AURA_RFROST  nonCombatAuraFrame.getButton(PALADIN_AURA_RFROST).setEnable()
	elseif MultiBot.isInside(pNormal, PALADIN_AURA_RSHADOW) then _naura = PALADIN_AURA_RSHADOW nonCombatAuraFrame.getButton(PALADIN_AURA_RSHADOW).setEnable()
	elseif MultiBot.isInside(pNormal, PALADIN_AURA_BAOE)    then _naura = PALADIN_AURA_BAOE    nonCombatAuraFrame.getButton(PALADIN_AURA_BAOE).setEnable()
	elseif MultiBot.isInside(pNormal, PALADIN_AURA_BARMOR)  then _naura = PALADIN_AURA_BARMOR  nonCombatAuraFrame.getButton(PALADIN_AURA_BARMOR).setEnable()
	elseif MultiBot.isInside(pNormal, PALADIN_AURA_BCAST)   then _naura = PALADIN_AURA_BCAST   nonCombatAuraFrame.getButton(PALADIN_AURA_BCAST).setEnable()
	end
	if _naura then
		MultiBot.RestoreExclusiveGroup(pFrame, "NonCombatAura", PALADIN_AURA_ICONS[_naura], "nc", _naura, AURA_BUTTONS)
	end

	-- CombatAura state --
	local _caura = nil
	if     MultiBot.isInside(pCombat, PALADIN_AURA_BSPEED)  then _caura = PALADIN_AURA_BSPEED  combatAuraFrame.getButton(PALADIN_AURA_BSPEED).setEnable()
	elseif MultiBot.isInside(pCombat, PALADIN_AURA_RFIRE)   then _caura = PALADIN_AURA_RFIRE   combatAuraFrame.getButton(PALADIN_AURA_RFIRE).setEnable()
	elseif MultiBot.isInside(pCombat, PALADIN_AURA_RFROST)  then _caura = PALADIN_AURA_RFROST  combatAuraFrame.getButton(PALADIN_AURA_RFROST).setEnable()
	elseif MultiBot.isInside(pCombat, PALADIN_AURA_RSHADOW) then _caura = PALADIN_AURA_RSHADOW combatAuraFrame.getButton(PALADIN_AURA_RSHADOW).setEnable()
	elseif MultiBot.isInside(pCombat, PALADIN_AURA_BAOE)    then _caura = PALADIN_AURA_BAOE    combatAuraFrame.getButton(PALADIN_AURA_BAOE).setEnable()
	elseif MultiBot.isInside(pCombat, PALADIN_AURA_BARMOR)  then _caura = PALADIN_AURA_BARMOR  combatAuraFrame.getButton(PALADIN_AURA_BARMOR).setEnable()
	elseif MultiBot.isInside(pCombat, PALADIN_AURA_BCAST)   then _caura = PALADIN_AURA_BCAST   combatAuraFrame.getButton(PALADIN_AURA_BCAST).setEnable()
	end
	if _caura then
		MultiBot.RestoreExclusiveGroup(pFrame, "CombatAura", PALADIN_AURA_ICONS[_caura], "co", _caura, AURA_BUTTONS)
	end

	if MultiBot.isInside(pCombat, PALADIN_STRAT_HEALER_DPS) then tControlFrame.getButton("HealerDps").setEnable() end
end