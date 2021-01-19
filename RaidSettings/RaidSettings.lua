RS = {}

RaidSettingsData = {}

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("ADDON_LOADED");

f:SetScript("OnEvent", function(self, event, arg1)
    if event == "PLAYER_ENTERING_WORLD" then
        RS:ResetProfilesPerformance()
    elseif event == "ADDON_LOADED" and arg1 == "RaidSettings" then
        if RaidSettingsData['profile'] == nil then
            RS:EnsureSchema()
        else
            RS:LoadProfile(RaidSettingsData['profile'])
        end

        self:UnregisterEvent("ADDON_LOADED")
    end
end)

SlashCmdList["RAIDSETTINGS"] = function(msg)
    if msg == "" then
        RS:PrintHelp()
        return false
    end

    local cmd, arg = string.split(" ", msg, 2)

    if cmd == "help" then
        RS:PrintHelp()
    elseif cmd == "sort" then
        if RS:RaidOnlyCommand() then RS:SortRaidGroups() end
    elseif cmd == "clean" then
        RS:CleanRaidGroups()
    elseif cmd == "promote" then
        if RS:RaidOnlyCommand() then RS:PromoteRaidAssist() end
    elseif cmd == "reset" then
        RS:EnsureSchema()
        RS:ResetProfiles()
    elseif cmd == "save" then
        if arg == "" or arg == nil then
            RS:PrintError("Must provide profile for save");
        else
            if RS:RaidOnlyCommand() then RS:SaveProfile(arg) end
        end
    elseif cmd == "delete" then
        if arg == "" or arg == nil then
            RS:PrintError("Must provide profile for delete");
        else
            RS:DeleteProfile(arg)
        end
    elseif cmd == "load" then
        if arg == "" or arg == nil then
            RS:PrintError("Must provide profile for load");
        else
            if RS:RaidOnlyCommand() then RS:LoadProfile(arg) end
        end
    elseif cmd == "list" then
        RS:ListProfiles()
    elseif cmd == "perf" then
        RS:TogglePerformance()
    elseif cmd == "invite" then
        if RS:RaidOnlyCommand() then RS:InviteRoster() end
    elseif cmd == "batch" then
        if arg == "" or arg == nil or tonumber(arg) == nil then
            RS:PrintError("Must provide batch size number, currently " .. RaidSettingsData['settings']['batch_size']);
        else
            RaidSettingsData['settings']['batch_size'] = tonumber(arg)
            RS:PrintInfo("Setting batch size to " .. arg);
        end
    elseif cmd == "add" then
        if arg == "" or arg == nil or string.match(arg, "^%u%l+:[0-8]") == nil then
            RS:PrintError("Must provide character:group");
        else
            RS:AddToProfile(arg)
        end
    elseif cmd == "remove" then
        if arg == "" or arg == nil and string.match(arg, "^%u%l+") == nil then
            RS:PrintError("Must provide character name");
        else
            RS:RemoveFromProfile(arg)
        end
    else
        RS:PrintError("Unknown command: " .. msg);
        RS:PrintHelp();
    end
end
SLASH_RAIDSETTINGS1 = "/rs";
SLASH_RAIDSETTINGS2 = "/raidsettings";

function RS:PrintInfo(msg)
    DEFAULT_CHAT_FRAME:AddMessage("RaidSettings: " .. msg);
end

function RS:PrintError(msg)
    DEFAULT_CHAT_FRAME:AddMessage("RaidSettings |cFFFF0000Error:|r" .. msg);
end

function RS:PrintHelp(msg)
    DEFAULT_CHAT_FRAME:AddMessage(
        "RaidSettings: Start off with clean then sort and repeat until organized")
    DEFAULT_CHAT_FRAME:AddMessage("  /rs sort - Sort raid group")
    DEFAULT_CHAT_FRAME:AddMessage(
        "  /rs clean - Move improper assignments to g6-8")
    DEFAULT_CHAT_FRAME:AddMessage("  /rs promote - Promote assistants")
    DEFAULT_CHAT_FRAME:AddMessage("  /rs reset - Reset profiles to default")
    DEFAULT_CHAT_FRAME:AddMessage(
        "  /rs [save|load|delete] profile - Save, load, or delete profile")
    DEFAULT_CHAT_FRAME:AddMessage("  /rs list - List profiles")
    DEFAULT_CHAT_FRAME:AddMessage("  /rs perf - Toggle performance tweaks")
    DEFAULT_CHAT_FRAME:AddMessage(
        "  /rs invite - Invite current profile's roster")
    DEFAULT_CHAT_FRAME:AddMessage("  /rs batch N - Set batch size")
    DEFAULT_CHAT_FRAME:AddMessage(
        "  /rs add character:group - Adds character to group roster")
    DEFAULT_CHAT_FRAME:AddMessage(
        "  /rs remove character - Removes character from group roster")
end

function RS:RaidOnlyCommand()
    if IsRaidLeader() == false or GetNumRaidMembers() < 2 then
        RS:PrintError("Missing role!");
        return false
    end
    return true
end

function RS:EnsureSchema()
    if RaidSettingsData['settings'] == nil then
        RaidSettingsData['settings'] = {performance = true, batch_size = 5}
    end
    if RaidSettingsData['settings']['batch_size'] == nil then
        RaidSettingsData['settings']['batch_size'] = 5
    end
    if RaidSettingsData['profile'] == nil then RS:ResetProfiles() end
end

function RS:ResetProfilesPerformance()
    RS:EnsureSchema()
    if RaidSettingsData['settings']['performance'] == true then
        SetCVar("scriptErrors", "0")
        ConsoleExec("cameraDistanceMax 50")
        ConsoleExec("cameraDistanceMoveSpeed 50")
        ConsoleExec("spelleffectlevel 30")
        SetCVar("maxFPS", "120")
        SetCVar("maxFPSBk", "30")
        SetCVar("M2Faster", "3")
        local g1, g2 = MainMenuBarLeftEndCap, MainMenuBarRightEndCap;
        if g1 and g2 then
            g1:Hide()
            g2:Hide()
        end
    end
end

function RS:TogglePerformance()
    RaidSettingsData['settings']['performance'] =
        not RaidSettingsData['settings']['performance']
    if RaidSettingsData['settings']['performance'] == true then
        RS:PrintInfo("Enabling performance tweaks, please /reloadui");
    else
        RS:PrintInfo("Disabling performance tweaks, please /reloadui");
    end
end

function RS:ResetProfiles()
    RS:PrintInfo("Resetting profiles");
    local default_profile = 'perseverance'
    RaidSettingsData['profile'] = default_profile
    RaidSettingsData['profiles'] = {}
    RaidSettingsData['profiles'][default_profile] = {}

    RaidSettingsData['profiles'][default_profile]['layout'] =
        {
            Nocka = 1,
            Stavre = 1,
            Aisin = 1,
            Megadask = 1,
            Rabi = 2,
            Vanquisher = 2,
            Felbourne = 2,
            Denagul = 2,
            Abaddom = 3,
            Cardran = 3,
            Immoist = 3,
            Getscared = 3,
            Yuyeli = 3,
            Sylabear = 4,
            Darkage = 4,
            Themise = 4,
            Flamelock = 4,
            Kynura = 4,
            Illjustdodge = 5,
            Saladin = 5,
            Bakedbeans = 5,
            UnholyMoly = 5,
            Clayman = 2,
            Salahunter = 1,
            Stavrjr = 5,
            Timfukis = 5,
            Asunayuuki = 5,
            Gankmejr = 1,
            Wrw = 5,
            Kagaw = 6,
            Metresa = 6
        }

    RaidSettingsData['profiles'][default_profile]['promote'] =
        {
            Stavre = 1,
            Stavjr = 1,
            Clayman = 1,
            Saladin = 1,
            Salahunter = 1,
            Getscared = 1,
            Bakedbeans = 1,
            Denagul = 1,
            Nocka = 1,
            Kynura = 1
        }
end

function RS:GetCurrentLayout()
    local raid_num = GetNumRaidMembers()
    local raiders = {}
    for i = 1, raid_num do
        local name, rank, subgroup = GetRaidRosterInfo(i)
        raiders[name] = {group = subgroup, id = i, rank = rank}
    end

    return raiders
end

function RS:LoadProfile(profile_name)
    if RaidSettingsData['profiles'][profile_name] == nil then
        RS:PrintError("No profile found for " .. profile_name);
        return false;
    end

    RaidSettingsData['profile'] = profile_name
    self.GroupLayout = RaidSettingsData['profiles'][profile_name]['layout']
    self.PromoteList = RaidSettingsData['profiles'][profile_name]['promote']
end

function RS:SaveProfile(profile_name)
    local raiders = RS:GetCurrentLayout()
    local raid_layout = {}
    local promote_list = {}

    for raider_name, raider_data in pairs(raiders) do
        raid_layout[raider_name] = raider_data['group']

        if raider_data['rank'] >= 1 then promote_list[raider_name] = 1 end
    end

    RaidSettingsData['profile'] = profile_name
    RaidSettingsData['profiles'][profile_name] =
        {layout = raid_layout, promote = promote_list}
    RS:PrintInfo("Saved profile " .. profile_name);
end

function RS:ListProfiles()
    local profile_string = 'Profiles: '
    for profile_name, profile_layout in pairs(RaidSettingsData['profiles']) do
        profile_string = profile_string .. profile_name .. ' '
    end

    RS:PrintInfo(profile_string);
end

function RS:DeleteProfile(profile_name)
    if RaidSettingsData['profiles'][profile_name] == nil then
        RS:PrintError("No profile found for " .. profile_name);
        return false;
    end
    RaidSettingsData['profiles'][profile_name] = nil
    RS:PrintInfo("Deleted profile " .. profile_name);
end

function RS:AddToProfile(character_mapping)
    local active_profile = RaidSettingsData['profile']
    local character_name, character_group =
        string.split(":", character_mapping, 2)

    if RaidSettingsData['profiles'][active_profile]['layout'][character_name] ~=
        nil then
        RS:PrintError("Character " .. character_name .. " already in " ..
                          active_profile);
        return false;
    end

    RaidSettingsData['profiles'][active_profile]['layout'][character_name] =
        character_group

    RS:PrintInfo("Character " .. character_name .. " added to group " ..
                     character_group);
end

function RS:RemoveFromProfile(character_name)
    local active_profile = RaidSettingsData['profile']
    if RaidSettingsData['profiles'][active_profile]['layout'][character_name] ==
        nil then
        RS:PrintError("Character " .. character_name .. " doesn't exist in " ..
                          active_profile);
        return false;
    end

    RaidSettingsData['profiles'][active_profile]['layout'][character_name] = nil

    RS:PrintInfo("Character " .. character_name .. " removed from " ..
                     active_profile);
end

function RS:CleanRaidGroups()
    local temp_group = 8
    local temp_count = 0
    local to_sort = {}
    local raiders = RS:GetCurrentLayout()

    for raider_name, raider_data in pairs(raiders) do
        if (self.GroupLayout[raider_name] == nil or raider_data['group'] ~=
            self.GroupLayout[raider_name]) and raider_data['group'] <= 5 then

            temp_count = temp_count + 1

            if temp_count >= 5 then
                temp_group = temp_group - 1
                temp_count = 0
            end

            to_sort[raider_name] = {
                id = raider_data['id'],
                temp_group = temp_group
            }

            if temp_group < 6 then
                RS:PrintInfo("Maximum temp reached");
                break
            end
        end
    end

    local change_count = 0
    for sort_name, sort_data in pairs(to_sort) do
        change_count = change_count + 1

        if change_count <= RaidSettingsData['settings']['batch_size'] then
            SetRaidSubgroup(sort_data['id'], sort_data['temp_group'])
        else
            RS:PrintInfo("Maximum clean changes reached");
            return true
        end
    end
end

function RS:InviteRoster()
    local raiders = RS:GetCurrentLayout()
    local missing_invite = {}

    local missing_id = 0
    for raider_name, raider_data in pairs(self.GroupLayout) do
        missing_id = missing_id + 1
        if raiders[raider_name] == nil then
            missing_invite[missing_id] = raider_name
        end
    end

    local change_count = 0
    for i = 1, #missing_invite do
        random_invite = missing_invite[math.random(#missing_invite)]
        change_count = change_count + 1

        if change_count <= RaidSettingsData['settings']['batch_size'] then
            InviteUnit(random_invite)
        else
            RS:PrintInfo("Maximum invites reached");
            return true
        end
    end
end

function RS:SortRaidGroups()
    local raiders = RS:GetCurrentLayout()
    local to_sort = {}

    for raider_name, raider_data in pairs(raiders) do
        if self.GroupLayout[raider_name] ~= nil then
            if raider_data['group'] ~= self.GroupLayout[raider_name] then
                to_sort[raider_name] = {id = raider_data['id']}
            end
        end
    end

    local change_count = 0
    for sort_name, sort_data in pairs(to_sort) do
        change_count = change_count + 1

        if change_count <= RaidSettingsData['settings']['batch_size'] then
            SetRaidSubgroup(sort_data['id'], self.GroupLayout[sort_name])
        else
            RS:PrintInfo("Maximum clean changes reached");
            return true
        end
    end
end

function RS:PromoteRaidAssist()
    local raiders = RS:GetCurrentLayout()
    RS:PrintInfo("Checking for promotions");

    for raider_name, raider_data in pairs(raiders) do

        if self.PromoteList[raider_name] ~= nil and raider_data['rank'] == 0 then
            RS:PrintInfo("Promoting " .. raider_name);
            PromoteToAssistant(raider_name)
        end
    end
end
