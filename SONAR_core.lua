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

-- experimental to make dealing with colors easier
local clr1_s = "|cffF94F97[SONAR] ";
local clr1_e = "|r";

function printclr(instring)
    print(clr1_s .. instring .. clr1_e);
end

-- **********************************************
-- ** START MAIN FRAME DEFINITION SECTION *******
-- **********************************************

function initializeSonar(self)
    --
    local tc = GetNumTrackingTypes();
    --print("|cffF94F97num tracking type available: |r" .. tc);
  
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
                                       (name ~= "Sense Undead")))   then -- add "Find Herbs" when testing
            sonarIDX = sonarIDX + 1;
            sonarTrackerID[sonarIDX] = i;
            --print(clr1_s .. name .. " added to sonarTrackerTypes." .. clr1_e);
            printclr(name .. " added to sonarTrackerTypes."); -- testing printclr(instring) function
        end
    end

    --GetTrackingInfo does not work for fishing in TBC, so manually check
    --for fishing in the player's spellbook
    --(skillType, special will be nil, nil if spell not found)
    skillType, special = GetSpellBookItemInfo("Find Fish");

    if (skillType == nil) then
        --print("No fishing"); 
        sonarHasFishing = false;
    elseif (skillType ~= nil) then
        --print("Fisherman detected");
        sonarHasFishing = true;
    end

    -- if we found trackable stuff intialize sonarCurrID
    if ((sonarIDX > 1) or (sonarIDX == 1 and sonarHasFishing == true)) then
        sonarRunning = true;
        sonarCurrID = 1;
    end

    -- if we found nothing then turn off the addon
    namechk, _, _, _, _ = GetTrackingInfo(1);
    --print("namechk: " .. namechk);
    if ((sonarIDX <= 1 and sonarHasFishing == false) or (sonarIDX <= 0 and sonarHasFishing == true) or (sonarIDX == 1 and sonarHasFishing == true and namechk == "Find Fish")) then
        sonarRunning = false;
        print(clr1_s .. "NEED MINIMUM 2+ GATHERING PROFESSIONS - SONAR DISABLED" .. clr1_e);
    end
end

--[[ This is the old version of cycleMinimapTracker
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

            if (sonarIDX <= 0 and sonarHasFishing == true) then
                --we may not need this check anymore since we detect
                --# of tracking types in the initializer function
                --(tracked by variable sonarRunning)
                --!! Cannot remove this code without robustness testing though
                print("|cffF94F97[SONAR] only fishing detected, shutting down|r");
                CastSpellByName("Find Fish");
                sonarRunning = false;
            end

            -- TODO1: remove all of the above if statment (2+ gathering prof check is taken care of in initializer)

            --if (sonarIDX > 0) then
            SetTracking(sonarCurrID,true);
            sonarCurrID = sonarCurrID + 1;
            --end
        end
    end   
end
--]]

---[[ this is the new and improved version of cycleMinimapTracker
function cycleMinimapTracker(self)
    --R: 0xF9
    --G: 0x4F
    --B: 0x97
    if sonarRunning == true then
        if (sonarCurrID > sonarIDX) then
            sonarCurrID = 1;
            if sonarHasFishing == true then
                CastSpellByName("Find Fish");
                return; --break out of this function
            end
        end
        SetTracking(sonarCurrID,true);
        sonarCurrID = sonarCurrID + 1;
    end   
end
--]]

function stopSonar()
    -- stop the addon's cycling action
    if (sonarTimer ~= nil) then
        if not sonarTimer:IsCancelled() then
            --print("not cancelled"); -- debug
        end
        if not sonarTimer:IsCancelled() then
            sonarTimer:Cancel();
            print("|cffF94F97[SONAR] Halted!|r");
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
        --print("sonarIDX: " .. sonarIDX);
        --[[
        if sonarRunning then
            print("sonarRunning TRUE");
        else
            print("sonarRunning FALSE");
        end
        --]]
        if sonarRunning == true then -- we've detected there are at least 2 trackers to switch between
            sonarTimer = C_Timer.NewTicker(2, cycleMinimapTracker)
        end
    elseif (msg == "E") then
        stopSonar();
    elseif (msg == "TRACKTYPE") then
        if sonarRunning == false then
            print(clr1_s .. "did not detect enough tracking types!" .. clr1_e);
        else
            print("|cffF94F97" .. " -- SONAR DETECTED TRACKERS -- " .. "|r");
            for i=1,sonarIDX do
                nametmp, _, _, _, _ = GetTrackingInfo(i);
                print(clr1_s .. sonarTrackerID[i] .. "- " .. nametmp .. clr1_e);
            end
        end
    else
        print("|cffF94F97 -- SONAR ADDON HELP -- |r");
        print("|cffF94F00'/snr S' to start Sonar|r");
        print("|cffF94F00'/snr E' to stop Sonar|r");
        print("|cffF94F00'/snr TRACKTYPE' to print detected tacking types|r");
    end
end

