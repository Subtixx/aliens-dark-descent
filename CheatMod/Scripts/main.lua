-- Import ASF.lua types
local UEHelpers = require("UEHelpers")
local AllMarineActors = nil
local Highlighted = false
local GodModeEnabled = false

function SplitCommandIntoArgs(Command)
    local Args = {}
    local Index = 0
    for match in Command:gmatch("%S+") do
        Args[Index] = match
        Index = Index + 1
    end
    return Args
end

function HealAll()
    ExecuteInGameThread(function()
        local ActorInstances = FindAllOf("BP_HumanoidMarinePlayer_C")
        if not ActorInstances then
            print("No instances of 'Actor' were found\n")
        else
            --[[for Index, ActorInstance in pairs(ActorInstances) do
                print(string.format("[%d] %s\n", Index, ActorInstance:GetFullName()))
            end]]
            for i, ActorInstance in ipairs(ActorInstances) do
                if string.find(ActorInstance:GetFullName(), "Cinematics") then
                else
                    ---@class ABP_HumanoidMarinePlayer_C
                    local HumanoidMarinePlayer = ActorInstance
                    if HumanoidMarinePlayer ~= nil then
                        ---@class UStatComponent
                        local ActionComponent = HumanoidMarinePlayer:GetStatComponent()

                        ---@class UDamageReceiverComponent
                        local DamageReceiver = HumanoidMarinePlayer.DamageReceiverComponent

                        -- Crash when unit has a wound..?
                        --DamageReceiver:HealHeavyWound()
                        --DamageReceiver:HealLightWound()

                        DamageReceiver:HealLife(ActionComponent.Life.MaxValue)
                        DamageReceiver:HealArmor(ActionComponent.Armor.MaxValue)

                        local name = HumanoidMarinePlayer:GetName(0):ToString()
                        print(string.format("Healed %s (Life: %d/%d, Armor: %d/%d)\n",
                            name,
                            ActionComponent.Life.CurrentValue, ActionComponent.Life.MaxValue,
                            ActionComponent.Armor.CurrentValue, ActionComponent.Armor.MaxValue)
                        )
                    end
                end
            end
        end
    end)
end

function HighlightAllDataPads()
    ExecuteInGameThread(function()
        local ActorInstances = FindAllOf("BP_DataPad_C")
        if not ActorInstances then
            print("No instances of 'Actor' were found\n")
        else
            for i, ActorInstance in ipairs(ActorInstances) do
                if string.find(ActorInstance:GetFullName(), "Cinematics") then
                else
                    ---@class ABP_DataPad_C
                    local DataPad = ActorInstance
                    if DataPad ~= nil then
                        DataPad.BP_InteractiveHoverComponent_Item:LightHover(true)
                    end
                end
            end
        end
    end)
end

function GetAllDataPads()
    local ActorInstances = FindAllOf("BP_DataPad_C")
    local DataPads = {}
    if not ActorInstances then
        print("No instances of 'Actor' were found\n")
    else
        for i, ActorInstance in ipairs(ActorInstances) do
            ---@class ABP_DataPad_C
            local DataPad = ActorInstance
            if DataPad ~= nil then
                table.insert(DataPads, DataPad)
            end
        end
    end

    return DataPads
end

---@param class string
function GetAllOfClass(class)
    local ActorInstances = FindAllOf(class)
    local Objects = {}
    if not ActorInstances then
        print(string.format("No instances of '%s' were found\n", class))
        return nil
    end

    for i, ActorInstance in ipairs(ActorInstances) do
        if ActorInstance ~= nil then
            table.insert(Objects, ActorInstance)
        end
    end

    return Objects
end

function GetAllInteractiveObjects()
    local InteractiveObjects = {}

    ---@type table<ABP_DataPad_C>|nil
    local DataPads = GetAllOfClass("BP_DataPad_C")
    if DataPads then
        for i, DataPad in ipairs(DataPads) do
            ---@class ABP_DataPad_C
            DataPad = DataPad
            InteractiveObjects[#InteractiveObjects + i] = DataPad
        end
    end

    ---@type table<ABP_Door_Generic_C>|nil
    local Doors = GetAllOfClass("BP_Door_Generic_C")
    if Doors then
        for i, Door in ipairs(Doors) do
            InteractiveObjects[#InteractiveObjects + i] = Door
        end
    end

    ---@type table<ABP_Storage_Generic_C>|nil
    local Storages = GetAllOfClass("BP_Storage_Generic_C")
    if Storages then
        for i, Storage in ipairs(Storages) do
            InteractiveObjects[#InteractiveObjects + i] = Storage
        end
    end

    ---@type table<ABP_FireZone_OilPuddle_C>|nil
    local FireZone = GetAllOfClass("BP_FireZone_OilPuddle_C")
    if FireZone then
        for i, Fire in ipairs(FireZone) do
            InteractiveObjects[#InteractiveObjects + i] = Fire
        end
    end

    ---@type table<ABP_CosmeticCorpse_Engineer_WithWelder_C>|nil
    local Corpse = GetAllOfClass("BP_CosmeticCorpse_Engineer_WithWelder_C")
    if Corpse then
        for i, Corpse in ipairs(Corpse) do
            InteractiveObjects[#InteractiveObjects + i] = Corpse
        end
    end

    return InteractiveObjects
end

function HighlightAllInteractiveObjects()
    ExecuteInGameThread(function()
        local ActorInstances = GetAllInteractiveObjects()
        Highlighted = not Highlighted
        print(string.format("%s %d interactive objects\n", Highlighted and "Highlighting" or "Unhighlighting", #ActorInstances))
        for i, ActorInstance in pairs(ActorInstances) do
            ---@class ABP_DataPad_C
            local DataPad = ActorInstance
            if DataPad ~= nil then
                DataPad.BP_InteractiveHoverComponent_Item:LightHover(Highlighted)
                DataPad.BP_InteractiveHoverComponent_Item:HeavyHover(Highlighted)
            end
        end
    end)
end

RegisterHook("/Script/ASF.DamageReceiverComponent:DoDamage", function()
    ExecuteInGameThread(function()
        if AllMarineActors == nil then
            AllMarineActors = FindAllOf("BP_HumanoidMarinePlayer_C")
        end
        if AllMarineActors and GodModeEnabled then
            for i, ActorInstance in ipairs(AllMarineActors) do
                if string.find(ActorInstance:GetFullName(), "Cinematics") then
                else
                    ---@class ABP_HumanoidMarinePlayer_C
                    local HumanoidMarinePlayer = ActorInstance
                    if HumanoidMarinePlayer ~= nil then
                        ---@class UStatComponent
                        local ActionComponent = HumanoidMarinePlayer:GetStatComponent()
                        ---@class UDamageReceiverComponent
                        local DamageReceiver = HumanoidMarinePlayer.DamageReceiverComponent
                        HumanoidMarinePlayer:ClearWounds()

                        DamageReceiver:HealLife(ActionComponent.Life.MaxValue)
                        DamageReceiver:HealArmor(ActionComponent.Armor.MaxValue)
                    end
                end
            end
        end
    end)
end)

function ToggleGodMode()
    GodModeEnabled = not GodModeEnabled
    print(string.format("God mode %s\n", GodModeEnabled and "enabled" or "disabled"))
end

RegisterKeyBind(Key.F1, { ModifierKey.CONTROL }, HealAll)
RegisterKeyBind(Key.F2, { ModifierKey.CONTROL }, HighlightAllInteractiveObjects)
RegisterKeyBind(Key.F3, { ModifierKey.CONTROL }, ToggleGodMode)