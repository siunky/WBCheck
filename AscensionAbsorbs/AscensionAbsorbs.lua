local addonName = "AscensionAbsorbs"

local eventFrame = CreateFrame("Frame")


--------------------------------------------------
-- Create absorb text + status bar using UIParent
--------------------------------------------------

local function CreateAbsorbDisplay(unitFrame)

    if not unitFrame then
        return
    end


    if unitFrame.AbsorbText then
        return
    end


    --------------------------------------------------
    -- Absorb Number
    --------------------------------------------------

    unitFrame.AbsorbText = UIParent:CreateFontString(
        nil,
        "OVERLAY"
    )


    unitFrame.AbsorbText:SetFont(
        STANDARD_TEXT_FONT,
        16,
        "OUTLINE"
    )


    unitFrame.AbsorbText:SetJustifyH(
        "CENTER"
    )


    unitFrame.AbsorbText:SetDrawLayer(
        "OVERLAY",
        7
    )


    unitFrame.AbsorbText:Show()



    --------------------------------------------------
    -- Absorb Status Bar
    --------------------------------------------------

    unitFrame.AbsorbBar = CreateFrame(
        "StatusBar",
        nil,
        UIParent
    )


    unitFrame.AbsorbBar:SetStatusBarTexture(
        "Interface\\TargetingFrame\\UI-StatusBar"
    )


    unitFrame.AbsorbBar:SetWidth(
        90
    )


    unitFrame.AbsorbBar:SetHeight(
        6
    )


    unitFrame.AbsorbBar:SetMinMaxValues(
        0,
        1
    )


    unitFrame.AbsorbBar:SetValue(
        0
    )


    unitFrame.AbsorbBar:Hide()

end



--------------------------------------------------
-- Position text and bar on unit frame
--------------------------------------------------

local function PositionAbsorbDisplay(unitFrame)

    if not unitFrame.AbsorbText then
        return
    end


    --------------------------------------------------
    -- Text position
    --------------------------------------------------

    unitFrame.AbsorbText:ClearAllPoints()


    unitFrame.AbsorbText:SetPoint(
        "CENTER",
        unitFrame,
        "CENTER",
        0,
        10
    )



    --------------------------------------------------
    -- Bar position
    --------------------------------------------------

    if unitFrame.AbsorbBar then

        unitFrame.AbsorbBar:ClearAllPoints()


        unitFrame.AbsorbBar:SetPoint(
            "BOTTOM",
            unitFrame,
            "BOTTOM",
            0,
            -3
        )

    end

end



--------------------------------------------------
-- Update absorb amount
--------------------------------------------------

local function UpdateAbsorb(unitFrame)

    if not unitFrame then
        return
    end


    if not unitFrame.unit then
        return
    end


    CreateAbsorbDisplay(unitFrame)

    PositionAbsorbDisplay(unitFrame)



    local absorb =
        UnitGetTotalAbsorbs(
            unitFrame.unit
        )



    if absorb and absorb > 0 then


        --------------------------------------------------
        -- Number
        --------------------------------------------------

        unitFrame.AbsorbText:SetText(
            "|cff66ccff" ..
            math.floor(absorb) ..
            "|r"
        )


        unitFrame.AbsorbText:Show()



        --------------------------------------------------
        -- Bar
        --------------------------------------------------

        local maxValue =
            UnitHealthMax(unitFrame.unit)
            +
            absorb


        if maxValue <= 0 then
            maxValue = absorb
        end



        unitFrame.AbsorbBar:SetMinMaxValues(
            0,
            maxValue
        )


        unitFrame.AbsorbBar:SetValue(
            absorb
        )


        unitFrame.AbsorbBar:Show()



    else


        --------------------------------------------------
        -- Hide
        --------------------------------------------------

        unitFrame.AbsorbText:SetText("")
        unitFrame.AbsorbText:Hide()


        if unitFrame.AbsorbBar then

            unitFrame.AbsorbBar:SetValue(0)
            unitFrame.AbsorbBar:Hide()

        end


    end

end



--------------------------------------------------
-- Scan ElvUI frames
--------------------------------------------------

local function ScanFrames()

    local found = 0


    -------------------------
    -- Player
    -------------------------

    if ElvUF_Player then

        UpdateAbsorb(
            ElvUF_Player
        )

        found = found + 1

    end



    -------------------------
    -- Party
    -------------------------

    for i = 1,5 do

        local frame =
            _G["ElvUF_PartyGroup1UnitButton"..i]


        if frame then

            UpdateAbsorb(frame)

            found = found + 1

        end

    end



    -------------------------
    -- Raid
    -------------------------

    for group = 1,8 do

        for button = 1,5 do

            local frame =
                _G["ElvUF_RaidGroup"..group.."UnitButton"..button]


            if frame then

                UpdateAbsorb(frame)

                found = found + 1

            end

        end

    end



    -------------------------
    -- Raid40
    -------------------------

    for group = 1,8 do

        for button = 1,5 do

            local frame =
                _G["ElvUF_Raid40Group"..group.."UnitButton"..button]


            if frame then

                UpdateAbsorb(frame)

                found = found + 1

            end

        end

    end


    return found

end



--------------------------------------------------
-- Events
--------------------------------------------------

eventFrame:RegisterEvent(
"PLAYER_LOGIN"
)

eventFrame:RegisterEvent(
"PLAYER_ENTERING_WORLD"
)

eventFrame:RegisterEvent(
"UNIT_ABSORB_AMOUNT_CHANGED"
)

eventFrame:RegisterEvent(
"GROUP_ROSTER_UPDATE"
)

eventFrame:RegisterEvent(
"PLAYER_TARGET_CHANGED"
)



eventFrame:SetScript(
"OnEvent",
function(self,event,unit)


    if event == "PLAYER_LOGIN"
    or event == "PLAYER_ENTERING_WORLD"
    then


        C_Timer.After(
            5,
            function()


                local count =
                    ScanFrames()


                print(
                    addonName ..
                    ": " ..
                    count ..
                    " frames scanned"
                )


                print(
                    "PLAYER ABSORB: " ..
                    (UnitGetTotalAbsorbs("player") or 0)
                )


            end
        )



    elseif event == "UNIT_ABSORB_AMOUNT_CHANGED" then


        ScanFrames()



    elseif event == "GROUP_ROSTER_UPDATE" then


        C_Timer.After(
            1,
            ScanFrames
        )



    elseif event == "PLAYER_TARGET_CHANGED" then


        ScanFrames()


    end

end)