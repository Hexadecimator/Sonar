-- ***********************************************************
-- Addon Name: SONAR
--  Author: MarxWasRight-Fairbanks[H]
--
-- Description: alternate minimap tracking type every GCD
-- Author: MarxWasRight-Fairbanks[H]
--
-- TODO:
-- 1. XML GUI interface to control which tracking types are
--    cycled through
-- 2. Add user options to GUI
-- 3. Save user options
--
--      Default text color: 0xffF94F97
--
-- ***********************************************************

-- name, table
local AddOn, SONARcore = ...;

-- ***********************************
-- **** START GLOBAL DEFINITIONS *****
-- ***********************************

local sonarRunning = false;
local sonarCurrID = 0;
local sonarTrackerID = {};
local sonarIDX = 0;
local sonarHasFishing = false;
local showfishing = true;
local sonarToggle = true;

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
    if ((sonarIDX <= 1 and sonarHasFishing == false) or 
        (sonarIDX <= 0 and sonarHasFishing == true)  or 
        (sonarIDX == 1 and sonarHasFishing == true and namechk == "Find Fish")) then
        sonarRunning = false;
        printclr("NEED MINIMUM 2+ GATHERING PROFESSIONS - SONAR DISABLED");
    end
end

function cycleMinimapTracker(self)
    if sonarRunning == true then
        if (sonarCurrID > sonarIDX) then
            sonarCurrID = 1;
        end
        
        namechkm, _, _, _, _ = GetTrackingInfo(sonarCurrID);
        if(namechkm == "Find Fish" and showfishing) then
            CastSpellByName("Find Fish");
            sonarCurrID = sonarCurrID + 1;
            return;
        end

        SetTracking(sonarCurrID,true);
        sonarCurrID = sonarCurrID + 1;
    end   
end

function stopSonar()
    -- stop the addon's cycling action
    if (sonarTimer) then
        if sonarTimer:IsCancelled() then return; end -- called to stop but addon is already stopped

        sonarTimer:Cancel();
        sonarToggle = true;
        -- the print statement below can get obnoxious
        -- TODO: add an option to suppress messages when
        -- the GUI is built
        printclr("Halted!");
    end
end


-- **********************************************
-- *********** SLASH CMD DEF SECTION ************
-- **********************************************

SLASH_SONAR1 = "/snr";
SlashCmdList["SONAR"] = function(msg)
    msg = string.upper(msg);
    if (msg == "T") then
        if (sonarToggle) then
            if sonarRunning == true then -- we've detected there are at least 2 trackers to switch between
                sonarTimer = C_Timer.NewTicker(2, cycleMinimapTracker)
                printclr("Started!");
                sonarToggle = false;
            end
        else
            stopSonar();
            sonarToggle = true;
        end        
    elseif (msg == "TRACKTYPE") then
        if sonarRunning == false then
            printclr("Did not detect 2+ tracking types - halted");
        else
            printclr(" --SONAR DETECTED TRACKERS-- ");
            for i=1,sonarIDX do
                nametmp, _, _, _, _ = GetTrackingInfo(i);
                printclr(sonarTrackerID[i] .. "- " .. nametmp);
            end
        end
    elseif (msg == "GOGOGO") then
        printclr("HE SAID THE THING!!");
    elseif (msg == "NOFISH") then
        if (showfishing) then
            showfishing = false;
            printclr("[SONAR] Fishing turned OFF");
        else
            showfishing = true;
            printclr("[SONAR] Fishing turned ON");
        end
    else
        printclr("-- SONAR ADDON HELP -- ");
        printclr("'/snr t' toggle (start/stop) Sonar");
        printclr("'/snr nofish' to toggle fishing display")
        printclr("'/snr tracktype' to print detected tacking types");
    end
end

