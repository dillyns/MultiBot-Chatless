local MultiBot = _G.MultiBot
if not MultiBot then return end

local WARLOCK_SPEC_AFFLI   = "affli"
local WARLOCK_SPEC_DEMO    = "demo"
local WARLOCK_SPEC_DESTRO  = "destro"

local WARLOCK_SPEC_ICONS = {
	[WARLOCK_SPEC_AFFLI]  = "spell_shadow_deathcoil",
	[WARLOCK_SPEC_DEMO]   = "spell_shadow_metamorphosis",
	[WARLOCK_SPEC_DESTRO] = "spell_shadow_rainoffire",
}

local WARLOCK_STRAT_TANK       = "tank"
local WARLOCK_STRAT_META_MELEE = "meta melee"
local WARLOCK_STRAT_PET        = "pet"

local WARLOCK_STRAT_ICONS = {
	[WARLOCK_STRAT_TANK]       = "spell_fire_soulburn",
	[WARLOCK_STRAT_META_MELEE] = "spell_shadow_demonform",
	[WARLOCK_STRAT_PET]        = "spell_shadow_enslavedemon",
}

local WARLOCK_BUFF_FIRESTONE  = "firestone"
local WARLOCK_BUFF_SPELLSTONE = "spellstone"

local WARLOCK_BUFF_ICONS = {
	[WARLOCK_BUFF_FIRESTONE]  = "inv_misc_gem_bloodstone_02",
	[WARLOCK_BUFF_SPELLSTONE] = "inv_misc_gem_sapphire_01",
}

local WARLOCK_PET_IMP        = "imp"
local WARLOCK_PET_VOIDWALKER = "voidwalker"
local WARLOCK_PET_SUCCUBUS   = "succubus"
local WARLOCK_PET_FELHUNTER  = "felhunter"
local WARLOCK_PET_FELGUARD   = "felguard"

local WARLOCK_PET_ICONS = {
	[WARLOCK_PET_IMP]        = "spell_shadow_summonimp",
	[WARLOCK_PET_VOIDWALKER] = "spell_shadow_summonvoidwalker",
	[WARLOCK_PET_SUCCUBUS]   = "spell_shadow_summonsuccubus",
	[WARLOCK_PET_FELHUNTER]  = "spell_shadow_summonfelhunter",
	[WARLOCK_PET_FELGUARD]   = "spell_shadow_summonfelguard",
}

local WARLOCK_SS_SELF   = "ss self"
local WARLOCK_SS_MASTER = "ss master"
local WARLOCK_SS_TANK   = "ss tank"
local WARLOCK_SS_HEALER = "ss healer"

local WARLOCK_SS_ICONS = {
	[WARLOCK_SS_SELF]   = "spell_shadow_soulgem",
	[WARLOCK_SS_MASTER] = "inv_crown_01",
	[WARLOCK_SS_TANK]   = "ability_defend",
	[WARLOCK_SS_HEALER] = "INV_Elemental_Primal_life",
}

local WARLOCK_CURSE_AGONY      = "curse of agony"
local WARLOCK_CURSE_ELEMENTS   = "curse of elements"
local WARLOCK_CURSE_DOOM       = "curse of doom"
local WARLOCK_CURSE_EXHAUSTION = "curse of exhaustion"
local WARLOCK_CURSE_TONGUES    = "curse of tongues"
local WARLOCK_CURSE_WEAKNESS   = "curse of weakness"

local WARLOCK_CURSE_ICONS = {
	[WARLOCK_CURSE_AGONY]      = "Spell_Shadow_CurseOfSargeras",
	[WARLOCK_CURSE_ELEMENTS]   = "Spell_Shadow_ChillTouch",
	[WARLOCK_CURSE_DOOM]       = "Spell_Shadow_AuraOfDarkness",
	[WARLOCK_CURSE_EXHAUSTION] = "Spell_Shadow_GrimWard",
	[WARLOCK_CURSE_TONGUES]    = "Spell_Shadow_CurseOfTounges",
	[WARLOCK_CURSE_WEAKNESS]   = "Spell_Shadow_CurseOfMannoroth",
}

local PLAYBOOK_BUTTONS = { WARLOCK_SPEC_AFFLI, WARLOCK_SPEC_DEMO, WARLOCK_SPEC_DESTRO }
local BUFF_BUTTONS     = { WARLOCK_BUFF_FIRESTONE, WARLOCK_BUFF_SPELLSTONE }
local DEMON_BUTTONS    = { WARLOCK_PET_IMP, WARLOCK_PET_VOIDWALKER, WARLOCK_PET_SUCCUBUS, WARLOCK_PET_FELHUNTER, WARLOCK_PET_FELGUARD }
local SS_BUTTONS       = { WARLOCK_SS_SELF, WARLOCK_SS_MASTER, WARLOCK_SS_TANK, WARLOCK_SS_HEALER }
local CURSE_BUTTONS    = { WARLOCK_CURSE_AGONY, WARLOCK_CURSE_ELEMENTS, WARLOCK_CURSE_DOOM, WARLOCK_CURSE_EXHAUSTION, WARLOCK_CURSE_TONGUES, WARLOCK_CURSE_WEAKNESS }

MultiBot.addWarlock = function(pFrame, pCombat, pNormal)
	MultiBot.AddNonCombatControl(pFrame, 0, pNormal)
	MultiBot.AddCombatControl(pFrame, -30, pCombat)

	-- PLAYBOOK --

	pFrame.addButton("Playbook", -60, 0, "inv_misc_book_06", MultiBot.L("tips.warlock.playbook.master"))
	.doLeft = function(pButton)
		MultiBot.ShowHideSwitch(pButton.getFrame("Playbook"))
	end

	local tPlaybookFrame = pFrame.addFrame("Playbook", -62, 30)
	tPlaybookFrame:Hide()

	MultiBot.AddExclusiveButton(tPlaybookFrame, "Playbook", WARLOCK_SPEC_AFFLI,  0,  WARLOCK_SPEC_ICONS[WARLOCK_SPEC_AFFLI],  MultiBot.L("tips.warlock.playbook.affli"),  "co", WARLOCK_SPEC_AFFLI,  PLAYBOOK_BUTTONS)
	MultiBot.AddExclusiveButton(tPlaybookFrame, "Playbook", WARLOCK_SPEC_DEMO,   26, WARLOCK_SPEC_ICONS[WARLOCK_SPEC_DEMO],   MultiBot.L("tips.warlock.playbook.demo"),   "co", WARLOCK_SPEC_DEMO,   PLAYBOOK_BUTTONS)
	MultiBot.AddExclusiveButton(tPlaybookFrame, "Playbook", WARLOCK_SPEC_DESTRO, 52, WARLOCK_SPEC_ICONS[WARLOCK_SPEC_DESTRO], MultiBot.L("tips.warlock.playbook.destro"), "co", WARLOCK_SPEC_DESTRO, PLAYBOOK_BUTTONS)

	-- WARLOCK STRATEGIES --

	pFrame.addButton("WarlockControl", -90, 0, "INV_Glyph_MajorWarlock", MultiBot.L("tips.warlock.strategy.master"))
	.doLeft = function(pButton)
		MultiBot.ShowHideSwitch(pButton.getFrame("WarlockControlFrame"))
	end

	local tControlFrame = pFrame.addFrame("WarlockControlFrame", -92, 30)
	tControlFrame:Hide()

	local tankOn  = "co +" .. WARLOCK_STRAT_TANK
	local tankOff = "co -" .. WARLOCK_STRAT_TANK
	tControlFrame.addButton("Tank", 0, 0, WARLOCK_STRAT_ICONS[WARLOCK_STRAT_TANK], MultiBot.L("tips.warlock.strategy.tank")).setDisable()
	.doLeft = function(pButton)
		MultiBot.OnOffActionToTarget(pButton, tankOn, tankOff, pButton.getName())
	end

	local metaMeleeOn  = "co +" .. WARLOCK_STRAT_META_MELEE
	local metaMeleeOff = "co -" .. WARLOCK_STRAT_META_MELEE
	tControlFrame.addButton("MetaMelee", 0, 26, WARLOCK_STRAT_ICONS[WARLOCK_STRAT_META_MELEE], MultiBot.L("tips.warlock.strategy.metamelee")).setDisable()
	.doLeft = function(pButton)
		MultiBot.OnOffActionToTarget(pButton, metaMeleeOn, metaMeleeOff, pButton.getName())
	end

	local petOn  = "co +" .. WARLOCK_STRAT_PET
	local petOff = "co -" .. WARLOCK_STRAT_PET
	tControlFrame.addButton("Pet", 0, 52, WARLOCK_STRAT_ICONS[WARLOCK_STRAT_PET], MultiBot.L("tips.warlock.strategy.pet")).setDisable()
	.doLeft = function(pButton)
		MultiBot.OnOffActionToTarget(pButton, petOn, petOff, pButton.getName())
	end

	-- DEMON (pet selection) --

	local demonButton = pFrame.addButton("DemonControl", -120, 0, WARLOCK_PET_ICONS[WARLOCK_PET_IMP], MultiBot.L("tips.warlock.pets.master"))
	demonButton.doLeft = function(pButton)
		MultiBot.ShowHideSwitch(pButton.getFrame("DemonControl"))
	end

	local demonFrame = pFrame.addFrame("DemonControl", -122, 30)
	demonFrame:Hide()

	MultiBot.AddExclusiveButton(demonFrame, "DemonControl", WARLOCK_PET_IMP,        0,   WARLOCK_PET_ICONS[WARLOCK_PET_IMP],        MultiBot.L("tips.warlock.pets.imp"),        "nc", WARLOCK_PET_IMP,        DEMON_BUTTONS)
	MultiBot.AddExclusiveButton(demonFrame, "DemonControl", WARLOCK_PET_VOIDWALKER, 26,  WARLOCK_PET_ICONS[WARLOCK_PET_VOIDWALKER], MultiBot.L("tips.warlock.pets.voidwalker"), "nc", WARLOCK_PET_VOIDWALKER, DEMON_BUTTONS)
	MultiBot.AddExclusiveButton(demonFrame, "DemonControl", WARLOCK_PET_SUCCUBUS,   52,  WARLOCK_PET_ICONS[WARLOCK_PET_SUCCUBUS],   MultiBot.L("tips.warlock.pets.succubus"),   "nc", WARLOCK_PET_SUCCUBUS,   DEMON_BUTTONS)
	MultiBot.AddExclusiveButton(demonFrame, "DemonControl", WARLOCK_PET_FELHUNTER,  78,  WARLOCK_PET_ICONS[WARLOCK_PET_FELHUNTER],  MultiBot.L("tips.warlock.pets.felhunter"),  "nc", WARLOCK_PET_FELHUNTER,  DEMON_BUTTONS)
	MultiBot.AddExclusiveButton(demonFrame, "DemonControl", WARLOCK_PET_FELGUARD,   104, WARLOCK_PET_ICONS[WARLOCK_PET_FELGUARD],   MultiBot.L("tips.warlock.pets.felguard"),   "nc", WARLOCK_PET_FELGUARD,   DEMON_BUTTONS)

	-- SOULSTONE --

	local ssButton = pFrame.addButton("SSControl", -150, 0, WARLOCK_SS_ICONS[WARLOCK_SS_SELF], MultiBot.L("tips.warlock.soulstones.masterbutton"))
	ssButton.doLeft = function(pButton)
		MultiBot.ShowHideSwitch(pButton.getFrame("SSControl"))
	end

	local ssFrame = pFrame.addFrame("SSControl", -152, 30)
	ssFrame:Hide()

	MultiBot.AddExclusiveButton(ssFrame, "SSControl", WARLOCK_SS_SELF,   0,  WARLOCK_SS_ICONS[WARLOCK_SS_SELF],   MultiBot.L("tips.warlock.soulstones.self"),   "nc", WARLOCK_SS_SELF,   SS_BUTTONS)
	MultiBot.AddExclusiveButton(ssFrame, "SSControl", WARLOCK_SS_MASTER, 26, WARLOCK_SS_ICONS[WARLOCK_SS_MASTER], MultiBot.L("tips.warlock.soulstones.master"), "nc", WARLOCK_SS_MASTER, SS_BUTTONS)
	MultiBot.AddExclusiveButton(ssFrame, "SSControl", WARLOCK_SS_TANK,   52, WARLOCK_SS_ICONS[WARLOCK_SS_TANK],   MultiBot.L("tips.warlock.soulstones.tank"),   "nc", WARLOCK_SS_TANK,   SS_BUTTONS)
	MultiBot.AddExclusiveButton(ssFrame, "SSControl", WARLOCK_SS_HEALER, 78, WARLOCK_SS_ICONS[WARLOCK_SS_HEALER], MultiBot.L("tips.warlock.soulstones.healer"), "nc", WARLOCK_SS_HEALER, SS_BUTTONS)

	-- CURSE --

	local curseButton = pFrame.addButton("CurseControl", -180, 0, WARLOCK_CURSE_ICONS[WARLOCK_CURSE_AGONY], MultiBot.L("tips.warlock.curses.master"))
	curseButton.doLeft = function(pButton)
		MultiBot.ShowHideSwitch(pButton.getFrame("CurseControl"))
	end

	local curseFrame = pFrame.addFrame("CurseControl", -182, 30)
	curseFrame:Hide()

	MultiBot.AddExclusiveButton(curseFrame, "CurseControl", WARLOCK_CURSE_AGONY,      0,   WARLOCK_CURSE_ICONS[WARLOCK_CURSE_AGONY],      MultiBot.L("tips.warlock.curses.agony"),      "co", WARLOCK_CURSE_AGONY,      CURSE_BUTTONS)
	MultiBot.AddExclusiveButton(curseFrame, "CurseControl", WARLOCK_CURSE_ELEMENTS,   26,  WARLOCK_CURSE_ICONS[WARLOCK_CURSE_ELEMENTS],   MultiBot.L("tips.warlock.curses.elements"),   "co", WARLOCK_CURSE_ELEMENTS,   CURSE_BUTTONS)
	MultiBot.AddExclusiveButton(curseFrame, "CurseControl", WARLOCK_CURSE_DOOM,       52,  WARLOCK_CURSE_ICONS[WARLOCK_CURSE_DOOM],       MultiBot.L("tips.warlock.curses.doom"),       "co", WARLOCK_CURSE_DOOM,       CURSE_BUTTONS)
	MultiBot.AddExclusiveButton(curseFrame, "CurseControl", WARLOCK_CURSE_EXHAUSTION, 78,  WARLOCK_CURSE_ICONS[WARLOCK_CURSE_EXHAUSTION], MultiBot.L("tips.warlock.curses.exhaustion"), "co", WARLOCK_CURSE_EXHAUSTION, CURSE_BUTTONS)
	MultiBot.AddExclusiveButton(curseFrame, "CurseControl", WARLOCK_CURSE_TONGUES,    104, WARLOCK_CURSE_ICONS[WARLOCK_CURSE_TONGUES],    MultiBot.L("tips.warlock.curses.tongues"),    "co", WARLOCK_CURSE_TONGUES,    CURSE_BUTTONS)
	MultiBot.AddExclusiveButton(curseFrame, "CurseControl", WARLOCK_CURSE_WEAKNESS,   130, WARLOCK_CURSE_ICONS[WARLOCK_CURSE_WEAKNESS],   MultiBot.L("tips.warlock.curses.weakness"),   "co", WARLOCK_CURSE_WEAKNESS,   CURSE_BUTTONS)

	-- BUFFS (weapon stones) --

	pFrame.addButton("BuffControl", -210, 0, WARLOCK_BUFF_ICONS[WARLOCK_BUFF_SPELLSTONE], MultiBot.L("tips.warlock.stones.master"))
	.doLeft = function(pButton)
		MultiBot.ShowHideSwitch(pButton.getFrame("BuffControlFrame"))
	end

	local tBuffFrame = pFrame.addFrame("BuffControlFrame", -212, 30)
	tBuffFrame:Hide()

	MultiBot.AddExclusiveButton(tBuffFrame, "BuffControl", WARLOCK_BUFF_FIRESTONE,  0,  WARLOCK_BUFF_ICONS[WARLOCK_BUFF_FIRESTONE],  MultiBot.L("tips.warlock.stones.firestone"),  "nc", WARLOCK_BUFF_FIRESTONE,  BUFF_BUTTONS)
	MultiBot.AddExclusiveButton(tBuffFrame, "BuffControl", WARLOCK_BUFF_SPELLSTONE, 26, WARLOCK_BUFF_ICONS[WARLOCK_BUFF_SPELLSTONE], MultiBot.L("tips.warlock.stones.spellstone"), "nc", WARLOCK_BUFF_SPELLSTONE, BUFF_BUTTONS)

	-- SET STRATS --

	-- Playbook state --
	local spec = nil
	if     MultiBot.isInside(pCombat, WARLOCK_SPEC_AFFLI)  then spec = WARLOCK_SPEC_AFFLI  tPlaybookFrame.getButton(WARLOCK_SPEC_AFFLI).setEnable()
	elseif MultiBot.isInside(pCombat, WARLOCK_SPEC_DEMO)   then spec = WARLOCK_SPEC_DEMO   tPlaybookFrame.getButton(WARLOCK_SPEC_DEMO).setEnable()
	elseif MultiBot.isInside(pCombat, WARLOCK_SPEC_DESTRO) then spec = WARLOCK_SPEC_DESTRO tPlaybookFrame.getButton(WARLOCK_SPEC_DESTRO).setEnable()
	end
	if spec then
		MultiBot.RestoreExclusiveGroup(pFrame, "Playbook", WARLOCK_SPEC_ICONS[spec], "co", spec, PLAYBOOK_BUTTONS)
	end

	-- Strategy state --
	if MultiBot.isInside(pCombat, WARLOCK_STRAT_TANK)       then tControlFrame.getButton("Tank").setEnable()      end
	if MultiBot.isInside(pCombat, WARLOCK_STRAT_META_MELEE) then tControlFrame.getButton("MetaMelee").setEnable() end
	if MultiBot.isInside(pCombat, WARLOCK_STRAT_PET)        then tControlFrame.getButton("Pet").setEnable()       end

	-- Buff state --
	local buff = nil
	if     MultiBot.isInside(pNormal, WARLOCK_BUFF_FIRESTONE)  then buff = WARLOCK_BUFF_FIRESTONE  tBuffFrame.getButton(WARLOCK_BUFF_FIRESTONE).setEnable()
	elseif MultiBot.isInside(pNormal, WARLOCK_BUFF_SPELLSTONE) then buff = WARLOCK_BUFF_SPELLSTONE tBuffFrame.getButton(WARLOCK_BUFF_SPELLSTONE).setEnable()
	end
	if buff then
		MultiBot.RestoreExclusiveGroup(pFrame, "BuffControl", WARLOCK_BUFF_ICONS[buff], "nc", buff, BUFF_BUTTONS)
	end

	-- Demon state --
	local demon = nil
	if     MultiBot.isInside(pNormal, WARLOCK_PET_IMP)        then demon = WARLOCK_PET_IMP        demonFrame.getButton(WARLOCK_PET_IMP).setEnable()
	elseif MultiBot.isInside(pNormal, WARLOCK_PET_VOIDWALKER) then demon = WARLOCK_PET_VOIDWALKER demonFrame.getButton(WARLOCK_PET_VOIDWALKER).setEnable()
	elseif MultiBot.isInside(pNormal, WARLOCK_PET_SUCCUBUS)   then demon = WARLOCK_PET_SUCCUBUS   demonFrame.getButton(WARLOCK_PET_SUCCUBUS).setEnable()
	elseif MultiBot.isInside(pNormal, WARLOCK_PET_FELHUNTER)  then demon = WARLOCK_PET_FELHUNTER  demonFrame.getButton(WARLOCK_PET_FELHUNTER).setEnable()
	elseif MultiBot.isInside(pNormal, WARLOCK_PET_FELGUARD)   then demon = WARLOCK_PET_FELGUARD   demonFrame.getButton(WARLOCK_PET_FELGUARD).setEnable()
	end
	if demon then
		MultiBot.RestoreExclusiveGroup(pFrame, "DemonControl", WARLOCK_PET_ICONS[demon], "nc", demon, DEMON_BUTTONS)
	end

	-- Soulstone state --
	local ss = nil
	if     MultiBot.isInside(pNormal, WARLOCK_SS_SELF)   then ss = WARLOCK_SS_SELF   ssFrame.getButton(WARLOCK_SS_SELF).setEnable()
	elseif MultiBot.isInside(pNormal, WARLOCK_SS_MASTER) then ss = WARLOCK_SS_MASTER ssFrame.getButton(WARLOCK_SS_MASTER).setEnable()
	elseif MultiBot.isInside(pNormal, WARLOCK_SS_TANK)   then ss = WARLOCK_SS_TANK   ssFrame.getButton(WARLOCK_SS_TANK).setEnable()
	elseif MultiBot.isInside(pNormal, WARLOCK_SS_HEALER) then ss = WARLOCK_SS_HEALER ssFrame.getButton(WARLOCK_SS_HEALER).setEnable()
	end
	if ss then
		MultiBot.RestoreExclusiveGroup(pFrame, "SSControl", WARLOCK_SS_ICONS[ss], "nc", ss, SS_BUTTONS)
	end

	-- Curse state --
	local curse = nil
	if     MultiBot.isInside(pCombat, WARLOCK_CURSE_AGONY)      then curse = WARLOCK_CURSE_AGONY      curseFrame.getButton(WARLOCK_CURSE_AGONY).setEnable()
	elseif MultiBot.isInside(pCombat, WARLOCK_CURSE_ELEMENTS)   then curse = WARLOCK_CURSE_ELEMENTS   curseFrame.getButton(WARLOCK_CURSE_ELEMENTS).setEnable()
	elseif MultiBot.isInside(pCombat, WARLOCK_CURSE_DOOM)       then curse = WARLOCK_CURSE_DOOM       curseFrame.getButton(WARLOCK_CURSE_DOOM).setEnable()
	elseif MultiBot.isInside(pCombat, WARLOCK_CURSE_EXHAUSTION) then curse = WARLOCK_CURSE_EXHAUSTION curseFrame.getButton(WARLOCK_CURSE_EXHAUSTION).setEnable()
	elseif MultiBot.isInside(pCombat, WARLOCK_CURSE_TONGUES)    then curse = WARLOCK_CURSE_TONGUES    curseFrame.getButton(WARLOCK_CURSE_TONGUES).setEnable()
	elseif MultiBot.isInside(pCombat, WARLOCK_CURSE_WEAKNESS)   then curse = WARLOCK_CURSE_WEAKNESS   curseFrame.getButton(WARLOCK_CURSE_WEAKNESS).setEnable()
	end
	if curse then
		MultiBot.RestoreExclusiveGroup(pFrame, "CurseControl", WARLOCK_CURSE_ICONS[curse], "co", curse, CURSE_BUTTONS)
	end
end