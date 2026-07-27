local frame = CreateFrame("Frame")

--------------------------------------------------
-- Buff Names
--------------------------------------------------

local BUFF1 = "PvE Mode"
local BUFF2 = "War Mode"
local BUFF3 = "Mercenary for Hire!"

--------------------------------------------------
-- Returns true if the player has the buff
--------------------------------------------------

local function HasBuff(buffName)
    local i = 1

    while true do
        local name = UnitBuff("player", i)

        if not name then
            return false
        end

        if name == buffName then
            return true
        end

        i = i + 1
    end
end

--------------------------------------------------
-- Determine which chat channel to reply in
--------------------------------------------------

local function GetChannel(event)
    if event == "CHAT_MSG_RAID" or event == "CHAT_MSG_RAID_LEADER" then
        return "RAID"
    elseif event == "CHAT_MSG_PARTY" or event == "CHAT_MSG_PARTY_LEADER" then
        return "PARTY"
    elseif event == "CHAT_MSG_INSTANCE_CHAT" then
        return "INSTANCE_CHAT"
    end

    return IsInRaid() and "RAID" or "PARTY"
end

--------------------------------------------------
-- Listen for chat commands
--------------------------------------------------

frame:RegisterEvent("CHAT_MSG_PARTY")
frame:RegisterEvent("CHAT_MSG_PARTY_LEADER")
frame:RegisterEvent("CHAT_MSG_RAID")
frame:RegisterEvent("CHAT_MSG_RAID_LEADER")
frame:RegisterEvent("CHAT_MSG_INSTANCE_CHAT")

frame:SetScript("OnEvent", function(self, event, msg, author)

    if not msg or msg:lower() ~= "1wbcheck" then
        return
    end

    local buff1 = HasBuff(BUFF1)
    local buff2 = HasBuff(BUFF2)
    local buff3 = HasBuff(BUFF3)

    local response

    if buff2 and buff3 then
        response = ">>PVP/MERC ON G2G<<"
    elseif buff3 and buff1 then
        response = ">>PVE + MERC TURN ON PVP<<"
    elseif buff2 then
        response = ">>PVP ONLY TURN ON MERC<<"
    elseif buff3 then
        response = ">>MERC ONLY TURN ON PVP<<"
    elseif buff1 then
        response = ">>PVE ONLY MODE ON GO CHANGE<<"
    else
        response = ">>NOTHING ON (ADDON BROKEN)<<"
    end

    SendChatMessage(response, GetChannel(event))
end)