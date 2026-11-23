local MultiBot = _G.MultiBot
local AceAddon = LibStub("AceAddon-3.0")

local Lifecycle = AceAddon:NewAddon(
  "MultiBotLifecycle",
  "AceEvent-3.0",
  "AceConsole-3.0",
  "AceTimer-3.0"
)

MultiBot.lifecycle = Lifecycle

function Lifecycle:OnInitialize()
  MultiBot.Storage.Initialize()
  MultiBot.Config.ApplyFrameStrata()
  MultiBot.Options.Register()
end

function Lifecycle:OnEnable()
  self:RegisterChatCommand("multibot", "HandleSlashCommand")
  self:RegisterEvent("CHAT_MSG_ADDON", "OnAddonMessage")
  self:RegisterEvent("PLAYER_ENTERING_WORLD", "OnRosterEvent")
  self:RegisterEvent("GROUP_ROSTER_UPDATE", "OnRosterEvent")
  self:RegisterEvent("PARTY_MEMBERS_CHANGED", "OnRosterEvent")
  self:RegisterEvent("RAID_ROSTER_UPDATE", "OnRosterEvent")
  MultiBot.MainUI.Initialize()
  MultiBot.MainUI.Show()
end

function Lifecycle:OnAddonMessage(_, prefix, message, distribution, sender)
  MultiBot.Bridge.OnAddonMessage(prefix, message, distribution, sender)
end

function Lifecycle:OnRosterEvent()
  MultiBot.Roster.RequestRefresh()
end

function Lifecycle:HandleSlashCommand()
  local profile = MultiBot.Storage.GetProfile()

  if profile then
    self:Print("MultiBot is active. Storage is ready.")
  else
    self:Print("MultiBot is active, but storage is unavailable.")
  end
end

function Lifecycle:OnDisable()
  MultiBot.Roster.CancelRefresh()
end
