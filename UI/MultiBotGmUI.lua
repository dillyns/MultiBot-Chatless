if not MultiBot then return end

local MEMORY_GEMS = {
    { label = "Red", x = 0, icon = "inv_jewelcrafting_gem_16" },
    { label = "Green", x = 30, icon = "inv_jewelcrafting_gem_13" },
    { label = "Blue", x = 60, icon = "inv_jewelcrafting_gem_17" },
}

local function ensureDeleteSavedVariablesDialog()
    StaticPopupDialogs["MULTIBOT_DELETE_SV"] = {
        text = MultiBot.L("tips.game.delsvwarning"),
        button1 = YES,
        button2 = NO,
        OnAccept = function()
            if MultiBot.ClearGlobalBotStore then
                MultiBot.ClearGlobalBotStore()
            elseif wipe then
                wipe(MultiBotGlobalSave)
            else
                for key in pairs(MultiBotGlobalSave) do
                    MultiBotGlobalSave[key] = nil
                end
            end

            ReloadUI()
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
    }
end

local function addMemoryGemButton(portalFrame, definition)
    local gem = portalFrame.addButton(
        definition.label,
        definition.x,
        0,
        definition.icon,
        MultiBot.doReplace(MultiBot.L("tips.game.memory"), "ABOUT", MultiBot.L("info.location"))
    )

    gem:setDisable()
    gem.goMap, gem.goX, gem.goY, gem.goZ = "", 0, 0, 0

    gem.doRight = function(button)
        if not button.state then
            SendChatMessage(MultiBot.L("info.itlocation"), "SAY")
            return
        end

        button.tip = MultiBot.doReplace(MultiBot.L("tips.game.memory"), "ABOUT", MultiBot.L("info.location"))
        button:setDisable()
    end

    gem.doLeft = function(button)
        local player = MultiBot.getBot(UnitName("player"))
        player.waitFor = player.waitFor or ""

        if player.waitFor ~= "" then
            SendChatMessage(MultiBot.L("info.saving"), "SAY")
            return
        end

        if button.state then
            SendChatMessage(".go xyz " .. button.goX .. " " .. button.goY .. " " .. button.goZ .. " " .. button.goMap, "SAY")
            return
        end

        player.memory = button
        player.waitFor = "COORDS"
        SendChatMessage(".gps", "SAY")
    end

    return gem
end

function MultiBot.ShowDeleteSVPrompt()
    if MultiBot.GM == false then
        SendChatMessage(MultiBot.L("info.rights"), "SAY")
        return
    end

    ensureDeleteSavedVariablesDialog()
    StaticPopup_Show("MULTIBOT_DELETE_SV")
end

function MultiBot.BuildGmUI(tMultiBar)
    if not tMultiBar or not tMultiBar.addButton or not tMultiBar.addFrame then
        return nil
    end

    local mainButton = tMultiBar.addButton("Masters", 38, 0, "mail_gmicon", MultiBot.L("tips.game.master"))
    mainButton:doHide()

    mainButton.doLeft = function(owner)
        MultiBot.ShowHideSwitch(owner.parent.frames["Masters"])
    end

    mainButton.doRight = function()
        MultiBot.doSlash("/MultiBot", "")
    end

    local mastersFrame = tMultiBar.addFrame("Masters", 36, 38)
    mastersFrame:Hide()

    mastersFrame.addButton("DelSV", 0, 204, "ability_golemstormbolt", MultiBot.L("tips.game.delsv"), "ActionButtonTemplate")
        .doLeft = function()
            MultiBot.ShowDeleteSVPrompt()
        end

    MultiBot.RegisterCommandAliases("MULTIBOTDELSV", function()
        if MultiBot.ShowDeleteSVPrompt then
            MultiBot.ShowDeleteSVPrompt()
        end
    end, { "mbdelsv" })

    ensureDeleteSavedVariablesDialog()

    return {
        mainButton = mainButton,
        mastersFrame = mastersFrame
    }
end