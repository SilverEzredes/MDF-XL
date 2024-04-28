--/////////////////////////////////////--
-- MDF XL

-- Author: SilverEzredes
-- Updated: 04/27/2024
-- Version: v1.0.40
-- Special Thanks to: praydog; alphaZomega

--/////////////////////////////////////--
local hk = require("Hotkeys\\Hotkeys")
local func = require("_SharedCore\\Functions")
local ui = require("_SharedCore\\Imgui")
local docs = require("MDF-XL\\MDF_XL_Docs")
local changed = false
local wc = false
local last_time = 0.0
local tick_interval = 1.0 / 2.5

local isPlayerInScene = false
local isNowLoading = false
local isLoadingScreenBypass = false
local isEquipmentUpdated = false
local isEquipmentDefaultsDumped = false
local isEquipmentMenuHidden = false
local isPauseMenuHidden = false
local isEquipmentMenuDrawn = false
local isItemMenuDrawn = false
local isItemMenuHidden = false
local isHKSavedPresets = false
local isHKLoadPresets = false
local isHKEmissiveToggle = false
local isHKLoadPresetsEditorBypass = false
local show_MDFXL_Editor = false
local show_MDFXL_OutfitManager = false
local show_MDFXL_Docs = false
local dumped_MDFXL_defaults = false
local MDFXL_MaterialParamUpdateHolder = {}
local MDFXL_MeshEditorParamHolder = nil
local MDFXL_MaterialEditorDefaultsHolder = {}
local MDFXL_MaterialEditorParamHolder = {}
local MDFXL_MaterialEditorSubParamFloat4Holder = nil
local presetName = "[Enter Preset Name Here]"
local outfitPresetName = "[Enter Outfit Preset Name Here]"
local presetSearchQuery = ""
local searchQuery = ""
local outfit_presets = {}
local outfit_preset_indx = 1
local dump_outfit_presets = false
local loadingPresetStartTime = 0
local elapsedLoadTime = 0
local progressLoad = 0.0
local savingPresetStartTime = 0
local elapsedSaveTime = 0
local progressSave = 0.0

local characterManager = sdk.get_managed_singleton("app.CharacterManager")
local itemManager = sdk.get_managed_singleton("app.ItemManager")
local GUIManager = sdk.get_managed_singleton("app.GuiManager")

local MDFXL_default_settings = {
    allowAutoJsonCache = true,
    isDEBUG = false,
    showMDFXLConsole = true,
    showMeshName = true,
    showMaterialCount = true,
    showPresetPath = false,
    showMeshPath = true,
    showMDFPath = true,
    isEmissiveHighlightEnabled = false,
    use_modifier = true,
    hotkeys = {
		["Modifier"] = "LControl",
        ["Update Preset Lists"] = "U",
        ["Emissive Highlighting"] = "E",
        ["Save Presets"] = "S",
    },
}

local MDFXL_Master = {
    DD2 = {
        Armor = {
            Helm      =     {ID = "Helm",         Type = "Helm",        MeshName = "",  MeshPath = "",  MDFPath = ""},
            HelmSub   =     {ID = "HelmSub",      Type = "Helm",        MeshName = "",  MeshPath = "",  MDFPath = ""},
            Face      =     {ID = "Facewear",     Type = "Face",        MeshName = "",  MeshPath = "",  MDFPath = ""},
            Mantle    =     {ID = "Mantle",       Type = "Mantle",      MeshName = "",  MeshPath = "",  MDFPath = ""},
            MantleSub =     {ID = "MantleSub",    Type = "Mantle",      MeshName = "",  MeshPath = "",  MDFPath = ""},
            Top       =     {ID = "Tops",         Type = "Top",         MeshName = "",  MeshPath = "",  MDFPath = ""},
            TopAM     =     {ID = "TopsAm",       Type = "Top",         MeshName = "",  MeshPath = "",  MDFPath = ""},
            TopAMs    =     {ID = "TopsAmSub",    Type = "Top",         MeshName = "",  MeshPath = "",  MDFPath = ""},
            TopBD     =     {ID = "TopsBd",       Type = "Top",         MeshName = "",  MeshPath = "",  MDFPath = ""},
            TopBDs    =     {ID = "TopsBdSub",    Type = "Top",         MeshName = "",  MeshPath = "",  MDFPath = ""},
            TopBT     =     {ID = "TopsBt",       Type = "Top",         MeshName = "",  MeshPath = "",  MDFPath = ""},
            TopBTs    =     {ID = "TopsBtSub",    Type = "Top",         MeshName = "",  MeshPath = "",  MDFPath = ""},
            TopUw     =     {ID = "TopsUw",       Type = "Top",         MeshName = "",  MeshPath = "",  MDFPath = ""},
            TopWB     =     {ID = "TopsWb",       Type = "Top",         MeshName = "",  MeshPath = "",  MDFPath = ""},
            TopWBs    =     {ID = "TopsWbSub",    Type = "Top",         MeshName = "",  MeshPath = "",  MDFPath = ""},
            Backpack  =     {ID = "Backpack",     Type = "Backpack",    MeshName = "",  MeshPath = "",  MDFPath = ""},
            Pants     =     {ID = "Pants",        Type = "Pants",       MeshName = "",  MeshPath = "",  MDFPath = ""},
            PantsLG   =     {ID = "PantsLg",      Type = "Pants",       MeshName = "",  MeshPath = "",  MDFPath = ""},
            PantsLGs  =     {ID = "PantsLgSub",   Type = "Pants",       MeshName = "",  MeshPath = "",  MDFPath = ""},
            PantsWL   =     {ID = "PantsWl",      Type = "Pants",       MeshName = "",  MeshPath = "",  MDFPath = ""},
            PantsWLs  =     {ID = "PantsWlSub",   Type = "Pants",       MeshName = "",  MeshPath = "",  MDFPath = ""},
            Underwear =     {ID = "Underwear",    Type = "Underwear",   MeshName = "",  MeshPath = "",  MDFPath = ""},
        },
        ArmorParams = {
            Helm = {
                Presets = {},
                current_preset_indx = 1,
                Materials = {},
                Enabled = {},
                Parts = {},
            },
            HelmSub = {
                Presets = {},
                current_preset_indx = 1,
                Materials = {},
                Enabled = {},
                Parts = {},
            },
            Facewear = {
                Presets = {},
                current_preset_indx = 1,
                Materials = {},
                Enabled = {},
                Parts = {},
            },
            Mantle = {
                Presets = {},
                current_preset_indx = 1,
                Materials = {},
                Enabled = {},
                Parts = {},
            },
            MantleSub = {
                Presets = {},
                current_preset_indx = 1,
                Materials = {},
                Enabled = {},
                Parts = {},
            },
            Tops = {
                Presets = {},
                current_preset_indx = 1,
                Materials = {},
                Enabled = {},
                Parts = {},
            },
            TopsAm = {
                Presets = {},
                current_preset_indx = 1,
                Materials = {},
                Enabled = {},
                Parts = {},
            },
            TopsAmSub = {
                Presets = {},
                current_preset_indx = 1,
                Materials = {},
                Enabled = {},
                Parts = {},
            },
            TopsBd = {
                Presets = {},
                current_preset_indx = 1,
                Materials = {},
                Enabled = {},
                Parts = {},
            },
            TopsBdSub = {
                Presets = {},
                current_preset_indx = 1,
                Materials = {},
                Enabled = {},
                Parts = {},
            },
            TopsBt = {
                Presets = {},
                current_preset_indx = 1,
                Materials = {},
                Enabled = {},
                Parts = {},
            },
            TopsBtSub = {
                Presets = {},
                current_preset_indx = 1,
                Materials = {},
                Enabled = {},
                Parts = {},
            },
            TopsUw = {
                Presets = {},
                current_preset_indx = 1,
                Materials = {},
                Enabled = {},
                Parts = {},
            },
            TopsWb = {
                Presets = {},
                current_preset_indx = 1,
                Materials = {},
                Enabled = {},
                Parts = {},
            },
            TopsWbSub = {
                Presets = {},
                current_preset_indx = 1,
                Materials = {},
                Enabled = {},
                Parts = {},
            },
            Backpack = {
                Presets = {},
                current_preset_indx = 1,
                Materials = {},
                Enabled = {},
                Parts = {},
            },
            Pants = {
                Presets = {},
                current_preset_indx = 1,
                Materials = {},
                Enabled = {},
                Parts = {},
            },
            PantsLg = {
                Presets = {},
                current_preset_indx = 1,
                Materials = {},
                Enabled = {},
                Parts = {},
            },
            PantsLgSub = {
                Presets = {},
                current_preset_indx = 1,
                Materials = {},
                Enabled = {},
                Parts = {},
            },
            PantsWl = {
                Presets = {},
                current_preset_indx = 1,
                Materials = {},
                Enabled = {},
                Parts = {},
            },
            PantsWlSub = {
                Presets = {},
                current_preset_indx = 1,
                Materials = {},
                Enabled = {},
                Parts = {},
            },
            Underwear = {
                Presets = {},
                current_preset_indx = 1,
                Materials = {},
                Enabled = {},
                Parts = {},
            },
        },
        ArmorOrder = {
            "Helm",
            "HelmSub",
            "Face",
            "Mantle",
            "MantleSub",
            "Top",
            "TopAM",
            "TopAMs",
            "TopBD",
            "TopBDs",
            "TopBT",
            "TopBTs",
            "TopUw",
            "TopWB",
            "TopWBs",
            "Backpack",
            "Pants",
            "PantsLG",
            "PantsLGs",
            "PantsWL",
            "PantsWLs",
            "Underwear",
        },
        ArmorOutfitPresets = {},
        Weapon = {
            WP01      =     {ID = "",         Type = "Weapon",        MeshName = "",  MeshPath = "",  MDFPath = ""},
        },
        WeaponParams = {
            WP01 = {
                Presets = {},
                current_preset_indx = 1,
                Materials = {},
                Enabled = {},
                Parts = {},
            },
        },
    }
}

local MDFXL = hk.merge_tables({}, MDFXL_Master) and hk.recurse_def_settings(json.load_file("MDF-XL/__Holders/_MaterialParamDefaultsHolder.json") or {}, MDFXL_Master)
local MDFXL_settings = hk.merge_tables({}, MDFXL_default_settings) and hk.recurse_def_settings(json.load_file("MDF-XL/MDF-XL_Settings.json") or {}, MDFXL_default_settings)
hk.setup_hotkeys(MDFXL_settings.hotkeys)

local function get_CharacterManager()
    if characterManager == nil then characterManager = sdk.get_managed_singleton("app.CharacterManager") end
	return characterManager
end

local function get_ItemManager()
    if itemManager == nil then itemManager = sdk.get_managed_singleton("app.ItemManager") end
	return itemManager
end

local function get_GUIManager()
    if GUIManager == nil then GUIManager = sdk.get_managed_singleton("app.GuiManager") end
	return GUIManager
end

local function check_if_playerIsInScene()
    if characterManager then
        local manualPlayer = characterManager:get_ManualPlayer()
        local player = manualPlayer and manualPlayer:get_Valid()

        if player then
            isPlayerInScene = true
        elseif not player then
            isPlayerInScene = false
        end
    end
end

local function check_if_loadingScreen()
    if GUIManager then
        local loadingGUI = GUIManager:get_IsRequestLoadGUIScene()

        if loadingGUI then
            isNowLoading = true
        elseif not loadingGUI then
            isNowLoading = false
        end
    end
end

local function get_PlayerEquipmentMaterialParams_Manager(armorData, MDFXL_table)
    for _, armor in pairs(armorData) do
        if MDFXL_table[armor.ID] then
            MDFXL_table[armor.ID].Materials = {}
            MDFXL_table[armor.ID].Parts = {}
        end
    end
    
    for _, armor in pairs(armorData) do
        if MDFXL_table[armor.ID] then
            local player = characterManager:get_ManualPlayer()
            local playerEquipment = player and player:get_Valid() and player:get_GameObject():get_Transform():find(armor.ID)

            if playerEquipment then
                local playerArmor = playerEquipment:get_GameObject()

                if playerArmor then
                    local render_mesh = playerArmor:call("getComponent(System.Type)", sdk.typeof("via.render.Mesh"))
                    
                    if render_mesh then
                        local MatCount = render_mesh:call("get_MaterialNum")
                        local nativesMesh = render_mesh:getMesh()
                        local nativesMDF = render_mesh:get_Material()
                        nativesMesh = nativesMesh and nativesMesh:call("ToString()")
                        nativesMDF = nativesMDF and nativesMDF:call("ToString()")
                        if nativesMesh then
                            local meshPath = string.gsub(nativesMesh, "Resource%[", "natives/stm/")
                            local formattedMeshPath = string.gsub(meshPath, ".mesh%]", ".mesh")
                            armor.MeshPath = formattedMeshPath
                            if MDFXL_settings.isDEBUG then
                               log.info("[MDF-XL] " .. formattedMeshPath .. "]")
                            end
                        end
                        nativesMesh = nativesMesh and nativesMesh:match("([^/]-)%.mesh]$")
                        if nativesMesh then
                            armor.MeshName = nativesMesh
                        end
                        if nativesMDF then
                            local mdfPath = string.gsub(nativesMDF, "Resource%[", "natives/stm/")
                            local formattedMDFPath = string.gsub(mdfPath, ".mdf2%]", ".mdf2")
                            armor.MDFPath = formattedMDFPath
                            if MDFXL_settings.isDEBUG then
                                log.info("[MDF-XL] " .. formattedMDFPath .. "]")
                            end
                        end

                        for MatName, _ in pairs(MDFXL_table[armor.ID].Materials) do
                            local found = false
                            for i = 0, MatCount - 1 do
                                if MatName == render_mesh:call("getMaterialName", i) then
                                    found = true
                                    break
                                end
                            end
                            if not found then
                                MDFXL_table[armor.ID].Materials[MatName] = nil
                            end
                        end
        
                        local newPartNames = {}
                        for i = 0, MatCount - 1 do
                            local MatName = render_mesh:call("getMaterialName", i)
                            if MatName then
                                table.insert(newPartNames, MatName)
                            end
                        end
        
                        for PartIndex, PartName in ipairs(MDFXL_table[armor.ID].Parts) do
                            if not func.table_contains(newPartNames, PartName) then
                                table.remove(MDFXL_table[armor.ID].Parts, PartIndex)
                                table.remove(MDFXL_table[armor.ID].Enabled, PartIndex)
                            end
                        end

                        if MatCount then
                            for i = 0, MatCount - 1 do
                                local MatName = render_mesh:call("getMaterialName", i)
                                local MatParam = render_mesh:call("getMaterialVariableNum", i)
                                local EnabledMat = render_mesh:call("getMaterialsEnableIndices", i)
                                
                                if MatName then
                                    if not MDFXL.DD2.ArmorParams[armor.ID].Materials[MatName] then
                                        MDFXL.DD2.ArmorParams[armor.ID].Materials[MatName] = {}
                                    end
                                    if not func.table_contains(MDFXL.DD2.ArmorParams[armor.ID].Parts, MatName) then
                                        table.insert(MDFXL.DD2.ArmorParams[armor.ID].Parts, MatName)
                                    end
                                    if not MDFXL_MaterialParamUpdateHolder[MatName] then
                                        MDFXL_MaterialParamUpdateHolder[MatName] = {}
                                    end
                                    if not func.table_contains(MDFXL_MaterialParamUpdateHolder[MatName], MatName) then
                                        table.insert(MDFXL_MaterialParamUpdateHolder, MatName)
                                    end
                                    
                                    if EnabledMat then
                                        if  MDFXL.DD2.ArmorParams[armor.ID].Presets == "Default Preset" or nil then
                                            for k, _ in ipairs(MDFXL.DD2.ArmorParams[armor.ID].Parts) do
                                                MDFXL.DD2.ArmorParams[armor.ID].Enabled[k] = true
                                            end
                                        end
                                    end
                                    
                                    if MatParam then
                                        for j = 0, MatParam - 1 do
                                            local MatParamNames = render_mesh:call("getMaterialVariableName", i, j)
                                            local MatType = render_mesh:call("getMaterialVariableType", i, j)
                                        
                                            if MatParamNames then
                                                if not MDFXL.DD2.ArmorParams[armor.ID].Materials[MatName][MatParamNames] then
                                                    MDFXL.DD2.ArmorParams[armor.ID].Materials[MatName][MatParamNames] = {}
                                                end
                                                if not MDFXL_MaterialParamUpdateHolder[MatName][MatParamNames] then
                                                    MDFXL_MaterialParamUpdateHolder[MatName][MatParamNames] = {}
                                                end
                                                if not func.table_contains(MDFXL_MaterialParamUpdateHolder[MatName], MatParamNames) then
                                                    table.insert(MDFXL_MaterialParamUpdateHolder[MatName], MatParamNames)
                                                end
                                                MDFXL_MaterialParamUpdateHolder[MatName][MatParamNames].isMaterialParamUpdated = false

                                                if MatType then
                                                    if MatType == 1 then
                                                        local MatType_Float = render_mesh:call("getMaterialFloat", i, j)
                                                        if not func.table_contains(MDFXL.DD2.ArmorParams[armor.ID].Materials[MatName][MatParamNames], MatType_Float) then
                                                            table.insert(MDFXL.DD2.ArmorParams[armor.ID].Materials[MatName][MatParamNames], MatType_Float)
                                                        end
                                                    elseif MatType == 4 then
                                                        local MatType_Float4 = render_mesh:call("getMaterialFloat4", i, j)
                                                        local MatType_Float4_New = {MatType_Float4.x, MatType_Float4.y, MatType_Float4.z, MatType_Float4.w}
                                                        local contains = false
                                                        for _, value in ipairs(MDFXL.DD2.ArmorParams[armor.ID].Materials[MatName][MatParamNames]) do
                                                            if #value == 4 then
                                                                value[1] = MatType_Float4_New[1]
                                                                value[2] = MatType_Float4_New[2]
                                                                value[3] = MatType_Float4_New[3]
                                                                value[4] = MatType_Float4_New[4]
                                                                contains = true
                                                                break
                                                            end
                                                        end
                                                    
                                                        if not contains then
                                                            table.insert(MDFXL.DD2.ArmorParams[armor.ID].Materials[MatName][MatParamNames], MatType_Float4_New)
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            elseif not playerEquipment then
                armor.MeshName = ""
                MDFXL.DD2.ArmorParams[armor.ID].Materials = {}
                MDFXL.DD2.ArmorParams[armor.ID].Parts = {}
                MDFXL.DD2.ArmorParams[armor.ID].Enabled = {}
            end
        end
    end
    json.dump_file("MDF-XL/__Holders/_MaterialParamDefaultsHolder.json", MDFXL)
    json.dump_file("MDF-XL/__Holders/_MaterialParamUpdateHolder.json", MDFXL_MaterialParamUpdateHolder)
end
--TODO
-- local function get_PlayerArmamentMaterialParams_Manager(weaponData, MDFXL_table)
--     for _, weapon in  pairs(weaponData) do
--         local player = characterManager:get_ManualPlayer()
--         local playerTransforms = player and player:get_Valid() and player:get_GameObject():get_Transform()
--         local playerChildren = func.get_children(playerTransforms)
        
--         for i, child in pairs(playerChildren) do
--             local childStrings = child:call("ToString()")
--             local playerArmament = childStrings:match("wp[^1].*")
--             if playerArmament then
--                 playerArmament = playerArmament:gsub("@.*", "")
--                 weapon.ID = playerArmament
--                 local playerEquipment = playerTransforms:find(playerArmament)

--                 if playerEquipment then
--                     local playerWeapon = playerEquipment:get_GameObject()

--                     if playerWeapon then
--                         local render_mesh = playerWeapon:call("getComponent(System.Type)", sdk.typeof("via.render.Mesh"))

--                         if render_mesh then
--                             local MatCount = render_mesh:call("get_MaterialNum")
--                             local nativesMesh = render_mesh:getMesh()
--                             local nativesMDF = render_mesh:get_Material()
--                             nativesMesh = nativesMesh and nativesMesh:call("ToString()")
--                             nativesMDF = nativesMDF and nativesMDF:call("ToString()")
--                             if nativesMesh then
--                                 local meshPath = string.gsub(nativesMesh, "Resource%[", "natives/stm/")
--                                 local formattedMeshPath = string.gsub(meshPath, ".mesh%]", ".mesh")
--                                 weapon.MeshPath = formattedMeshPath
--                                 if MDFXL_settings.isDEBUG then
--                                    log.info("[MDF-XL] " .. formattedMeshPath .. "]")
--                                 end
--                             end
--                             nativesMesh = nativesMesh and nativesMesh:match("([^/]-)%.mesh]$")
--                             if nativesMesh then
--                                 weapon.MeshName = nativesMesh
--                             end
--                             if nativesMDF then
--                                 local mdfPath = string.gsub(nativesMDF, "Resource%[", "natives/stm/")
--                                 local formattedMDFPath = string.gsub(mdfPath, ".mdf2%]", ".mdf2")
--                                 weapon.MDFPath = formattedMDFPath
--                                 if MDFXL_settings.isDEBUG then
--                                     log.info("[MDF-XL] " .. formattedMDFPath .. "]")
--                                 end
--                             end
--                             --TODO
--                             -- for MatName, _ in pairs(MDFXL_table[weapon.ID].Materials) do
--                             --     local found = false
--                             --     for i = 0, MatCount - 1 do
--                             --         if MatName == render_mesh:call("getMaterialName", i) then
--                             --             found = true
--                             --             break
--                             --         end
--                             --     end
--                             --     if not found then
--                             --         MDFXL_table[weapon.ID].Materials[MatName] = nil
--                             --     end
--                             -- end
--                         end
--                     end
--                 end
--             end
--         end
--     end
-- end

local function dump_PlayerEquipmentMaterialParamDefaults(armorData)
    for _, armor in pairs(armorData) do
        local armorType = MDFXL.DD2.ArmorParams[armor.ID]

        if armorType then
            if armor.MeshName ~= "" then
                json.dump_file("MDF-XL\\".. armor.Type .. "\\" .. armor.ID .. "\\" .. armor.MeshName .. "\\Default Preset.json", armorType)
            end
        end
    end
end

local function dump_PlayerEquipmentMaterialParamCurrents(armorData)
    for _, armor in pairs(armorData) do
        local armorType = MDFXL.DD2.ArmorParams[armor.ID]

        if armorType then
            if armor.MeshName ~= "" then
                json.dump_file("MDF-XL\\".. armor.Type .. "\\" .. armor.ID .. "\\" .. armor.MeshName .. "\\Current Preset.json", armorType)
            end
        end
    end
end

local function cache_MDFXL_json_files(armorData)
    local MDFXL_outfitPresets = MDFXL.DD2.ArmorOutfitPresets
    if MDFXL_outfitPresets then
        local json_names = MDFXL.DD2.ArmorOutfitPresets or {}
        local json_filepaths = fs.glob([[MDF-XL\\_Outfits\\.*.json]])

        if json_filepaths then
            for i, filepath in ipairs(json_filepaths) do
                local name = filepath:match("^.+\\(.+)%.")
                local nameExists = false
                
                for j, existingName in ipairs(json_names) do
                    if existingName == name then
                        nameExists = true
                        break
                    end
                end
                
                if not nameExists then
                    if MDFXL_settings.isDEBUG then
                        log.info("[Loaded " .. filepath .. " for MDF-XL Outfit Manager]")
                    end
                    table.insert(json_names, name)
                end
            end
            for i = #json_names, 1, -1 do
                local nameExists = false
                local name = json_names[i]
                for _, filepath in ipairs(json_filepaths) do
                    if filepath:match("^.+\\(.+)%.") == name then
                        nameExists = true
                        break
                    end
                end
                if not nameExists then
                    if MDFXL_settings.isDEBUG then
                        log.info("[Removed " .. name .. " from MDF-XL Outfit Manager]")
                    end
                    table.remove(json_names, i)
                end
            end
        else
            if MDFXL_settings.isDEBUG then
                log.info("[No MDF-XL Outfit Manager JSON files found.]")
            end
        end
    end

    for _, armor in pairs(armorData) do
        local MDFXL_presets = MDFXL.DD2.ArmorParams[armor.ID]
        
        if MDFXL_presets then
            local json_names = MDFXL.DD2.ArmorParams[armor.ID].Presets or {}
            local json_filepaths = fs.glob([[MDF-XL\\]] .. armor.Type .. [[\\]] .. armor.ID .. [[\\]] .. armor.MeshName .. [[\\.*.json]])

            if json_filepaths then
                for i, filepath in ipairs(json_filepaths) do
                    local name = filepath:match("^.+\\(.+)%.")
                    local nameExists = false
                    
                    for j, existingName in ipairs(json_names) do
                        if existingName == name then
                            nameExists = true
                            break
                        end
                    end
                    
                    if not nameExists then
                        if MDFXL_settings.isDEBUG then
                            log.info("[Loaded " .. filepath .. " for "  .. armor.MeshName .. " MDF-XL]")
                        end
                        table.insert(json_names, name)
                    end
                end
                for i = #json_names, 1, -1 do
                    local nameExists = false
                    local name = json_names[i]
                    for _, filepath in ipairs(json_filepaths) do
                        if filepath:match("^.+\\(.+)%.") == name then
                            nameExists = true
                            break
                        end
                    end
                    if not nameExists then
                        if MDFXL_settings.isDEBUG then
                            log.info("[Removed " .. name .. " from " .. armor.MeshName .. "MDF-XL]")
                        end
                        table.remove(json_names, i)
                    end
                end
            else
                if MDFXL_settings.isDEBUG then
                    log.info("[No MDF-XL JSON files found.]")
                end
            end
        end
    end
end

cache_MDFXL_json_files(MDFXL.DD2.Armor)

local function update_PlayerEquipmentMaterialParams_Manager(armorData, MDFXL_table)
    for _, armor in pairs(armorData) do
        if MDFXL_table[armor.ID] then
            if MDFXL_table[armor.ID].isUpdated or isLoadingScreenBypass then
                local player = characterManager:get_ManualPlayer()
               
                local playerEquipment = player and player:get_Valid() and player:get_GameObject():get_Transform():find(armor.ID)
            
                if playerEquipment then
                    local playerArmor = playerEquipment:get_GameObject()
                    if MDFXL_settings.isDEBUG then
                        log.info("[MDF-XL] update_PlayerEquipmentMaterialParams_Manager] " .. tostring(playerEquipment:call("ToString()")))
                    end
                   
                    if playerArmor then
                        local render_mesh = playerArmor:call("getComponent(System.Type)", sdk.typeof("via.render.Mesh"))
                        
                        if render_mesh then
                            local MatCount = render_mesh:call("get_MaterialNum")
                                    
                            if MatCount then
                                for i = 0, MatCount - 1 do
                                    local MatName = render_mesh:call("getMaterialName", i)
                                    local MatParam = render_mesh:call("getMaterialVariableNum", i)
                                    local EnabledMat = render_mesh:call("getMaterialsEnableIndices", i)
                                    
                                    if MatName then
                                        if MatParam then
                                            for k = 0, MatParam - 1 do
                                                local MatParamNames = render_mesh:call("getMaterialVariableName", i, k)
                                                local MatType = render_mesh:call("getMaterialVariableType", i, k)
                                                if MDFXL_MaterialParamUpdateHolder[MatName][MatParamNames].isMaterialParamUpdated or isLoadingScreenBypass then
                                                    if MatParamNames then
                                                        if MatType then
                                                            if MatType == 1 then
                                                                render_mesh:call("setMaterialFloat", i, k, MDFXL.DD2.ArmorParams[armor.ID].Materials[MatName][MatParamNames][1])
                                                            end
                                                            if MatType == 4 then
                                                                local vec4 = MDFXL.DD2.ArmorParams[armor.ID].Materials[MatName][MatParamNames][1]
                                                                render_mesh:call("setMaterialFloat4", i, k, Vector4f.new(vec4[1], vec4[2], vec4[3], vec4[4]))
                                                            end
                                                        end
                                                    end
                                                    MDFXL_MaterialParamUpdateHolder[MatName][MatParamNames].isMaterialParamUpdated = false
                                                end
                                            end
                                        end
                                    end
                                    if EnabledMat then
                                        for j = 0, EnabledMat do
                                            render_mesh:call("setMaterialsEnable", j, MDFXL.DD2.ArmorParams[armor.ID].Enabled[j + 1])
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
                MDFXL_table[armor.ID].isUpdated = false
            end
        end
    end
end

local function get_MasterEquipmentData(armorData)
    get_CharacterManager()
    check_if_playerIsInScene()

    if isPlayerInScene then
        if not dumped_MDFXL_defaults then
            wc = true
            changed = true
            isLoadingScreenBypass = true
            get_PlayerEquipmentMaterialParams_Manager(MDFXL.DD2.Armor, MDFXL.DD2.ArmorParams)
            if not isEquipmentDefaultsDumped then
                dump_PlayerEquipmentMaterialParamDefaults(MDFXL.DD2.Armor)
                isEquipmentDefaultsDumped = true
            end
            cache_MDFXL_json_files(MDFXL.DD2.Armor)
            MDFXL_MaterialEditorDefaultsHolder = func.deepcopy(MDFXL)

            if os.clock() - last_time < tick_interval then return end
            
            for _, armor in pairs(armorData) do
                local total_presets = #MDFXL.DD2.ArmorParams[armor.ID].Presets

                if MDFXL.DD2.ArmorParams[armor.ID].current_preset_indx > total_presets then
                    MDFXL.DD2.ArmorParams[armor.ID].current_preset_indx = 1
                end

                if MDFXL.DD2.ArmorParams[armor.ID].current_preset_indx <= total_presets then
                    if MDFXL.DD2.ArmorParams[armor.ID].current_preset_indx > 1 then
                        local selected_preset = MDFXL.DD2.ArmorParams[armor.ID].Presets[MDFXL.DD2.ArmorParams[armor.ID].current_preset_indx]
                        local json_filepath = [[MDF-XL\\]] .. armor.Type .. "\\" .. armor.ID .. "\\" .. armor.MeshName .. "\\".. selected_preset .. [[.json]]
                        local temp_parts = json.load_file(json_filepath)
                        
                        temp_parts.Presets = nil
                        temp_parts.current_preset_indx = nil

                        for key, value in pairs(temp_parts) do
                            MDFXL.DD2.ArmorParams[armor.ID][key] = value
                        end
                    end
                end
            end
            update_PlayerEquipmentMaterialParams_Manager(MDFXL.DD2.Armor, MDFXL.DD2.ArmorParams)
            last_time = os.clock()
            dumped_MDFXL_defaults = true
            if MDFXL_settings.isDEBUG then
                log.info("[MDF-XL] Master Data Updated]")
            end
        end
    end
end

local function update_OnLoadingScreens(armorData)
    check_if_loadingScreen()
    
    if isPlayerInScene and dumped_MDFXL_defaults then
        if isNowLoading then
            if os.clock() - last_time < tick_interval then return end
            isLoadingScreenBypass = true
            wc = true
            if MDFXL_settings.isDEBUG then
                log.info("[MDF-XL] Now Loading]")
            end
            for _, armor in pairs(armorData) do
                if MDFXL.DD2.ArmorParams[armor.ID].current_preset_indx > 1 then
                    local selected_preset = MDFXL.DD2.ArmorParams[armor.ID].Presets[MDFXL.DD2.ArmorParams[armor.ID].current_preset_indx]
                    local json_filepath = [[MDF-XL\\]] .. armor.Type .. "\\" .. armor.ID .. "\\" .. armor.MeshName .. "\\".. selected_preset .. [[.json]]
                    local temp_parts = json.load_file(json_filepath)
                    
                    temp_parts.Presets = nil
                    temp_parts.current_preset_indx = nil

                    for key, value in pairs(temp_parts) do
                        MDFXL.DD2.ArmorParams[armor.ID][key] = value
                    end
                end
            end
            update_PlayerEquipmentMaterialParams_Manager(MDFXL.DD2.Armor, MDFXL.DD2.ArmorParams)
            last_time = os.clock()
        elseif not isNowLoading then
            isLoadingScreenBypass = false
        end
    end
end

sdk.hook(sdk.find_type_definition("app.ItemManager"):get_method("applyEquipChange()"),
    function(args)
        isEquipmentUpdated = true
    end
)

sdk.hook(sdk.find_type_definition("app.ui060101"):get_method("onHidden()"),
    function(args)
        isPauseMenuHidden = true
    end
)

sdk.hook(sdk.find_type_definition("app.ui060301_00"):get_method("Initialize()"),
    function(args)
        isItemMenuDrawn = true
        isEquipmentMenuHidden = false
    end
)

sdk.hook(sdk.find_type_definition("app.ui060301_00"):get_method("onDestroy()"),
    function(args)
        isItemMenuHidden = true
    end
)

sdk.hook(sdk.find_type_definition("app.ui060401_00"):get_method("Initialize()"),
    function(args)
        isEquipmentMenuDrawn = true
        isItemMenuHidden = false
    end
)

sdk.hook(sdk.find_type_definition("app.ui060401_00"):get_method("onDestroy()"),
    function(args)
        isEquipmentMenuHidden = true
    end
)

local function update_MasterEquipmentData()
    local isPaused = GUIManager:call("isPausedGUI")
    
    if isEquipmentUpdated and isPauseMenuHidden and not isPaused and isEquipmentMenuHidden and isEquipmentMenuDrawn then
        get_PlayerEquipmentMaterialParams_Manager(MDFXL.DD2.Armor, MDFXL.DD2.ArmorParams)
        MDFXL_MaterialEditorDefaultsHolder = func.deepcopy(MDFXL)
        dump_PlayerEquipmentMaterialParamCurrents(MDFXL.DD2.Armor)
        if MDFXL_settings.allowAutoJsonCache then
            cache_MDFXL_json_files(MDFXL.DD2.Armor)
        end
        if MDFXL_settings.isDEBUG then
            log.info("[MDF-XL] Left pause menu, master data updated.]")
        end
        isEquipmentMenuDrawn = false
        isEquipmentMenuHidden = false
    end

    if isEquipmentUpdated and isPauseMenuHidden and not isPaused and isItemMenuDrawn and isItemMenuHidden then
        get_PlayerEquipmentMaterialParams_Manager(MDFXL.DD2.Armor, MDFXL.DD2.ArmorParams)
        MDFXL_MaterialEditorDefaultsHolder = func.deepcopy(MDFXL)
        dump_PlayerEquipmentMaterialParamCurrents(MDFXL.DD2.Armor)
        if MDFXL_settings.allowAutoJsonCache then
            cache_MDFXL_json_files(MDFXL.DD2.Armor)
        end
        if MDFXL_settings.isDEBUG then
            log.info("[MDF-XL] Left pause menu, master data updated.]")
        end
        isItemMenuDrawn = false
        isItemMenuHidden = false
    end

    if not isPaused and isEquipmentMenuHidden then
        get_PlayerEquipmentMaterialParams_Manager(MDFXL.DD2.Armor, MDFXL.DD2.ArmorParams)
        MDFXL_MaterialEditorDefaultsHolder = func.deepcopy(MDFXL)
        dump_PlayerEquipmentMaterialParamCurrents(MDFXL.DD2.Armor)
        if MDFXL_settings.allowAutoJsonCache then
            cache_MDFXL_json_files(MDFXL.DD2.Armor)
        end
        isEquipmentMenuHidden = false
    end
end

local function update_via_Hotkeys(armorData)
    local KM_UPL_controls = ((not MDFXL_settings.use_modifier or hk.check_hotkey("Modifier", false)) and hk.check_hotkey("Update Preset Lists")) or (hk.check_hotkey("Modifier", true) and hk.check_hotkey("Update Preset Lists"))
    local KM_EH_controls = ((not MDFXL_settings.use_modifier or hk.check_hotkey("Modifier", false)) and hk.check_hotkey("Emissive Highlighting")) or (hk.check_hotkey("Modifier", true) and hk.check_hotkey("Emissive Highlighting"))
    local KM_SA_controls = ((not MDFXL_settings.use_modifier or hk.check_hotkey("Modifier", false)) and hk.check_hotkey("Save Presets")) or (hk.check_hotkey("Modifier", true) and hk.check_hotkey("Save Presets"))

    if KM_UPL_controls then
        isHKLoadPresets = true
        cache_MDFXL_json_files(MDFXL.DD2.Armor)
    end
    --TODO
    -- if KM_UPL_controls and isHKLoadPresetsEditorBypass then
    --     cache_MDFXL_json_files(MDFXL.DD2.Armor)
    -- end
    if KM_EH_controls then
        isHKEmissiveToggle = true
        MDFXL_settings.isEmissiveHighlightEnabled = not MDFXL_settings.isEmissiveHighlightEnabled
    end
    if KM_SA_controls then
        isHKSavedPresets = true
        for _, armor in pairs(armorData) do
            local armorType = MDFXL.DD2.ArmorParams[armor.ID]
    
            if armorType then
                if armor.MeshName ~= "" then
                    json.dump_file("MDF-XL\\".. armor.Type .. "\\" .. armor.ID .. "\\" .. armor.MeshName .. "\\Current Preset.json", armorType)
                end
            end
        end
    end
end

re.on_frame( function()
    update_MasterEquipmentData()
    get_MasterEquipmentData(MDFXL.DD2.Armor)
    update_OnLoadingScreens(MDFXL.DD2.Armor)
    if show_MDFXL_Editor then
        update_via_Hotkeys(MDFXL.DD2.Armor)
        if isHKLoadPresets then
            progressLoad = math.min(progressLoad + 0.020, 1.0)
            if loadingPresetStartTime == 0 then
                loadingPresetStartTime = os.clock()
                
            else
                elapsedLoadTime = os.clock() - loadingPresetStartTime
            
                if elapsedLoadTime >= 1.0 then
                    if progressLoad > 0.99 then
                        progressLoad = 0.0
                    end
                    isHKLoadPresets = false
                    loadingPresetStartTime = 0
                end
            end
        end
        if isHKSavedPresets then
            progressSave = math.min(progressSave + 0.012, 1.0)
            if savingPresetStartTime == 0 then
                savingPresetStartTime = os.clock()
                
            else
                elapsedSaveTime = os.clock() - savingPresetStartTime
            
                if elapsedSaveTime >= 1.5 then
                    if progressSave > 0.99 then
                        progressSave = 0.0
                    end
                    isHKSavedPresets = false
                    savingPresetStartTime = 0
                end
            end
        end
        if isHKEmissiveToggle then
            if savingPresetStartTime == 0 then
                savingPresetStartTime = os.clock()
                
            else
                elapsedSaveTime = os.clock() - savingPresetStartTime
            
                if elapsedSaveTime >= 1.0 then
                    isHKEmissiveToggle = false
                    savingPresetStartTime = 0
                end
            end
        end
        if changed or wc then
            isLoadingScreenBypass = false
            changed = false
            wc = false
            update_PlayerEquipmentMaterialParams_Manager(MDFXL.DD2.Armor, MDFXL.DD2.ArmorParams)
        end
    end
end)

local function draw_MDFXL_Editor_GUI(armorOrder)
    if imgui.begin_window("MDF-XL - Editor") then
        imgui.begin_rect()
        imgui.spacing()
        imgui.spacing()
        for _, armor in ipairs(armorOrder) do
            local armorData = MDFXL.DD2.Armor[armor]
            imgui.spacing()
            imgui.indent(20)

            imgui.push_id(_)
            if armorData and imgui.tree_node(armorData.ID) then
                imgui.spacing()
                imgui.begin_rect()
                imgui.text_colored("  " .. ui.draw_line("=", 85) .."  ", 0xFFFFFFFF)
                imgui.indent(15)
                if imgui.button("Update Preset Lists") then
                    wc = true
                    cache_MDFXL_json_files(MDFXL.DD2.Armor)
                end

                if MDFXL_settings.showMeshName then
                    imgui.same_line()
                    imgui.text("[ Mesh Name:")
                    imgui.same_line()
                    imgui.text_colored(armorData.MeshName, 0xFF00BBFF)
                    imgui.same_line()
                    imgui.text("]")
                end

                if MDFXL_settings.showMaterialCount then
                    imgui.same_line()
                    imgui.text("[ Material Count:")
                    imgui.same_line()
                    imgui.text_colored(#MDFXL.DD2.ArmorParams[armorData.ID].Parts, 0xFFDBFF00)
                    imgui.same_line()
                    imgui.text("]")
                end

                changed, MDFXL.DD2.ArmorParams[armorData.ID].current_preset_indx = imgui.combo("Preset", MDFXL.DD2.ArmorParams[armorData.ID].current_preset_indx or 1, MDFXL.DD2.ArmorParams[armorData.ID].Presets); wc = wc or changed
                func.tooltip("Select a file from the dropdown menu to load the settings from that file.")
                if changed then
                    isLoadingScreenBypass = true
                    local selected_preset = MDFXL.DD2.ArmorParams[armorData.ID].Presets[MDFXL.DD2.ArmorParams[armorData.ID].current_preset_indx]
                    local json_filepath = [[MDF-XL\\]] .. armorData.Type .. "\\" .. armorData.ID .. "\\" .. armorData.MeshName .. "\\".. selected_preset .. [[.json]]
                    local temp_parts = json.load_file(json_filepath)
                    
                    temp_parts.Presets = nil
                    temp_parts.current_preset_indx = nil

                    for key, value in pairs(temp_parts) do
                        MDFXL.DD2.ArmorParams[armorData.ID][key] = value
                    end
                    update_PlayerEquipmentMaterialParams_Manager(MDFXL.DD2.Armor, MDFXL.DD2.ArmorParams)
                    json.dump_file("MDF-XL/__Holders/_MaterialParamDefaultsHolder.json", MDFXL)
                end
                
                imgui.push_id(armor)
                changed, presetName = imgui.input_text("", presetName); wc = wc or changed
                imgui.pop_id()

                imgui.same_line()
                if imgui.button("Save Preset") then
                    json.dump_file("MDF-XL\\" .. armorData.Type .. "\\" .. armorData.ID .. "\\" .. armorData.MeshName .. "\\" .. presetName .. ".json", MDFXL.DD2.ArmorParams[armorData.ID])
                    cache_MDFXL_json_files(MDFXL.DD2.Armor)
                end
                func.tooltip("Save the current preset to '[PresetName].json' found in [Dragons Dogma 2/reframework/data/MDF-XL/" .. armorData.Type .. "/" .. armorData.ID .. "/" .. armorData.MeshName .. "/[PresetName].json]")
                
                imgui.spacing()

                if MDFXL_settings.showPresetPath and #MDFXL.DD2.ArmorParams[armorData.ID].Parts > 0 then
                    imgui.input_text("Preset Path", "Dragons Dogma 2/reframework/data/MDF-XL/" .. armorData.Type .. "/" .. armorData.ID .. "/" .. armorData.MeshName .. "/" .. presetName .. ".json")
                end

                if MDFXL_settings.showMeshPath then
                    imgui.push_id(armorData.MeshPath)
                    imgui.input_text("Mesh Path", armorData.MeshPath)
                    imgui.pop_id()
                end

                if MDFXL_settings.showMDFPath then
                    imgui.push_id(armorData.MDFPath)
                    imgui.input_text("MDF Path", armorData.MDFPath)
                    imgui.pop_id()
                end
                
                if imgui.tree_node("Mesh Editor") then
                    local isArmorHovered = imgui.is_item_hovered()
                    imgui.spacing()
                    imgui.text_colored(ui.draw_line("=", 78), 0xFF00BBFF)
                    imgui.indent(15)
                    
                    for i, partName in ipairs(MDFXL.DD2.ArmorParams[armorData.ID].Parts) do
                        local enabledMeshPart = MDFXL.DD2.ArmorParams[armorData.ID].Enabled[i]
                        local defaultEnabledMeshPart = MDFXL_MaterialEditorDefaultsHolder.DD2.ArmorParams[armorData.ID].Enabled[i]
            
                        if enabledMeshPart == defaultEnabledMeshPart or enabledMeshPart ~= defaultEnabledMeshPart then
                            changed, enabledMeshPart = imgui.checkbox(partName, enabledMeshPart); wc = wc or changed
                            MDFXL.DD2.ArmorParams[armorData.ID].Enabled[i] = enabledMeshPart
            
                            if MDFXL_settings.isEmissiveHighlightEnabled then
                                local isHovered = imgui.is_item_hovered()

                                for matName, matData in func.orderedPairs(MDFXL.DD2.ArmorParams[armorData.ID].Materials) do
                                    if partName == matName then
                                        local paramValue = matData["Emissive_Enable"]
                                        if paramValue then
                                            paramValue[1] = (isHovered or isArmorHovered) and 1.0 or 0.0
                                            wc = true
                                            MDFXL_MaterialParamUpdateHolder[matName]["Emissive_Enable"].isMaterialParamUpdated = true
                                        end
                                    end
                                end
                            end
                        end
            
                        if enabledMeshPart ~= defaultEnabledMeshPart then
                            imgui.same_line()
                            imgui.text_colored("*", 0xFF00BBFF)
                        end
                    end
            
                    imgui.indent(-15)
                    imgui.text_colored(ui.draw_line("=", 78), 0xFF00BBFF)
                    imgui.tree_pop()
                end
                
                if imgui.tree_node("Material Editor") then
                    imgui.spacing()
                    imgui.text_colored(ui.draw_line("=", 78), 0xFFDBFF00)
                    changed, searchQuery = imgui.input_text("Search", searchQuery); wc = wc or changed
                    imgui.indent(5)
                    
                    for matName, matData in func.orderedPairs(MDFXL.DD2.ArmorParams[armorData.ID].Materials) do
                        imgui.spacing()
                        
                        if imgui.tree_node(matName) then
                            imgui.push_id(matName)
                            imgui.spacing()
                            if imgui.begin_popup_context_item() then
                                if imgui.menu_item("Reset") then
                                    for paramName, _ in pairs(matData) do
                                        MDFXL.DD2.ArmorParams[armorData.ID].Materials[matName][paramName][1] = MDFXL_MaterialEditorDefaultsHolder.DD2.ArmorParams[armorData.ID].Materials[matName][paramName][1]
                                        wc = true
                                    end
                                    changed = true
                                end
                                if imgui.menu_item("Copy") then
                                    MDFXL_MaterialEditorParamHolder = func.deepcopy(MDFXL.DD2.ArmorParams[armorData.ID].Materials[matName])
                                    wc = true
                                end
                                if imgui.menu_item("Paste") then
                                    local copiedParams = MDFXL_MaterialEditorParamHolder
                                    local targetParams = MDFXL.DD2.ArmorParams[armorData.ID].Materials[matName]
                                    
                                    for paramName, paramValue in pairs(copiedParams) do
                                        if targetParams[paramName] ~= nil then
                                            targetParams[paramName] = func.deepcopy(paramValue)
                                            wc = true
                                        end
                                    end
                                end
                                imgui.end_popup()
                            end
                            for paramName, paramValue in func.orderedPairs(matData) do
                                local originalData = MDFXL_MaterialEditorDefaultsHolder.DD2.ArmorParams[armorData.ID].Materials[matName][paramName]

                                if searchQuery == "" then
                                    imgui.spacing()
                                end
                                
                                if string.find(paramName, searchQuery) then
                                    imgui.begin_rect()
                                    if func.compareTables(paramValue, originalData) then
                                        if imgui.button("[ " .. tostring(paramName) .. " ]") then
                                            paramValue[1] = MDFXL_MaterialEditorDefaultsHolder.DD2.ArmorParams[armorData.ID].Materials[matName][paramName][1] or nil
                                            wc = true
                                        end
                                        if imgui.begin_popup_context_item() then
                                            if imgui.menu_item("Reset") then
                                                paramValue[1] = MDFXL_MaterialEditorDefaultsHolder.DD2.ArmorParams[armorData.ID].Materials[matName][paramName][1]
                                                wc = true
                                            end
                                            if imgui.menu_item("Copy") then
                                                MDFXL_MaterialEditorSubParamFloat4Holder = paramValue[1]
                                                wc = true
                                            end
                                            if imgui.menu_item("Paste") then
                                                paramValue[1] = MDFXL_MaterialEditorSubParamFloat4Holder
                                                wc = true
                                            end
                                            imgui.end_popup()
                                        end
                                    elseif not func.compareTables(paramValue, originalData) then
                                        imgui.indent(35)
                                        if imgui.button("[ " .. tostring(paramName) .. " ]") then
                                            paramValue[1] = MDFXL_MaterialEditorDefaultsHolder.DD2.ArmorParams[armorData.ID].Materials[matName][paramName][1]
                                            wc = true
                                        end
                                        if imgui.begin_popup_context_item() then
                                            if imgui.menu_item("Reset") then
                                                paramValue[1] = MDFXL_MaterialEditorDefaultsHolder.DD2.ArmorParams[armorData.ID].Materials[matName][paramName][1]
                                                wc = true
                                            end
                                            if imgui.menu_item("Copy") then
                                                MDFXL_MaterialEditorSubParamFloat4Holder = paramValue[1]
                                                wc = true
                                            end
                                            if imgui.menu_item("Paste") then
                                                paramValue[1] = MDFXL_MaterialEditorSubParamFloat4Holder
                                                wc = true
                                            end
                                            imgui.end_popup()
                                        end
                                        imgui.same_line()
                                        imgui.text_colored("*", 0xFFDBFF00)
                                    end
                                
                                    if type(paramValue) == "table" then
                                        if type(paramValue[1]) == "table" then
                                            for i, value in ipairs(paramValue) do
                                                imgui.push_id(tostring(paramName))
                                                local newcolor = Vector4f.new(value[1], value[2], value[3], value[4])
                                                changed, newcolor = imgui.color_edit4("", newcolor, nil); wc = wc or changed
                                                paramValue[i] = {newcolor.x, newcolor.y, newcolor.z, newcolor.w}
                                                imgui.pop_id()
                                            end
                                        else
                                            imgui.push_id(tostring(paramName))
                                            changed, paramValue[1] = imgui.drag_float("", paramValue[1], 0.001, 0.0, 100.0); wc = wc or changed
                                            imgui.pop_id()
                                        end
                                        
                                        if changed or wc then
                                            MDFXL_MaterialParamUpdateHolder[matName][paramName].isMaterialParamUpdated = true
                                        end
                                    end
                                    imgui.end_rect(3)
                                    imgui.spacing()
                                end
                            end
                            imgui.pop_id()
                            imgui.spacing()
                            imgui.tree_pop()
                        end
                        
                    end
                    imgui.indent(-5)
                    imgui.text_colored(ui.draw_line("=", 78), 0xFFDBFF00)
                    imgui.tree_pop()
                end

                if changed or wc then
                    MDFXL.DD2.ArmorParams[armorData.ID].isUpdated = true
                end
                imgui.indent(-15)
                imgui.text_colored("  " .. ui.draw_line("=", 85) .."  ", 0xFFFFFFFF)
               
                imgui.end_rect(2)
                imgui.tree_pop()
            end
            imgui.pop_id()
            imgui.text_colored(ui.draw_line("-", 160) .. "    ", 0xFF00BBFF)
            imgui.indent(-20)
        end
        imgui.spacing()
        imgui.spacing()
        imgui.end_rect(1)
       
        imgui.tree_pop()
        imgui.end_window()
    end
end

local function draw_MDFXL_Preset_GUI(armorOrder)
    local filteredOutfitPresets = {}
    for _, preset in ipairs(MDFXL.DD2.ArmorOutfitPresets) do
        if string.find(preset, presetSearchQuery) then
            table.insert(filteredOutfitPresets, preset)
        end
    end
    
    changed, outfit_preset_indx = imgui.combo("Outfit Preset", outfit_preset_indx or 1, filteredOutfitPresets); wc = wc or changed
    if changed then
        local selected_outfitPresetName = filteredOutfitPresets[outfit_preset_indx]
        local json_filepath = "MDF-XL/_Outfits/" .. selected_outfitPresetName .. ".json"
        local selected_outfitPresetContents = json.load_file(json_filepath)
        
        if selected_outfitPresetContents then
            for armorID, current_outfitPresetName in pairs(selected_outfitPresetContents) do
                for _, armor in ipairs(armorOrder) do
                    local armorData = MDFXL.DD2.Armor[armor]
                    local presets = MDFXL.DD2.ArmorParams[armorData.ID].Presets
                    
                    for presetIndex, presetName2 in ipairs(presets) do
                        if presetName2 == current_outfitPresetName and armorData.ID == armorID then
                            isLoadingScreenBypass = true
                            MDFXL.DD2.ArmorParams[armorData.ID].current_preset_indx = presetIndex
                            local json_filepath2 = "MDF-XL/" .. armorData.Type .. "/" .. armorData.ID .. "/" .. armorData.MeshName .. "/".. current_outfitPresetName .. ".json"
                            local temp_parts2 = json.load_file(json_filepath2)
                            
                            temp_parts2.Presets = nil
                            temp_parts2.current_preset_indx = nil
        
                            for key, value in pairs(temp_parts2) do
                                MDFXL.DD2.ArmorParams[armorData.ID][key] = value
                            end
                            update_PlayerEquipmentMaterialParams_Manager(MDFXL.DD2.Armor, MDFXL.DD2.ArmorParams)
                            json.dump_file("MDF-XL/__Holders/_MaterialParamDefaultsHolder.json", MDFXL)
                        end
                    end
                end
            end
        end
    end
    
    for _, armor in ipairs(armorOrder) do
        local armorData = MDFXL.DD2.Armor[armor]
        
        imgui.spacing()
        imgui.push_id(_)
        if armorData then
            local filteredPresets = {}
            local currentPresetIndex = MDFXL.DD2.ArmorParams[armorData.ID].current_preset_indx or 1
        
            for _, preset in ipairs(MDFXL.DD2.ArmorParams[armorData.ID].Presets) do
                if string.find(preset, presetSearchQuery) then
                    table.insert(filteredPresets, preset)
                end
            end
        
            changed, currentPresetIndex = imgui.combo(armorData.ID, currentPresetIndex, filteredPresets); wc = wc or changed
            MDFXL.DD2.ArmorParams[armorData.ID].current_preset_indx = currentPresetIndex
            func.tooltip("Select a file from the dropdown menu to load the settings from that file.")
            
            if changed then
                isLoadingScreenBypass = true
                local selected_preset = filteredPresets[currentPresetIndex]
                local json_filepath = "MDF-XL/" .. armorData.Type .. "/" .. armorData.ID .. "/" .. armorData.MeshName .. "/".. selected_preset .. ".json"
                local temp_parts = json.load_file(json_filepath)
                
                temp_parts.Presets = nil
                temp_parts.current_preset_indx = nil
        
                for key, value in pairs(temp_parts) do
                    MDFXL.DD2.ArmorParams[armorData.ID][key] = value
                end
                update_PlayerEquipmentMaterialParams_Manager(MDFXL.DD2.Armor, MDFXL.DD2.ArmorParams)
                json.dump_file("MDF-XL/__Holders/_MaterialParamDefaultsHolder.json", MDFXL)
            end
        end
        imgui.pop_id()
    end
    imgui.spacing()
end

local function draw_MDFXL_OutfitManager_GUI(armorOrder)
    imgui.begin_rect()
    imgui.spacing()
    imgui.indent(5)
    changed, outfitPresetName = imgui.input_text("", outfitPresetName)
    imgui.same_line()
    if imgui.button("Save Outfit Preset") then
        dump_outfit_presets = true
    else
        dump_outfit_presets = false
    end
    func.tooltip("Save the current preset to '[OutfitPresetName].json' found in [Dragons Dogma 2/reframework/data/MDF-XL/_Outfits/[OutfitPresetName].json")
    imgui.text(ui.draw_line("-", 105) .. ui.draw_line(" ", 5))
    for _, armor in ipairs(armorOrder) do
        local armorData = MDFXL.DD2.Armor[armor]
        imgui.spacing()

        imgui.push_id(_)
        if armorData then
            changed, MDFXL.DD2.ArmorParams[armorData.ID].current_preset_indx = imgui.combo(armorData.ID, MDFXL.DD2.ArmorParams[armorData.ID].current_preset_indx or 1, MDFXL.DD2.ArmorParams[armorData.ID].Presets); wc = wc or changed
            local current_selected_preset = MDFXL.DD2.ArmorParams[armorData.ID].Presets[MDFXL.DD2.ArmorParams[armorData.ID].current_preset_indx]

            if current_selected_preset ~= "Default Preset" and current_selected_preset ~= "Current Preset" then
                outfit_presets[armorData.ID] = current_selected_preset
            end
        end
        imgui.pop_id()
    end
    imgui.text(ui.draw_line("-", 105) .. ui.draw_line(" ", 5))
    imgui.indent(-5)
    imgui.end_rect()

    if dump_outfit_presets then
        json.dump_file("MDF-XL//_Outfits//".. outfitPresetName .. ".json", outfit_presets)
        cache_MDFXL_json_files(MDFXL.DD2.Armor)
    end

    imgui.spacing()
end

local function draw_MDFXL_Docs_GUI()
    if imgui.tree_node("1. Introduction") then
        docs.MDFXL_Docs_Chapter_01()
        imgui.tree_pop()
    end
    if imgui.tree_node("2. Usage") then
        docs.MDFXL_Docs_Chapter_02()
        imgui.tree_pop()
    end
    if imgui.tree_node("3. Material Parameters") then
        docs.MDFXL_Docs_Chapter_03()
        imgui.tree_pop()
    end
end

re.on_draw_ui(function ()
    if imgui.tree_node("MDF-XL") then
        imgui.begin_rect()
        imgui.spacing()
        imgui.indent(20)
        if imgui.button("Update Preset Lists") then
            wc = true
            cache_MDFXL_json_files(MDFXL.DD2.Armor)
        end
        imgui.same_line()
        changed, show_MDFXL_OutfitManager = imgui.checkbox("Open MDF-XL - Outfit Manager", show_MDFXL_OutfitManager)
        imgui.same_line()
        changed, show_MDFXL_Editor = imgui.checkbox("Open MDF-XL - Editor", show_MDFXL_Editor); wc = wc or changed
        imgui.spacing()
        if show_MDFXL_Editor and MDFXL_settings.showMDFXLConsole then
            imgui.indent(2)
            imgui.begin_rect()
            imgui.indent(5)
            imgui.text("MDF-XL Console:")
            imgui.text(ui.draw_line(" ", 100))
            if isHKSavedPresets then
                imgui.progress_bar(progressSave, Vector2f.new(300, 20), string.format("Saving Presets: %.1f%%", progressSave * 100))
                imgui.spacing()
            end
            if isHKLoadPresets then
                imgui.progress_bar(progressLoad, Vector2f.new(300, 20), string.format("Loading Presets: %.1f%%", progressLoad * 100))
                imgui.spacing()
            end
            if isHKEmissiveToggle then
                if MDFXL_settings.isEmissiveHighlightEnabled then
                    imgui.text("Emissive Highlight:")
                    imgui.same_line()
                    imgui.text_colored("[ON]", 0xFF00FF00)
                elseif not MDFXL_settings.isEmissiveHighlightEnabled then
                    imgui.text("Emissive Highlight:")
                    imgui.same_line()
                    imgui.text_colored("[OFF]", 0xFF0000FF)
                end
            end
            imgui.indent(-5)
            imgui.end_rect(2)
            imgui.indent(-2)
            imgui.spacing()
        end
        
        changed, presetSearchQuery = imgui.input_text("Search", presetSearchQuery); wc = wc or changed
        imgui.text(ui.draw_line("-", 135) .. ui.draw_line(" ", 5))

        if not show_MDFXL_Editor or imgui.begin_window("MDF-XL - Editor", true, 0) == false then
            show_MDFXL_Editor = false
        else
            imgui.spacing()
            imgui.indent()
            
            draw_MDFXL_Editor_GUI(MDFXL.DD2.ArmorOrder)
            
            imgui.unindent()
            imgui.end_window()
        end

        if not show_MDFXL_OutfitManager or imgui.begin_window("MDF-XL - Outfit Manager", true, 0) == false then
            show_MDFXL_OutfitManager = false
        else
            imgui.spacing()
            imgui.indent()
            
            draw_MDFXL_OutfitManager_GUI(MDFXL.DD2.ArmorOrder)
            
            imgui.unindent()
            imgui.end_window()
        end

        draw_MDFXL_Preset_GUI(MDFXL.DD2.ArmorOrder)
       
        imgui.text(ui.draw_line("-", 135) .. ui.draw_line(" ", 5))

        imgui.spacing()
        
        if imgui.tree_node("MDF-XL Settings") then
            imgui.begin_rect()
            imgui.spacing()
            imgui.indent(5)
            if imgui.button("Reset to Defaults") then
                wc = true
                changed = true
                MDFXL_settings = hk.recurse_def_settings({}, MDFXL_default_settings); wc = wc or changed
                hk.reset_from_defaults_tbl(MDFXL_default_settings.hotkeys)
            end
            imgui.same_line()
            changed, show_MDFXL_Docs = imgui.checkbox("Open MDF-XL User Manual", show_MDFXL_Docs); wc = wc or changed
        
            if not show_MDFXL_Docs or imgui.begin_window("MDF-XL Documentation", true, 0) == false then
                show_MDFXL_Docs = false
            else
                imgui.spacing()
                imgui.indent()
                
                draw_MDFXL_Docs_GUI()
                
                imgui.unindent()
                imgui.end_window()
            end

            imgui.spacing()
            
            imgui.text("MDF-XL:")
            changed, MDFXL_settings.allowAutoJsonCache = imgui.checkbox("Auto-Cache Presets", MDFXL_settings.allowAutoJsonCache); wc = wc or changed
            func.tooltip("Enable/Disable auto-caching of JSON files. When disabled, you can manually cache the JSON files using the 'Update Preset Lists' button, which will improve performance on lower-end rigs.\nLeave this on if you don't know what you are doing.")
            changed, MDFXL_settings.isDEBUG = imgui.checkbox("Debug Mode", MDFXL_settings.isDEBUG); wc = wc or changed
            func.tooltip("Enable/Disable debug mode. When enabled, MDF-XL will log significantly more information in the re2_framework_log.txt file, located in the game's root folder.")
            changed, MDFXL_settings.showMDFXLConsole = imgui.checkbox("Show MDF-XL Console", MDFXL_settings.showMDFXLConsole)
            imgui.spacing()

            imgui.text("MDF-XL - Editor:")
            changed, MDFXL_settings.showMeshName = imgui.checkbox("Show Mesh Name", MDFXL_settings.showMeshName); wc = wc or changed
            changed, MDFXL_settings.showMaterialCount = imgui.checkbox("Show Material Count", MDFXL_settings.showMaterialCount); wc = wc or changed
            changed, MDFXL_settings.showPresetPath = imgui.checkbox("Show Preset Path", MDFXL_settings.showPresetPath); wc = wc or changed
            changed, MDFXL_settings.showMeshPath = imgui.checkbox("Show Mesh Path", MDFXL_settings.showMeshPath); wc = wc or changed
            changed, MDFXL_settings.showMDFPath = imgui.checkbox("Show MDF Path", MDFXL_settings.showMDFPath); wc = wc or changed
            changed, MDFXL_settings.isEmissiveHighlightEnabled = imgui.checkbox("Emissive Highlighting", MDFXL_settings.isEmissiveHighlightEnabled); wc = wc or changed
            func.tooltip("Enable/Disable Emissive Highlighting for the mesh editor. When enabled, submeshes will glow when hovered over in the Mesh Editor.\nThis option is resource-intensive and will impact performance while the MDF-XL Editor is open.")
            if imgui.tree_node("Hotkey Settings") then
                changed, MDFXL_settings.use_modifier = imgui.checkbox("", MDFXL_settings.use_modifier); wc = wc or changed
                func.tooltip("Require that you hold down this button.")
                imgui.same_line()
                changed = hk.hotkey_setter("Modifier"); wc = wc or changed
                imgui.text(ui.draw_line("-", 60).. ui.draw_line(" ", 2))
                changed = hk.hotkey_setter("Save Presets", MDFXL_settings.use_modifier and "Modifier"); wc = wc or changed
                changed = hk.hotkey_setter("Update Preset Lists", MDFXL_settings.use_modifier and "Modifier"); wc = wc or changed
                changed = hk.hotkey_setter("Emissive Highlighting", MDFXL_settings.use_modifier and "Modifier"); wc = wc or changed
                imgui.tree_pop()
            end
            
            imgui.indent(-5)
            imgui.spacing()
            imgui.end_rect(3)
            imgui.tree_pop()
        end
        
        if wc or changed then
            json.dump_file("MDF-XL/MDF-XL_Settings.json", MDFXL_settings)
        end

        imgui.spacing()

        ui.button_n_colored_txt("Current Version:", "v1.0.40 | 04/27/2024", 0xFF00BBFF)
        imgui.same_line()
        imgui.text("| by SilverEzredes")
        imgui.indent(-20)

        imgui.spacing()

        imgui.end_rect(1)
        imgui.tree_pop()
    end
end)