-- Confirmation popup for Autogear
if not StaticPopupDialogs["MULTIBOT_AUTOGEAR_CONFIRM"] then
  StaticPopupDialogs["MULTIBOT_AUTOGEAR_CONFIRM"] = {
    text = MultiBot.L("tips.every.autogearpopup"),
    button1 = ACCEPT,
    button2 = CANCEL,
    OnAccept = function(self, data)
      if data and data.target then
        SendChatMessage("autogear", "WHISPER", nil, data.target)
      end
    end,
    timeout = 0,
    whileDead = 1,
    hideOnEscape = 1,
    preferredIndex = 3, -- évite les conflits d’index avec d’autres popups
  }
end

local function showEveryMessage(message)
  if DEFAULT_CHAT_FRAME and DEFAULT_CHAT_FRAME.AddMessage then
    DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99MultiBot|r " .. tostring(message or ""))
  elseif print then
    print("MultiBot " .. tostring(message or ""))
  end
end

local function runBotCombatCommand(button, command)
  if not button or type(command) ~= "string" or command == "" then
    return false
  end

  local botName = button.getName and button.getName() or ""
  if botName == "" then
    return false
  end

  local comm = MultiBot and MultiBot.Comm or nil
  if comm and comm.RunCombatCommand and comm.RunCombatCommand("BOT", botName, command) then
    return true
  end

  showEveryMessage(MultiBot.L("tips.every.combatbridge", "Bridge unavailable: combat command was not sent."))
  return false
end

local function runBotCombatToggle(button, enableCommand, disableCommand)
  if not button then
    return
  end

  if button.state then
    if runBotCombatCommand(button, disableCommand) then
      button.setDisable()
    end
  elseif runBotCombatCommand(button, enableCommand) then
    button.setEnable()
  end
end

local function addBotCombatButton(parent, name, x, y, icon, tip, enableCommand, disableCommand)
  local button = parent.addButton(name, x, y, icon, tip)

  if disableCommand then
    button.setDisable()
    button.doLeft = function(self)
      runBotCombatToggle(self, enableCommand, disableCommand)
    end
  else
    button.doLeft = function(self)
      runBotCombatCommand(self, enableCommand)
    end
  end

  return button
end

-- Adds a sub-button to an exclusive radio group dropdown.
-- Left-click: selects this strat (enables self + master, disables siblings, wires master doRight).
-- Master doRight: sends "mode -strat", disables master + all siblings.
-- tFrame: the dropdown frame. masterKey: name of the master button on the parent frame.
-- siblings: ordered list of all button names in this group (used for mutual exclusion).
function MultiBot.AddExclusiveButton(tFrame, masterKey, name, y, icon, tip, mode, strat, siblings)
	local onCmd  = mode .. " +" .. strat
	local offCmd = mode .. " -" .. strat
	tFrame.addButton(name, 0, y, icon, tip).setDisable()
	.doLeft = function(pButton)
		MultiBot.SelectToTarget(pButton.get(), masterKey, pButton.texture, onCmd, pButton.getName())
		pButton.setEnable()
		local master = pButton.getButton(masterKey)
		master.setEnable()
		for _, other in ipairs(siblings) do
			if other ~= name then pButton.getButton(other).setDisable() end
		end
		master.doRight = function(btn)
			MultiBot.ActionToTarget(offCmd, btn.getName())
			btn.setDisable()
			for _, other in ipairs(siblings) do
				pButton.getButton(other).setDisable()
			end
		end
	end
end

-- Restores an exclusive group master button to its active state on load.
-- Sets master texture, enables it, and wires doRight to send "mode -strat" + disable all.
function MultiBot.RestoreExclusiveGroup(pFrame, masterKey, icon, mode, strat, siblings)
	local offCmd = mode .. " -" .. strat
	local master = pFrame.getButton(masterKey)
	master.setTexture(icon)
	master.setEnable()
	master.doRight = function(btn)
		MultiBot.ActionToTarget(offCmd, btn.getName())
		btn.setDisable()
		for _, other in ipairs(siblings) do
			pFrame.getButton(other).setDisable()
		end
	end
end

MultiBot.addEvery = function(pFrame, pCombat, pNormal)

    -- MENU MISC --------------------------------------------
    -- Crée un sous-frame « Misc » au-dessus du bouton
    local tMisc = pFrame.addFrame("Misc",  64,  29)
    tMisc:Hide()

    -- Bouton parent « Misc »
    local btnMisc = pFrame.addButton("Misc",  64,  0, "inv_misc_enggizmos_swissarmy", MultiBot.L("tips.every.misc"))
    btnMisc.doLeft = function(self)
       MultiBot.ShowHideSwitch(tMisc)
    end

    -- Texture étoile
    local STAR_TEX = "Interface\\TARGETINGFRAME\\UI-RaidTargetingIcon_1"
    local y, dy = 0, 28
    -- Buttons inside the "Misc" sub-frame
	for _, data in ipairs{
		{ "Wipe", "Achievement_Halloween_Ghost_01", MultiBot.L("tips.every.wipe"), function(b)
		    MultiBot.ActionToTarget("wipe", b.getName())
          end
		},
		{ "Autogear", "inv_misc_enggizmos_30", MultiBot.L("tips.every.autogear"), function(b)
            StaticPopup_Show("MULTIBOT_AUTOGEAR_CONFIRM", b.getName(), nil, { target = b.getName() })
          end
        },
        -- NEW: Favorite toggle (per-character)
        -- { "Favorite",   "Interface\\RaidFrame\\ReadyCheck-Ready",  MultiBot.L("tips.every.favorite"), function(b)
        -- Favorite toggle (per-character) - étoile
        { "Favorite",   STAR_TEX,  MultiBot.L("tips.every.favorite"), function(b)
            local name = b.getName()
            MultiBot.ToggleFavorite(name)
            local tex = b.icon
            if tex then
              tex:SetTexture(MultiBot.SafeTexturePath(STAR_TEX))
			  local isFav = MultiBot.IsFavorite(name)
              -- Griser l’étoile quand favori, sinon couleur normale
              if tex.SetDesaturated then tex:SetDesaturated(isFav) end
              if tex.SetVertexColor then
                if isFav then tex:SetVertexColor(0.5, 0.5, 0.5) else tex:SetVertexColor(1, 1, 1) end
              end
            end
            -- If the current roster filter is "favorites", refresh the list
            local unitsBtn = MultiBot.frames and
                MultiBot.frames["MultiBar"] and
                MultiBot.frames["MultiBar"].buttons and
                MultiBot.frames["MultiBar"].buttons["Units"]
            if unitsBtn and unitsBtn.roster == "favorites" then
              unitsBtn.doLeft(unitsBtn, "favorites", unitsBtn.filter)
            end
          end
        },
        { "CharacterInfo", "inv_misc_note_05", MultiBot.L("tips.every.characterinfo", "Infos personnage"), function(b)
            if MultiBot.OpenCharacterInfo then
                MultiBot.OpenCharacterInfo(b.getName())
            end
        end
        },
		{ "Maintenance", "Achievement_Halloween_Smiley_01", MultiBot.L("tips.every.maintenance"), function(b)
            SendChatMessage("maintenance", "WHISPER", nil, b.getName())
        end
        },
	} do
		local btn = tMisc.addButton(data[1], 0, y, data[2], data[3])
		btn.doLeft = data[4]
		y = y + dy
	end


    -- Initialize the Favorite icon to the correct state if this bot is already saved
    do
      local favBtn = tMisc.buttons and tMisc.buttons["Favorite"]
      if favBtn then
        local name = favBtn.getName and favBtn.getName()
        local tex = favBtn.icon
        if tex then
          tex:SetTexture(MultiBot.SafeTexturePath(STAR_TEX))
          local isFav = (name and MultiBot.IsFavorite and MultiBot.IsFavorite(name)) and true or false
          -- Appliquer l’état visuel au chargement
          if tex.SetDesaturated then tex:SetDesaturated(isFav) end
          if tex.SetVertexColor then
            if isFav then tex:SetVertexColor(0.5, 0.5, 0.5) else tex:SetVertexColor(1, 1, 1) end
          end
        end
      end
    end
    -- MENU MISC END-----------------------------------------

	pFrame.addButton("Summon", 94, 0, "ability_hunter_beastcall", MultiBot.L("tips.every.summon"))
	.doLeft = function(pButton)
		MultiBot.ActionToTarget("summon", pButton.getName())
	end

	pFrame.addButton("Uninvite", 124, 0, "inv_misc_grouplooking", MultiBot.L("tips.every.uninvite")).doShow()
	.doLeft = function(pButton)
		MultiBot.doSlash("/uninvite", pButton.getName())
		pButton.getButton("Invite").doShow()
		pButton.doHide()
	end

	pFrame.addButton("Invite", 124, 0, "inv_misc_groupneedmore", MultiBot.L("tips.every.invite")).doHide()
	.doLeft = function(pButton)
		MultiBot.doSlash("/invite", pButton.getName())
		pButton.getButton("Uninvite").doShow()
		pButton.doHide()
	end

	-- Selfbot is not allowed to use these Tools --
	if(pFrame.getName() == UnitName("player")) then return end

	pFrame.addButton("Inventory", 154, 0, "inv_misc_bag_08", MultiBot.L("tips.every.inventory")).setDisable()
	.doLeft = function(pButton)
		if(pButton.state) then
			MultiBot.inventory:Hide()
			pButton.setDisable()
			if(MultiBot.SyncToolWindowButtons) then
				MultiBot.SyncToolWindowButtons(nil, nil)
			end
			return
		end

		if(MultiBot.RequestBotInventory and MultiBot.RequestBotInventory(pButton.getName())) then
			if(MultiBot.SyncToolWindowButtons) then
				MultiBot.SyncToolWindowButtons(pButton.getName(), "Inventory")
			end
			return
		end

		pButton.setEnable()
		if(MultiBot.SyncToolWindowButtons) then
			MultiBot.SyncToolWindowButtons(pButton.getName(), "Inventory")
		end
	end

	pFrame.addButton("Outfits", 274, 0, "inv_chest_chain_15", MultiBot.L("tips.every.outfits", "Outfits")).setDisable()
	.doLeft = function(pButton)
		if(MultiBot.OpenBotOutfits) then
			MultiBot.OpenBotOutfits(pButton.getName(), pButton)
		end
	end

	pFrame.addButton("Trainer", 304, 0, "spell_holy_magicalsentry", MultiBot.L("tips.every.trainer", "Trainer")).setDisable()
	.doLeft = function(pButton)
		if(MultiBot.OpenBotTrainer) then
			MultiBot.OpenBotTrainer(pButton.getName(), pButton)
		end
	end

	local botName = pFrame.getName and pFrame.getName() or nil
	if MultiBot.BuildBotRTIUI and botName and botName ~= "" then
		MultiBot.BuildBotRTIUI(pFrame, botName, 334, 0)
	end

	local combatFrame = pFrame.addFrame("CombatCommands", 364, 29, nil, 58, 88)
	combatFrame:Hide()
	combatFrame._mbDropdownManaged = true

	pFrame.addButton("Combat", 364, 0, "Ability_Warrior_BattleShout", MultiBot.L("tips.every.combat"))
	.doLeft = function()
		MultiBot.ShowHideSwitch(combatFrame)
	end

	addBotCombatButton(combatFrame, "CombatFocus", -28, 56, "Ability_Hunter_MasterMarksman", MultiBot.L("tips.every.combatfocus"), "co +focus", "co -focus")
	addBotCombatButton(combatFrame, "CombatAoe", 0, 56, "Spell_Fire_SelfDestruct", MultiBot.L("tips.every.combataoe"), "co +aoe", "co -aoe")
	addBotCombatButton(combatFrame, "CombatWait0", -28, 28, "Spell_Holy_BorrowedTime", MultiBot.L("tips.every.combatwait0"), "wait for attack time 0")
	addBotCombatButton(combatFrame, "CombatWait3", 0, 28, "Spell_Holy_BorrowedTime", MultiBot.L("tips.every.combatwait3"), "wait for attack time 3")
	addBotCombatButton(combatFrame, "CombatWait5", -28, 0, "Spell_Holy_BorrowedTime", MultiBot.L("tips.every.combatwait5"), "wait for attack time 5")
	addBotCombatButton(combatFrame, "CombatWait10", 0, 0, "Spell_Holy_BorrowedTime", MultiBot.L("tips.every.combatwait10"), "wait for attack time 10")

	pFrame.addButton("Spellbook", 184, 0, "inv_misc_book_09", MultiBot.L("tips.every.spellbook")).setDisable()
	.doLeft = function(pButton)
		if(pButton.state) then
			MultiBot.spellbook:Hide()
			pButton.setDisable()
		else
			local tUnits = MultiBot.frames["MultiBar"].frames["Units"]
			for key, value in pairs(MultiBot.index.actives) do
				if(tUnits.buttons[value].name ~= UnitName("player")) then
					tUnits.frames[value].getButton("Spellbook").setDisable()
				end
			end

			pButton.setEnable()
			MultiBot.spellbook.name = pButton.getName()

			local tBridge = MultiBot and MultiBot.bridge or nil
			local tComm = MultiBot and MultiBot.Comm or nil
			if(tBridge and tBridge.connected and tComm and tComm.RequestSpellbook and tComm.RequestSpellbook(pButton.getName())) then
				tUnits.buttons[MultiBot.spellbook.name].waitFor = ""
				return
			end

			if(MultiBot.allowLegacyChatFallback == true) then
				tUnits.buttons[MultiBot.spellbook.name].waitFor = "SPELLBOOK"
				SendChatMessage("spells", "WHISPER", nil, pButton.getName())
			else
				tUnits.buttons[MultiBot.spellbook.name].waitFor = ""
			end
		end
	end

	pFrame.addButton("Talent", 214, 0, "ability_marksmanship", MultiBot.L("tips.every.talent")).setDisable()
	.doLeft = function(pButton)
		if(pButton.state) then
			pButton.setDisable()
			MultiBot.talent:Hide()
		elseif(UnitLevel(MultiBot.toUnit(pButton.getName())) < 10) then
			SendChatMessage(MultiBot.L("info.talent.Level"), "SAY")
		elseif(CheckInteractDistance(MultiBot.toUnit(pButton.getName()), 1) == nil) then
			SendChatMessage(MultiBot.L("info.talent.OutOfRange"), "SAY")
		else
			MultiBot.talent:Hide()
			MultiBot.talent.doClear()

			local tUnits = MultiBot.frames["MultiBar"].frames["Units"]
			for key, value in pairs(MultiBot.index.actives) do
				if(tUnits.buttons[value].name ~= UnitName("player")) then
					tUnits.frames[value].getButton("Talent").setDisable()
				end
			end

			InspectUnit(MultiBot.toUnit(pButton.getName()))
			pButton.setEnable()

			MultiBot.talent.name = pButton.getName()
			MultiBot.talent.class = pButton.getClass()
			MultiBot.auto.talent = true
		end
	end

	-- BOUTON SETTALENTS : toggle affichage de la barre des specs
    local btn = pFrame
        .addButton("SetTalents", 244, 0, "inv_sword_22", MultiBot.L("tips.every.settalent"))
    -- état initial : toujours désactivé (zen, pas de barre affichée au load)
    btn:setDisable()

    btn.doLeft = function(self)
      -- si le dropdown existe et est visible → on le ferme
      if MultiBot.spec.dropdown and MultiBot.spec.dropdown:IsShown() then
        MultiBot.spec:HideDropdown()
        self:setDisable()
      else
        -- sinon on envoie la requête au bot, et on active le bouton
        MultiBot.spec:RequestList(self:getName(), self)
        self:setEnable()
      end
    end

-- STRATEGIES --

end

local function sendCommonStrategy(pButton, command)
	local botName = pButton and pButton.getName and pButton.getName() or nil
	if type(botName) ~= "string" or botName == "" then
		return false
	end

	if MultiBot.Comm and type(MultiBot.Comm.RunCombatCommand) == "function" then
		return MultiBot.Comm.RunCombatCommand("BOT", botName, command)
	end

	SendChatMessage(command, "WHISPER", nil, botName)
	return true
end

local function addCommonStrategyButton(pFrame, pState, buttonName, y, icon, tipKey, strategyName, prefix)
	if not pFrame or not pFrame.addButton then
		return
	end

	local plusCommand  = prefix .. " +" .. strategyName
	local minusCommand = prefix .. " -" .. strategyName

	local button = pFrame.addButton(
		buttonName,
		0,
		y,
		"Interface\\Icons\\" .. icon,
		MultiBot.L(tipKey)
	):setDisable()

	button.doLeft = function(self)
		if MultiBot.OnOffSwitch(self) then
			sendCommonStrategy(self, plusCommand)
		else
			sendCommonStrategy(self, minusCommand)
		end
	end

	if MultiBot.isInside(pState, strategyName) then
		button.setEnable()
	end
end

function MultiBot.AddCommonCombatStrategyButtons(pFrame, tFrame, pCombat, yOffset)
	local y = tonumber(yOffset) or 0

	addCommonStrategyButton(tFrame, pCombat, "DpsAssist",  y,       "spell_holy_heroism.blp",         "tips.every.strategy.dpsassist",  "dps assist",  "co")
	addCommonStrategyButton(tFrame, pCombat, "TankAssist", y + 26,  "ability_warrior_innerrage.blp",  "tips.every.strategy.tankassist", "tank assist", "co")
	addCommonStrategyButton(tFrame, pCombat, "AvoidAoe",   y + 52,  "spell_shadow_antishadow.blp",    "tips.every.strategy.avoidaoe",   "avoid aoe",   "co")
	addCommonStrategyButton(tFrame, pCombat, "SaveMana",   y + 78,  "spell_frost_manarecharge.blp",   "tips.every.strategy.savemana",   "save mana",   "co")
	addCommonStrategyButton(tFrame, pCombat, "Threat",     y + 104, "ability_warrior_challange.blp",  "tips.every.strategy.threat",     "threat",      "co")
	addCommonStrategyButton(tFrame, pCombat, "Behind",     y + 130, "ability_backstab.blp",           "tips.every.strategy.behind",     "behind",      "co")
end

function MultiBot.AddNonCombatControl(pFrame, x, pNormal)
	pFrame.addButton("NonCombatControl", x, 0, "INV_Scroll_01", MultiBot.L("tips.every.noncombat.master"))
	.doLeft = function(pButton)
		MultiBot.ShowHideSwitch(pButton.getFrame("NonCombatControl"))
	end

	local tNonCombatFrame = pFrame.addFrame("NonCombatControl", x - 2, 30)
	tNonCombatFrame:Hide()

	addCommonStrategyButton(tNonCombatFrame, pNormal, "Buff",   0,  "spell_holy_power",      "tips.every.strategy.buff",   "buff,",  "nc")
	addCommonStrategyButton(tNonCombatFrame, pNormal, "Food",   26, "inv_drink_24_sealwhey", "tips.every.strategy.food",   "food",   "nc")
	addCommonStrategyButton(tNonCombatFrame, pNormal, "Loot",   52, "inv_misc_coin_16",      "tips.every.strategy.loot",   "loot",   "nc")
	addCommonStrategyButton(tNonCombatFrame, pNormal, "Gather", 78, "trade_mining",          "tips.every.strategy.gather", "gather", "nc")
end

function MultiBot.AddCombatControl(pFrame, x, pCombat)
	pFrame.addButton("CombatControl", x, 0, "INV_Sword_06", MultiBot.L("tips.every.combat.master"))
	.doLeft = function(pButton)
		MultiBot.ShowHideSwitch(pButton.getFrame("CombatControl"))
	end

	local tCombatFrame = pFrame.addFrame("CombatControl", x - 2, 30)
	tCombatFrame:Hide()

	addCommonStrategyButton(tCombatFrame, pCombat, "DpsAssist",  0,   "spell_holy_heroism.blp",         "tips.every.strategy.dpsassist",  "dps assist",  "co")
	addCommonStrategyButton(tCombatFrame, pCombat, "TankAssist", 26,  "ability_warrior_innerrage.blp",  "tips.every.strategy.tankassist", "tank assist", "co")
	addCommonStrategyButton(tCombatFrame, pCombat, "AvoidAoe",   52,  "spell_shadow_antishadow.blp",    "tips.every.strategy.avoidaoe",   "avoid aoe",   "co")
	-- addCommonStrategyButton(tCombatFrame, pCombat, "SaveMana",   78,  "spell_frost_manarecharge.blp",   "tips.every.strategy.savemana",   "save mana",   "co")
	addCommonStrategyButton(tCombatFrame, pCombat, "Threat",     78,  "ability_warrior_challange.blp",  "tips.every.strategy.threat",     "threat",      "co")
	addCommonStrategyButton(tCombatFrame, pCombat, "Behind",     104, "ability_backstab.blp",           "tips.every.strategy.behind",     "behind",      "co")

	return tCombatFrame
end