local MultiBot = _G.MultiBot

local ClassStrategies = {}
MultiBot.ClassStrategies = ClassStrategies

local function entry(name, prefix, icon, alias)
  return {
    name = name,
    prefix = prefix,
    icon = icon,
    alias = alias,
  }
end

local function group(key, masterIcon, mode, entries)
  return {
    key = key,
    masterIcon = masterIcon,
    mode = mode,
    entries = entries,
  }
end

local sharedNonCombat = group("nonCombat", "INV_Scroll_01", "toggle", {
  entry("buff,", "nc", "spell_holy_power"),
  entry("food", "nc", "inv_drink_24_sealwhey"),
  entry("loot", "nc", "inv_misc_coin_16"),
  entry("gather", "nc", "trade_mining"),
})

local sharedCombat = group("combat", "INV_Sword_06", "toggle", {
  entry("dps assist", "co", "spell_holy_heroism.blp"),
  entry("tank assist", "co", "ability_warrior_innerrage.blp"),
  entry("avoid aoe", "co", "spell_shadow_antishadow.blp"),
  entry("save mana", "co", "spell_frost_manarecharge.blp"),
  entry("threat", "co", "ability_warrior_challange.blp"),
  entry("behind", "co", "ability_backstab.blp"),
})

local function playbook(entries)
  return group("Playbook", "inv_misc_book_06", "exclusive", entries)
end

local function toggleGroup(key, icon, entries)
  return group(key, icon, "toggle", entries)
end

local function exclusiveGroup(key, icon, entries)
  return group(key, icon, "exclusive", entries)
end

ClassStrategies.shared = { sharedNonCombat, sharedCombat }

ClassStrategies[1] = {
  playbook({ entry("tank", "co", "ability_warrior_shieldmastery", "prot"), entry("arms", "co", "ability_warrior_savageblow"), entry("fury", "co", "ability_warrior_innerrage") }),
}

ClassStrategies[2] = {
  playbook({ entry("heal", "co", "spell_holy_holybolt", "holy"), entry("dps", "co", "spell_holy_auraoflight", "ret"), entry("tank", "co", "spell_holy_devotionaura", "prot"), entry("offheal", "co", "spell_holy_flashheal") }),
  toggleGroup("PaladinControl", "INV_Glyph_MajorPaladin", { entry("healer dps", "co", "spell_holy_healingaura") }),
  exclusiveGroup("NonCombatAura", "spell_holy_auraoflight", { entry("bspeed", "nc", "spell_holy_crusaderaura"), entry("rfire", "nc", "spell_fire_sealoffire"), entry("rfrost", "nc", "spell_frost_wizardmark"), entry("rshadow", "nc", "spell_shadow_sealofkings"), entry("baoe", "nc", "spell_holy_auraoflight"), entry("barmor", "nc", "spell_holy_devotionaura"), entry("bcast", "nc", "spell_holy_mindsooth") }),
  exclusiveGroup("CombatAura", "spell_holy_auraoflight", { entry("bspeed", "co", "spell_holy_crusaderaura"), entry("rfire", "co", "spell_fire_sealoffire"), entry("rfrost", "co", "spell_frost_wizardmark"), entry("rshadow", "co", "spell_shadow_sealofkings"), entry("baoe", "co", "spell_holy_auraoflight"), entry("barmor", "co", "spell_holy_devotionaura"), entry("bcast", "co", "spell_holy_mindsooth") }),
  exclusiveGroup("BlessingControl", "spell_holy_sealofwisdom", { entry("bsanc", "nc", "spell_nature_lightningshield"), entry("bwisdom", "nc", "spell_holy_sealofwisdom"), entry("bkings", "nc", "spell_magic_magearmor"), entry("bmight", "nc", "spell_holy_fistofjustice") }),
}

ClassStrategies[3] = {
  playbook({ entry("bm", "co", "ability_hunter_beasttaming"), entry("mm", "co", "ability_marksmanship"), entry("surv", "co", "ability_hunter_swiftstrike") }),
  toggleGroup("HunterControl", "INV_Glyph_MajorHunter", { entry("trap weave", "co", "ability_ensnare") }),
  exclusiveGroup("HunterNCBuffControl", "ability_hunter_pet_dragonhawk", { entry("bspeed", "nc", "ability_mount_whitetiger"), entry("bdps", "nc", "ability_hunter_pet_dragonhawk"), entry("rnature", "nc", "spell_nature_protectionformnature") }),
  exclusiveGroup("HunterBuffControl", "ability_hunter_pet_dragonhawk", { entry("bspeed", "co", "ability_mount_whitetiger"), entry("bdps", "co", "ability_hunter_pet_dragonhawk"), entry("rnature", "co", "spell_nature_protectionformnature") }),
}

ClassStrategies[4] = {
  playbook({ entry("dps", "co", "ability_backstab"), entry("melee", "co", "ability_rogue_eviscerate") }),
  toggleGroup("RogueControl", "INV_Glyph_MajorRogue", { entry("stealth", "co", "ability_stealth"), entry("stealthed", "co", "ability_rogue_ambush") }),
}

ClassStrategies[5] = {
  playbook({ entry("heal", "co", "spell_holy_wordfortitude", "disc"), entry("dps", "co", "spell_shadow_shadowwordpain", "shadow"), entry("holy dps", "co", "spell_holy_searinglight"), entry("holy heal", "co", "spell_holy_holybolt", "holy") }),
  toggleGroup("PriestControl", "INV_Glyph_MajorPriest", { entry("shadow debuff", "co", "spell_holy_stoicism"), entry("shadow aoe", "co", "spell_shadow_mindshear"), entry("rshadow", "co", "spell_shadow_antishadow"), entry("healer dps", "co", "spell_holy_holysmite") }),
}

ClassStrategies[6] = {
  playbook({ entry("blood", "co", "spell_deathknight_bloodpresence"), entry("frost", "co", "spell_deathknight_frostpresence"), entry("unholy", "co", "spell_deathknight_unholypresence") }),
  toggleGroup("DkControl", "INV_Glyph_MajorDeathKnight", { entry("frost aoe", "co", "spell_frost_arcticwinds"), entry("unholy aoe", "co", "spell_shadow_plaguecloud") }),
}

ClassStrategies[7] = {
  playbook({ entry("enh", "co", "spell_nature_lightningshield"), entry("ele", "co", "spell_nature_lightning"), entry("resto", "co", "spell_nature_magicimmunity") }),
  toggleGroup("ShamanControl", "INV_Glyph_MajorShaman", { entry("healer dps", "co", "INV_Alchemy_Elixir_02") }),
  exclusiveGroup("earth", "inv_relics_totemofrebirth", { entry("strength of earth", "co", "spell_nature_earthbindtotem"), entry("stoneskin", "co", "spell_nature_stoneskintotem"), entry("tremor", "co", "spell_nature_tremortotem"), entry("earthbind", "co", "spell_nature_strengthofearthtotem02") }),
  exclusiveGroup("fire", "inv_relics_totemofrebirth", { entry("searing", "co", "spell_fire_searingtotem"), entry("magma", "co", "spell_fire_moltenblood"), entry("flametongue", "co", "spell_nature_guardianward"), entry("wrath", "co", "spell_fire_totemofwrath"), entry("frost resistance", "co", "spell_frost_frostward") }),
  exclusiveGroup("water", "inv_relics_totemofrebirth", { entry("healing stream", "co", "spell_nature_healingwavelesser"), entry("mana spring", "co", "spell_nature_manaregentotem"), entry("cleansing", "co", "spell_nature_nullifydisease"), entry("fire resistance", "co", "spell_fire_firearmor") }),
  exclusiveGroup("air", "inv_relics_totemofrebirth", { entry("wrath of air", "co", "spell_nature_slowingtotem"), entry("windfury", "co", "spell_nature_windfury"), entry("nature resistance", "co", "spell_nature_natureresistancetotem"), entry("grounding", "co", "spell_nature_groundingtotem") }),
}

ClassStrategies[8] = {
  playbook({ entry("arcane", "co", "spell_holy_magicalsentry"), entry("frost", "co", "spell_frost_frostbolt02"), entry("fire", "co", "spell_fire_flamebolt"), entry("frostfire", "co", "ability_mage_frostfirebolt") }),
  toggleGroup("MageControl", "INV_Glyph_MajorMage", { entry("firestarter", "co", "ability_mage_firestarter") }),
  exclusiveGroup("MageBuffControl", "spell_magearmor", { entry("bmana", "nc", "spell_magearmor"), entry("bdps", "nc", "ability_mage_moltenarmor") }),
}

ClassStrategies[9] = {
  playbook({ entry("affli", "co", "spell_shadow_deathcoil"), entry("demo", "co", "spell_shadow_metamorphosis"), entry("destro", "co", "spell_shadow_rainoffire") }),
  toggleGroup("WarlockControl", "INV_Glyph_MajorWarlock", { entry("tank", "co", "spell_fire_soulburn"), entry("meta melee", "co", "spell_shadow_demonform"), entry("pet", "co", "spell_shadow_enslavedemon") }),
  exclusiveGroup("DemonControl", "spell_shadow_summonimp", { entry("imp", "nc", "spell_shadow_summonimp"), entry("voidwalker", "nc", "spell_shadow_summonvoidwalker"), entry("succubus", "nc", "spell_shadow_summonsuccubus"), entry("felhunter", "nc", "spell_shadow_summonfelhunter"), entry("felguard", "nc", "spell_shadow_summonfelguard") }),
  exclusiveGroup("SSControl", "spell_shadow_soulgem", { entry("ss self", "nc", "spell_shadow_soulgem"), entry("ss master", "nc", "inv_crown_01"), entry("ss tank", "nc", "ability_defend"), entry("ss healer", "nc", "INV_Elemental_Primal_life") }),
  exclusiveGroup("CurseControl", "Spell_Shadow_CurseOfSargeras", { entry("curse of agony", "co", "Spell_Shadow_CurseOfSargeras"), entry("curse of elements", "co", "Spell_Shadow_ChillTouch"), entry("curse of doom", "co", "Spell_Shadow_AuraOfDarkness"), entry("curse of exhaustion", "co", "Spell_Shadow_GrimWard"), entry("curse of tongues", "co", "Spell_Shadow_CurseOfTounges"), entry("curse of weakness", "co", "Spell_Shadow_CurseOfMannoroth") }),
  exclusiveGroup("BuffControl", "inv_misc_gem_bloodstone_02", { entry("firestone", "nc", "inv_misc_gem_bloodstone_02"), entry("spellstone", "nc", "inv_misc_gem_sapphire_01") }),
}

ClassStrategies[11] = {
  playbook({ entry("resto", "co", "spell_nature_healingtouch"), entry("balance", "co", "spell_nature_starfall"), entry("cat", "co", "ability_druid_catform"), entry("bear", "co", "ability_racial_bearform") }),
  toggleGroup("DruidControl", "INV_Glyph_MajorDruid", { entry("healer dps", "co", "spell_nature_abolishmagic"), entry("blanketing", "co", "spell_nature_rejuvenation"), entry("tranquility", "co", "spell_nature_tranquility"), entry("feral charge", "co", "Spell_Druid_feralchargecat"), entry("offheal", "co", "spell_nature_resistnature") }),
}

return ClassStrategies
