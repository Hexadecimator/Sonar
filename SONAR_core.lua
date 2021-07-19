-- ***********************************************************
-- Addon: SONAR
-- Description: alternate minimap tracking type every GCD
-- Author: MarxWasRight-Fairbanks[H]
--
-- TODO:
-- 1. Add an event listener for entering combat and stop the
--    looping because it eats GCDs [DONE]
-- 2. XML GUI interface to control which tracking types are
--    cycled through
-- 3. Disable addon if current character only has 1 or less
--    tracking types [DONE]
--
-- ***********************************************************

local AddOn, SONARcore = ...;

-- ***********************************
-- **** START GLOBAL DEFINITIONS *****
-- ***********************************

local sonarRunning = false;
local sonarCurrID = 0;
local sonarTrackerID = {};
local sonarIDX = 0;
local sonarHasFishing = false;
local sonarStarting = true;

-- **********************************************
-- ** START MAIN FRAME DEFINITION SECTION *******
-- **********************************************

function initializeSonar(self)
    --
    local tc = GetNumTrackingTypes();
    print("|cffF94F97num tracking type available: |r" .. tc);
    --
    for i=1,tc do
        --name, texture, active, category, nested = GetTrackingInfo(i);
        name, _, _, category, _ = GetTrackingInfo(i);

        if category == "spell" then
            sonarIDX = sonarIDX + 1;
            sonarTrackerID[sonarIDX] = i;
            print(name .. "|cffF94F97 added to sonarTrackerTypes. sonarIDX = |r" .. sonarIDX);
        end
    end

    --GetTrackingInfo does not work for fishing in TBC, so manually check
    --for fishing in the player's spellbook
    --(skillType, special will be nil, nil if spell not found)
    skillType, special = GetSpellBookItemInfo("Find Fish");

    if (skillType == nil) then
        --print("No fishing"); 
        sonarHasFishing = false;
    elseif(skillType ~= nil) then
        --print("Fisherman detected");
        sonarHasFishing = true;
    end

    -- if we found trackable stuff intialize sonarCurrID
    if ((sonarIDX > 1) or (sonarIDX == 1 and sonarHasFishing == true)) then
        sonarCurrID = 1;
    end

    -- if we found nothing then turn off the addon
    if ((sonarIDX <= 1 and sonarHasFishing == false) or (sonarIDX <= 0 and sonarHasFishing == true)) then
        sonarRunning = false;
        print("|cffF94F97NEED MINIMUM 2+ GATHERING PROFESSIONS - SONAR DISABLED|r");
    end
end

function cycleMinimapTracker(self)
    --R: 0xF9
    --G: 0x4F
    --B: 0x97
    if sonarRunning == true then
        if sonarStarting == false then
            if (sonarCurrID > sonarIDX) then
                sonarCurrID = 1;
                if sonarHasFishing == true then
                    CastSpellByName("Find Fish");
                    return; --break out of this function
                end
            end
            SetTracking(sonarCurrID,true);
            sonarCurrID = sonarCurrID + 1;
        elseif sonarStarting == true then
            sonarStarting = false;
            ---[[
            if (sonarIDX <= 0 and sonarHasFishing == true) then
                --we may not need this check anymore since we detect
                --# of tracking types in the initializer function
                --(tracked by variable sonarRunning)
                --!! Cannot remove this code without robustness testing though
                print("|cffF94F97only fishing detected, shutting down|r");
                CastSpellByName("Find Fish");
                sonarRunning = false;
            end
            --]]
            -- TODO1: remove all of the above if statment (2+ gathering prof check is taken care of in initializer)
            -- TODO2: make the if statement below only do SetTracking(sonarCurrID, true);
            --       (because sonarCurrID + 1; is done in initialize function only if
            --       the current character has 2+ gathering professions)
            -- !!! NEED TO TEST !!!

            if (sonarIDX > 0) then
                SetTracking(sonarCurrID,true);
                sonarCurrID = sonarCurrID + 1;
            end
        end
    end   
end

function stopSonar(self)
    -- stop the addon's cycling action
    if (sonarTimer ~= nil) then
        if (sonarTimer:IsCancelled() == false) then
            sonarTimer:Cancel();
            print("|cffFF0000" .. "SONAR TIMER CANCELLED" .. "|r");
        end
        
    end
end


-- **********************************************
-- *********** SLASH CMD DEF SECTION ************
-- **********************************************

SLASH_SONAR1 = "/snr";
SlashCmdList["SONAR"] = function(msg)
    msg = string.upper(msg);
    if (msg == "S") then
        if sonarRunning == true then -- we've detected there are at least 2 trackers to switch between
            sonarTimer = C_Timer.NewTicker(1.5, cycleMinimapTracker)
        end
    elseif (msg == "E") then
        --need to end the timer here
        stopSonar();
    elseif (msg == "TRACKTYPE") then
        if sonarRunning == false then
            print("|cffF94F97SONAR did not detect enough tracking types!|r")
        else
            print("|cffF94F97" .. " -- SONAR DETECTED TRACKERS -- " .. "|r");
            for i=1,sonarIDX do
                print("|cffF94F00" .. sonarTrackerID[i] .. "|r");
            end
        end
    else
        print("|cffF94F97 -- SONAR ADDON HELP -- |r");
        print("|cffF94F00'/snr S' to start Sonar|r");
        print("|cffF94F00'/snr E' to stop Sonar|r");
        print("|cffF94F00'/snr TRACKTYPE' to print detected tacking types|r");
    end
end

