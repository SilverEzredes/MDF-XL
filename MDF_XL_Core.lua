--/////////////////////////////////////--
-- MDF XL

-- Author: SilverEzredes
-- Updated: 04/11/2024
-- Version: v0.4.85
-- Special Thanks to: praydog; alphaZomega

--/////////////////////////////////////--

local re = re
local sdk = sdk
local imgui = imgui
local log = log
local Vector2f = Vector2f
local Vector4f = Vector4f
local json = json
local fs = fs
local reframework = reframework

local hk = require("Hotkeys\\Hotkeys")
local func = require("_SharedCore\\Functions")
local ui = require("_SharedCore\\Imgui")
local changed = false
local wc = false
local isDEBUG = false
local last_time = 0.0
local tick_interval = 1.0 / 2.5

local characterManager = sdk.get_managed_singleton("app.CharacterManager")
local itemManager = sdk.get_managed_singleton("app.ItemManager")
local GUIManager = sdk.get_managed_singleton("app.GuiManager")

local isPlayerInScene = false
local isNowLoading = false
local isLoadingScreenBypass = false
local isEquipmentUpdated = false
local isEquipmentDefaultsDumped = false
local show_MDFXL_Editor = false
local dumped_MDFXL_defaults = false
local MDFXL_MaterialParamUpdateHolder = {}
local MDFXL_MeshEditorParamHolder = nil
local MDFXL_MaterialEditorDefaultsHolder = {}
local MDFXL_MaterialEditorParamHolder = {}
local MDFXL_MaterialEditorSubParamFloat4Holder = nil
local presetName = "[Enter Preset Name Here]"
local presetSearchQuery = ""
local searchQuery = ""

local MDFXL_Master = {
    DD2 = {
        Armor = {
            Helm      =     {ID = "Helm",         Type = "Helm",        MeshName = ""},
            HelmSub   =     {ID = "HelmSub",      Type = "Helm",        MeshName = ""},
            Face      =     {ID = "Facewear",     Type = "Face",        MeshName = ""},
            Mantle    =     {ID = "Mantle",       Type = "Mantle",      MeshName = ""},
            MantleSub =     {ID = "MantleSub",    Type = "Mantle",      MeshName = ""},
            Top       =     {ID = "Tops",         Type = "Top",         MeshName = ""},
            TopAM     =     {ID = "TopsAm",       Type = "Top",         MeshName = ""},
            TopAMs    =     {ID = "TopsAmSub",    Type = "Top",         MeshName = ""},
            TopBD     =     {ID = "TopsBd",       Type = "Top",         MeshName = ""},
            TopBDs    =     {ID = "TopsBdSub",    Type = "Top",         MeshName = ""},
            TopBT     =     {ID = "TopsBt",       Type = "Top",         MeshName = ""},
            TopBTs    =     {ID = "TopsBtSub",    Type = "Top",         MeshName = ""},
            TopUw     =     {ID = "TopsUw",       Type = "Top",         MeshName = ""},
            TopWB     =     {ID = "TopsWb",       Type = "Top",         MeshName = ""},
            TopWBs    =     {ID = "TopsWbSub",    Type = "Top",         MeshName = ""},
            Backpack  =     {ID = "Backpack",     Type = "Backpack",    MeshName = ""},
            Pants     =     {ID = "Pants",        Type = "Pants",       MeshName = ""},
            PantsLG   =     {ID = "PantsLg",      Type = "Pants",       MeshName = ""},
            PantsLGs  =     {ID = "PantsLgSub",   Type = "Pants",       MeshName = ""},
            PantsWL   =     {ID = "PantsWl",      Type = "Pants",       MeshName = ""},
            PantsWLs  =     {ID = "PantsWlSub",   Type = "Pants",       MeshName = ""},
            Underwear =     {ID = "Underwear",    Type = "Underwear",   MeshName = ""},
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
    }
}

local MDFXL = hk.merge_tables({}, MDFXL_Master) and hk.recurse_def_settings(json.load_file("MDF-XL/__Holders/_MaterialParamDefaultsHolder.json") or {}, MDFXL_Master)

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
            local player = characterManager:get_ManualPlayer()
            local playerEquipment = player and player:get_Valid() and player:get_GameObject():get_Transform():find(armor.ID)

            if playerEquipment then
                local playerArmor = playerEquipment:get_GameObject()

                if playerArmor then
                    local render_mesh = playerArmor:call("getComponent(System.Type)", sdk.typeof("via.render.Mesh"))
                    
                    if render_mesh then
                        local MatCount = render_mesh:call("get_MaterialNum")
                        local nativesMesh = render_mesh:getMesh()
                        nativesMesh = nativesMesh and nativesMesh:call("ToString()")
                        nativesMesh = nativesMesh and nativesMesh:match("([^/]-)%.mesh]$")
                        if nativesMesh then
                            armor.MeshName = nativesMesh
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
                                        if  MDFXL.DD2.ArmorParams[armor.ID].current_preset_indx == 1 or nil then
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
    
    for armorID, armorParams in pairs(MDFXL.DD2.ArmorParams) do
        if armorData[armorID] then
            local player = characterManager:get_ManualPlayer()
            local playerEquipment = player and player:get_Valid() and player:get_GameObject():get_Transform():find(armorID)
            
            if playerEquipment then
                local playerArmor = playerEquipment:get_GameObject()
                
                if playerArmor then
                    local render_mesh = playerArmor:call("getComponent(System.Type)", sdk.typeof("via.render.Mesh"))
                    
                    if render_mesh then
                        local currentEnabledMats = {}
                        local currentMatNames = {}
                        local MatCount = render_mesh:call("get_MaterialNum")
                        
                        if MatCount then
                            for i = 0, MatCount - 1 do
                                local MatName = render_mesh:call("getMaterialName", i)
                                local EnabledMat = render_mesh:call("getMaterialsEnableIndices", i)
                                table.insert(currentMatNames, MatName)
                                
                                if EnabledMat then
                                    table.insert(currentEnabledMats, i)
                                end
                            end
                        end
                        
                        local materialNamesChanged = false
                        for _, PartName in ipairs(armorParams.Parts) do
                            if not func.table_contains(currentMatNames, PartName) then
                                materialNamesChanged = true
                                break
                            end
                        end
    
                        if materialNamesChanged then
                            MDFXL.DD2.ArmorParams[armorID].Materials = {}
                            MDFXL.DD2.ArmorParams[armorID].Parts = {}
                            MDFXL.DD2.ArmorParams[armorID].Enabled = {}
    
                            for _, MatName in ipairs(currentMatNames) do
                                MDFXL.DD2.ArmorParams[armorID].Materials[MatName] = {}
                                table.insert(MDFXL.DD2.ArmorParams[armorID].Parts, MatName)
                            end
                        end
                    end
                end
            elseif not playerEquipment then
                MDFXL.DD2.ArmorParams[armorID].Materials = {}
                MDFXL.DD2.ArmorParams[armorID].Parts = {}
                MDFXL.DD2.ArmorParams[armorID].Enabled = {}
            end
        end
    end
    json.dump_file("MDF-XL/__Holders/_MaterialParamDefaultsHolder.json", MDFXL)
    json.dump_file("MDF-XL/__Holders/_MaterialParamUpdateHolder.json", MDFXL_MaterialParamUpdateHolder)
end

local function dump_PlayerEquipmentMaterialParamDefaults(armorData)
    for _, armor in pairs(armorData) do
        local armorType = MDFXL.DD2.ArmorParams[armor.ID]

        if armorType then
            --json.dump_file("MDF-XL\\".. armor.Type .. "\\" .. armor.ID .. "\\Defaults.json", armorType)
            
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
            --json.dump_file("MDF-XL\\".. armor.Type .. "\\" .. armor.ID .. "\\Defaults.json", armorType)
            
            if armor.MeshName ~= "" then
                json.dump_file("MDF-XL\\".. armor.Type .. "\\" .. armor.ID .. "\\" .. armor.MeshName .. "\\Current Preset.json", armorType)
            end
        end
    end
end

local function cache_MDFXL_json_files(armorData)
    for _, armor in pairs(armorData) do
        local MDF_presets = MDFXL.DD2.ArmorParams[armor.ID]

        if MDF_presets then
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
                        log.info("[Loaded " .. filepath .. " for MDF-XL]")
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
                        log.info("[Removed " .. name .. " from MDF-XL]")
                        table.remove(json_names, i)
                    end
                end
            else
                log.info("[No MDF-XL JSON files found.]")
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
                --local inventoryPlayer = string.gsub(player:get_GameObject():ToString(), "ch000000_00", "MockupModel_ch000000_00")
               
                local playerEquipment = player and player:get_Valid() and player:get_GameObject():get_Transform():find(armor.ID)
            
                if playerEquipment then
                    local playerArmor = playerEquipment:get_GameObject()

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
            dumped_MDFXL_defaults = true
            print("[MDF-XL Master Data Updated]")
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
            print("[Now Loading]")
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

local function update_MasterEquipmentData()
    if isEquipmentUpdated then
        get_PlayerEquipmentMaterialParams_Manager(MDFXL.DD2.Armor, MDFXL.DD2.ArmorParams)
        MDFXL_MaterialEditorDefaultsHolder = func.deepcopy(MDFXL)
        dump_PlayerEquipmentMaterialParamCurrents(MDFXL.DD2.Armor)
        print("[New Item Equipped]")
        isEquipmentUpdated = false
    end
end

re.on_frame( function()
    update_MasterEquipmentData()
    get_MasterEquipmentData(MDFXL.DD2.Armor)
    update_OnLoadingScreens(MDFXL.DD2.Armor)
    if show_MDFXL_Editor and (changed or wc) then
        isLoadingScreenBypass = false
        changed = false
        wc = false
        update_PlayerEquipmentMaterialParams_Manager(MDFXL.DD2.Armor, MDFXL.DD2.ArmorParams)
    end
end)

local function draw_MDFXL_Editor_GUI(armorOrder)
    if imgui.begin_window("MDF XL") then
        imgui.begin_rect()
        imgui.spacing()
        imgui.spacing()
        for _, armor in ipairs(armorOrder) do
            imgui.spacing()
            local armorData = MDFXL.DD2.Armor[armor]
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
                
                changed, presetName = imgui.input_text("", presetName); wc = wc or changed

                imgui.same_line()
                if imgui.button("Save Preset") then
                    json.dump_file("MDF-XL\\" .. armorData.Type .. "\\" .. armorData.ID .. "\\" .. armorData.MeshName .. "\\" .. presetName .. ".json", MDFXL.DD2.ArmorParams[armorData.ID])
                    cache_MDFXL_json_files(MDFXL.DD2.Armor)
                end
                func.tooltip("Save the current preset to '[PresetName].json' found in [Dragons Dogma 2/reframework/data/MDF-XL/" .. armorData.Type .. "/" .. armorData.ID .. "/" .. armorData.MeshName .. "/[PresetName].json]")

                imgui.text("[ Mesh Name:")
                imgui.same_line()
                imgui.text_colored(armorData.MeshName, 0xFF00BBFF)
                imgui.same_line()
                imgui.text("]")

                imgui.same_line()

                imgui.text("[ Material Count:")
                imgui.same_line()
                imgui.text_colored(#MDFXL.DD2.ArmorParams[armorData.ID].Parts, 0xFFDBFF00)
                imgui.same_line()
                imgui.text("]")

                imgui.spacing()

                if imgui.tree_node("Mesh Editor") then
                    imgui.spacing()
                    imgui.text_colored(ui.draw_line("=", 78), 0xFF00BBFF)
                    imgui.indent(15)

                    for i, partName in ipairs(MDFXL.DD2.ArmorParams[armorData.ID].Parts) do
                        if  MDFXL.DD2.ArmorParams[armorData.ID].Enabled[i] == MDFXL_MaterialEditorDefaultsHolder.DD2.ArmorParams[armorData.ID].Enabled[i] then
                            changed, MDFXL.DD2.ArmorParams[armorData.ID].Enabled[i] = imgui.checkbox(partName, MDFXL.DD2.ArmorParams[armorData.ID].Enabled[i]); wc = wc or changed
                            if imgui.begin_popup_context_item(i) then
                                if imgui.menu_item("Reset") then
                                    MDFXL.DD2.ArmorParams[armorData.ID].Enabled[i] = MDFXL_MaterialEditorDefaultsHolder.DD2.ArmorParams[armorData.ID].Enabled[i]
                                    wc = true
                                end
                                if imgui.menu_item("Copy") then
                                    MDFXL_MeshEditorParamHolder = MDFXL.DD2.ArmorParams[armorData.ID].Enabled[i]
                                    wc = true
                                end
                                if imgui.menu_item("Paste") then
                                    MDFXL.DD2.ArmorParams[armorData.ID].Enabled[i] = MDFXL_MeshEditorParamHolder
                                    wc = true
                                end
                                imgui.end_popup()
                            end
                        elseif  MDFXL.DD2.ArmorParams[armorData.ID].Enabled[i] ~= MDFXL_MaterialEditorDefaultsHolder.DD2.ArmorParams[armorData.ID].Enabled[i] then
                            changed, MDFXL.DD2.ArmorParams[armorData.ID].Enabled[i] = imgui.checkbox(partName, MDFXL.DD2.ArmorParams[armorData.ID].Enabled[i]); wc = wc or changed
                            if imgui.begin_popup_context_item(i) then
                                if imgui.menu_item("Reset") then
                                    MDFXL.DD2.ArmorParams[armorData.ID].Enabled[i] = MDFXL_MaterialEditorDefaultsHolder.DD2.ArmorParams[armorData.ID].Enabled[i]
                                    wc = true
                                end
                                if imgui.menu_item("Copy") then
                                    MDFXL_MeshEditorParamHolder = MDFXL.DD2.ArmorParams[armorData.ID].Enabled[i]
                                    wc = true
                                end
                                if imgui.menu_item("Paste") then
                                    MDFXL.DD2.ArmorParams[armorData.ID].Enabled[i] = MDFXL_MeshEditorParamHolder
                                    wc = true
                                end
                                imgui.end_popup()
                            end
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
                                            changed, paramValue[1] = imgui.drag_float("", paramValue[1], 0.001, 0.0, 100.0)
                                            wc = wc or changed
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
        end
        imgui.pop_id()
    end
    imgui.spacing()
end


re.on_draw_ui(function ()
    if imgui.tree_node("MDF XL") then
        imgui.begin_rect()
        imgui.spacing()
        imgui.indent(20)
        if imgui.button("Update Preset Lists") then
            wc = true
            cache_MDFXL_json_files(MDFXL.DD2.Armor)
        end
        imgui.same_line()
        changed, show_MDFXL_Editor = imgui.checkbox("Open MDF XL Editor", show_MDFXL_Editor); wc = wc or changed
        changed, presetSearchQuery = imgui.input_text("Search", presetSearchQuery); wc = wc or changed
        imgui.text(ui.draw_line("-", 135) .. ui.draw_line(" ", 5))

        if not show_MDFXL_Editor or imgui.begin_window("MDF XL", true, 0) == false then
            show_MDFXL_Editor = false
        else
            imgui.spacing()
            imgui.indent()
            
            draw_MDFXL_Editor_GUI(MDFXL.DD2.ArmorOrder)
            
            imgui.unindent()
            imgui.end_window()
        end

        draw_MDFXL_Preset_GUI(MDFXL.DD2.ArmorOrder)

       
        imgui.text(ui.draw_line("-", 135) .. ui.draw_line(" ", 5))

        imgui.button("Notes:")
        imgui.same_line()
        imgui.button("(1)")
        func.tooltip("Right Click on the material name to copy/paste all material params.")
        imgui.same_line()
        imgui.button("(2)")
        func.tooltip("Click on the [material param name] button to reset the selected material param.")
        imgui.same_line()
        imgui.button("(3)")
        func.tooltip("Right Click on the [material param name] button to copy/paste the selected material param.")
        imgui.same_line()
        imgui.button("(4)")
        func.tooltip("The search functions are case-sensitive.")
        
        imgui.spacing()

        ui.button_n_colored_txt("Current Version:", "v0.4.85 | 04/11/2024", 0xFF00BBFF)
        imgui.same_line()
        imgui.text("| by SilverEzredes")
        imgui.indent(-20)
        imgui.spacing()
        imgui.end_rect(1)
        imgui.tree_pop()
    end
end)