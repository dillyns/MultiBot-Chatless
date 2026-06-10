local MultiBot = _G.MultiBot
if not MultiBot then return end

MultiBot.data = MultiBot.data or {}

MultiBot.data.petFamily = {
  [1]  = {enUS="Wolf",         deDE="Wolf",            frFR="Loup",                 esES="Lobo",             esMX="Lobo",             ruRU="Волк",          koKR="늑대",          zhCN="狼",        zhTW="狼"},
  [2]  = {enUS="Cat",          deDE="Katze",           frFR="Félin",                esES="Felino",           esMX="Felino",           ruRU="Кошка",         koKR="살쾡이",        zhCN="猫",        zhTW="貓"},
  [3]  = {enUS="Spider",       deDE="Spinne",          frFR="Araignée",             esES="Araña",            esMX="Araña",            ruRU="Паук",          koKR="거미",          zhCN="蜘蛛",      zhTW="蜘蛛"},
  [4]  = {enUS="Bear",         deDE="Bär",             frFR="Ours",                 esES="Oso",              esMX="Oso",              ruRU="Медведь",       koKR="곰",            zhCN="熊",        zhTW="熊"},
  [5]  = {enUS="Boar",         deDE="Eber",            frFR="Sanglier",             esES="Jabalí",           esMX="Jabalí",           ruRU="Кабан",         koKR="멧돼지",        zhCN="野猪",      zhTW="野豬"},
  [6]  = {enUS="Crocolisk",    deDE="Krokilisk",       frFR="Crocilisque",          esES="Crocolisco",       esMX="Crocolisco",       ruRU="Кроколиск",     koKR="악어",          zhCN="鳄鱼",      zhTW="鱷魚"},
  [7]  = {enUS="Carrion Bird", deDE="Aasvogel",        frFR="Charognard",           esES="Ave carroñera",    esMX="Ave carroñera",    ruRU="Падальщик",     koKR="독수리",        zhCN="食腐鸟",    zhTW="食腐鳥"},
  [8]  = {enUS="Crab",         deDE="Krabbe",          frFR="Crabe",                esES="Cangrejo",         esMX="Cangrejo",         ruRU="Краб",          koKR="게",            zhCN="螃蟹",      zhTW="螃蟹"},
  [9]  = {enUS="Gorilla",      deDE="Gorilla",         frFR="Gorille",              esES="Gorila",           esMX="Gorila",           ruRU="Горилла",       koKR="고릴라",        zhCN="猩猩",      zhTW="大猩猩"},
  [11] = {enUS="Raptor",       deDE="Raptor",          frFR="Raptor",               esES="Raptor",           esMX="Raptor",           ruRU="Ящер",          koKR="랩터",          zhCN="迅猛龙",    zhTW="迅猛龍"},
  [12] = {enUS="Tallstrider",  deDE="Weitschreiter",   frFR="Haut-trotteur",        esES="Zancudo",          esMX="Zancudo",          ruRU="Долгоног",      koKR="타조",          zhCN="长颈陆行鸟", zhTW="長腳陸行鳥"},
  [20] = {enUS="Scorpid",      deDE="Skorpid",         frFR="Scorpid",              esES="Escórpido",        esMX="Escórpido",        ruRU="Скорпид",       koKR="전갈",          zhCN="蝎子",      zhTW="毒蠍"},
  [21] = {enUS="Turtle",       deDE="Schildkröte",     frFR="Tortue",               esES="Tortuga",          esMX="Tortuga",          ruRU="Черепаха",      koKR="거북",          zhCN="海龟",      zhTW="海龜"},
  [24] = {enUS="Bat",          deDE="Fledermaus",      frFR="Chauve-souris",        esES="Murciélago",       esMX="Murciélago",       ruRU="Летучая мышь",  koKR="박쥐",          zhCN="蝙蝠",      zhTW="蝙蝠"},
  [25] = {enUS="Hyena",        deDE="Hyäne",           frFR="Hyène",                esES="Hiena",            esMX="Hiena",            ruRU="Гиена",         koKR="하이에나",      zhCN="土狼",      zhTW="土狼"},
  [26] = {enUS="Bird of Prey", deDE="Raubvogel",       frFR="Oiseau de proie",      esES="Ave rapaz",        esMX="Ave rapaz",        ruRU="Хищная птица",  koKR="맹금수",        zhCN="猎鹰",      zhTW="猛禽"},
  [27] = {enUS="Wind Serpent", deDE="Windnatter",      frFR="Serpent des vents",    esES="Serpiente alada",  esMX="Serpiente alada",  ruRU="Крылатый змей", koKR="풍뱀",          zhCN="风蛇",      zhTW="風蛇"},
  [30] = {enUS="Dragonhawk",   deDE="Drachenfalke",    frFR="Faucon-dragon",        esES="Halcón dracónico", esMX="Halcón dracónico", ruRU="Дракондор",     koKR="용매",          zhCN="龙鹰",      zhTW="龍鷹"},
  [31] = {enUS="Ravager",      deDE="Verheerer",       frFR="Ravageur",             esES="Devastador",       esMX="Devastador",       ruRU="Опустошитель",  koKR="칼날발톱",      zhCN="劫掠者",    zhTW="劫掠者"},
  [32] = {enUS="Warp Stalker", deDE="Sphärenpirscher", frFR="Traqueur dimensionnel", esES="Acechador vil",   esMX="Acechador vil",   ruRU="Прыгуана",      koKR="차원의 추적자", zhCN="扭曲猎手",  zhTW="扭曲巡者"},
  [33] = {enUS="Sporebat",     deDE="Sporensegler",    frFR="Sporoptère",           esES="Esporiélago",      esMX="Esporiélago",      ruRU="Спороскат",     koKR="포자날개",      zhCN="孢子蝠",    zhTW="孢子蝙蝠"},
  [34] = {enUS="Nether Ray",   deDE="Netherrochen",    frFR="Raie du Néant",        esES="Raya abisal",      esMX="Raya abisal",      ruRU="Скат Пустоты",  koKR="황천의 가오리", zhCN="虚空鳐",    zhTW="虛空魟"},
  [35] = {enUS="Serpent",      deDE="Schlange",        frFR="Serpent",              esES="Serpiente",        esMX="Serpiente",        ruRU="Змея",          koKR="뱀",            zhCN="蛇",        zhTW="蛇"},
  [37] = {enUS="Moth",         deDE="Motte",           frFR="Phalène",              esES="Polilla",          esMX="Polilla",          ruRU="Мотылек",       koKR="나방",          zhCN="蛾",        zhTW="蛾"},
  [38] = {enUS="Chimaera",     deDE="Chimäre",         frFR="Chimère",              esES="Quimera",          esMX="Quimera",          ruRU="Химера",        koKR="키메라",        zhCN="双头龙",    zhTW="奇美拉"},
  [39] = {enUS="Devilsaur",    deDE="Teufelssaurier",  frFR="Diablosaurien",        esES="Devilsaurio",      esMX="Devilsaurio",      ruRU="Дьявозавр",     koKR="악마사우루스",  zhCN="魔暴龙",    zhTW="魔暴龍"},
  [41] = {enUS="Silithid",     deDE="Silithide",       frFR="Silithide",            esES="Silítido",         esMX="Silítido",         ruRU="Силитид",       koKR="실리시드",      zhCN="异种蝎",    zhTW="異種蟲"},
  [42] = {enUS="Worm",         deDE="Wurm",            frFR="Ver",                  esES="Gusano",           esMX="Gusano",           ruRU="Червь",         koKR="벌레",          zhCN="蠕虫",      zhTW="蠕蟲"},
  [43] = {enUS="Rhino",        deDE="Nashorn",         frFR="Rhinocéros",           esES="Rinoceronte",      esMX="Rinoceronte",      ruRU="Носорог",       koKR="코뿔소",        zhCN="犀牛",      zhTW="犀牛"},
  [44] = {enUS="Wasp",         deDE="Wespe",           frFR="Guêpe",                esES="Avispa",           esMX="Avispa",           ruRU="Оса",           koKR="말벌",          zhCN="黄蜂",      zhTW="黃蜂"},
  [45] = {enUS="Core Hound",   deDE="Kernhund",        frFR="Chien du magma",       esES="Can del Núcleo",   esMX="Can del Núcleo",   ruRU="Гончая Недр",   koKR="용암사냥개",    zhCN="核犬",      zhTW="熔核犬"},
  [46] = {enUS="Spirit Beast", deDE="Geisterbestie",   frFR="Bête spirituelle",     esES="Bestia espíritu",  esMX="Bestia espíritu",  ruRU="Дух зверя",     koKR="영혼의 야수",   zhCN="灵魂兽",    zhTW="靈魂獸"},
}
