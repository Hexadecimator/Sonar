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
--      Default text color: 0xffF94F97
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

function printclr(instring)
    print("|cffF94F97[SONAR] " .. instring .. "|r");
end

function initializeSonar(self)
    --
    local tc = GetNumTrackingTypes();
    --printclr("num tracking type available: " .. tc);
  
    for i=1,tc do
        --name, texture, active, category, nested = GetTrackingInfo(i);
        name, _, _, category, _ = GetTrackingInfo(i);

        -- this if statement is an affront to god and i'm sorry
        if ((category == "spell") and ((name ~= "Track Humanoids")  and
                                       (name ~= "Track Beasts")     and
                                       (name ~= "Track Demons")     and
                                       (name ~= "Track Dragonkin")  and
                                       (name ~= "Track Elementals") and
                                       (name ~= "Track Giants")     and
                                       (name ~= "Track Hidden")     and
                                       (name ~= "Track Undead")     and
                                       (name ~= "Sense Undead")))   then
            sonarIDX = sonarIDX + 1;
            sonarTrackerID[sonarIDX] = i;
            printclr(name .. " added to sonarTrackerTypes.");
        end
    end

    --GetTrackingInfo does not work for fishing in TBC, so manually check
    --for fishing in the player's spellbook
    --(skillType, special will be nil, nil if spell not found)
    skillType, special = GetSpellBookItemInfo("Find Fish");

    if (skillType == nil) then
        --printclr("No fishing"); 
        sonarHasFishing = false;
    elseif (skillType ~= nil) then
        --printclr("Fisherman detected");
        sonarHasFishing = true;
    end

    -- if we found trackable stuff intialize sonarCurrID
    if ((sonarIDX > 1) or (sonarIDX == 1 and sonarHasFishing == true)) then
        sonarRunning = true;
        sonarCurrID = 1;
    end

    -- if we found nothing then turn off the addon
    namechk, _, _, _, _ = GetTrackingInfo(1);
    --printclr("namechk: " .. namechk);
    if ((sonarIDX <= 1 and sonarHasFishing == false) or (sonarIDX <= 0 and sonarHasFishing == true) or (sonarIDX == 1 and sonarHasFishing == true and namechk == "Find Fish")) then
        sonarRunning = false;
        printclr("NEED MINIMUM 2+ GATHERING PROFESSIONS - SONAR DISABLED");
    end
end

function cycleMinimapTracker(self)
    if sonarRunning == true then
        if (sonarCurrID > sonarIDX) then
            sonarCurrID = 1;
            if sonarHasFishing == true then
                CastSpellByName("Find Fish");
                return;
            end
        end
        SetTracking(sonarCurrID,true);
        sonarCurrID = sonarCurrID + 1;
    end   
end

function stopSonar()
    -- stop the addon's cycling action
    if (sonarTimer ~= nil) then
        if not sonarTimer:IsCancelled() then
            --printclr("not cancelled"); -- debug
        end
        if not sonarTimer:IsCancelled() then
            sonarTimer:Cancel();
            printclr("Halted!");
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
        --printclr("sonarIDX: " .. sonarIDX);
        --[[
        if sonarRunning then
            printclr("sonarRunning TRUE");
        else
            printclr("sonarRunning FALSE");
        end
        --]]
        if sonarRunning == true then -- we've detected there are at least 2 trackers to switch between
            sonarTimer = C_Timer.NewTicker(2, cycleMinimapTracker)
        end
    elseif (msg == "E") then
        stopSonar();
    elseif (msg == "TRACKTYPE") then
        if sonarRunning == false then
            printclr("Did not detect enough tracking types!");
        else
            printclr(" -- SONAR DETECTED TRACKERS -- ");
            for i=1,sonarIDX do
                nametmp, _, _, _, _ = GetTrackingInfo(i);
                printclr(sonarTrackerID[i] .. "- " .. nametmp);
            end
        end
    else
        printclr(" -- SONAR ADDON HELP -- ");
        printclr("'/snr S' to start Sonar");
        printclr("'/snr E' to stop Sonar");
        printclr("'/snr TRACKTYPE' to print detected tacking types");
    end
end

