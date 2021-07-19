-- **************************************************
-- Addon: SONAR
-- Description: alternate tracking type every GCD
-- Author: MarxWasRight-Fairbanks
--
-- TODO:
-- 1. Add an event listener for entering combat and stop the
--    looping because it eats GCDs
-- 2. XML GUI interface to control which tracking types are
--    cycled through
-- 3. Disable addon if current character only has 1 or less
--    tracking types
--
-- **************************************************

local AddOn, SONARcore = ...;

local slfgBTNState = false;
local sonarRunning = false;
local sonarCurrID = 0;
local sonarTrackerID = {};
local sonarIDX = 0;
local sonarHasFishing = false;
local sonarStarting = true;

-- allow use of arrows inside windows
-- (so your char won't move in game)
for i = 1, NUM_CHAT_WINDOWS do
    _G["ChatFrame"..i.."EditBox"]:SetAltArrowKeyMode(false)
end

-- **********************************************
-- ** START MAIN FRAME DEFINITION SECTION *******
-- **********************************************

function initializeSonar(self)
    --
    local tc = GetNumTrackingTypes();
    print("num tracking type available: " .. tc);
    --
    for i=1,tc do
        --stuff
        --name, texture, active, category, nested = GetTrackingInfo(i);
        name, _, _, category, _ = GetTrackingInfo(i);

        if category == "spell" then
            sonarIDX = sonarIDX + 1;
            --sonarTrackerTypes[sonarIDX] = name;
            sonarTrackerID[sonarIDX] = i;
            print(name .. " added to sonarTrackerTypes. sonarIDX = " .. sonarIDX);
        end
    end

    --GetTrackingInfo does not work for fishing in TBC, so manually check
    --for fishing in the player's spellbook
    --(skillType, special will be nil, nil if spell not found)
    skillType, special = GetSpellBookItemInfo("Find Fish");

    if (skillType == nil) then 
        --print("No fishing"); 
        sonarHasFishing = false;
    end

    if (skillType ~= nil) then 
        --print("Fisherman detected");
        sonarHasFishing = true;
    end
    
    -- if we found trackable stuff intialize sonarCurrID
    if (sonarIDX > 0 or sonarHasFishing == true) then sonarCurrID = 1; end

    -- if we found nothing then turn off the addon
    if (sonarIDX <= 0 and sonarHasFishing == false) then 
        sonarRunning = False; 
        print("|cff377CF0NO TRACKING DETECTED - SONAR DISABLED|r");
    end
    
    -- TODO: disable the addon if they have ONLY 1 gathering profession

    --[[
    print(" -- Final sonarTrackerTypes contents -- ");
    for i=1,sonarIDX do
        print(sonarTrackerID[i]);
    end
    --]]

end

function cycleMinimapTracker(self)
    --R: 0x37
    --G: 0x7C
    --B: 0xF0
    --print("|cff377CF0TIMER TICKING|r"); -- debug
    if sonarRunning == true then
        if sonarStarting == false then
            sonarCurrID = sonarCurrID + 1;
            if (sonarCurrID > sonarIDX) then
                sonarCurrID = 1;
                if sonarHasFishing == true then
                    CastSpellByName("Find Fish");
                    return;
                end
            end
            SetTracking(sonarCurrID,true);
        elseif sonarStarting == true then
            sonarStarting = false;
            if (sonarIDX <= 0 and sonarHasFishing == true) then
                print("only fishing detected, shutting down");
                CastSpellByName("Find Fish");
                sonarRunning = false;
            end
            if (sonarIDX > 0) then
                SetTracking(sonarCurrID,true);
                sonarCurrID = sonarCurrID + 1;
            end
        end
    end   
end




-- **********************************************
-- ** SLASH CMD DEF SECTION *********************
-- **********************************************

-- quick access to frame stack for debugging
SLASH_FRAMESTK1 = "/fs";
SlashCmdList.FRAMESTK = function()
    LoadAddOn("Blizzard_DebugTools");
    FrameStackTooltip_Toggle();
end

SLASH_SLFG1 = "/slfg";
SlashCmdList["SLFG"] = function(msg)
    msg = string.upper(msg);
    if (msg == "HELP") then
        print("--Silence LFG Channel Addon--");
        print("'/slfg hide' to hide SLFG");
        print("'/slfg UL' to unlock the frame");
        print("'/slfg L' to lock the frame");
        print("'/slfg show' to show SLFG");
        print("'/slfg join' to join LFG");
        print("'/slfg leave' to leave LFG");
    elseif (msg == "SHOW") then
        UItogBtn:Show();
        print("SHOW");
    elseif (msg == "HIDE") then
        UItogBtn:Hide();
        print("HIDE");
    elseif (msg == "JOIN") then
        local channel_type, channel_name = JoinChannelByName("LookingForGroup");
        ChatFrame_AddChannel(DEFAULT_CHAT_FRAME, "LookingForGroup");
        print("JOIN");
    elseif (msg == "LEAVE") then
        LeaveChannelByName("LookingForGroup");
        print("LEAVE");
    elseif (msg == "UL") then
        -- TODO: toggle lock for position of SLFG's main frame
        UItogBtn:SetMovable(true);
        UItogBtn:RegisterForDrag("LeftButton");
        UItogBtn:SetScript("OnDragStart", UItogBtn.StartMoving);
        UItogBtn:SetScript("OnDragStop", UItogBtn.StopMovingOrSizing);
        UItogBtn:SetUserPlaced(true);
        print("SLFG FRAME UNLOCKED");
    elseif (msg == "L") then
        UItogBtn:StopMovingOrSizing();
        UItogBtn:RegisterForDrag();
        UItogBtn:SetMovable(false);
        print("SLFG FRAME LOCKED");
    elseif (msg == "Q") then
        print("W-H-L-R");
        print(UItogBtn:GetWidth());
        print(UItogBtn:GetHeight());
        print(UItogBtn:GetLeft());
        print(UItogBtn:GetRight());
    elseif (msg == "S") then
        sonarRunning = true;
        sonarTimer = C_Timer.NewTicker(1.5, cycleMinimapTracker)
    elseif (msg == "E") then
        --need to end the timer here    
        if sonarTimer ~= null then
            sonarTimer:Cancel();
        end
        --print("Timer cancelled: " .. sonarTimer:IsCancelled());
    elseif (msg == "TRACKTYPE") then
        --
    end
end