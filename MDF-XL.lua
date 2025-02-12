--/////////////////////////////////////--
local modName =  "MDF-XL"

local modAuthor = "SilverEzredes"
local modUpdated = "02/12/2025"
local modVersion = "v1.4.72"
local modCredits = "alphaZomega; praydog"

--/////////////////////////////////////--
local func = require("_SharedCore/Functions")
local ui = require("_SharedCore/Imgui")
local hk = require("Hotkeys/Hotkeys")

local changed = false
local wc = false

local renderComp = "via.render.Mesh"
local texResourceComp = "via.render.TextureResource"
local masterPlayer = nil

local isPlayerInScene = false
local isDefaultsDumped = false
local isUpdaterBypass = false
local isNowLoading = false
local isLoadingScreenUpdater = false
local isAutoSaved = false
local isOutfitManagerBypass = false
local isMDFXL = false
local isMeshEditor = false
local isFlagEditor = false
local isTextureEditor = false
local isUserManual = false
local isAdvancedSearch = false
local materialParamDefaultsHolder = {}
local materialEditorParamHolder = {}
local materialEditorSubParamFloatHolder = nil
local materialEditorSubParamFloat4Holder = nil
local textureEditorStringHolder = nil
local presetName = "[Enter Preset Name Here]"
local paletteName = "[Enter Palette Name Here]"
local outfitName = "[Enter Outfit Name Here]"
local searchQuery = ""
local outfitPresetSearchQuery = ""
local presetSearchQuery = ""
local textureSearchQuery = ""
local lastMatParamName = ""
local lastTime = 0.0
local tickInterval = 0.0
local autoSaveProgress = 0
local wasEditorShown = false

local MDFXL_Cache = {
    resourceOG = "Resource%[",
    nativesSTM = "natives/stm/",
    meshOG = ".mesh%]",
    mesh = ".mesh",
    matchMesh = "([^/]-)%.mesh]$",
    mdf2OG = ".mdf2%]",
    mdf2 = ".mdf2",
    texOG = ".tex%]",
    tex = ".tex",
    AppearanceMenu = {
        "身だしなみの変更",
        "Change Appearance",
        "Changer apparence",
        "Modifica aspetto",
        "Aussehen verändern",
        "Cambiar apariencia",
        "Изменить внешность",
        "Zmień wygląd",
        "Alterar Aparência",
        "變更造型",
        "变更造型",
        "차림새 변경",
        "تغيير المظهر"
    },
    SaveDataPaths = {},
}
local MDFXL_DefaultSettings = {
    showMDFXLEditor = false,
    isDebug = true,
    showEquipmentName = true,
    showEquipmentType = true,
    showMeshName = true,
    showMaterialCount = true,
    showMaterialParamCount = true,
    showTextureCount = true,
    showMaterialFavoritesCount = true,
    showFinalizedPresetName = true,
    showPresetPath = false,
    showPresetVersion = true,
    showMeshPath = true,
    showMDFPath = true,
    primaryDividerLen = 100,
    secondaryDividerLen = 75,
    tertiaryDividerLen = 90,
    isAutoSave = true,
    showAutoSaveProgressBar = true,
    autoSaveInterval = 30.0,
    isSearchMatchCase = false,
    isFilterFavorites = false,
    isInheritPresetName = true,
    isAutoLoadPresetAfterSave = true,
    isHideMainWeapon = false,
    isHideSubWeapon = false,
    version = modVersion,
    presetVersion = "v1.00",
    presetManager = {
        isTrimPresetNames = true,
        showOutfitPreset = true,
        showHunterEquipment = true,
        showHunterArmament = true,
        showOtomoEquipment = true,
        showOtomoArmament = true,
        showPorter = true,
        showEquipmentName = true,
        showEquipmentType = true,
        authorButtonsPerLine = 4,
        tagButtonsPerLine = 5,
        primaryDividerLen = 100,
        secondaryDividerLen = 40,
        menuWidth = 280,
    },
    useModifier = true,
    useModifier2 = true,
    useOutfitModifier = true,
    useOutfitPadModifier = true,
    hotkeys = {
        ["Modifier"] = "LControl",
        ["Secondary Modifier"] = "LAlt",
        ["Toggle MDF-XL Editor"] = "E",
        ["Toggle Filter Favorites"] = "F",
        ["Toggle Color Palettes"] = "P",
        ["Toggle Outfit Manager"] = "O",
        ["Toggle Back Weapons"] = "B",
        ["Toggle Case Sensitive Search"] = "C",
        ["Clear Outfit Search"] = "X",
        ["Outfit Change Modifier"] = "RShift",
        ["Outfit Next"] = "Next",
        ["Outfit Previous"] = "Prior",
        ["GamePad Modifier"] = "LT (L2)",
        ["GamePad Outfit Next"] = "RB (R1)",
        ["GamePad Outfit Previous"] = "LB (L1)",
        ["GamePad Toggle Back Weapons"] = "LStickPush",
    },
    stats = {
        equipmentDataVarCount = 0,
        textureCount = 0,
        presetCount = 0,
        outfitPresetCount = 0,
        colorPaletteCount = 0,
    },
}
local MDFXL_Master = {}
local MDFXL_Sub = {
    order = {},
    weaponOrder = {},
    otomoOrder = {},
    otomoWeaponOrder = {},
    porterOrder = {},
    jsonPaths = {},
    matParamFavorites = {},
    texturePaths = {},
}
local MDFXL_OutfitManager = {
    showMDFXLOutfitEditor = false,
    isUpdated = false,
    currentOutfitPresetIDX = 1,
    jsonPaths = [[MDF-XL\\Outfits\\.*.json]],
    Presets = {},
    isHunterEquipment = true,
    isHunterArmament = true,
    isOtomoEquipment = true,
    isOtomoArmament = true,
    isPorter = true,
}
local MDFXL_ColorPalettes = {
    showMDFXLPaletteEditor = false,
    isUpdated = false,
    currentPalettePresetIDX = 1,
    jsonPaths = [[MDF-XL\\ColorPalettes\\.*.json]],
    Presets = {},
    colors = {},
    newColorIDX = 1,
}
local MDFXL_PresetTracker = {}
local MDFXLSaveDataChunks = {}
local MDFXLTags = {
    _AuthorList = {},
    _AuthorSearchList = {},
    _TagList = {},
    _TagSearchList = {},
}
local MDFXLDatabase = {
    MHWS = {},
}
MDFXLDatabase.MHWS = require("MDF-XLCore/MHWS_Database")

local MDFXLUserManual = {}
MDFXLUserManual = require("MDF-XLCore/UserManual")

local MDFXLSub = hk.merge_tables({}, MDFXL_Sub) and hk.recurse_def_settings(json.load_file("MDF-XL/_Holders/MDF-XL_SubData.json") or {}, MDFXL_Sub)
local MDFXLPresetTracker = hk.merge_tables({}, MDFXL_PresetTracker) and hk.recurse_def_settings(json.load_file("MDF-XL/_Holders/MDF-XL_PresetTracker.json") or {}, MDFXL_PresetTracker)
local MDFXLSettings = hk.merge_tables({}, MDFXL_DefaultSettings) and hk.recurse_def_settings(json.load_file("MDF-XL/_Settings/MDF-XL_Settings.json") or {}, MDFXL_DefaultSettings)
MDFXLSettings.presetVersion = MDFXL_DefaultSettings.presetVersion
local MDFXLPalettes = hk.merge_tables({}, MDFXL_ColorPalettes) and hk.recurse_def_settings(json.load_file("MDF-XL/_Settings/MDF-XL_ColorPalettesSettings.json") or {}, MDFXL_ColorPalettes)
local MDFXLOutfits = hk.merge_tables({}, MDFXL_OutfitManager) and hk.recurse_def_settings(json.load_file("MDF-XL/_Settings/MDF-XL_OutfitManagerSettings.json") or {}, MDFXL_OutfitManager)
hk.setup_hotkeys(MDFXLSettings.hotkeys)

local function cache_SaveDataChunkPaths(saveDataPathsTbl, saveDataChunksPath)
    local saveDataJSONPaths = fs.glob(saveDataChunksPath)
    if saveDataJSONPaths then
        for i, filepath in ipairs(saveDataJSONPaths) do
            local chunkName = filepath:match("^.+\\(.+)%.")
            table.insert(saveDataPathsTbl, "MDF-XL\\_Holders\\_Chunks\\" .. chunkName .. ".json")
        end
    end
end
cache_SaveDataChunkPaths(MDFXL_Cache.SaveDataPaths, [[MDF-XL\\_Holders\\_Chunks\\.*.json]])
local MDFXL = hk.merge_tables({}, MDFXL_Master)
for _, path in ipairs(MDFXL_Cache.SaveDataPaths) do
    local data = json.load_file(path) or {}
    MDFXL = hk.recurse_def_settings(data, MDFXL)
end
--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////--
--MARK:Shared Functions
local function setup_MDFXLTable(MDFXLData, entry)
    MDFXLData[entry] = {}
    MDFXLData[entry].Presets = {}
    MDFXLData[entry].currentPresetIDX = 1
    MDFXLData[entry].presetVersion = MDFXLSettings.presetVersion
    MDFXLData[entry].Parts = {}
    MDFXLData[entry].Flags = {
        isForceTwoSide = nil,
        isBeautyMask = nil,
        isReceiveSSSSS = nil,
    }
    MDFXLData[entry].Textures = {}
    MDFXLData[entry].TextureCount = {}
    MDFXLData[entry].Enabled = {}
    MDFXLData[entry].Materials = {}
    MDFXLData[entry].MaterialParamCount = {}
    MDFXLData[entry].MeshPath = ""
    MDFXLData[entry].MDFPath = ""
    MDFXLData[entry].MeshName = ""
    MDFXLData[entry].AuthorName = ""
    MDFXLData[entry].Tags = {
        "noTag"
    }
    MDFXLData[entry].isUpdated = false
end
local function get_MaterialParams(gameObject, dataTable, entry, subDataTable, order, saveDataTable)
    local renderMesh = func.get_GameObjectComponent(gameObject, renderComp)

    if renderMesh then
        local matCount = renderMesh:get_MaterialNum()
        local nativesMesh = renderMesh:getMesh():ToString()
        local nativesMDF = renderMesh:get_Material():ToString()

        if nativesMesh then
            local meshPath = string.gsub(nativesMesh, MDFXL_Cache.resourceOG, MDFXL_Cache.nativesSTM)
            local formattedMeshPath = string.gsub(meshPath, MDFXL_Cache.meshOG, MDFXL_Cache.mesh)
            dataTable[entry].MeshPath = formattedMeshPath
            if order == "porterOrder" then
                nativesMesh = nativesMesh and nativesMesh:match(MDFXL_Cache.matchMesh)
                dataTable[entry].MeshName = nativesMesh
                table.insert(subDataTable[order], nativesMesh)
            else
                nativesMesh = gameObject:get_Name()
                dataTable[entry].MeshName = nativesMesh
                table.insert(subDataTable[order], nativesMesh)
            end
            local chunkID = nativesMesh:sub(1, 4)
            if (chunkID == "ch02") or (chunkID == "ch03") then
                chunkID = nativesMesh:sub(1, 8)
            end
            if saveDataTable[chunkID] then
                saveDataTable[chunkID].wasUpdated = true
            end
            table.sort(subDataTable[order])
        end
        if nativesMDF then
            local mdfPath = string.gsub(nativesMDF, MDFXL_Cache.resourceOG, MDFXL_Cache.nativesSTM)
            local formattedMDFPath = string.gsub(mdfPath, MDFXL_Cache.mdf2OG, MDFXL_Cache.mdf2)
            dataTable[entry].MDFPath = formattedMDFPath
        end
        if matCount then
            for j = 0, matCount - 1 do
                local matName = renderMesh:getMaterialName(j)
                local matParam = renderMesh:getMaterialVariableNum(j)
                local enabledMat = renderMesh:getMaterialsEnable(j)
                dataTable[entry].MaterialParamCount[matName] = matParam

                if matName then
                    local textureCount = renderMesh:getMaterialTextureNum(j)
                    dataTable[entry].TextureCount[matName] = textureCount
                    if not dataTable[entry].Materials[matName] then
                        dataTable[entry].Materials[matName] = {}
                    end
                    
                    if not func.table_contains(dataTable[entry].Parts, matName) then
                        table.insert(dataTable[entry].Parts, matName)
                    end

                    if enabledMat then
                        if dataTable[entry].currentPresetIDX >= 1 or nil then
                            for k, _ in ipairs(dataTable[entry].Parts) do
                                dataTable[entry].Enabled[k] = true
                            end
                        end
                    end

                    if matParam then
                        for k = 0, matParam - 1 do
                            local matParamNames = renderMesh:getMaterialVariableName(j, k)
                            local matType = renderMesh:getMaterialVariableType(j, k)

                            if matParamNames then
                                if not dataTable[entry].Materials[matName][matParamNames] then
                                    dataTable[entry].Materials[matName][matParamNames] = {}
                                end

                                if matType then
                                    if matType == 1 then
                                        local matTypeFloat = renderMesh:getMaterialFloat(j, k)
                                        table.insert(dataTable[entry].Materials[matName][matParamNames], matTypeFloat)
                                    elseif matType == 4 then
                                        local matTypeFloat4 = renderMesh:getMaterialFloat4(j, k)
                                        local matTypeFloat4New = {matTypeFloat4.x, matTypeFloat4.y, matTypeFloat4.z, matTypeFloat4.w}
                                        table.insert(dataTable[entry].Materials[matName][matParamNames], matTypeFloat4New)
                                    end
                                end
                            end
                        end
                    end

                    for t = 0, textureCount - 1 do
                        local textureName = renderMesh:getMaterialTextureName(j, t)
                        local nativesTexture = renderMesh:getMaterialTexture(j, t):ToString()
                        local texturePath = string.gsub(nativesTexture, MDFXL_Cache.resourceOG, "")
                        local formattedTexturePath = string.gsub(texturePath, MDFXL_Cache.texOG, MDFXL_Cache.tex)
                        
                        if not func.table_contains(subDataTable.texturePaths, formattedTexturePath) then
                            table.insert(subDataTable.texturePaths, formattedTexturePath)
                        end

                        if not dataTable[entry].Textures[matName] then
                            dataTable[entry].Textures[matName] = {}
                        end
                        if not dataTable[entry].Textures[matName][textureName] then
                            dataTable[entry].Textures[matName][textureName] = ""
                        end
                        dataTable[entry].Textures[matName][textureName] = formattedTexturePath
                    end
                end
            end
        end
        dataTable[entry].Flags.isForceTwoSide = renderMesh:get_ForceTwoSide()
        dataTable[entry].Flags.isBeautyMask = renderMesh:get_BeautyMaskFlag()
        dataTable[entry].Flags.isReceiveSSSSS = renderMesh:get_ReceiveSSSSSFlag()
        table.sort(subDataTable.texturePaths)
    end
end
local function set_MaterialParams(gameObject, dataTable, entry, saveDataTable)
    local renderMesh = func.get_GameObjectComponent(gameObject, renderComp)
                                
    if renderMesh then
        local matCount = renderMesh:get_MaterialNum()
        if matCount then
            for j = 0, matCount - 1 do
                local matName = renderMesh:getMaterialName(j)
                local matParam = renderMesh:getMaterialVariableNum(j)
                
                if matName then
                    local textureCount = renderMesh:getMaterialTextureNum(j)

                    if matParam then
                        for k = 0, matParam - 1 do
                            local matParamNames = renderMesh:getMaterialVariableName(j, k)
                            local matType = renderMesh:getMaterialVariableType(j, k)
                            
                            if (matParamNames == lastMatParamName and matType) or isUpdaterBypass then
                                if matType == 1 then
                                    renderMesh:setMaterialFloat(j, k, dataTable[entry.MeshName].Materials[matName][matParamNames][1])
                                end
                                if matType == 4 then
                                    local vec4 = dataTable[entry.MeshName].Materials[matName][matParamNames][1]
                                    renderMesh:setMaterialFloat4(j, k, Vector4f.new(vec4[1], vec4[2], vec4[3], vec4[4]))
                                end
                            end
                        end
                    end
                    if isUpdaterBypass or isTextureEditor then
                        for t = 0, textureCount - 1 do
                            local textureName = renderMesh:getMaterialTextureName(j, t)
                            local textureResource = func.create_resource(texResourceComp, dataTable[entry.MeshName].Textures[matName][textureName])
                            renderMesh:setMaterialTexture(j, t, textureResource)
                        end
                    end
                end
                if isUpdaterBypass or isMeshEditor then
                    for v = 0, #dataTable[entry.MeshName].Enabled do
                        renderMesh:setMaterialsEnable(v, dataTable[entry.MeshName].Enabled[v + 1])
                    end
                end
            end
        end
        if isUpdaterBypass or isFlagEditor then
            renderMesh:set_ForceTwoSide(dataTable[entry.MeshName].Flags.isForceTwoSide)
            renderMesh:set_BeautyMaskFlag(dataTable[entry.MeshName].Flags.isBeautyMask)
            renderMesh:set_ReceiveSSSSSFlag(dataTable[entry.MeshName].Flags.isReceiveSSSSS)
        end
        local chunkID = entry.MeshName:sub(1, 4)
        if (chunkID == "ch02") or (chunkID == "ch03") then
            chunkID = entry.MeshName:sub(1, 8)
        end
        if saveDataTable[chunkID] then
            saveDataTable[chunkID].wasUpdated = true
        end
    end
end
local function manage_SaveDataChunks(MDFXLData, saveDataTable)
    for key, value in pairs(MDFXLData) do
        local chunkID = key:sub(1, 4)
        if reframework.get_game_name() == "mhwilds" then
            if (chunkID == "ch02") or (chunkID == "ch03") then
                chunkID = key:sub(1, 8)
            end
        end
        if not saveDataTable[chunkID] then
            saveDataTable[chunkID] = {
                data = {},
                fileName = "MDF-XL/_Holders/_Chunks/MDF-XL_EquipmentData_" .. chunkID .. ".json",
                wasUpdated = true,
            }
        end
        saveDataTable[chunkID].data[key] = value
    end
end
local function setup_OutfitChanger()
    if #MDFXLOutfits.Presets > 0 then
        local selected_preset = MDFXLOutfits.Presets[MDFXLOutfits.currentOutfitPresetIDX]
        local json_filepath = [[MDF-XL\\Outfits\\]] .. selected_preset .. [[.json]]
        local temp_parts = json.load_file(json_filepath)
        wc = true
        if temp_parts ~= nil then
            for key, value in pairs(temp_parts) do
                MDFXLPresetTracker[key].lastPresetName = value.lastPresetName
            end
            isOutfitManagerBypass = true
            json.dump_file("MDF-XL/_Holders/MDF-XL_PresetTracker.json", MDFXLPresetTracker)
        end
    end
end
--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////--
--MARK: MHWilds
local playerManager_MHWS = sdk.get_managed_singleton("app.PlayerManager")
local otomoManager = sdk.get_managed_singleton("app.OtomoManager")
local porterManager = sdk.get_managed_singleton("app.PorterManager")

local masterOtomo = nil
local masterPorter = nil
local playerCharacter = nil
local otomoCharacter = nil
local porterCharacter = nil
local GUI010000 = nil
local GUI080001 = nil
local GUI090000 = nil
local GUI090001MenuIDX = 0
local GUI090001DecideIDX = 0
local isOtomoInScene = false
local isPorterInScene = false
local isPlayerLeftEquipmentMenu = false
local isPlayerOpenEquipmentMenu = false
local isPlayerLeftCamp = false
local isAppearanceEditorOpen = false
local isAppearanceEditorUpdater = false
local isWeaponDrawn = false
--Generic getters and checks
local function get_PlayerManager_MHWS()
    if playerManager_MHWS == nil then playerManager_MHWS = sdk.get_managed_singleton("app.PlayerManager") end
	return playerManager_MHWS
end
local function get_OtomoManager_MHWS()
    if otomoManager == nil then otomoManager = sdk.get_managed_singleton("app.OtomoManager") end
	return otomoManager
end
local function get_PorterManager_MHWS()
    if porterManager == nil then porterManager = sdk.get_managed_singleton("app.PorterManager") end
	return porterManager
end
local function check_IfPlayerIsInScene_MHWS()
    get_PlayerManager_MHWS()
    
    if playerManager_MHWS then
        masterPlayer = playerManager_MHWS:getMasterPlayer()
        local player = masterPlayer and masterPlayer:get_Valid()

        if player then
            playerCharacter = masterPlayer:get_Character()
            isPlayerInScene = true
        else
            isPlayerInScene = false
        end
    end
end
local function check_IfOtomoIsInScene_MHWS()
    get_OtomoManager_MHWS()
    
    if otomoManager then
        masterOtomo = otomoManager:getMasterOtomoInfo()
        local otomo = masterOtomo and masterOtomo:get_Valid()

        if otomo then
            otomoCharacter = masterOtomo:get_Character()
            isOtomoInScene = true
        else
            isOtomoInScene = false
        end
    end
end
local function check_IfPorterIsInScene_MHWS()
    get_PorterManager_MHWS()
    
    if porterManager then
        masterPorter = porterManager:getMasterPlayerPorter()
        local porter = masterPorter and masterPorter:get_Valid()

        if porter then
            porterCharacter = masterPorter:get_Character()
            isPorterInScene = true
        else
            isPorterInScene = false
        end
    end
end
--Hooks
if reframework.get_game_name() == "mhwilds" then
    --Loading Screen
    sdk.hook(sdk.find_type_definition("app.GUI010000"):get_method("guiLateUpdate()"),
        function(args)
            GUI010000 = sdk.to_managed_object(args[2])
            if GUI010000._Param:getValue() == 90.0 then
                isNowLoading = true
            else
                isNowLoading = false
                isLoadingScreenUpdater = false
            end
        end,
        function(retval)
            return retval
        end
    )
    --Equipment Menu GUI
    sdk.hook(sdk.find_type_definition("app.GUI080001"):get_method("onClose()"),
        function(args)
            isPlayerLeftEquipmentMenu = true
        end
    )
    sdk.hook(sdk.find_type_definition("app.GUI080001"):get_method("onOpen()"),
        function(args)
            isPlayerOpenEquipmentMenu = true
            GUI080001 = sdk.to_managed_object(args[2])
        end
    )
    --Camp GUI
    sdk.hook(sdk.find_type_definition("app.GUI090001"):get_method("guiUpdate()"),
        function (args)
            local GUI090001 = sdk.to_managed_object(args[2])
            GUI090001MenuIDX = sdk.to_int64(args[3])
            GUI090001DecideIDX = GUI090001._DecideCategory
        end
    )
    sdk.hook(sdk.find_type_definition("app.GUI090001"):get_method("closeRequest()"),
        function(args)
            if (GUI090001MenuIDX == 6) or (GUI090001MenuIDX == 7) then
                isPlayerLeftCamp = true
            end
        end
    )
    --Appearance Editor GUI
    sdk.hook(sdk.find_type_definition("app.GUI090000"):get_method("guiUpdate()"),
        function(args)
            if not isPlayerInScene then return end
            GUI090000 = sdk.to_managed_object(args[2])
            local currentMenu = GUI090000:get__MainText():get_Message()
            if func.table_contains(MDFXL_Cache.AppearanceMenu, currentMenu) then
                isAppearanceEditorOpen = true
            end
            if not func.table_contains(MDFXL_Cache.AppearanceMenu, currentMenu) and isAppearanceEditorOpen then
                isAppearanceEditorUpdater = true
                isAppearanceEditorOpen = false
            end
        end,
        function(retval)
            return retval
        end
    )
    --Check if the currently equipped weapon is drawn or not
    sdk.hook(sdk.find_type_definition("app.HunterCharacter"):get_method("checkWeaponOn()"),
        function (args)
            local hunterChar = sdk.to_managed_object(args[2])
            local hunterCharString = hunterChar:ToString()
            if hunterCharString:match("MasterPlayer") then
                isWeaponDrawn = hunterChar._IsWeaponOn
            end
        end,
        function(retval)
            return retval
        end
    )
end
--Material Param Getters
local function help_GetMaterialParams_MHWS(gameObject, gameObjectID, order, MDFXLData, MDFXLSubData, MDFXLSaveDataChunks)
    if gameObject and gameObject:get_Valid() then
        if not MDFXLData[gameObjectID] then
            setup_MDFXLTable(MDFXLData, gameObjectID)
        end
        MDFXLData[gameObjectID].isInScene = true
        MDFXLData[gameObjectID].Parts = {}
        MDFXLData[gameObjectID].Enabled = {}
        MDFXLData[gameObjectID].Materials = {}
        get_MaterialParams(gameObject, MDFXLData, gameObjectID, MDFXLSubData, order, MDFXLSaveDataChunks)
    elseif (not gameObject) or (not gameObject:get_Valid()) then
        MDFXLData[gameObjectID].isInScene = false
    end
end
local function get_PlayerEquipmentMaterialParams_MHWS(MDFXLData, MDFXLSubData)
    if not isPlayerInScene then return end
    MDFXLSubData.order = {}
    
    if playerCharacter then
        local helm = playerCharacter:getParts(0)
        local body = playerCharacter:getParts(1)
        local arm = playerCharacter:getParts(2)
        local waist = playerCharacter:getParts(3)
        local leg = playerCharacter:getParts(4)
        local slinger = playerCharacter:getParts(5)

        if helm then
            local helmID = helm:get_Name()
            help_GetMaterialParams_MHWS(helm, helmID, "order", MDFXLData, MDFXLSubData, MDFXLSaveDataChunks)
        end
        if body then
            local bodyID = body:get_Name()
            help_GetMaterialParams_MHWS(body, bodyID, "order", MDFXLData, MDFXLSubData, MDFXLSaveDataChunks)
        end
        if arm then
            local armID = arm:get_Name()
            help_GetMaterialParams_MHWS(arm, armID, "order", MDFXLData, MDFXLSubData, MDFXLSaveDataChunks)
        end
        if waist then
            local waistID = waist:get_Name()
            help_GetMaterialParams_MHWS(waist, waistID, "order", MDFXLData, MDFXLSubData, MDFXLSaveDataChunks)
        end
        if leg then
            local legID = leg:get_Name()
            help_GetMaterialParams_MHWS(leg, legID, "order", MDFXLData, MDFXLSubData, MDFXLSaveDataChunks)
        end
        if slinger then
            local slingerID = slinger:get_Name()
            help_GetMaterialParams_MHWS(slinger, slingerID, "order", MDFXLData, MDFXLSubData, MDFXLSaveDataChunks)
        end
    end
end
local function get_PlayerArmamentMaterialParams_MHWS(MDFXLData, MDFXLSubData)
    if not isPlayerInScene then return end
    MDFXLSubData.weaponOrder = {}
    if playerCharacter then
        local mainWeapon = playerCharacter:get_Weapon()
        local subWeapon = playerCharacter:get_SubWeapon()
        local subWeaponInsect = playerCharacter:get_Wp10Insect()
        local reserveWeapon = playerCharacter:get_ReserveWeapon()
        local reserveSubWeapon = playerCharacter:get_ReserveSubWeapon()
        local mainWeaponCharm = playerCharacter:get_WeaponCharm()
        local reserveWeaponCharm = playerCharacter:get_ReserveWeaponCharm()

        if mainWeapon then
            mainWeapon = mainWeapon:get_GameObject()
            local mainWeaponID = mainWeapon:get_Name()
            help_GetMaterialParams_MHWS(mainWeapon, mainWeaponID, "weaponOrder", MDFXLData, MDFXLSubData, MDFXLSaveDataChunks)
        end
        if subWeapon then
            subWeapon = subWeapon:get_GameObject()
            local subWeaponID = subWeapon:get_Name()
            help_GetMaterialParams_MHWS(subWeapon, subWeaponID, "weaponOrder", MDFXLData, MDFXLSubData, MDFXLSaveDataChunks)
        end
        if subWeaponInsect then
            subWeaponInsect = subWeaponInsect:get_GameObject()
            local subWeaponInsectID = subWeaponInsect:get_Name()
            help_GetMaterialParams_MHWS(subWeaponInsect, subWeaponInsectID, "weaponOrder", MDFXLData, MDFXLSubData, MDFXLSaveDataChunks)
        end
        if reserveWeapon then
            reserveWeapon = reserveWeapon:get_GameObject()
            local reserveWeaponID = reserveWeapon:get_Name()
            help_GetMaterialParams_MHWS(reserveWeapon, reserveWeaponID, "weaponOrder", MDFXLData, MDFXLSubData, MDFXLSaveDataChunks)
        end
        if reserveSubWeapon then
            reserveSubWeapon = reserveSubWeapon:get_GameObject()
            local reserveSubWeaponID = reserveSubWeapon:get_Name()
            help_GetMaterialParams_MHWS(reserveSubWeapon, reserveSubWeaponID, "weaponOrder", MDFXLData, MDFXLSubData, MDFXLSaveDataChunks)
        end
        if mainWeaponCharm then
            mainWeaponCharm = mainWeaponCharm:get_GameObject()
            local mainWeaponCharmID = mainWeaponCharm:get_Name()
            help_GetMaterialParams_MHWS(mainWeaponCharm, mainWeaponCharmID, "weaponOrder", MDFXLData, MDFXLSubData, MDFXLSaveDataChunks)
        end
        if reserveWeaponCharm then
            reserveWeaponCharm = reserveWeaponCharm:get_GameObject()
            local reserveWeaponCharmID = reserveWeaponCharm:get_Name()
            help_GetMaterialParams_MHWS(reserveWeaponCharm, reserveWeaponCharmID, "weaponOrder", MDFXLData, MDFXLSubData, MDFXLSaveDataChunks)
        end
    end
end
local function get_OtomoEquipmentMaterialParams_MHWS(MDFXLData, MDFXLSubData)
    if not isOtomoInScene then return end
    MDFXLSubData.otomoOrder = {}

    if otomoCharacter then
        local otomoHelm = otomoCharacter:get_HelmGameObject()
        local otomoBody = otomoCharacter:get_BodyGameObject()
        
        if otomoHelm then
            local otomoHelmID = otomoHelm:get_Name()
            help_GetMaterialParams_MHWS(otomoHelm, otomoHelmID, "otomoOrder", MDFXLData, MDFXLSubData, MDFXLSaveDataChunks)
        end
        if otomoBody then
            local otomoBodyID = otomoBody:get_Name()
            help_GetMaterialParams_MHWS(otomoBody, otomoBodyID, "otomoOrder", MDFXLData, MDFXLSubData, MDFXLSaveDataChunks)
        end
    end
end
local function get_OtomoArmamentMaterialParams_MHWS(MDFXLData, MDFXLSubData)
    if not isOtomoInScene then return end
    MDFXLSubData.otomoWeaponOrder = {}

    if otomoCharacter then
        local otomoWeapon = otomoCharacter:get_WeaponGameObject()
        if otomoWeapon then
            local otomoWeaponID = otomoWeapon:get_Name()
            help_GetMaterialParams_MHWS(otomoWeapon, otomoWeaponID, "otomoWeaponOrder", MDFXLData, MDFXLSubData, MDFXLSaveDataChunks)
        end
    end
end
local function get_PorterMaterialParams_MHWS(MDFXLData, MDFXLSubData)
    if not isPorterInScene then return end

    MDFXLSubData.porterOrder = {}
    if porterCharacter then
        local porterBody = porterCharacter:get_EquipBody()
        local porterSaddle = porterCharacter:get_EquipSaddle()
        local porterRein = porterCharacter:get_EquipRein()
        local porterWeaponBag = porterCharacter:get_EquipWeaponBags()

        if porterBody then
            local renderMesh = func.get_GameObjectComponent(porterBody, renderComp)
            local porterBodyID = renderMesh:getMesh():ToString()
            porterBodyID = porterBodyID and porterBodyID:match(MDFXL_Cache.matchMesh)
            help_GetMaterialParams_MHWS(porterBody, porterBodyID, "porterOrder", MDFXLData, MDFXLSubData, MDFXLSaveDataChunks)
        end
        if porterSaddle then
            local renderMesh = func.get_GameObjectComponent(porterSaddle, renderComp)
            local porterSaddleID = renderMesh:getMesh():ToString()
            porterSaddleID = porterSaddleID and porterSaddleID:match(MDFXL_Cache.matchMesh)
            help_GetMaterialParams_MHWS(porterSaddle, porterSaddleID, "porterOrder", MDFXLData, MDFXLSubData, MDFXLSaveDataChunks)
        end
        if porterRein then
            local renderMesh = func.get_GameObjectComponent(porterRein, renderComp)
            local porterReinID = renderMesh:getMesh():ToString()
            porterReinID = porterReinID and porterReinID:match(MDFXL_Cache.matchMesh)
            help_GetMaterialParams_MHWS(porterRein, porterReinID, "porterOrder", MDFXLData, MDFXLSubData, MDFXLSaveDataChunks)
        end
        if porterWeaponBag then
            local renderMesh = func.get_GameObjectComponent(porterWeaponBag, renderComp)
            local porterWeaponBagID = renderMesh:getMesh():ToString()
            porterWeaponBagID = porterWeaponBagID and porterWeaponBagID:match(MDFXL_Cache.matchMesh)
            help_GetMaterialParams_MHWS(porterWeaponBag, porterWeaponBagID, "porterOrder", MDFXLData, MDFXLSubData, MDFXLSaveDataChunks)
        end
    end
end
--Preset Managers 
local function dump_DefaultMaterialParamJSON_MHWS(MDFXLData)
    for _, equipment in pairs(MDFXLData) do
        if (equipment and equipment.isInScene and not isDefaultsDumped) or (isPlayerLeftEquipmentMenu and #equipment.Presets == 0) or (isPlayerLeftCamp and #equipment.Presets == 0) or (isAppearanceEditorUpdater and #equipment.Presets == 0) then
            json.dump_file("MDF-XL/Equipment/" .. equipment.MeshName .. "/" .. equipment.MeshName .. " Default.json", equipment)
            
            if MDFXLSettings.isDebug then
                log.info("[MDF-XL-JSON] [" .. equipment.MeshName .. " Default Preset Dumped]")
            end
        end
    end
end
local function clear_MDFXLJSONCache_MHWS(MDFXLData, MDFXLSubData)
    for _, equipment in pairs(MDFXLData) do
        if (MDFXLData[equipment.MeshName].isUpdated) or (isUpdaterBypass) or (not isDefaultsDumped) or (isNowLoading and not isLoadingScreenUpdater) then
            local cacheKey = "MDF-XL/Equipment/" .. equipment.MeshName
            MDFXLSubData.jsonPaths[cacheKey] = nil

            if MDFXLSettings.isDebug then
                log.info("[MDF-XL-JSON] [Preset path cache cleared for " .. equipment.MeshName .. " ]")
            end
        end
    end
end
local function cache_MDFXLJSONFiles_MHWS(MDFXLData, MDFXLSubData)
    for _, equipment in pairs(MDFXLData) do
        local equipmentParams = MDFXL[equipment.MeshName]
        
        if equipmentParams then
            local json_names = equipmentParams.Presets or {}
            local cacheKey = "MDF-XL/Equipment/" .. equipment.MeshName
            
            if not MDFXLSubData.jsonPaths[cacheKey] then
                local path = [[MDF-XL\\Equipment\\]] .. equipment.MeshName .. [[\\.*.json]]
                MDFXLSubData.jsonPaths[cacheKey] = fs.glob(path)
            end

            local json_filepaths = MDFXLSubData.jsonPaths[cacheKey]
            
            if json_filepaths then
                local defaultName = equipment.MeshName .. " Default"
                local defaultNameInserted = false

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
                        if name == defaultName then
                            table.insert(json_names, 1, name)
                            defaultNameInserted = true
                        else
                            table.insert(json_names, name)
                        end

                        if MDFXLSettings.isDebug then
                            log.info("[MDF-XL-JSON] [Loaded " .. filepath .. " for "  .. equipment.MeshName .. "]")
                        end
                    end
                end
                
                if not defaultNameInserted then
                    for i, name in ipairs(json_names) do
                        if name == defaultName then
                            table.remove(json_names, i)
                            table.insert(json_names, 1, name)
                            break
                        end
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
                        if MDFXLSettings.isDebug then
                            log.info("[MDF-XL-JSON] [Removed " .. name .. " from " ..equipment.MeshName .. "]")
                        end
                        table.remove(json_names, i)
                    end
                end
            else
                if MDFXLSettings.isDebug then
                    log.info("[MDF-XL-JSON] [No MDF-XL JSON files found.]")
                end
            end
        end
    end
    if MDFXLPalettes.Presets then
        local json_names = MDFXLPalettes.Presets or {}
        local json_filepaths = fs.glob(MDFXLPalettes.jsonPaths)

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
                    if MDFXLSettings.isDebug then
                        log.info("[MDF-XL-JSON] [Loaded " .. filepath .. " for MDF-XL Color Palettes]")
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
                    if MDFXLSettings.isDebug then
                        log.info("[MDF-XL-JSON] [Removed " .. name .. " from MDF-XL Color Palettes]")
                    end
                    table.remove(json_names, i)
                end
            end
        else
            if MDFXLSettings.isDebug then
                log.info("[MDF-XL-JSON] [No MDF-XL Color Palettes JSON files found.]")
            end
        end
    end
    if MDFXLOutfits.Presets then
        local json_names = MDFXLOutfits.Presets or {}
        local json_filepaths = fs.glob(MDFXLOutfits.jsonPaths)

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
                    if MDFXLSettings.isDebug then
                        log.info("[MDF-XL-JSON] [Loaded " .. filepath .. " for MDF-XL Outfit Manager]")
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
                    if MDFXLSettings.isDebug then
                        log.info("[MDF-XL-JSON] [Removed " .. name .. " from MDF-XL Outfit Manager]")
                    end
                    table.remove(json_names, i)
                end
            end
        else
            if MDFXLSettings.isDebug then
                log.info("[MDF-XL-JSON] [No MDF-XL Outfit Manager JSON files found]")
            end
        end
    end
end
local function cache_MDFXLTags_MHWS(MDFXLData, tagTable)
    for _, equipment in pairs(MDFXLData) do
        local presetTable = MDFXLData[equipment.MeshName].Presets
        
        for i, presetName in pairs(presetTable) do
            if presetName ~= MDFXLData[equipment.MeshName].MeshName .. " Default" then
                local name = MDFXLData[equipment.MeshName].MeshName
                local tagString = presetName:match("__TAG%-([^_]+)")
                local authorString = presetName:match("__BY%-(.+)")

                if not tagTable[name] then
                    tagTable[name] = {}
                end

                if not tagTable[name][presetName] then
                    tagTable[name][presetName] = {}
                    tagTable[name][presetName].tags = {}
                    tagTable[name][presetName].author = ""
                end

                if tagString then
                    for tag in tagString:gmatch("[^-]+") do
                        tag = tag:lower()
                        local tagSearchKey = "isSearchFor" .. tag
                        if not func.table_contains(tagTable._TagList, tag) then
                            table.insert(tagTable._TagList, tag)
                        end
                        if not func.table_contains(tagTable._TagSearchList, tagSearchKey) then
                            tagTable._TagSearchList[tagSearchKey] = false
                        end
                        if not func.table_contains(tagTable[name][presetName].tags, tag) then
                            table.insert(tagTable[name][presetName].tags, tag)
                        end
                    end
                end

                if authorString then
                    local authorSearchKey = "isSearchFor" .. authorString
                    if not func.table_contains(tagTable._AuthorList, authorString) then
                        table.insert(tagTable._AuthorList, authorString)
                    end
                    if not func.table_contains(tagTable._AuthorSearchList, authorSearchKey) then
                        tagTable._AuthorSearchList[authorSearchKey] = false
                    end
                    tagTable[name][presetName].author = authorString
                end
            end
        end
    end
    table.sort(tagTable._AuthorList)
    table.sort(tagTable._AuthorSearchList)
    table.sort(tagTable._TagList)
    table.sort(tagTable._TagSearchList)
end
--Material Param Setters
local function update_PlayerEquipmentMaterialParams_MHWS(MDFXLData)
    if not isPlayerInScene then return end
    for _, equipment in pairs(MDFXLData) do
        if not func.table_contains(MDFXLSub.order, MDFXLData[equipment.MeshName].MeshName) then
            goto continue
        end
        if (MDFXLData[equipment.MeshName] and MDFXLData[equipment.MeshName].isUpdated) then
            if playerCharacter then
                local helm = playerCharacter:getParts(0)
                local body = playerCharacter:getParts(1)
                local arm = playerCharacter:getParts(2)
                local waist = playerCharacter:getParts(3)
                local leg = playerCharacter:getParts(4)
                local slinger = playerCharacter:getParts(5)
        
                if helm then
                    local helmID = helm:get_Name()
                    if helmID == equipment.MeshName then
                        set_MaterialParams(helm, MDFXLData, equipment, MDFXLSaveDataChunks)
                    end
                end
                if body then
                    local bodyID = body:get_Name()
                    if bodyID == equipment.MeshName then
                        set_MaterialParams(body, MDFXLData, equipment, MDFXLSaveDataChunks)
                    end
                end
                if arm then
                    local armID = arm:get_Name()
                    if armID == equipment.MeshName then
                        set_MaterialParams(arm, MDFXLData, equipment, MDFXLSaveDataChunks)
                    end
                end
                if waist then
                    local waistID = waist:get_Name()
                    if waistID == equipment.MeshName then
                        set_MaterialParams(waist, MDFXLData, equipment, MDFXLSaveDataChunks)
                    end
                end
                if leg then
                    local legID = leg:get_Name()
                    if legID == equipment.MeshName then
                        set_MaterialParams(leg, MDFXLData, equipment, MDFXLSaveDataChunks)
                    end
                end
                if slinger then
                    local slingerID = slinger:get_Name()
                    if slingerID == equipment.MeshName then
                        set_MaterialParams(slinger, MDFXLData, equipment, MDFXLSaveDataChunks)
                    end
                end
            end
        end
        ::continue::
    end
end
local function update_PlayerArmamentMaterialParams_MHWS(MDFXLData)
    if not isPlayerInScene then return end
    for _, weapon in pairs(MDFXLData) do
        if not func.table_contains(MDFXLSub.weaponOrder, MDFXLData[weapon.MeshName].MeshName) then
            goto continue
        end
        if (MDFXLData[weapon.MeshName] and MDFXLData[weapon.MeshName].isUpdated) then
            if playerCharacter then
                local mainWeapon = playerCharacter:get_Weapon()
                local subWeapon = playerCharacter:get_SubWeapon()
                local subWeaponInsect = playerCharacter:get_Wp10Insect()
                local reserveWeapon = playerCharacter:get_ReserveWeapon()
                local reserveSubWeapon = playerCharacter:get_ReserveSubWeapon()
                local mainWeaponCharm = playerCharacter:get_WeaponCharm()
                local reserveWeaponCharm = playerCharacter:get_ReserveWeaponCharm()

                if mainWeapon then
                    mainWeapon = mainWeapon:get_GameObject()
                    if not (mainWeapon and mainWeapon:get_Valid()) then return end
                    
                    local mainWeaponID = mainWeapon:get_Name()
                    if mainWeaponID == weapon.MeshName then
                        set_MaterialParams(mainWeapon, MDFXLData, weapon, MDFXLSaveDataChunks)
                    end
                end
                if subWeapon then
                    subWeapon = subWeapon:get_GameObject()
                    if not (subWeapon and subWeapon:get_Valid()) then return end
                    
                    local subWeaponID = subWeapon:get_Name()
                    if subWeaponID == weapon.MeshName then
                        set_MaterialParams(subWeapon, MDFXLData, weapon, MDFXLSaveDataChunks)
                    end
                end
                if subWeaponInsect then
                    subWeaponInsect = subWeaponInsect:get_GameObject()
                    if not (subWeaponInsect and subWeaponInsect:get_Valid()) then return end
                    
                    local subWeaponInsectID = subWeaponInsect:get_Name()
                    if subWeaponInsectID == weapon.MeshName then
                        set_MaterialParams(subWeaponInsect, MDFXLData, weapon, MDFXLSaveDataChunks)
                    end
                end
                if reserveWeapon then
                    reserveWeapon = reserveWeapon:get_GameObject()
                    if not (reserveWeapon and reserveWeapon:get_Valid()) then return end
                    
                    local reserveWeaponID = reserveWeapon:get_Name()
                    if reserveWeaponID == weapon.MeshName then
                        set_MaterialParams(reserveWeapon, MDFXLData, weapon, MDFXLSaveDataChunks)
                    end
                end
                if reserveSubWeapon then
                    reserveSubWeapon = reserveSubWeapon:get_GameObject()
                    if not (reserveSubWeapon and reserveSubWeapon:get_Valid()) then return end
                    
                    local reserveSubWeaponID = reserveSubWeapon:get_Name()
                    if reserveSubWeaponID == weapon.MeshName then
                        set_MaterialParams(reserveSubWeapon, MDFXLData, weapon, MDFXLSaveDataChunks)
                    end
                end
                if mainWeaponCharm then
                    mainWeaponCharm = mainWeaponCharm:get_GameObject()
                    if not (mainWeaponCharm and mainWeaponCharm:get_Valid()) then return end
                    
                    local mainWeaponCharmID = mainWeaponCharm:get_Name()
                    if mainWeaponCharmID == weapon.MeshName then
                        set_MaterialParams(mainWeaponCharm, MDFXLData, weapon, MDFXLSaveDataChunks)
                    end
                end
                if reserveWeaponCharm then
                    reserveWeaponCharm = reserveWeaponCharm:get_GameObject()
                    if not (reserveWeaponCharm and reserveWeaponCharm:get_Valid()) then return end
                    
                    local reserveWeaponCharmID = reserveWeaponCharm:get_Name()
                    if reserveWeaponCharmID == weapon.MeshName then
                        set_MaterialParams(reserveWeaponCharm, MDFXLData, weapon, MDFXLSaveDataChunks)
                    end
                end
            end
        end
        ::continue::
    end
end
local function update_PlayerArmamentVisibility_MHWS()
    if not playerCharacter then return end

    local mainWeapon = playerCharacter:get_Weapon()
    local subWeapon = playerCharacter:get_SubWeapon()
    local subWeaponInsect = playerCharacter:get_Wp10Insect()
    local reserveWeapon = playerCharacter:get_ReserveWeapon()

    if mainWeapon then
        if not mainWeapon then return end
        mainWeapon = mainWeapon:get_GameObject()
        if not isWeaponDrawn and GUI090001MenuIDX ~= 6 and GUI090001MenuIDX ~= 7 then
            if MDFXLSettings.isHideMainWeapon then
                mainWeapon:set_DrawSelf(false)
            else
                mainWeapon:set_DrawSelf(true)
            end
        else
            mainWeapon:set_DrawSelf(true)
        end
    end

    if subWeapon then
        if not subWeapon then return end
        subWeapon = subWeapon:get_GameObject()
        
        if not isWeaponDrawn and GUI090001MenuIDX ~= 6 and GUI090001MenuIDX ~= 7 then
            if MDFXLSettings.isHideSubWeapon then
                subWeapon:set_DrawSelf(false)
            else
                subWeapon:set_DrawSelf(true)
            end
        else
            subWeapon:set_DrawSelf(true)
        end
    end

    if subWeaponInsect then
        if not subWeaponInsect then return end
        subWeaponInsect = subWeaponInsect:get_GameObject()
        
        if not isWeaponDrawn and GUI090001MenuIDX ~= 6 and GUI090001MenuIDX ~= 7 then
            if MDFXLSettings.isHideSubWeapon then
                subWeaponInsect:set_DrawSelf(false)
            else
                subWeaponInsect:set_DrawSelf(true)
            end
        else
            subWeaponInsect:set_DrawSelf(true)
        end
    end
    
    if reserveWeapon then
        if not reserveWeapon then return end
        reserveWeapon = reserveWeapon:get_GameObject()
        reserveWeapon:set_DrawSelf(true)
    end
end
local function update_OtomoEquipmentMaterialParams_MHWS(MDFXLData)
    if not isOtomoInScene then return end
    for _, equipment in pairs(MDFXLData) do
        if not func.table_contains(MDFXLSub.otomoOrder, MDFXLData[equipment.MeshName].MeshName) then
            goto continue
        end
        if (MDFXLData[equipment.MeshName] and MDFXLData[equipment.MeshName].isUpdated) then
            if otomoCharacter then
                local otomoHelm = otomoCharacter:get_HelmGameObject()
                local otomoBody = otomoCharacter:get_BodyGameObject()
                
                if otomoHelm then
                    local otomoHelmID = otomoHelm:get_Name()
                    if otomoHelmID == equipment.MeshName then
                        set_MaterialParams(otomoHelm, MDFXLData, equipment, MDFXLSaveDataChunks)
                    end
                end
                if otomoBody then
                    local otomoBodyID = otomoBody:get_Name()
                    if otomoBodyID == equipment.MeshName then
                        set_MaterialParams(otomoBody, MDFXLData, equipment, MDFXLSaveDataChunks)
                    end
                end
            end
        end
        :: continue ::
    end
end
local function update_OtomoArmamentMaterialParams_MHWS(MDFXLData)
    if not isOtomoInScene then return end
    for _, weapon in pairs(MDFXLData) do
        if not func.table_contains(MDFXLSub.otomoOrder, MDFXLData[weapon.MeshName].MeshName) then
            goto continue
        end
        if (MDFXLData[weapon.MeshName] and MDFXLData[weapon.MeshName].isUpdated) then
            if otomoCharacter then
                local otomoWeapon = otomoCharacter:get_WeaponGameObject()
                if otomoWeapon then
                    local otomoWeaponID = otomoWeapon:get_Name()
                    if otomoWeaponID == weapon.MeshName then
                        set_MaterialParams(otomoWeapon, MDFXLData, weapon, MDFXLSaveDataChunks)
                    end
                end
            end
        end
        :: continue ::
    end
end
local function update_PorterMaterialParams_MHWS(MDFXLData)
    if not isPorterInScene then return end
    for _, equipment in pairs(MDFXLData) do
        if not func.table_contains(MDFXLSub.porterOrder, MDFXLData[equipment.MeshName].MeshName) then
            goto continue
        end
        if (MDFXLData[equipment.MeshName] and MDFXLData[equipment.MeshName].isUpdated) then
            if porterCharacter then
                local porterBody = porterCharacter:get_EquipBody()
                local porterSaddle = porterCharacter:get_EquipSaddle()
                local porterRein = porterCharacter:get_EquipRein()
                local porterWeaponBag = porterCharacter:get_EquipWeaponBags()
                
                if porterBody then
                    local renderMesh = func.get_GameObjectComponent(porterBody, renderComp)
                    local porterBodyID = renderMesh:getMesh():ToString()
                    porterBodyID = porterBodyID and porterBodyID:match(MDFXL_Cache.matchMesh)

                    if porterBodyID == equipment.MeshName then
                        set_MaterialParams(porterBody, MDFXLData, equipment, MDFXLSaveDataChunks)
                    end
                end
                if porterSaddle then
                    local renderMesh = func.get_GameObjectComponent(porterSaddle, renderComp)
                    local porterSaddleID = renderMesh:getMesh():ToString()
                    porterSaddleID = porterSaddleID and porterSaddleID:match(MDFXL_Cache.matchMesh)

                    if porterSaddleID == equipment.MeshName then
                        set_MaterialParams(porterSaddle, MDFXLData, equipment, MDFXLSaveDataChunks)
                    end
                end
                if porterRein then
                    local renderMesh = func.get_GameObjectComponent(porterRein, renderComp)
                    local porterReinID = renderMesh:getMesh():ToString()
                    porterReinID = porterReinID and porterReinID:match(MDFXL_Cache.matchMesh)

                    if porterReinID == equipment.MeshName then
                        set_MaterialParams(porterRein, MDFXLData, equipment, MDFXLSaveDataChunks)
                    end
                end
                if porterWeaponBag then
                    local renderMesh = func.get_GameObjectComponent(porterWeaponBag, renderComp)
                    local porterWeaponBagID = renderMesh:getMesh():ToString()
                    porterWeaponBagID = porterWeaponBagID and porterWeaponBagID:match(MDFXL_Cache.matchMesh)

                    if porterWeaponBagID == equipment.MeshName then
                        set_MaterialParams(porterWeaponBag, MDFXLData, equipment, MDFXLSaveDataChunks)
                    end
                end
            end
        end
        :: continue ::
    end
end
--Master Functions
local function manage_MasterMaterialData_MHWS(MDFXLData, MDFXLSubData, MDFXLSaveData)
    check_IfPlayerIsInScene_MHWS()
    check_IfOtomoIsInScene_MHWS()
    check_IfPorterIsInScene_MHWS()
    --Initial Loading Screen Updater
    if isNowLoading and not isDefaultsDumped and not isLoadingScreenUpdater then
        get_PlayerEquipmentMaterialParams_MHWS(MDFXLData, MDFXLSubData)
        get_PlayerArmamentMaterialParams_MHWS(MDFXLData, MDFXLSubData)
        get_OtomoEquipmentMaterialParams_MHWS(MDFXLData, MDFXLSubData)
        get_OtomoArmamentMaterialParams_MHWS(MDFXLData, MDFXLSubData)
        get_PorterMaterialParams_MHWS(MDFXLData, MDFXLSubData)
        manage_SaveDataChunks(MDFXLData, MDFXLSaveData)
        dump_DefaultMaterialParamJSON_MHWS(MDFXLData)
        clear_MDFXLJSONCache_MHWS(MDFXLData, MDFXLSubData)
        cache_MDFXLJSONFiles_MHWS(MDFXLData, MDFXLSubData)
        json.dump_file("MDF-XL/_Settings/MDF-XL_Settings.json", MDFXLSettings)
        for i, chunk in pairs(MDFXLSaveData) do
            if chunk.wasUpdated then
                json.dump_file(chunk.fileName, chunk.data)
                chunk.wasUpdated = false
            end
        end
        json.dump_file("MDF-XL/_Holders/MDF-XL_SubData.json", MDFXLSubData)
        materialParamDefaultsHolder = func.deepcopy(MDFXLData)

        for _, equipment in pairs(MDFXLData) do
            if MDFXLData[equipment.MeshName].Presets ~= nil then
                local selected_preset = MDFXLData[equipment.MeshName].Presets[MDFXLData[equipment.MeshName].currentPresetIDX]
                if selected_preset ~= equipment.MeshName .. " Default" and selected_preset ~= nil and equipment.isInScene then
                    wc = true
                    local json_filepath = [[MDF-XL\\Equipment\\]] .. equipment.MeshName .. [[\\]] .. selected_preset .. [[.json]]
                    local temp_parts = json.load_file(json_filepath)

                    if temp_parts.Parts ~= nil then
                        if MDFXLSettings.isDebug then
                            log.info("[MDF-XL] [Auto Preset Loader: " .. equipment.MeshName  .. " ]")
                        end
                        
                        local partsMatch = #temp_parts.Parts == #MDFXLData[equipment.MeshName].Parts

                        if partsMatch then
                            for _, part in ipairs(temp_parts.Parts) do
                                local found = false
                                for _, ogPart in ipairs(MDFXLData[equipment.MeshName].Parts) do
                                    if part == ogPart then
                                        found = true
                                        break
                                    end
                                end
                
                                if not found then
                                    partsMatch = false
                                    break
                                end
                            end
                        end
                
                        if partsMatch then
                            temp_parts.Presets = nil
                            temp_parts.currentPresetIDX = nil

                            for key, value in pairs(temp_parts) do
                                MDFXLData[equipment.MeshName][key] = value
                            end
                            MDFXLData[equipment.MeshName].isUpdated = true
                            isUpdaterBypass = true
                            update_PlayerEquipmentMaterialParams_MHWS(MDFXLData)
                            update_PlayerArmamentMaterialParams_MHWS(MDFXLData)
                            update_OtomoEquipmentMaterialParams_MHWS(MDFXLData)
                            update_OtomoArmamentMaterialParams_MHWS(MDFXLData)
                            update_PorterMaterialParams_MHWS(MDFXLData)
                        else
                            log.info("[MDF-XL] [ERROR-000] [Parts do not match, skipping the update.]")
                            MDFXLData[equipment.MeshName].currentPresetIDX = 1
                        end
                        if temp_parts.presetVersion ~= MDFXLSettings.presetVersion then
                            log.info("[MDF-XL] [WARNING-000] [" .. equipment.MeshName .. " Preset Version is outdated.]")
                        end
                    end
                elseif selected_preset == nil or {} then
                    MDFXLData[equipment.MeshName].currentPresetIDX = 1
                end
                if not func.table_contains(MDFXLPresetTracker, equipment.MeshName) then
                    MDFXLPresetTracker[equipment.MeshName] = {}
                end
                MDFXLPresetTracker[equipment.MeshName].lastPresetName = MDFXLData[equipment.MeshName].Presets[MDFXLData[equipment.MeshName].currentPresetIDX]
            end
        end
        
        for i, chunk in pairs(MDFXLSaveData) do
            if chunk.wasUpdated then
                chunk.wasUpdated = false
            end
        end
        cache_MDFXLTags_MHWS(MDFXL, MDFXLTags)
        json.dump_file("MDF-XL/_Settings/MDF-XL_ColorPalettesSettings.json", MDFXLPalettes)
        json.dump_file("MDF-XL/_Holders/MDF-XL_PresetTracker.json", MDFXLPresetTracker)
        log.info("[MDF-XL] [Master Data defaults dumped.]")
        isDefaultsDumped = true
        isLoadingScreenUpdater = true
    end
    --Subsequent Loading Screen Updater
    if isNowLoading and isDefaultsDumped and not isLoadingScreenUpdater then
        get_PlayerEquipmentMaterialParams_MHWS(MDFXLData, MDFXLSubData)
        get_PlayerArmamentMaterialParams_MHWS(MDFXLData, MDFXLSubData)
        get_OtomoEquipmentMaterialParams_MHWS(MDFXLData, MDFXLSubData)
        get_OtomoArmamentMaterialParams_MHWS(MDFXLData, MDFXLSubData)
        get_PorterMaterialParams_MHWS(MDFXLData, MDFXLSubData)
        manage_SaveDataChunks(MDFXLData, MDFXLSaveData)
        clear_MDFXLJSONCache_MHWS(MDFXLData, MDFXLSubData)
        cache_MDFXLJSONFiles_MHWS(MDFXLData, MDFXLSubData)
        json.dump_file("MDF-XL/_Settings/MDF-XL_Settings.json", MDFXLSettings)
        for i, chunk in pairs(MDFXLSaveData) do
            if chunk.wasUpdated then
                json.dump_file(chunk.fileName, chunk.data)
                chunk.wasUpdated = false
            end
        end
        json.dump_file("MDF-XL/_Holders/MDF-XL_SubData.json", MDFXLSubData)

        for _, equipment in pairs(MDFXLData) do
            if MDFXLData[equipment.MeshName].Presets ~= nil then
                local selected_preset = MDFXLData[equipment.MeshName].Presets[MDFXLData[equipment.MeshName].currentPresetIDX]
                if selected_preset ~= equipment.MeshName .. " Default" and selected_preset ~= nil then
                    wc = true
                    local json_filepath = [[MDF-XL\\Equipment\\]] .. equipment.MeshName .. [[\\]] .. selected_preset .. [[.json]]
                    local temp_parts = json.load_file(json_filepath)

                    if temp_parts.Parts ~= nil then
                        if MDFXLSettings.isDebug then
                            log.info("[MDF-XL] [Auto Preset Loader: " .. equipment.MeshName  .. " ]")
                        end
                        
                        local partsMatch = #temp_parts.Parts == #MDFXLData[equipment.MeshName].Parts

                        if partsMatch then
                            for _, part in ipairs(temp_parts.Parts) do
                                local found = false
                                for _, ogPart in ipairs(MDFXLData[equipment.MeshName].Parts) do
                                    if part == ogPart then
                                        found = true
                                        break
                                    end
                                end
                
                                if not found then
                                    partsMatch = false
                                    break
                                end
                            end
                        end
                
                        if partsMatch then
                            temp_parts.Presets = nil
                            temp_parts.currentPresetIDX = nil

                            for key, value in pairs(temp_parts) do
                                MDFXLData[equipment.MeshName][key] = value
                            end
                            MDFXLData[equipment.MeshName].isUpdated = true
                            isUpdaterBypass = true
                            update_PlayerEquipmentMaterialParams_MHWS(MDFXLData)
                            update_PlayerArmamentMaterialParams_MHWS(MDFXLData)
                            update_OtomoEquipmentMaterialParams_MHWS(MDFXLData)
                            update_OtomoArmamentMaterialParams_MHWS(MDFXLData)
                            update_PorterMaterialParams_MHWS(MDFXLData)
                        else
                            log.info("[MDF-XL] [ERROR-000] [Parts do not match, skipping the update.]")
                            MDFXLData[equipment.MeshName].currentPresetIDX = 1
                        end
                        if temp_parts.presetVersion ~= MDFXLSettings.presetVersion then
                            log.info("[MDF-XL] [WARNING-000] [" .. equipment.MeshName .. " Preset Version is outdated.]")
                        end
                    end
                elseif selected_preset == nil or {} then
                    MDFXLData[equipment.MeshName].currentPresetIDX = 1
                end
                if not func.table_contains(MDFXLPresetTracker, equipment.MeshName) then
                    MDFXLPresetTracker[equipment.MeshName] = {}
                end
                MDFXLPresetTracker[equipment.MeshName].lastPresetName = MDFXLData[equipment.MeshName].Presets[MDFXLData[equipment.MeshName].currentPresetIDX]
            end
        end
        
        for i, chunk in pairs(MDFXLSaveData) do
            if chunk.wasUpdated then
                chunk.wasUpdated = false
            end
        end
        cache_MDFXLTags_MHWS(MDFXL, MDFXLTags)
        json.dump_file("MDF-XL/_Settings/MDF-XL_ColorPalettesSettings.json", MDFXLPalettes)
        json.dump_file("MDF-XL/_Holders/MDF-XL_PresetTracker.json", MDFXLPresetTracker)
        log.info("[MDF-XL] [Loading Screen detected, MDF-XL data updated.]")
        isLoadingScreenUpdater = true
    end
    --Equipment Menu Updater
    if isPlayerLeftEquipmentMenu and isDefaultsDumped then
        if GUI090001DecideIDX == 1 then
            get_PlayerEquipmentMaterialParams_MHWS(MDFXLData, MDFXLSubData)
            get_PlayerArmamentMaterialParams_MHWS(MDFXLData, MDFXLSubData)
        elseif GUI090001DecideIDX == 2 then
            get_OtomoEquipmentMaterialParams_MHWS(MDFXLData, MDFXLSubData)
            get_OtomoArmamentMaterialParams_MHWS(MDFXLData, MDFXLSubData)
        end
        manage_SaveDataChunks(MDFXLData, MDFXLSaveData)
        dump_DefaultMaterialParamJSON_MHWS(MDFXLData)
        clear_MDFXLJSONCache_MHWS(MDFXLData, MDFXLSubData)
        cache_MDFXLJSONFiles_MHWS(MDFXLData, MDFXLSubData)
        
        for i, chunk in pairs(MDFXLSaveData) do
            if chunk.wasUpdated then
                json.dump_file(chunk.fileName, chunk.data)
                chunk.wasUpdated = false
            end
        end
        json.dump_file("MDF-XL/_Holders/MDF-XL_SubData.json", MDFXLSubData)

        for _, equipment in pairs(MDFXLData) do
            if GUI090001DecideIDX == 1 then
                if not func.table_contains(MDFXLSubData.order, MDFXLData[equipment.MeshName].MeshName) and not func.table_contains(MDFXLSubData.weaponOrder, MDFXLData[equipment.MeshName].MeshName) then
                    goto continue
                end
            end
            if GUI090001DecideIDX == 2 then
                if not func.table_contains(MDFXLSubData.otomoOrder, MDFXLData[equipment.MeshName].MeshName) and not func.table_contains(MDFXLSubData.otomoWeaponOrder, MDFXLData[equipment.MeshName].MeshName) then
                    goto continue
                end
            end

            if not func.table_contains(materialParamDefaultsHolder, MDFXLData[equipment.MeshName]) then
                materialParamDefaultsHolder[equipment.MeshName] = func.deepcopy(MDFXLData[equipment.MeshName])
                MDFXLPresetTracker[equipment.MeshName] = {}
                MDFXLPresetTracker[equipment.MeshName].lastPresetName = MDFXLData[equipment.MeshName].Presets[MDFXLData[equipment.MeshName].currentPresetIDX]
            end

            local lastPresetIndex = func.find_index(MDFXLData[equipment.MeshName].Presets, MDFXLPresetTracker[equipment.MeshName].lastPresetName)
            local selected_preset = MDFXLData[equipment.MeshName].Presets[lastPresetIndex]
            if selected_preset ~= equipment.MeshName .. " Default" and selected_preset ~= nil then
                wc = true
                local json_filepath = [[MDF-XL\\Equipment\\]] .. equipment.MeshName .. [[\\]] .. selected_preset .. [[.json]]
                local temp_parts = json.load_file(json_filepath)
                if #temp_parts.Parts ~= 0 then
                    if MDFXLSettings.isDebug then
                        log.info("[MDF-XL] [Auto Preset Loader: " .. equipment.MeshName  .. " ]")
                    end
                    
                    local partsMatch = #temp_parts.Parts == #MDFXLData[equipment.MeshName].Parts

                    if partsMatch then
                        for _, part in ipairs(temp_parts.Parts) do
                            local found = false
                            for _, ogPart in ipairs(MDFXLData[equipment.MeshName].Parts) do
                                if part == ogPart then
                                    found = true
                                    break
                                end
                            end
            
                            if not found then
                                partsMatch = false
                                break
                            end
                        end
                    end
            
                    if partsMatch then
                        temp_parts.Presets = nil
                        temp_parts.currentPresetIDX = nil

                        for key, value in pairs(temp_parts) do
                            MDFXLData[equipment.MeshName][key] = value
                        end
                        MDFXLData[equipment.MeshName].isUpdated = true
                        isUpdaterBypass = true
                        if GUI090001DecideIDX == 1 then
                            update_PlayerEquipmentMaterialParams_MHWS(MDFXLData)
                            update_PlayerArmamentMaterialParams_MHWS(MDFXLData)
                        elseif GUI090001DecideIDX == 2 then
                            update_OtomoEquipmentMaterialParams_MHWS(MDFXLData)
                            update_OtomoArmamentMaterialParams_MHWS(MDFXLData)
                        end
                    else
                        log.info("[MDF-XL] [ERROR-000] [Parts do not match, skipping the update.]")
                        MDFXLData[equipment.MeshName].currentPresetIDX = 1
                    end
                    if temp_parts.presetVersion ~= MDFXLSettings.presetVersion then
                        log.info("[MDF-XL] [WARNING-000] [" .. equipment.MeshName .. " Preset Version is outdated.]")
                    end
                end
            elseif selected_preset == nil or {} then
                MDFXLData[equipment.MeshName].currentPresetIDX = 1
            end
            ::continue::
        end
        
        for i, chunk in pairs(MDFXLSaveData) do
            if chunk.wasUpdated then
                chunk.wasUpdated = false
            end
        end
        json.dump_file("MDF-XL/_Holders/MDF-XL_PresetTracker.json", MDFXLPresetTracker)
        if GUI090001DecideIDX == 1 then
            log.info("[MDF-XL] [Player left the Equipment Menu, MDF-XL data updated.]")
        elseif GUI090001DecideIDX == 2 then
            log.info("[MDF-XL] [Player left the Palico Equipment Menu, MDF-XL data updated.]")
        end
        isPlayerLeftEquipmentMenu = false
    end
    --Appearance Menu Updater
    if isAppearanceEditorUpdater and isDefaultsDumped then
        get_PlayerEquipmentMaterialParams_MHWS(MDFXLData, MDFXLSubData)
        get_PlayerArmamentMaterialParams_MHWS(MDFXLData, MDFXLSubData)
        get_OtomoEquipmentMaterialParams_MHWS(MDFXLData, MDFXLSubData)
        get_OtomoArmamentMaterialParams_MHWS(MDFXLData, MDFXLSubData)
        dump_DefaultMaterialParamJSON_MHWS(MDFXLData)
        manage_SaveDataChunks(MDFXLData, MDFXLSaveData)
        clear_MDFXLJSONCache_MHWS(MDFXLData, MDFXLSubData)
        cache_MDFXLJSONFiles_MHWS(MDFXLData, MDFXLSubData)
        for i, chunk in pairs(MDFXLSaveData) do
            if chunk.wasUpdated then
                json.dump_file(chunk.fileName, chunk.data)
                chunk.wasUpdated = false
            end
        end
        json.dump_file("MDF-XL/_Holders/MDF-XL_SubData.json", MDFXLSubData)

        for _, equipment in pairs(MDFXLData) do
            if not func.table_contains(materialParamDefaultsHolder, MDFXLData[equipment.MeshName]) then
                materialParamDefaultsHolder[equipment.MeshName] = func.deepcopy(MDFXLData[equipment.MeshName])
                MDFXLPresetTracker[equipment.MeshName] = {}
                MDFXLPresetTracker[equipment.MeshName].lastPresetName = MDFXLData[equipment.MeshName].Presets[MDFXLData[equipment.MeshName].currentPresetIDX]
            end

            local lastPresetIndex = func.find_index(MDFXLData[equipment.MeshName].Presets, MDFXLPresetTracker[equipment.MeshName].lastPresetName)
            local selected_preset = MDFXLData[equipment.MeshName].Presets[lastPresetIndex]
            if selected_preset ~= equipment.MeshName .. " Default" and selected_preset ~= nil then
                wc = true
                local json_filepath = [[MDF-XL\\Equipment\\]] .. equipment.MeshName .. [[\\]] .. selected_preset .. [[.json]]
                local temp_parts = json.load_file(json_filepath)
                if #temp_parts.Parts ~= 0 then
                    if MDFXLSettings.isDebug then
                        log.info("[MDF-XL] [Auto Preset Loader: " .. equipment.MeshName  .. " ]")
                    end
                    
                    local partsMatch = #temp_parts.Parts == #MDFXLData[equipment.MeshName].Parts

                    if partsMatch then
                        for _, part in ipairs(temp_parts.Parts) do
                            local found = false
                            for _, ogPart in ipairs(MDFXLData[equipment.MeshName].Parts) do
                                if part == ogPart then
                                    found = true
                                    break
                                end
                            end
            
                            if not found then
                                partsMatch = false
                                break
                            end
                        end
                    end
            
                    if partsMatch then
                        temp_parts.Presets = nil
                        temp_parts.currentPresetIDX = nil

                        for key, value in pairs(temp_parts) do
                            MDFXLData[equipment.MeshName][key] = value
                        end
                        MDFXLData[equipment.MeshName].isUpdated = true
                        isUpdaterBypass = true
                        update_PlayerEquipmentMaterialParams_MHWS(MDFXLData)
                        update_PlayerArmamentMaterialParams_MHWS(MDFXLData)
                        update_OtomoEquipmentMaterialParams_MHWS(MDFXLData)
                        update_OtomoArmamentMaterialParams_MHWS(MDFXLData)
                    else
                        log.info("[MDF-XL] [ERROR-000] [Parts do not match, skipping the update.]")
                        MDFXLData[equipment.MeshName].currentPresetIDX = 1
                    end
                    if temp_parts.presetVersion ~= MDFXLSettings.presetVersion then
                        log.info("[MDF-XL] [WARNING-000] [" .. equipment.MeshName .. " Preset Version is outdated.]")
                    end
                end
            elseif selected_preset == nil or {} then
                MDFXLData[equipment.MeshName].currentPresetIDX = 1
            end
        end
        for i, chunk in pairs(MDFXLSaveData) do
            if chunk.wasUpdated then
                chunk.wasUpdated = false
            end
        end
        json.dump_file("MDF-XL/_Holders/MDF-XL_PresetTracker.json", MDFXLPresetTracker)
        log.info("[MDF-XL] [Player left the Appearance Menu, MDF-XL data updated.]")
        isAppearanceEditorUpdater = false
    end
    --Camp Menu Updater
    if isPlayerLeftCamp and isDefaultsDumped and isPlayerInScene then
        get_PorterMaterialParams_MHWS(MDFXLData, MDFXLSubData)
        manage_SaveDataChunks(MDFXLData, MDFXLSaveData)
        dump_DefaultMaterialParamJSON_MHWS(MDFXLData)
        clear_MDFXLJSONCache_MHWS(MDFXLData, MDFXLSubData)
        cache_MDFXLJSONFiles_MHWS(MDFXLData, MDFXLSubData)
        for i, chunk in pairs(MDFXLSaveData) do
            if chunk.wasUpdated then
                json.dump_file(chunk.fileName, chunk.data)
                chunk.wasUpdated = false
            end
        end
        json.dump_file("MDF-XL/_Holders/MDF-XL_SubData.json", MDFXLSubData)

        for _, equipment in pairs(MDFXLData) do
            if not func.table_contains(MDFXLSubData.porterOrder, MDFXLData[equipment.MeshName].MeshName) then
                goto continue
            end
            if not func.table_contains(materialParamDefaultsHolder, MDFXLData[equipment.MeshName]) then
                materialParamDefaultsHolder[equipment.MeshName] = func.deepcopy(MDFXLData[equipment.MeshName])
                MDFXLPresetTracker[equipment.MeshName] = {}
                MDFXLPresetTracker[equipment.MeshName].lastPresetName = MDFXLData[equipment.MeshName].Presets[MDFXLData[equipment.MeshName].currentPresetIDX]
            end

            local lastPresetIndex = func.find_index(MDFXLData[equipment.MeshName].Presets, MDFXLPresetTracker[equipment.MeshName].lastPresetName)
            local selected_preset = MDFXLData[equipment.MeshName].Presets[lastPresetIndex]
            if selected_preset ~= equipment.MeshName .. " Default" and selected_preset ~= nil then
                wc = true
                local json_filepath = [[MDF-XL\\Equipment\\]] .. equipment.MeshName .. [[\\]] .. selected_preset .. [[.json]]
                local temp_parts = json.load_file(json_filepath)
                if #temp_parts.Parts ~= 0 then
                    if MDFXLSettings.isDebug then
                        log.info("[MDF-XL] [Auto Preset Loader: " .. equipment.MeshName  .. " ]")
                    end
                    
                    local partsMatch = #temp_parts.Parts == #MDFXLData[equipment.MeshName].Parts

                    if partsMatch then
                        for _, part in ipairs(temp_parts.Parts) do
                            local found = false
                            for _, ogPart in ipairs(MDFXLData[equipment.MeshName].Parts) do
                                if part == ogPart then
                                    found = true
                                    break
                                end
                            end
            
                            if not found then
                                partsMatch = false
                                break
                            end
                        end
                    end
            
                    if partsMatch then
                        temp_parts.Presets = nil
                        temp_parts.currentPresetIDX = nil

                        for key, value in pairs(temp_parts) do
                            MDFXLData[equipment.MeshName][key] = value
                        end
                        MDFXLData[equipment.MeshName].isUpdated = true
                        isUpdaterBypass = true
                        update_PorterMaterialParams_MHWS(MDFXLData)
                    else
                        log.info("[MDF-XL] [ERROR-000] [Parts do not match, skipping the update.]")
                        MDFXLData[equipment.MeshName].currentPresetIDX = 1
                    end
                    if temp_parts.presetVersion ~= MDFXLSettings.presetVersion then
                        log.info("[MDF-XL] [WARNING-000] [" .. equipment.MeshName .. " Preset Version is outdated.]")
                    end
                end
            elseif selected_preset == nil or {} then
                MDFXLData[equipment.MeshName].currentPresetIDX = 1
            end
            :: continue ::
        end
        for i, chunk in pairs(MDFXLSaveData) do
            if chunk.wasUpdated then
                chunk.wasUpdated = false
            end
        end
        json.dump_file("MDF-XL/_Holders/MDF-XL_PresetTracker.json", MDFXLPresetTracker)
        log.info("[MDF-XL] [Player left the Camp Menu, MDF-XL data updated.]")
        isPlayerLeftCamp = false
    end
    --Outfit Preset Updater
    if isOutfitManagerBypass then
        manage_SaveDataChunks(MDFXLData, MDFXLSaveData)
        clear_MDFXLJSONCache_MHWS(MDFXLData, MDFXLSubData)
        cache_MDFXLJSONFiles_MHWS(MDFXLData, MDFXLSubData)
        
        for _, equipment in pairs(MDFXLData) do
            local lastPresetIndex = func.find_index(MDFXLData[equipment.MeshName].Presets, MDFXLPresetTracker[equipment.MeshName].lastPresetName)
            local selected_preset = MDFXLData[equipment.MeshName].Presets[lastPresetIndex]
            if selected_preset ~= equipment.MeshName .. " Default" and selected_preset ~= nil then
                wc = true
                local json_filepath = [[MDF-XL\\Equipment\\]] .. equipment.MeshName .. [[\\]] .. selected_preset .. [[.json]]
                local temp_parts = json.load_file(json_filepath)
                if #temp_parts.Parts ~= 0 then
                    if MDFXLSettings.isDebug then
                        log.info("[MDF-XL] [Auto Preset Loader: " .. equipment.MeshName  .. " ]")
                    end
                    
                    local partsMatch = #temp_parts.Parts == #MDFXLData[equipment.MeshName].Parts

                    if partsMatch then
                        for _, part in ipairs(temp_parts.Parts) do
                            local found = false
                            for _, ogPart in ipairs(MDFXLData[equipment.MeshName].Parts) do
                                if part == ogPart then
                                    found = true
                                    break
                                end
                            end
            
                            if not found then
                                partsMatch = false
                                break
                            end
                        end
                    end
            
                    if partsMatch then
                        temp_parts.Presets = nil
                        temp_parts.currentPresetIDX = nil

                        for key, value in pairs(temp_parts) do
                            MDFXLData[equipment.MeshName][key] = value
                        end
                        MDFXLData[equipment.MeshName].currentPresetIDX = lastPresetIndex
                        MDFXLData[equipment.MeshName].isUpdated = true
                        isUpdaterBypass = true
                        update_PlayerEquipmentMaterialParams_MHWS(MDFXLData)
                        update_PlayerArmamentMaterialParams_MHWS(MDFXLData)
                        update_OtomoEquipmentMaterialParams_MHWS(MDFXLData)
                        update_OtomoArmamentMaterialParams_MHWS(MDFXLData)
                        update_PorterMaterialParams_MHWS(MDFXLData)
                    else
                        log.info("[MDF-XL] [ERROR-000] [Parts do not match, skipping the update.]")
                        MDFXLData[equipment.MeshName].currentPresetIDX = 1
                    end
                    if temp_parts.presetVersion ~= MDFXLSettings.presetVersion then
                        log.info("[MDF-XL] [WARNING-000] [" .. equipment.MeshName .. " Preset Version is outdated.]")
                    end
                end
            elseif selected_preset == nil or {} then
                MDFXLData[equipment.MeshName].currentPresetIDX = 1
            end
        end
        for i, chunk in pairs(MDFXLSaveData) do
            if chunk.wasUpdated then
                json.dump_file(chunk.fileName, chunk.data)
                chunk.wasUpdated = false
            end
        end
        json.dump_file("MDF-XL/_Holders/MDF-XL_SubData.json", MDFXLSubData)
        log.info("[MDF-XL] [Outfit Preset loaded, MDF-XL data updated.]")
        isOutfitManagerBypass = false
    end
    --Sheathed Weapon Visibility Updater
    if isPlayerInScene and isDefaultsDumped then
        update_PlayerArmamentVisibility_MHWS()
    end
end
local function update_MDFXLViaHotkeys_MHWS()
    local KBM_Controls = not MDFXLSettings.useModifier or hk.check_hotkey("Modifier", true)
    local KBM_Controls2 = not MDFXLSettings.useModifier2 or hk.check_hotkey("Secondary Modifier", true)
    local KBM_OutfitChangeControls = not MDFXLSettings.useOutfitModifier or hk.check_hotkey("Outfit Change Modifier", true)
    local PAD_Controls = not MDFXLSettings.useOutfitPadModifier or hk.check_hotkey("GamePad Modifier", true)

    if (KBM_OutfitChangeControls and hk.check_hotkey("Outfit Next")) or (PAD_Controls and hk.check_hotkey("GamePad Outfit Next") and not isWeaponDrawn) then
        local outfitCount = func.countTableElements(MDFXLOutfits.Presets)
        MDFXLOutfits.currentOutfitPresetIDX = math.min(MDFXLOutfits.currentOutfitPresetIDX + 1, outfitCount)
        setup_OutfitChanger()
    end
    if (KBM_OutfitChangeControls and hk.check_hotkey("Outfit Previous")) or (PAD_Controls and hk.check_hotkey("GamePad Outfit Previous") and not isWeaponDrawn) then
        MDFXLOutfits.currentOutfitPresetIDX = math.max(MDFXLOutfits.currentOutfitPresetIDX - 1, 1)
        setup_OutfitChanger()
    end
    if (KBM_Controls and hk.check_hotkey("Toggle Back Weapons")) or (PAD_Controls and hk.check_hotkey("GamePad Toggle Back Weapons") and not isWeaponDrawn) then
        MDFXLSettings.isHideMainWeapon = not MDFXLSettings.isHideMainWeapon
        MDFXLSettings.isHideSubWeapon = not MDFXLSettings.isHideSubWeapon
        json.dump_file("MDF-XL/_Settings/MDF-XL_Settings.json", MDFXLSettings)
    end
    if KBM_Controls and hk.check_hotkey("Toggle MDF-XL Editor") and isMDFXL then
        MDFXLSettings.showMDFXLEditor = not MDFXLSettings.showMDFXLEditor
    end
    if KBM_Controls and hk.check_hotkey("Clear Outfit Search") and isMDFXL then
        outfitPresetSearchQuery = ""
    end
    if KBM_Controls2 and hk.check_hotkey("Toggle Case Sensitive Search") and isMDFXL then
        MDFXLSettings.isSearchMatchCase = not MDFXLSettings.isSearchMatchCase
    end

    if not MDFXLSettings.showMDFXLEditor then return end

    if KBM_Controls and hk.check_hotkey("Toggle Filter Favorites") then
        MDFXLSettings.isFilterFavorites = not MDFXLSettings.isFilterFavorites
    end
    
    if KBM_Controls and hk.check_hotkey("Toggle Outfit Manager") then
        MDFXLOutfits.showMDFXLOutfitEditor = not MDFXLOutfits.showMDFXLOutfitEditor
    end
    
    if KBM_Controls and hk.check_hotkey("Toggle Color Palettes") then
        MDFXLPalettes.showMDFXLPaletteEditor = not MDFXLPalettes.showMDFXLPaletteEditor
    end
end
--Imgui Functions
local function setup_MDFXLEditorGUI_MHWS(MDFXLData, MDFXLDefaultsData, MDFXLSettingsData, MDFXLSubData, order, updateFunc, color01)
    for _, entryName in pairs(MDFXLSubData[order]) do
        local entry = MDFXLData[entryName]

        if entry then
            imgui.indent(15)
            local displayName = nil
            if MDFXLSettings.showEquipmentName and MDFXLDatabase.MHWS[entry.MeshName] then
                displayName = MDFXLDatabase.MHWS[entry.MeshName].Name
                if MDFXLSettings.showEquipmentType then
                    displayName = MDFXLDatabase.MHWS[entry.MeshName].Name .. " | " .. MDFXLDatabase.MHWS[entry.MeshName].Type .. " |"
                end
            else
                displayName = entry.MeshName
            end

            if imgui.tree_node(displayName) then
                imgui.begin_rect()
                imgui.spacing()
                
                imgui.text_colored("  " .. ui.draw_line("=", MDFXLSettingsData.tertiaryDividerLen) .."  ", func.convert_rgba_to_ABGR(ui.colors.white))
                imgui.indent(10)

                if imgui.button("Reset to Defaults") then
                    wc = true
                    MDFXLData[entry.MeshName].isUpdated = true
                    MDFXLData[entry.MeshName].Enabled = MDFXLDefaultsData[entry.MeshName].Enabled
                    MDFXLData[entry.MeshName].Materials = MDFXLDefaultsData[entry.MeshName].Materials
                    clear_MDFXLJSONCache_MHWS(MDFXLData, MDFXLSubData)
                    cache_MDFXLJSONFiles_MHWS(MDFXLData, MDFXLSubData)
                    updateFunc(MDFXLData)
                    json.dump_file("MDF-XL/_Holders/MDF-XL_SubData.json", MDFXLSubData)
                end
                func.tooltip("Reset all material and mesh parameters.")

                if MDFXLSettingsData.showMeshName then
                    imgui.same_line()
                    ui.textButton_ColoredValue("Mesh Name:", entry.MeshName, func.convert_rgba_to_ABGR(ui.colors.gold))
                end

                if MDFXLSettingsData.showMaterialCount then
                    imgui.same_line()
                    ui.textButton_ColoredValue("Material Count:", #entry.Parts, func.convert_rgba_to_ABGR(ui.colors.cerulean))
                end
                if MDFXLPresetTracker[entry.MeshName].lastPresetName ~= entry.MeshName .. " Default" then
                    imgui.push_style_color(ui.ImGuiCol.Border, func.convert_rgba_to_ABGR(color01))
                    imgui.begin_rect()
                    changed, MDFXLData[entry.MeshName].currentPresetIDX = imgui.combo("Preset ", MDFXLData[entry.MeshName].currentPresetIDX or 1, MDFXLData[entry.MeshName].Presets); wc = wc or changed
                    imgui.end_rect()
                    imgui.pop_style_color(1)
                else
                    changed, MDFXLData[entry.MeshName].currentPresetIDX = imgui.combo("Preset", MDFXLData[entry.MeshName].currentPresetIDX or 1, MDFXLData[entry.MeshName].Presets); wc = wc or changed
                end
                func.tooltip("Select a file from the dropdown menu to load the variant from that file.")
                if changed then
                    local selected_preset = MDFXLData[entry.MeshName].Presets[MDFXLData[entry.MeshName].currentPresetIDX]
                    local json_filepath = [[MDF-XL\\Equipment\\]] ..entry.MeshName .. [[\\]] .. selected_preset .. [[.json]]
                    local temp_parts = json.load_file(json_filepath)

                    if temp_parts.Parts ~= nil then
                        if MDFXLSettingsData.isDebug then
                            log.info("[MDF-XL] [Preset Loader: " .. entry.MeshName .. " --- " .. #temp_parts.Parts .. " ]")
                        end
                        
                        local partsMatch = #temp_parts.Parts == #MDFXLData[entry.MeshName].Parts
    
                        if partsMatch then
                            for _, part in ipairs(temp_parts.Parts) do
                                local found = false
                                for _, ogPart in ipairs(MDFXLData[entry.MeshName].Parts) do
                                    if part == ogPart then
                                        found = true
                                        break
                                    end
                                end
                
                                if not found then
                                    partsMatch = false
                                    break
                                end
                            end
                        end
                
                        if partsMatch then
                            temp_parts.Presets = nil
                            temp_parts.currentPresetIDX = nil
    
                            for key, value in pairs(temp_parts) do
                                MDFXLData[entry.MeshName][key] = value
                            end
                        else
                            log.info("[MDF-XL] [ERROR-000] [" .. entry.MeshName .. " Parts do not match, skipping the update.]")
                            MDFXLData[entry.MeshName].currentPresetIDX = 1
                        end
                        if temp_parts.presetVersion ~= MDFXLSettingsData.presetVersion then
                            log.info("[MDF-XL] [WARNING-000] [" .. entry.MeshName .. " Preset Version is outdated.]")
                        end
                    end

                    if MDFXLSettingsData.isInheritPresetName then
                        local trimmedName = selected_preset:match("^(.-)__TAG") or selected_preset:match("^(.-)__BY") or selected_preset
                        presetName = trimmedName
                    end
                    MDFXLPresetTracker[entry.MeshName].lastPresetName = selected_preset
                    isUpdaterBypass = true
                    updateFunc(MDFXLData)
                    local chunkID = entry.MeshName:sub(1, 4)
                    if (chunkID == "ch02") or (chunkID == "ch03") then
                        chunkID = entry.MeshName:sub(1, 8)
                    end
                    json.dump_file("MDF-XL/_Holders/_Chunks/MDF-XL_EquipmentData_" .. chunkID .. ".json", MDFXLSaveDataChunks[chunkID].data)
                    json.dump_file("MDF-XL/_Holders/MDF-XL_PresetTracker.json", MDFXLPresetTracker)
                end
                
                imgui.spacing()

                imgui.push_id(_)
                changed, presetName = imgui.input_text("Name", presetName); wc = wc or changed
                imgui.pop_id()
                local tags = table.concat(MDFXLData[entry.MeshName].Tags, ", ") .. ","
                local tagCount = 0
                changed, tags = imgui.input_text("Tags", tags); wc = wc or changed
                if changed then
                    MDFXLData[entry.MeshName].Tags = {}
                    if tags == "" or tags == "," then
                        tags = "noTag"
                    end
                    for tag in tags:gmatch("[^,]+") do
                        if tagCount >= 5 then
                            break
                        end

                        tag = tag:match("^%s*(.-)%s*$")
                        if tag ~= "" then
                            table.insert(MDFXLData[entry.MeshName].Tags, tag)
                            tagCount = tagCount + 1
                        end
                    end
                end
                imgui.same_line()
                imgui.text("[ " .. #MDFXLData[entry.MeshName].Tags .. " / 5 ]")
                
                changed, MDFXLData[entry.MeshName].AuthorName = imgui.input_text("Author", MDFXLData[entry.MeshName].AuthorName); wc = wc or changed
                local finalPresetName = presetName
                if #MDFXLData[entry.MeshName].Tags > 0 then
                    finalPresetName = finalPresetName .. "__TAG-" .. table.concat(MDFXLData[entry.MeshName].Tags, "-")
                    if #MDFXLData[entry.MeshName].Tags == 1 and MDFXLData[entry.MeshName].Tags[1] == "noTag" then
                        finalPresetName = presetName
                    end
                end
                if MDFXLData[entry.MeshName].AuthorName ~= "" then
                    finalPresetName = finalPresetName .. "__BY-" .. MDFXLData[entry.MeshName].AuthorName
                end
                local presetNameLen = string.len(finalPresetName)
                
                if imgui.button("Save Preset") and presetNameLen < 200 and presetName ~= "" then
                    json.dump_file("MDF-XL/Equipment/".. entry.MeshName .. "/" .. finalPresetName .. ".json", MDFXLData[entry.MeshName])
                    log.info("[MDF-XL] [Preset with the name: " .. finalPresetName .. " saved for " ..  entry.MeshName .. ".]")
                    MDFXLData[entry.MeshName].isUpdated = true
                    clear_MDFXLJSONCache_MHWS(MDFXLData, MDFXLSubData)
                    cache_MDFXLJSONFiles_MHWS(MDFXLData, MDFXLSubData)
                    json.dump_file("MDF-XL/_Holders/MDF-XL_SubData.json", MDFXLSubData)

                    if MDFXLSettingsData.isAutoLoadPresetAfterSave then
                        local saved_preset_IDX = func.find_index(MDFXLData[entry.MeshName].Presets, finalPresetName)
                        local selected_preset = MDFXLData[entry.MeshName].Presets[saved_preset_IDX]
                        MDFXLData[entry.MeshName].currentPresetIDX = saved_preset_IDX
                        local json_filepath = [[MDF-XL\\Equipment\\]] ..entry.MeshName .. [[\\]] .. selected_preset .. [[.json]]
                        local temp_parts = json.load_file(json_filepath)
    
                        if temp_parts.Parts ~= nil then
                            if MDFXLSettingsData.isDebug then
                                log.info("[MDF-XL] [Auto Preset Loader: " .. entry.MeshName .. " --- " .. #temp_parts.Parts .. " ]")
                            end
                            
                            local partsMatch = #temp_parts.Parts == #MDFXLData[entry.MeshName].Parts
        
                            if partsMatch then
                                for _, part in ipairs(temp_parts.Parts) do
                                    local found = false
                                    for _, ogPart in ipairs(MDFXLData[entry.MeshName].Parts) do
                                        if part == ogPart then
                                            found = true
                                            break
                                        end
                                    end
                    
                                    if not found then
                                        partsMatch = false
                                        break
                                    end
                                end
                            end
                    
                            if partsMatch then
                                temp_parts.Presets = nil
                                temp_parts.currentPresetIDX = nil
        
                                for key, value in pairs(temp_parts) do
                                    MDFXLData[entry.MeshName][key] = value
                                end
                            else
                                log.info("[MDF-XL] [ERROR-000] [" .. entry.MeshName .. " Parts do not match, skipping the update.]")
                                MDFXLData[entry.MeshName].currentPresetIDX = 1
                            end
                            if temp_parts.presetVersion ~= MDFXLSettingsData.presetVersion then
                                log.info("[MDF-XL] [WARNING-000] [" .. entry.MeshName .. " Preset Version is outdated.]")
                            end
                        end
    
                        MDFXLPresetTracker[entry.MeshName].lastPresetName = selected_preset
                        isUpdaterBypass = true
                        updateFunc(MDFXLData)
                        local chunkID = entry.MeshName:sub(1, 4)
                        if (chunkID == "ch02") or (chunkID == "ch03") then
                            chunkID = entry.MeshName:sub(1, 8)
                        end
                        json.dump_file("MDF-XL/_Holders/_Chunks/MDF-XL_EquipmentData_" .. chunkID .. ".json", MDFXLSaveDataChunks[chunkID].data)
                        json.dump_file("MDF-XL/_Holders/MDF-XL_PresetTracker.json", MDFXLPresetTracker)
                    end
                end
                if presetNameLen < 200 and presetName ~= "" then
                    func.tooltip("Save the current parameters of the " ..  entry.MeshName .. " to " .. finalPresetName .. ".json found in [MonsterHunterWilds/reframework/data/MDF-XL/Equipment/"..  entry.MeshName .. "]")
                elseif presetName == "" then
                    ui.tooltip_colored(MDFXLUserManual.Errors[001], func.convert_rgba_to_ABGR(ui.colors.red))
                elseif presetNameLen > 200 then
                    ui.tooltip_colored(MDFXLUserManual.Errors[002], func.convert_rgba_to_ABGR(ui.colors.red))
                elseif presetNameLen > 200 and presetName == "" then
                    ui.tooltip_colored(MDFXLUserManual.Errors[099], func.convert_rgba_to_ABGR(ui.colors.red))
                end
                imgui.same_line()
                if MDFXLSettingsData.showFinalizedPresetName then
                    ui.textButton_ColoredValue("Finalized Preset Name: ", finalPresetName, func.convert_rgba_to_ABGR(ui.colors.cerulean))
                    imgui.same_line()
                    if presetNameLen < 200 then
                        imgui.text("[ " .. presetNameLen .. " / 200 ]")
                    else
                        imgui.text_colored("[ " .. presetNameLen .. " / 200 ]", func.convert_rgba_to_ABGR(ui.colors.red))
                    end
                end
                imgui.spacing()

                if MDFXLSettingsData.showPresetPath and #MDFXLData[entry.MeshName].Parts > 0 then
                    imgui.input_text("Preset Path", "MonsterHunterWilds/reframework/data/MDF-XL/Equipment/".. entry.MeshName .. "/")
                end

                if MDFXLSettingsData.showMeshPath then
                    imgui.push_id(MDFXLData[entry.MeshName].MeshPath)
                    imgui.input_text("Mesh Path", MDFXLData[entry.MeshName].MeshPath)
                    imgui.pop_id()
                end

                if MDFXLSettingsData.showMDFPath then
                    imgui.push_id(MDFXLData[entry.MeshName].MDFPath)
                    imgui.input_text("MDF Path", MDFXLData[entry.MeshName].MDFPath)
                    imgui.pop_id()
                end

                if imgui.tree_node("Mesh Editor") then
                    isMeshEditor = true
                    imgui.spacing()
                    imgui.text_colored(ui.draw_line("=", MDFXLSettingsData.tertiaryDividerLen - 15), func.convert_rgba_to_ABGR(ui.colors.gold))
                    imgui.indent(15)
                    if imgui.tree_node("Flags") then
                        isFlagEditor = true
                        if MDFXLData[entry.MeshName].Flags.isForceTwoSide == MDFXLDefaultsData[entry.MeshName].Flags.isForceTwoSide or MDFXLData[entry.MeshName].Flags.isForceTwoSide ~= MDFXLDefaultsData[entry.MeshName].Flags.isForceTwoSide then
                            changed, MDFXLData[entry.MeshName].Flags.isForceTwoSide = imgui.checkbox("Force Two Side", MDFXLData[entry.MeshName].Flags.isForceTwoSide); wc = wc or changed
                            if MDFXLData[entry.MeshName].Flags.isForceTwoSide ~= MDFXLDefaultsData[entry.MeshName].Flags.isForceTwoSide then
                                imgui.same_line()
                                imgui.text_colored("*", func.convert_rgba_to_ABGR(ui.colors.cerulean))
                            end
                        end
                        if MDFXLData[entry.MeshName].Flags.isBeautyMask == MDFXLDefaultsData[entry.MeshName].Flags.isBeautyMask or MDFXLData[entry.MeshName].Flags.isBeautyMask ~= MDFXLDefaultsData[entry.MeshName].Flags.isBeautyMask then
                            changed, MDFXLData[entry.MeshName].Flags.isBeautyMask = imgui.checkbox("Beauty Mask", MDFXLData[entry.MeshName].Flags.isBeautyMask); wc = wc or changed
                            if MDFXLData[entry.MeshName].Flags.isBeautyMask ~= MDFXLDefaultsData[entry.MeshName].Flags.isBeautyMask then
                                imgui.same_line()
                                imgui.text_colored("*", func.convert_rgba_to_ABGR(ui.colors.cerulean))
                            end
                        end
                        if MDFXLData[entry.MeshName].Flags.isReceiveSSSSS == MDFXLDefaultsData[entry.MeshName].Flags.isReceiveSSSSS or MDFXLData[entry.MeshName].Flags.isReceiveSSSSS ~= MDFXLDefaultsData[entry.MeshName].Flags.isReceiveSSSSS then
                            changed, MDFXLData[entry.MeshName].Flags.isReceiveSSSSS = imgui.checkbox("Receive SSSSS Flag", MDFXLData[entry.MeshName].Flags.isReceiveSSSSS); wc = wc or changed
                            if MDFXLData[entry.MeshName].Flags.isReceiveSSSSS ~= MDFXLDefaultsData[entry.MeshName].Flags.isReceiveSSSSS then
                                imgui.same_line()
                                imgui.text_colored("*", func.convert_rgba_to_ABGR(ui.colors.cerulean))
                            end
                        end
                        imgui.tree_pop()
                    else
                        isFlagEditor = false
                    end

                    imgui.text_colored(ui.draw_line("-", math.floor(MDFXLSettingsData.primaryDividerLen / 2)), func.convert_rgba_to_ABGR(ui.colors.gold))
                    
                    for i, partName in ipairs(MDFXLData[entry.MeshName].Parts) do
                        local enabledMeshPart =  MDFXLData[entry.MeshName].Enabled[i]
                        local defaultEnabledMeshPart = MDFXLDefaultsData[entry.MeshName].Enabled[i]
        
                        if enabledMeshPart == defaultEnabledMeshPart or enabledMeshPart ~= defaultEnabledMeshPart then
                            changed, enabledMeshPart = imgui.checkbox(partName, enabledMeshPart); wc = wc or changed
                            MDFXLData[entry.MeshName].Enabled[i] = enabledMeshPart
                            if enabledMeshPart ~= defaultEnabledMeshPart then
                                imgui.same_line()
                                imgui.text_colored("*", func.convert_rgba_to_ABGR(ui.colors.cerulean))
                            end
                        end
                    end
                    imgui.indent(-15)
                    imgui.text_colored(ui.draw_line("=", MDFXLSettingsData.tertiaryDividerLen - 15), func.convert_rgba_to_ABGR(ui.colors.gold))
                    imgui.tree_pop()
                else
                    isMeshEditor = false
                end
                
                if imgui.tree_node("Material Editor") then
                    imgui.spacing()
                    imgui.text_colored(ui.draw_line("=", MDFXLSettingsData.tertiaryDividerLen - 15), func.convert_rgba_to_ABGR(ui.colors.cerulean))
                    changed, searchQuery = imgui.input_text("Param Search", searchQuery); wc = wc or changed
                    ui.button_CheckboxStyle("[ Aa ]", MDFXLSettings, "isSearchMatchCase", func.convert_rgba_to_ABGR(ui.colors.REFgray), func.convert_rgba_to_ABGR(ui.colors.gold), func.convert_rgba_to_ABGR(ui.colors.gold))
                    func.tooltip("Match Case")
                    imgui.same_line()
                    if imgui.button("Clear Search") then
                        searchQuery = ""
                    end
                    imgui.same_line()
                    if imgui.checkbox("Filter: Favorites", MDFXLSettingsData.isFilterFavorites) then
                        MDFXLSettingsData.isFilterFavorites = not MDFXLSettingsData.isFilterFavorites
                    end
                    if MDFXLSettingsData.showMaterialFavoritesCount then
                        imgui.same_line()
                        local favCount = #MDFXLSubData.matParamFavorites
                        ui.textButton_ColoredValue("", favCount .. " ", func.convert_rgba_to_ABGR(ui.colors.gold))
                    end
                    imgui.same_line()
                    if imgui.button("Clear Favorites") then
                        MDFXLSubData.matParamFavorites = {}
                        json.dump_file("MDF-XL/_Holders/MDF-XL_SubData.json", MDFXLSubData)
                    end
                    imgui.indent(5)

                    for matName, matData in func.orderedPairs(MDFXLData[entry.MeshName].Materials) do
                        imgui.spacing()
                        for i, partName in ipairs(MDFXLData[entry.MeshName].Parts) do
                            if partName == matName then
                                local meshPart = MDFXLData[entry.MeshName].Enabled[i]
                                if not meshPart then
                                    imgui.push_style_color(ui.ImGuiCol.Text, func.convert_rgba_to_ABGR(ui.colors.white50))
                                else
                                    imgui.push_style_color(ui.ImGuiCol.Text, func.convert_rgba_to_ABGR(ui.colors.white))
                                end
                            end
                        end
                        if imgui.tree_node(matName) then
                            imgui.push_id(matName)
                            imgui.pop_style_color(1)
                            imgui.spacing()
                            if imgui.begin_popup_context_item() then
                                if imgui.menu_item("Reset") then
                                    for paramName, _ in pairs(matData) do
                                        MDFXLData[entry.MeshName].Materials[matName][paramName][1] = MDFXLDefaultsData[entry.MeshName].Materials[matName][paramName][1]
                                        wc = true
                                    end
                                    changed = true
                                end
                                if imgui.menu_item("Copy") then
                                    materialEditorParamHolder = func.deepcopy(MDFXLData[entry.MeshName].Materials[matName])
                                    wc = true
                                end
                                if imgui.menu_item("Paste") then
                                    local copiedParams = materialEditorParamHolder
                                    local targetParams = MDFXLData[entry.MeshName].Materials[matName]
                                    
                                    for paramName, paramValue in pairs(copiedParams) do
                                        if targetParams[paramName] ~= nil then
                                            targetParams[paramName] = func.deepcopy(paramValue)
                                            wc = true
                                        end
                                    end
                                end
                                
                                imgui.end_popup()
                            end
                            if MDFXLSettingsData.showMaterialParamCount then
                                ui.textButton_ColoredValue("Parameter Count:", entry.MaterialParamCount[matName], func.convert_rgba_to_ABGR(ui.colors.cerulean))
                            end
                            if MDFXLSettingsData.showTextureCount then
                                imgui.same_line()
                                ui.textButton_ColoredValue("Texture Count:", entry.TextureCount[matName], func.convert_rgba_to_ABGR(ui.colors.cerulean))
                            end
                            
                            if entry.TextureCount[matName] ~= 0 then
                                if imgui.tree_node("Textures") then
                                    isTextureEditor = true
                                    imgui.text_colored(ui.draw_line("=", MDFXLSettingsData.tertiaryDividerLen - 15), func.convert_rgba_to_ABGR(ui.colors.cerulean))

                                    changed, textureSearchQuery = imgui.input_text("Texture Search", textureSearchQuery); wc = wc or changed
                                    ui.button_CheckboxStyle("[ Aa ]", MDFXLSettings, "isSearchMatchCase", func.convert_rgba_to_ABGR(ui.colors.REFgray), func.convert_rgba_to_ABGR(ui.colors.gold), func.convert_rgba_to_ABGR(ui.colors.gold))
                                    func.tooltip("Match Case")
                                    imgui.same_line()
                                    if imgui.button("Clear Search") then
                                        textureSearchQuery = ""
                                    end
                                    imgui.same_line()
                                    imgui.text("Filters:")
                                    imgui.same_line()
                                    if imgui.button("[ ART ]") then
                                        textureSearchQuery = "Art/"
                                    end
                                    imgui.same_line()
                                    if imgui.button("[ MMTR ]") then
                                        textureSearchQuery = "MasterMaterial/"
                                    end
                                    imgui.same_line()
                                    if imgui.button("[ RELib ]") then
                                        textureSearchQuery = "RE_ENGINE_LIBRARY/"
                                    end
                                    imgui.same_line()
                                    if imgui.button("[ SYS ]") then
                                        textureSearchQuery = "systems/"
                                    end

                                    imgui.spacing()
                                    for texName, texData in func.orderedPairs(MDFXLData[entry.MeshName].Textures[matName]) do
                                        local originalData = MDFXLDefaultsData[entry.MeshName].Textures[matName][texName]
                                        local currentData = MDFXLData[entry.MeshName].Textures[matName][texName]
                                        local filteredTextures = {}
                                        local filteredIDX = nil

                                        for _, texture in ipairs(MDFXLSubData.texturePaths) do
                                            if textureSearchQuery == "" or (MDFXLSettings.isSearchMatchCase and texture:find(textureSearchQuery, 1, true)) or (not MDFXLSettings.isSearchMatchCase and texture:lower():find(textureSearchQuery:lower(), 1, true)) then
                                                table.insert(filteredTextures, texture)
                                            end
                                        end

                                        for i, texture in ipairs(filteredTextures) do
                                            if texture == MDFXLData[entry.MeshName].Textures[matName][texName] then
                                                filteredIDX = i
                                                break
                                            end
                                        end
                                        filteredIDX = filteredIDX or 1

                                        if currentData == originalData or currentData ~= originalData then
                                            imgui.begin_rect()
                                            if currentData ~= originalData then
                                                imgui.indent(35)
                                            end
                                            if imgui.button("[ " .. texName .. " ]") then
                                                MDFXLData[entry.MeshName].Textures[matName][texName] = MDFXLDefaultsData[entry.MeshName].Textures[matName][texName]
                                                wc = true
                                            end
                                            if imgui.begin_popup_context_item() then
                                                if imgui.menu_item("Reset") then
                                                    MDFXLData[entry.MeshName].Textures[matName][texName] = MDFXLDefaultsData[entry.MeshName].Textures[matName][texName]
                                                    wc = true
                                                end
                                                if imgui.menu_item("Copy") then
                                                textureEditorStringHolder = MDFXLData[entry.MeshName].Textures[matName][texName]
                                                    wc = true
                                                end
                                                if textureEditorStringHolder ~= nil then
                                                    if imgui.menu_item("Paste") then
                                                        MDFXLData[entry.MeshName].Textures[matName][texName] = textureEditorStringHolder
                                                        wc = true
                                                    end
                                                end
                                                imgui.end_popup()
                                            end
                                            if currentData ~= originalData then
                                                imgui.same_line()
                                                imgui.text_colored("*", func.convert_rgba_to_ABGR(ui.colors.cerulean))
                                                imgui.push_style_color(ui.ImGuiCol.Text, func.convert_rgba_to_ABGR(ui.colors.cerulean))
                                            end
                                            imgui.push_id(texName)
                                            
                                            changed, filteredIDX = imgui.combo("", filteredIDX, filteredTextures); wc = wc or changed
                                            if changed then
                                                local selectedTexture = filteredTextures[filteredIDX]
                                                local realIDX = func.find_index(MDFXLSubData.texturePaths, selectedTexture)
                                                
                                                if realIDX then
                                                    MDFXLData[entry.MeshName].Textures[matName][texName] = MDFXLSubData.texturePaths[realIDX]
                                                end
                                                wc = true
                                            end
                                            if currentData ~= originalData then
                                                imgui.indent(-35)
                                            end
                                            imgui.pop_id()
                                            imgui.pop_style_color()
                                            imgui.end_rect()
                                            imgui.spacing()
                                        end
                                    end
                                    imgui.text_colored(ui.draw_line("=", MDFXLSettingsData.tertiaryDividerLen - 15), func.convert_rgba_to_ABGR(ui.colors.cerulean))
                                    imgui.tree_pop()
                                else
                                    isTextureEditor = false
                                end
                                imgui.text_colored(ui.draw_line("-", math.floor(MDFXLSettingsData.primaryDividerLen / 2)), func.convert_rgba_to_ABGR(ui.colors.cerulean))
                            end

                            for paramName, paramValue in func.orderedPairs(matData) do
                                local originalData = MDFXLDefaultsData[entry.MeshName].Materials[matName][paramName]
                                local match
                                if searchQuery == "" and not MDFXLSettingsData.isFilterFavorites then
                                    imgui.spacing()
                                end
                                
                                if MDFXLSettingsData.isSearchMatchCase then
                                    match = string.find(paramName, searchQuery, 1, true)
                                else
                                    match = string.find(paramName:lower(), searchQuery:lower(), 1, true)
                                end
                                
                                if (not MDFXLSettingsData.isFilterFavorites or func.table_contains(MDFXLSubData.matParamFavorites, paramName)) and match then
                                    if func.table_contains(MDFXLSubData.matParamFavorites, paramName) then
                                        imgui.push_style_color(ui.ImGuiCol.Border, func.convert_rgba_to_ABGR(ui.colors.gold))
                                    end
                                    imgui.begin_rect()
                                    if func.compareTables(paramValue, originalData) then
                                        if imgui.button("[ " .. tostring(paramName) .. " ]") then
                                            paramValue[1] = MDFXLDefaultsData[entry.MeshName].Materials[matName][paramName][1]
                                            wc = true
                                        end
                                        if imgui.is_item_hovered() then
                                            lastMatParamName = paramName
                                        end
                                        if imgui.begin_popup_context_item() then
                                            if imgui.menu_item("Reset") then
                                                paramValue[1] = MDFXLDefaultsData[entry.MeshName].Materials[matName][paramName][1]
                                                wc = true
                                            end
                                            if imgui.menu_item("Copy") then
                                                if type(paramValue[1]) == "table" then
                                                    materialEditorSubParamFloat4Holder = paramValue[1]
                                                    materialEditorSubParamFloatHolder = nil
                                                else
                                                    materialEditorSubParamFloat4Holder = nil
                                                    materialEditorSubParamFloatHolder = paramValue[1]
                                                end
                                                wc = true
                                            end
                                            if imgui.menu_item("Paste") then
                                                wc = true
                                                if type(paramValue[1]) == "table" then
                                                    if materialEditorSubParamFloat4Holder ~= nil then
                                                        paramValue[1] = materialEditorSubParamFloat4Holder
                                                    end
                                                else
                                                    if materialEditorSubParamFloatHolder ~= nil then
                                                        paramValue[1] = materialEditorSubParamFloatHolder
                                                    end
                                                end
                                            end
                                            if not func.table_contains(MDFXLSubData.matParamFavorites, paramName) then
                                                if imgui.menu_item("Add to Favorites") then
                                                    wc = true
                                                    table.insert(MDFXLSubData.matParamFavorites, paramName)
                                                    json.dump_file("MDF-XL/_Holders/MDF-XL_SubData.json", MDFXLSubData)
                                                end
                                            else
                                                if imgui.menu_item("Remove from Favorites") then
                                                    local faveIDX = func.find_index(MDFXLSubData.matParamFavorites, paramName)
                                                    if faveIDX then
                                                        wc = true
                                                        table.remove(MDFXLSubData.matParamFavorites, faveIDX)
                                                        json.dump_file("MDF-XL/_Holders/MDF-XL_SubData.json", MDFXLSubData)
                                                    end
                                                end
                                            end
                                            imgui.end_popup()
                                        end
                                        if func.table_contains(MDFXLSubData.matParamFavorites, paramName) then
                                            imgui.same_line()
                                            imgui.text_colored("*", func.convert_rgba_to_ABGR(ui.colors.gold))
                                        end
                                    elseif not func.compareTables(paramValue, originalData) then
                                        imgui.indent(35)
                                        if imgui.button("[ " .. tostring(paramName) .. " ]") then
                                            paramValue[1] = MDFXLDefaultsData[entry.MeshName].Materials[matName][paramName][1]
                                            wc = true
                                        end
                                        if imgui.is_item_hovered() then
                                            lastMatParamName = paramName
                                        end
                                        if imgui.begin_popup_context_item() then
                                            if imgui.menu_item("Reset") then
                                                paramValue[1] = MDFXLDefaultsData[entry.MeshName].Materials[matName][paramName][1]
                                                wc = true
                                            end
                                            if imgui.menu_item("Copy") then
                                                if type(paramValue[1]) == "table" then
                                                    materialEditorSubParamFloat4Holder = paramValue[1]
                                                    materialEditorSubParamFloatHolder = nil
                                                else
                                                    materialEditorSubParamFloat4Holder = nil
                                                    materialEditorSubParamFloatHolder = paramValue[1]
                                                end
                                                wc = true
                                            end
                                            if imgui.menu_item("Paste") then
                                                wc = true
                                                if type(paramValue[1]) == "table" then
                                                    if materialEditorSubParamFloat4Holder ~= nil then
                                                        paramValue[1] = materialEditorSubParamFloat4Holder
                                                    end
                                                else
                                                    if materialEditorSubParamFloatHolder ~= nil then
                                                        paramValue[1] = materialEditorSubParamFloatHolder
                                                    end
                                                end
                                            end
                                            if not func.table_contains(MDFXLSubData.matParamFavorites, paramName) then
                                                if imgui.menu_item("Add to Favorites") then
                                                    wc = true
                                                    table.insert(MDFXLSubData.matParamFavorites, paramName)
                                                    json.dump_file("MDF-XL/_Holders/MDF-XL_SubData.json", MDFXLSubData)
                                                end
                                            else
                                                if imgui.menu_item("Remove from Favorites") then
                                                    local faveIDX = func.find_index(MDFXLSubData.matParamFavorites, paramName)
                                                    if faveIDX then
                                                        wc = true
                                                        table.remove(MDFXLSubData.matParamFavorites, faveIDX)
                                                        json.dump_file("MDF-XL/_Holders/MDF-XL_SubData.json", MDFXLSubData)
                                                    end
                                                end
                                            end
                                            imgui.end_popup()
                                        end
                                        if func.table_contains(MDFXLSubData.matParamFavorites, paramName) then
                                            imgui.same_line()
                                            imgui.text_colored("*", func.convert_rgba_to_ABGR(ui.colors.gold))
                                        end
                                        imgui.same_line()
                                        imgui.text_colored("*", func.convert_rgba_to_ABGR(ui.colors.cerulean))
                                    end

                                    if type(paramValue) == "table" then
                                        if type(paramValue[1]) == "table" then
                                            for i, value in ipairs(paramValue) do
                                                imgui.push_id(tostring(paramName))
                                                local newcolor = Vector4f.new(value[1], value[2], value[3], value[4])
                                                changed, newcolor = imgui.color_edit4("", newcolor, nil); wc = wc or changed
                                                if imgui.is_item_hovered() then
                                                    lastMatParamName = paramName
                                                end
                                                paramValue[i] = {newcolor.x, newcolor.y, newcolor.z, newcolor.w}
                                                imgui.pop_id()
                                            end
                                        else
                                            imgui.push_id(tostring(paramName))
                                            changed, paramValue[1] = imgui.drag_float("", paramValue[1], 0.001, 0.0, 100.0); wc = wc or changed
                                            if imgui.is_item_hovered() then
                                                lastMatParamName = paramName
                                            end
                                            imgui.pop_id()
                                        end
                                    end
                                    imgui.end_rect()
                                    imgui.pop_style_color()
                                end
                            end
                            imgui.pop_id()
                            imgui.spacing()
                            imgui.tree_pop()
                        end
                        imgui.pop_style_color(1)
                    end
                    
                    imgui.indent(-5)
                    imgui.text_colored(ui.draw_line("=", MDFXLSettingsData.tertiaryDividerLen - 15), func.convert_rgba_to_ABGR(ui.colors.cerulean))
                    imgui.tree_pop()
                end

                if changed or wc then
                    MDFXLData[entry.MeshName].isUpdated = true
                end
                imgui.indent(-10)
                imgui.text_colored("  " .. ui.draw_line("=", MDFXLSettingsData.tertiaryDividerLen) .."  ", func.convert_rgba_to_ABGR(ui.colors.white))
                imgui.end_rect(); imgui.tree_pop()
            end
            imgui.text_colored("  " .. ui.draw_line("-", MDFXLSettingsData.primaryDividerLen) .."  ", func.convert_rgba_to_ABGR(color01))
            imgui.indent(-15)
        end
    end
end
local function setup_MDFXLPresetGUI_MHWS(MDFXLData, MDFXLSettingsData, MDFXLSubData, order, updateFunc, displayText, color01, isDraw)
    if not isDraw then return end

    imgui.text_colored(ui.draw_line("=", MDFXLSettingsData.presetManager.secondaryDividerLen) ..  " // " .. displayText .. " // ", func.convert_rgba_to_ABGR(color01))
    imgui.indent(10)
    if order == "weaponOrder" then
        changed, MDFXLSettingsData.isHideMainWeapon = imgui.checkbox("Hide Main Weapon", MDFXLSettingsData.isHideMainWeapon); wc = wc or changed
        ui.tooltip("Hides the currently equipped main weapon when sheathed.")
        imgui.same_line()
        changed, MDFXLSettingsData.isHideSubWeapon = imgui.checkbox("Hide Sub Weapon", MDFXLSettingsData.isHideSubWeapon); wc = wc or changed
        ui.tooltip("Hides the currently equipped sub weapon when sheathed.")
    end
    for _, entryName in pairs(MDFXLSubData[order]) do
        local entry = MDFXLData[entryName]
        local displayName = nil
        local filteredPresets = {}
        local presetIndexMap = {}
        local activeAuthors = {}
        local activeTags = {}
        if isAdvancedSearch then
            for authorKey, isActive in pairs(MDFXLTags._AuthorSearchList) do
                if isActive then
                    local authorName = authorKey:match("isSearchFor(.+)")
                    if authorName then
                        activeAuthors[authorName] = true
                    end
                end
            end
            for tagKey, isActive in pairs(MDFXLTags._TagSearchList) do
                if isActive then
                    local tagName = tagKey:match("isSearchFor(.+)")
                    if tagName then
                        activeTags[tagName] = true
                    end
                end
            end
        end

        if MDFXLSettings.presetManager.showEquipmentName and MDFXLDatabase.MHWS[entry.MeshName] then
            displayName = MDFXLDatabase.MHWS[entry.MeshName].Name
            if MDFXLSettings.presetManager.showEquipmentType then
                displayName = MDFXLDatabase.MHWS[entry.MeshName].Name .. " | " .. MDFXLDatabase.MHWS[entry.MeshName].Type .. " |"
            end
        else
            displayName = entry.MeshName
        end
        
        if entry then
            imgui.spacing()
            local currentFilteredIDX = nil
            local displayPresets = {}
            local advancedFilteredPresets = {}
            local advancedPresetIndexMap = {}
            local authorCount = func.get_table_size(activeAuthors)
            local tagCount = func.get_table_size(activeTags)

            if isAdvancedSearch then
                if func.table_contains(MDFXLTags, MDFXLData[entry.MeshName].MeshName, true) then
                    for i, preset in pairs(MDFXLData[entry.MeshName].Presets) do
                        if func.table_contains(MDFXLTags[MDFXLData[entry.MeshName].MeshName], preset, true) then
                            if tagCount == 0 and authorCount > 0 and func.table_contains(activeAuthors, MDFXLTags[MDFXLData[entry.MeshName].MeshName][preset].author, true) then
                                table.insert(advancedFilteredPresets, preset)
                                advancedPresetIndexMap[#advancedFilteredPresets] = i
                            elseif tagCount > 0 and authorCount > 0 and func.table_contains(activeAuthors, MDFXLTags[MDFXLData[entry.MeshName].MeshName][preset].author, true) then
                                for tag in pairs(activeTags) do
                                    if func.table_contains(MDFXLTags[MDFXLData[entry.MeshName].MeshName][preset].tags, tag) then
                                        if not func.table_contains(advancedFilteredPresets, preset) then
                                            table.insert(advancedFilteredPresets, preset)
                                            advancedPresetIndexMap[#advancedFilteredPresets] = i
                                        end
                                    end
                                end
                            elseif tagCount > 0 and authorCount == 0 then
                                for tag in pairs(activeTags) do
                                    if func.table_contains(MDFXLTags[MDFXLData[entry.MeshName].MeshName][preset].tags, tag) then
                                        if not func.table_contains(advancedFilteredPresets, preset) then
                                            table.insert(advancedFilteredPresets, preset)
                                            advancedPresetIndexMap[#advancedFilteredPresets] = i
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
            
            local searchSource = #advancedFilteredPresets > 0 and advancedFilteredPresets or MDFXLData[entry.MeshName].Presets
            if authorCount > 0 and tagCount > 0 and #advancedFilteredPresets == 0 or authorCount == 0 and tagCount > 0 and #advancedFilteredPresets == 0 or authorCount > 0 and tagCount == 0 and #advancedFilteredPresets == 0 then
                searchSource = {}
            end
            local indexMapSource = #advancedFilteredPresets > 0 and advancedPresetIndexMap or nil

            if presetSearchQuery ~= "" then
                for i, preset in ipairs(searchSource) do
                    if (MDFXLSettings.isSearchMatchCase and preset:find(presetSearchQuery, 1, true)) or (not MDFXLSettings.isSearchMatchCase and preset:lower():find(presetSearchQuery:lower(), 1, true)) then
                        table.insert(filteredPresets, preset)
                        presetIndexMap[#filteredPresets] = indexMapSource and indexMapSource[i] or i
                    end
                end
            else
                filteredPresets = searchSource
                for i, _ in ipairs(filteredPresets) do
                    presetIndexMap[i] = indexMapSource and indexMapSource[i] or i
                end
            end
            
            if MDFXLSettings.presetManager.isTrimPresetNames then
                local nameCounts = {}
                for i, presetName in ipairs(filteredPresets) do
                    local trimmedName = presetName:match("^(.-)__TAG") or presetName:match("^(.-)__BY") or presetName
            
                    if nameCounts[trimmedName] then
                        nameCounts[trimmedName] = nameCounts[trimmedName] + 1
                        trimmedName = trimmedName .. " (" .. nameCounts[trimmedName] .. ")"
                    else
                        nameCounts[trimmedName] = 1
                    end
            
                    table.insert(displayPresets, trimmedName)
                end
            else
                displayPresets = filteredPresets
            end

            for filteredIdx, originalIdx in pairs(presetIndexMap) do
                if MDFXLData[entry.MeshName].currentPresetIDX == originalIdx then
                    currentFilteredIDX = filteredIdx
                    break
                end
            end
            imgui.push_item_width(MDFXLSettingsData.presetManager.menuWidth)
            if MDFXLPresetTracker[entry.MeshName].lastPresetName ~= entry.MeshName .. " Default" then
                imgui.push_style_color(ui.ImGuiCol.Border, func.convert_rgba_to_ABGR(color01))
                imgui.begin_rect()
                changed, currentFilteredIDX = imgui.combo(displayName .. " ", currentFilteredIDX or 1, displayPresets);wc = wc or changed
                imgui.end_rect()
                imgui.pop_style_color(1)
            else
                changed, currentFilteredIDX = imgui.combo(displayName .. " ", currentFilteredIDX or 1, displayPresets); wc = wc or changed
            end
            imgui.pop_item_width()
            if changed then
                MDFXLData[entry.MeshName].currentPresetIDX = presetIndexMap[currentFilteredIDX]
                
                local selected_preset = MDFXLData[entry.MeshName].Presets[MDFXLData[entry.MeshName].currentPresetIDX]
                local json_filepath = [[MDF-XL\\Equipment\\]] ..entry.MeshName .. [[\\]] .. selected_preset .. [[.json]]
                local temp_parts = json.load_file(json_filepath)
                
                if temp_parts.Parts ~= nil then
                    if MDFXLSettingsData.isDebug then
                        log.info("[MDF-XL] [Preset Loader: " .. entry.MeshName .. " --- " .. #temp_parts.Parts .. " ]")
                    end
                    
                    local partsMatch = #temp_parts.Parts == #MDFXLData[entry.MeshName].Parts

                    if partsMatch then
                        for _, part in ipairs(temp_parts.Parts) do
                            local found = false
                            for _, ogPart in ipairs(MDFXLData[entry.MeshName].Parts) do
                                if part == ogPart then
                                    found = true
                                    break
                                end
                            end
            
                            if not found then
                                partsMatch = false
                                break
                            end
                        end
                    end
            
                    if partsMatch then
                        temp_parts.Presets = nil
                        temp_parts.currentPresetIDX = nil

                        for key, value in pairs(temp_parts) do
                            MDFXLData[entry.MeshName][key] = value
                        end
                    else
                        log.info("[MDF-XL] [ERROR-000] [" .. entry.MeshName .. " Parts do not match, skipping the update.]")
                        MDFXLData[entry.MeshName].currentPresetIDX = 1
                    end
                    if temp_parts.presetVersion ~= MDFXLSettingsData.presetVersion then
                        log.info("[MDF-XL] [WARNING-000] [" .. entry.MeshName .. " Preset Version is outdated.]")
                    end
                end

                if MDFXLSettingsData.isInheritPresetName then
                    local trimmedName = selected_preset:match("^(.-)__TAG") or selected_preset:match("^(.-)__BY") or selected_preset
                    presetName = trimmedName
                end
                if changed or wc then
                    MDFXLData[entry.MeshName].isUpdated = true
                end
                MDFXLPresetTracker[entry.MeshName].lastPresetName = selected_preset
                isUpdaterBypass = true
                updateFunc(MDFXLData)
                local chunkID = entry.MeshName:sub(1, 4)
                if (chunkID == "ch02") or (chunkID == "ch03") then
                    chunkID = entry.MeshName:sub(1, 8)
                end
                json.dump_file("MDF-XL/_Holders/_Chunks/MDF-XL_EquipmentData_" .. chunkID .. ".json", MDFXLSaveDataChunks[chunkID].data)
                json.dump_file("MDF-XL/_Holders/MDF-XL_PresetTracker.json", MDFXLPresetTracker)
            end
        end
    end
    imgui.indent(-10)
end
local function draw_MDFXLOutfitManagerGUI_MHWS()
    if imgui.begin_window("MDF-XL: Outfit Manager") then
        imgui.begin_rect()
        imgui.text_colored("  [ " .. ui.draw_line("=", math.floor(MDFXLSettings.presetManager.primaryDividerLen * 0.75))  .. " ] ", func.convert_rgba_to_ABGR(ui.colors.white))
        imgui.spacing()
        imgui.indent(25)
        imgui.push_item_width(MDFXLSettings.presetManager.menuWidth)
        changed, MDFXLOutfits.currentOutfitPresetIDX = imgui.combo("Outfit Preset", MDFXLOutfits.currentOutfitPresetIDX or 1, MDFXLOutfits.Presets); wc = wc or changed
        if changed then
            local selected_preset = MDFXLOutfits.Presets[MDFXLOutfits.currentOutfitPresetIDX]
            local json_filepath = [[MDF-XL\\Outfits\\]] .. selected_preset .. [[.json]]
            local temp_parts = json.load_file(json_filepath)
            wc = true
            if temp_parts ~= nil then
                for key, value in pairs(temp_parts) do
                    MDFXLPresetTracker[key].lastPresetName = value.lastPresetName
                end
                isOutfitManagerBypass = true
                json.dump_file("MDF-XL/_Holders/MDF-XL_PresetTracker.json", MDFXLPresetTracker)
            end
        end
        changed, outfitName = imgui.input_text("", outfitName); wc = wc or changed
        imgui.pop_item_width()
        imgui.same_line()
        if imgui.button("Save Outfit Preset") then
            local MDFXLOutfitData = {}
            for i, equipment in pairs(MDFXL) do
                if MDFXLPresetTracker[equipment.MeshName].lastPresetName ~= equipment.MeshName .. " Default" then
                    MDFXLOutfitData[equipment.MeshName] = {}
                    if MDFXLOutfits.isHunterEquipment then
                        if func.table_contains(MDFXLSub.order, equipment.MeshName) then
                            MDFXLOutfitData[equipment.MeshName].lastPresetName = ""
                            MDFXLOutfitData[equipment.MeshName].lastPresetName = MDFXLPresetTracker[equipment.MeshName].lastPresetName
                        end
                    end
                    if MDFXLOutfits.isHunterArmament then
                        if func.table_contains(MDFXLSub.weaponOrder, equipment.MeshName) then
                            MDFXLOutfitData[equipment.MeshName].lastPresetName = ""
                            MDFXLOutfitData[equipment.MeshName].lastPresetName = MDFXLPresetTracker[equipment.MeshName].lastPresetName
                        end
                    end
                    if MDFXLOutfits.isOtomoEquipment then
                        if func.table_contains(MDFXLSub.otomoOrder, equipment.MeshName) then
                            MDFXLOutfitData[equipment.MeshName].lastPresetName = ""
                            MDFXLOutfitData[equipment.MeshName].lastPresetName = MDFXLPresetTracker[equipment.MeshName].lastPresetName
                        end
                    end
                    if MDFXLOutfits.isOtomoArmament then
                        if func.table_contains(MDFXLSub.otomoWeaponOrder, equipment.MeshName) then
                            MDFXLOutfitData[equipment.MeshName].lastPresetName = ""
                            MDFXLOutfitData[equipment.MeshName].lastPresetName = MDFXLPresetTracker[equipment.MeshName].lastPresetName
                        end
                    end
                    if MDFXLOutfits.isPorter then
                        if func.table_contains(MDFXLSub.porterOrder, equipment.MeshName) then
                            MDFXLOutfitData[equipment.MeshName].lastPresetName = ""
                            MDFXLOutfitData[equipment.MeshName].lastPresetName = MDFXLPresetTracker[equipment.MeshName].lastPresetName
                        end
                    end
                end
            end
            json.dump_file("MDF-XL/Outfits/" .. outfitName .. ".json", MDFXLOutfitData)
            cache_MDFXLJSONFiles_MHWS(MDFXL, MDFXLSub)
        end

        imgui.spacing()
        changed, MDFXLOutfits.isHunterEquipment = imgui.checkbox("Include Hunter: Armor", MDFXLOutfits.isHunterEquipment); wc = wc or changed
        changed, MDFXLOutfits.isHunterArmament = imgui.checkbox("Include Hunter: Weapon", MDFXLOutfits.isHunterArmament); wc = wc or changed
        changed, MDFXLOutfits.isOtomoEquipment = imgui.checkbox("Include Palico: Armor", MDFXLOutfits.isOtomoEquipment); wc = wc or changed
        changed, MDFXLOutfits.isOtomoArmament = imgui.checkbox("Include Palico: Weapon", MDFXLOutfits.isOtomoArmament); wc = wc or changed
        changed, MDFXLOutfits.isPorter = imgui.checkbox("Include Seikret", MDFXLOutfits.isPorter); wc = wc or changed

        setup_MDFXLPresetGUI_MHWS(MDFXL, MDFXLSettings, MDFXLSub, "order", update_PlayerEquipmentMaterialParams_MHWS, "Hunter: Armor", ui.colors.gold, MDFXLOutfits.isHunterEquipment)
        setup_MDFXLPresetGUI_MHWS(MDFXL, MDFXLSettings, MDFXLSub, "weaponOrder", update_PlayerArmamentMaterialParams_MHWS, "Hunter: Weapon", ui.colors.orange, MDFXLOutfits.isHunterArmament)
        setup_MDFXLPresetGUI_MHWS(MDFXL, MDFXLSettings, MDFXLSub, "otomoOrder", update_OtomoEquipmentMaterialParams_MHWS, "Palico: Armor", ui.colors.cyan, MDFXLOutfits.isOtomoEquipment)
        setup_MDFXLPresetGUI_MHWS(MDFXL, MDFXLSettings, MDFXLSub, "otomoWeaponOrder", update_OtomoArmamentMaterialParams_MHWS, "Palico: Weapon", ui.colors.cerulean, MDFXLOutfits.isOtomoArmament)
        setup_MDFXLPresetGUI_MHWS(MDFXL, MDFXLSettings, MDFXLSub, "porterOrder", update_PorterMaterialParams_MHWS, "Seikret", ui.colors.lime, MDFXLOutfits.isPorter)
    
        imgui.indent(-25)
        imgui.text_colored("  [ " .. ui.draw_line("=", math.floor(MDFXLSettings.presetManager.primaryDividerLen * 0.75))  .. " ] ", func.convert_rgba_to_ABGR(ui.colors.white))
        imgui.end_rect(1)
        imgui.end_window()
    end
end
local function draw_MDFXLPaletteGUI_MHWS()
    if imgui.begin_window("MDF-XL: Color Palette Editor") then
        imgui.begin_rect()
        imgui.text_colored("  [ " .. ui.draw_line("=", 60)  .. " ] ", func.convert_rgba_to_ABGR(ui.colors.white))
        imgui.spacing()
        imgui.indent(25)

        changed, MDFXLPalettes.currentPresetIDX = imgui.combo("Color Palettes", MDFXLPalettes.currentPresetIDX or 1, MDFXLPalettes.Presets); wc = wc or changed
        func.tooltip("Select a file from the dropdown menu to load the color palette from that file.")
        if changed then
            local selected_preset = MDFXLPalettes.Presets[MDFXLPalettes.currentPresetIDX]
            local json_filepath = [[MDF-XL\\ColorPalettes\\]] .. selected_preset .. [[.json]]
            local temp_parts = json.load_file(json_filepath)
            if temp_parts ~= nil then
                MDFXLPalettes.colors = {}
                for key, value in pairs(temp_parts) do
                    MDFXLPalettes.colors[key] = value
                end
            else
                MDFXLPalettes.colors = {}
            end
            json.dump_file("MDF-XL/_Settings/MDF-XL_ColorPalettesSettings.json", MDFXLPalettes)
        end

        changed, paletteName = imgui.input_text("", paletteName); wc = wc or changed
        imgui.same_line()
        if imgui.button("Save Palette") then
            json.dump_file("MDF-XL/ColorPalettes/" .. paletteName .. ".json", MDFXLPalettes.colors)
            cache_MDFXLJSONFiles_MHWS(MDFXL, MDFXLSub)
        end
        
        imgui.spacing()

        if imgui.button("Add New Color") then
            table.insert(MDFXLPalettes.colors, {name = "Color " .. MDFXLPalettes.newColorIDX, value = {1.0, 1.0, 1.0, 1.0}})
            MDFXLPalettes.newColorIDX = MDFXLPalettes.newColorIDX + 1
        end
        imgui.same_line()
        if materialEditorSubParamFloat4Holder ~= nil then
            if imgui.button("Add New Color from Clipboard") then
                table.insert(MDFXLPalettes.colors, {name = "Color " .. MDFXLPalettes.newColorIDX, value = {materialEditorSubParamFloat4Holder[1], materialEditorSubParamFloat4Holder[2], materialEditorSubParamFloat4Holder[3], materialEditorSubParamFloat4Holder[4]}})
                MDFXLPalettes.newColorIDX = MDFXLPalettes.newColorIDX + 1
            end
        end

        imgui.spacing()

        for i, color in ipairs(MDFXLPalettes.colors) do
            imgui.push_id(i)
            imgui.begin_rect()
            imgui.spacing()
            imgui.indent(5)

            imgui.button("[ ".. color.name .. " ]")
            if imgui.begin_popup_context_item() then
                if imgui.menu_item("Reset") then
                    color.value = {1.0, 1.0, 1.0, 1.0}
                    wc = true
                end
                if imgui.menu_item("Copy") then
                    if type(color.value) == "table" then
                        materialEditorSubParamFloat4Holder = color.value
                        materialEditorSubParamFloatHolder = nil
                    end
                    wc = true
                end
                if materialEditorSubParamFloat4Holder ~= nil then
                    if imgui.menu_item("Paste") then
                        if type(color.value) == "table" then
                            color.value = materialEditorSubParamFloat4Holder
                        end
                        wc = true
                    end
                end
                if i ~= 1 then
                    if imgui.menu_item("Delete") then
                        table.remove(MDFXLPalettes.colors, i)
                        MDFXLPalettes.newColorIDX = math.max(0, MDFXLPalettes.newColorIDX - 1)
                        wc = true
                    end
                end
                imgui.end_popup()
            end
            local newColor = Vector4f.new(color.value[1], color.value[2], color.value[3], color.value[4])
            changed, newColor = imgui.color_edit4(" ",newColor); wc = wc or changed
            color.value = {newColor.x, newColor.y, newColor.z, newColor.w}
            
            imgui.pop_id()
            imgui.unindent()
            imgui.spacing()
            imgui.end_rect(1)

            imgui.spacing()
        end
        imgui.indent(-25)
        imgui.text_colored("  [ " .. ui.draw_line("=", 60)  .. " ] ", func.convert_rgba_to_ABGR(ui.colors.white))
        imgui.end_rect(1)
        imgui.end_window()
    end
end
local function draw_MDFXLEditorGUI_MHWS()
    if imgui.begin_window("MDF-XL: Editor") then
        imgui.begin_rect()
        
        imgui.text_colored("[ " .. ui.draw_line("=", MDFXLSettings.primaryDividerLen)  .. " ]", func.convert_rgba_to_ABGR(ui.colors.white))
        
        imgui.indent(25)

        changed, MDFXLOutfits.showMDFXLOutfitEditor = imgui.checkbox("Outfit Manager", MDFXLOutfits.showMDFXLOutfitEditor); wc = wc or changed
        func.tooltip("Show/Hide the Outfit Manager.")
        if not MDFXLOutfits.showMDFXLOutfitEditor or imgui.begin_window("MDF-XL: Outfit Manager", true, 0) == false  then
            MDFXLOutfits.showMDFXLOutfitEditor = false
        else
            imgui.spacing()
            imgui.indent()
            
            draw_MDFXLOutfitManagerGUI_MHWS()

            imgui.unindent()
            imgui.end_window()
        end
        imgui.same_line()
        changed, MDFXLPalettes.showMDFXLPaletteEditor = imgui.checkbox("Color Palette Editor", MDFXLPalettes.showMDFXLPaletteEditor); wc = wc or changed
        func.tooltip("Show/Hide the Color Palette Editor.")
        if not MDFXLPalettes.showMDFXLPaletteEditor or imgui.begin_window("MDF-XL: Color Palette Editor", true, 0) == false  then
            MDFXLPalettes.showMDFXLPaletteEditor = false
        else
            imgui.spacing()
            imgui.indent()
            
            draw_MDFXLPaletteGUI_MHWS()

            imgui.unindent()
            imgui.end_window()
        end
        if MDFXLSettings.showPresetVersion then
            imgui.same_line()
            ui.textButton_ColoredValue("Preset Version :", MDFXLSettings.presetVersion, func.convert_rgba_to_ABGR(ui.colors.gold))
        end

        imgui.indent(-15)
        
        imgui.text_colored(ui.draw_line("=", MDFXLSettings.secondaryDividerLen) ..  " // Hunter: Armor // ", func.convert_rgba_to_ABGR(ui.colors.gold))
        setup_MDFXLEditorGUI_MHWS(MDFXL, materialParamDefaultsHolder, MDFXLSettings, MDFXLSub, "order", update_PlayerEquipmentMaterialParams_MHWS, ui.colors.gold)

        imgui.text_colored(ui.draw_line("=", MDFXLSettings.secondaryDividerLen) ..  " // Hunter: Weapon // ", func.convert_rgba_to_ABGR(ui.colors.orange))
        setup_MDFXLEditorGUI_MHWS(MDFXL, materialParamDefaultsHolder, MDFXLSettings, MDFXLSub, "weaponOrder", update_PlayerArmamentMaterialParams_MHWS, ui.colors.orange)

        imgui.text_colored(ui.draw_line("=", MDFXLSettings.secondaryDividerLen) ..  " // Palico: Armor // ", func.convert_rgba_to_ABGR(ui.colors.cyan))
        setup_MDFXLEditorGUI_MHWS(MDFXL, materialParamDefaultsHolder, MDFXLSettings, MDFXLSub, "otomoOrder", update_OtomoEquipmentMaterialParams_MHWS, ui.colors.cyan)

        imgui.text_colored(ui.draw_line("=", MDFXLSettings.secondaryDividerLen) ..  " // Palico: Weapon // ", func.convert_rgba_to_ABGR(ui.colors.cerulean))
        setup_MDFXLEditorGUI_MHWS(MDFXL, materialParamDefaultsHolder, MDFXLSettings, MDFXLSub, "otomoWeaponOrder", update_OtomoArmamentMaterialParams_MHWS, ui.colors.cerulean)

        imgui.text_colored(ui.draw_line("=", MDFXLSettings.secondaryDividerLen) ..  " // Seikret // ", func.convert_rgba_to_ABGR(ui.colors.lime))
        setup_MDFXLEditorGUI_MHWS(MDFXL, materialParamDefaultsHolder, MDFXLSettings, MDFXLSub, "porterOrder", update_PorterMaterialParams_MHWS, ui.colors.lime)

        imgui.indent(-10)
        imgui.text_colored("[ " .. ui.draw_line("=", MDFXLSettings.primaryDividerLen)  .. " ]", func.convert_rgba_to_ABGR(ui.colors.white))
        imgui.end_rect()
        imgui.end_window()
    end
end
local function draw_MDFXLPresetGUI_MHWS()
    imgui.text_colored(ui.draw_line("-", MDFXLSettings.presetManager.primaryDividerLen), func.convert_rgba_to_ABGR(ui.colors.white))
    
    if MDFXLSettings.presetManager.showOutfitPreset then
        imgui.indent(10)
        imgui.push_item_width(MDFXLSettings.presetManager.menuWidth - 50)
        imgui.push_id(10)
        changed, outfitPresetSearchQuery = imgui.input_text("", outfitPresetSearchQuery); wc = wc or changed
        imgui.pop_id()
        imgui.pop_item_width()
        imgui.same_line()
        ui.button_CheckboxStyle("[ Aa ]", MDFXLSettings, "isSearchMatchCase", func.convert_rgba_to_ABGR(ui.colors.REFgray), func.convert_rgba_to_ABGR(ui.colors.gold), func.convert_rgba_to_ABGR(ui.colors.gold))
        func.tooltip("Match Case")
        imgui.same_line()
        imgui.text("Outfit Search")

        local filteredPresets = {}
        local currentOutfitPreset = MDFXLOutfits.Presets[MDFXLOutfits.currentOutfitPresetIDX]
        local filteredIDX = nil

        for _, preset in ipairs(MDFXLOutfits.Presets) do
            if outfitPresetSearchQuery == "" then
                table.insert(filteredPresets, preset)
            else
                local match
                if MDFXLSettings.isSearchMatchCase then
                    match = preset:find(outfitPresetSearchQuery, 1, true)
                else
                    match = preset:lower():find(outfitPresetSearchQuery:lower(), 1, true)
                end
                
                if match then
                    table.insert(filteredPresets, preset)
                end
            end
        end

        for i, preset in ipairs(filteredPresets) do
            if preset == currentOutfitPreset then
                filteredIDX = i
                break
            end
        end
        imgui.push_item_width(MDFXLSettings.presetManager.menuWidth)
        changed, filteredIDX = imgui.combo("Outfit Preset", filteredIDX or 1, filteredPresets); wc = wc or changed
        if changed then
            local selected_preset = filteredPresets[filteredIDX]
            for i, preset in ipairs(MDFXLOutfits.Presets) do
                if preset == selected_preset then
                    MDFXLOutfits.currentOutfitPresetIDX = i
                    break
                end
            end
    
            local json_filepath = [[MDF-XL\\Outfits\\]] .. selected_preset .. [[.json]]
            local temp_parts = json.load_file(json_filepath)
            wc = true
            if temp_parts ~= nil then
                for key, value in pairs(temp_parts) do
                    MDFXLPresetTracker[key].lastPresetName = value.lastPresetName
                end
                isOutfitManagerBypass = true
                json.dump_file("MDF-XL/_Holders/MDF-XL_PresetTracker.json", MDFXLPresetTracker)
            end
        end
        imgui.pop_item_width()
        imgui.indent(-10)
    end
    if imgui.tree_node("Advanced Search") then
        isAdvancedSearch = true
        imgui.push_item_width(MDFXLSettings.presetManager.menuWidth - 60)
        imgui.push_id(15)
        changed, presetSearchQuery = imgui.input_text("", presetSearchQuery); wc = wc or changed
        imgui.pop_id()
        imgui.pop_item_width()
        imgui.same_line()
        ui.button_CheckboxStyle("[ Aa ]", MDFXLSettings, "isSearchMatchCase", func.convert_rgba_to_ABGR(ui.colors.REFgray), func.convert_rgba_to_ABGR(ui.colors.gold), func.convert_rgba_to_ABGR(ui.colors.gold))
        func.tooltip("Match Case")
        imgui.same_line()
        imgui.text("Preset Search")

        if imgui.tree_node("Author List") then
            local counter = 0
            for i, author in pairs(MDFXLTags._AuthorList) do
                ui.button_CheckboxStyle(author, MDFXLTags._AuthorSearchList, string.format("isSearchFor" .. author), func.convert_rgba_to_ABGR(ui.colors.REFgray), func.convert_rgba_to_ABGR(ui.colors.cerulean), func.convert_rgba_to_ABGR(ui.colors.cerulean))
                counter = counter + 1
                if counter == MDFXLSettings.presetManager.authorButtonsPerLine then
                    imgui.spacing()
                else
                    imgui.same_line()
                end
            end
            imgui.new_line()
            imgui.tree_pop()
        end
        if imgui.tree_node("Tags") then
            local counter = 0
            for i, tag in pairs(MDFXLTags._TagList) do
                ui.button_CheckboxStyle(tag, MDFXLTags._TagSearchList, string.format("isSearchFor" .. tag), func.convert_rgba_to_ABGR(ui.colors.REFgray), func.convert_rgba_to_ABGR(ui.colors.gold), func.convert_rgba_to_ABGR(ui.colors.gold))
                counter = counter + 1
                if counter == MDFXLSettings.presetManager.tagButtonsPerLine then
                    imgui.spacing()
                else
                    imgui.same_line()
                end
            end
            imgui.new_line()
            imgui.tree_pop()
        end
        imgui.tree_pop()
    else
        isAdvancedSearch = false
    end
    setup_MDFXLPresetGUI_MHWS(MDFXL, MDFXLSettings, MDFXLSub, "order", update_PlayerEquipmentMaterialParams_MHWS, "Hunter: Armor", ui.colors.gold, MDFXLSettings.presetManager.showHunterEquipment)
    setup_MDFXLPresetGUI_MHWS(MDFXL, MDFXLSettings, MDFXLSub, "weaponOrder", update_PlayerArmamentMaterialParams_MHWS, "Hunter: Weapon", ui.colors.orange, MDFXLSettings.presetManager.showHunterArmament)
    setup_MDFXLPresetGUI_MHWS(MDFXL, MDFXLSettings, MDFXLSub, "otomoOrder", update_OtomoEquipmentMaterialParams_MHWS, "Palico: Armor", ui.colors.cyan, MDFXLSettings.presetManager.showOtomoEquipment)
    setup_MDFXLPresetGUI_MHWS(MDFXL, MDFXLSettings, MDFXLSub, "otomoWeaponOrder", update_OtomoArmamentMaterialParams_MHWS, "Palico: Weapon", ui.colors.cerulean, MDFXLSettings.presetManager.showOtomoArmament)
    setup_MDFXLPresetGUI_MHWS(MDFXL, MDFXLSettings, MDFXLSub, "porterOrder", update_PorterMaterialParams_MHWS, "Seikret", ui.colors.lime, MDFXLSettings.presetManager.showPorter)
    imgui.text_colored(ui.draw_line("-", MDFXLSettings.presetManager.primaryDividerLen), func.convert_rgba_to_ABGR(ui.colors.white))
end
local function load_MDFXLEditorAndPresetGUI_MHWS()
    changed, MDFXLSettings.showMDFXLEditor = imgui.checkbox("Open MDF-XL: Editor", MDFXLSettings.showMDFXLEditor); wc = wc or changed
    func.tooltip("Show/Hide the MDF-XL Editor.")
    if not MDFXLSettings.showMDFXLEditor or imgui.begin_window("MDF-XL: Editor", true, 0) == false  then
        MDFXLSettings.showMDFXLEditor = false
        lastMatParamName = ""
        if isAutoSaved then
            for i, chunk in pairs(MDFXLSaveDataChunks) do
                json.dump_file(chunk.fileName, chunk.data)
            end

            json.dump_file("MDF-XL/_Settings/MDF-XL_ColorPalettesSettings.json", MDFXLPalettes)
            json.dump_file("MDF-XL/_Settings/MDF-XL_OutfitManagerSettings.json", MDFXLOutfits)
            isAutoSaved = false
            autoSaveProgress = 0
        end
    else
        imgui.spacing()
        imgui.indent()
        
        draw_MDFXLEditorGUI_MHWS()
        if MDFXLSettings.showMDFXLEditor then
            isAutoSaved = true
        end
        imgui.unindent()
        imgui.end_window()
    end

    if MDFXLSettings.isAutoSave and MDFXLSettings.showAutoSaveProgressBar then
        imgui.push_style_color(ui.ImGuiCol.PlotHistogram, func.convert_rgba_to_ABGR(ui.colors.gold))
        imgui.progress_bar(autoSaveProgress, Vector2f.new(150, 5))
        imgui.pop_style_color()
    end

    draw_MDFXLPresetGUI_MHWS()
end
local function draw_MDFXLUserManual()
    if imgui.begin_window("MDF-XL: User Manual") then
        imgui.begin_rect()
        imgui.spacing()
        imgui.text("   " .. ui.draw_line("=", 5) .. MDFXLUserManual.Generic.header .. ui.draw_line("=", 100) .. "   ")
        imgui.spacing()
        imgui.indent(20)
        if imgui.tree_node(MDFXLUserManual.About.header) then
            imgui.spacing()
            imgui.indent(10)
            imgui.text_colored(ui.draw_line("-", 100), func.convert_rgba_to_ABGR(ui.colors.gold))
            imgui.text(MDFXLUserManual.About[000])
            imgui.spacing()
            imgui.text(MDFXLUserManual.About[001])
            imgui.indent(15)
            imgui.text(MDFXLUserManual.About[002])
            --imgui.text(MDFXLUserManual.About[003])
            imgui.indent(-15)
            imgui.spacing()
            imgui.text(MDFXLUserManual.About[099])
            imgui.push_id(0)
            imgui.push_item_width(500)
            imgui.input_text("", MDFXLUserManual.Links[299])
            imgui.pop_id()
            imgui.pop_item_width()
            imgui.text_colored(ui.draw_line("-", 100), func.convert_rgba_to_ABGR(ui.colors.gold))
            imgui.indent(-10)
            imgui.tree_pop()
        end
        imgui.indent(15)
        if imgui.tree_node(MDFXLUserManual.Install.header) then
            imgui.spacing()
            imgui.indent(10)
            imgui.text_colored(ui.draw_line("-", 100), func.convert_rgba_to_ABGR(ui.colors.gold))
            imgui.text(MDFXLUserManual.Install[010])
            imgui.spacing()
            imgui.text_colored(ui.draw_line("-", 50), func.convert_rgba_to_ABGR(ui.colors.white50))
            imgui.text(MDFXLUserManual.Install[011])
            imgui.push_id(0)
            imgui.push_item_width(500)
            imgui.input_text("", MDFXLUserManual.Links[200])
            imgui.pop_id()
            imgui.text(MDFXLUserManual.Install[012])

            imgui.text_colored(ui.draw_line("-", 50), func.convert_rgba_to_ABGR(ui.colors.white50))

            imgui.text(MDFXLUserManual.Install[013])
            imgui.text(MDFXLUserManual.About[2])
            imgui.push_id(1)
            imgui.input_text("", MDFXLUserManual.Links[201])
            imgui.pop_id()
            -- imgui.text(MDFXLUserManual.About[3])
            -- imgui.push_id(2)
            -- imgui.input_text("", MDFXLUserManual.Links[202])
            -- imgui.pop_id()
            imgui.spacing()
            imgui.text(MDFXLUserManual.Install[014])
            imgui.push_id(3)
            imgui.input_text("", MDFXLUserManual.Links[298])
            imgui.pop_id()
            imgui.spacing()
            imgui.text(MDFXLUserManual.Install[015])
            imgui.text_colored(ui.draw_line("-", 50), func.convert_rgba_to_ABGR(ui.colors.white50))
            imgui.spacing()
            imgui.text(MDFXLUserManual.Install[016])
            imgui.pop_item_width()
            
            imgui.text_colored(ui.draw_line("-", 100), func.convert_rgba_to_ABGR(ui.colors.gold))
            imgui.indent(-10)
            imgui.tree_pop()
        end
        if imgui.tree_node(MDFXLUserManual.Troubleshooting.header) then
            imgui.spacing()
            imgui.indent(10)
            imgui.text_colored(ui.draw_line("-", 100), func.convert_rgba_to_ABGR(ui.colors.gold))
            imgui.text(MDFXLUserManual.Troubleshooting[020])
            imgui.indent(30)
            imgui.spacing()
            imgui.text(MDFXLUserManual.Troubleshooting[021])
            imgui.indent(-30)
            imgui.text_colored(ui.draw_line("-", 50), func.convert_rgba_to_ABGR(ui.colors.white50))
            imgui.text(MDFXLUserManual.Troubleshooting[022])
            imgui.indent(30)
            imgui.spacing()
            imgui.text(MDFXLUserManual.Troubleshooting[023])
            imgui.indent(-30)
            imgui.text_colored(ui.draw_line("-", 50), func.convert_rgba_to_ABGR(ui.colors.white50))
            imgui.text(MDFXLUserManual.Troubleshooting[024])
            imgui.indent(30)
            imgui.spacing()
            imgui.text(MDFXLUserManual.Troubleshooting[025])
            imgui.indent(-30)
            imgui.text_colored(ui.draw_line("-", 50), func.convert_rgba_to_ABGR(ui.colors.white50))
            imgui.spacing()
            imgui.spacing()
            imgui.text(MDFXLUserManual.Troubleshooting[099])
            imgui.text_colored(ui.draw_line("-", 100), func.convert_rgba_to_ABGR(ui.colors.gold))
            imgui.indent(-10)
            imgui.tree_pop()
        end
        if imgui.tree_node(MDFXLUserManual.ReportingABug.header) then
            imgui.spacing()
            imgui.indent(10)
            imgui.text_colored(ui.draw_line("-", 100), func.convert_rgba_to_ABGR(ui.colors.gold))
            imgui.text(MDFXLUserManual.ReportingABug[030])
            imgui.spacing()
            imgui.text(MDFXLUserManual.ReportingABug[031])
            imgui.text_colored(ui.draw_line("-", 100), func.convert_rgba_to_ABGR(ui.colors.gold))
            imgui.indent(-10)
            imgui.tree_pop()
        end
        if imgui.tree_node(MDFXLUserManual.UpdateLoop.header) then
            imgui.spacing()
            imgui.indent(10)
            imgui.text_colored(ui.draw_line("-", 100), func.convert_rgba_to_ABGR(ui.colors.gold))
            imgui.text(MDFXLUserManual.UpdateLoop[040])
            imgui.spacing()
            imgui.text_colored(MDFXLUserManual.UpdateLoop[041], func.convert_rgba_to_ABGR(ui.colors.orange))
            imgui.text_colored(ui.draw_line("-", 50), func.convert_rgba_to_ABGR(ui.colors.white50))
            imgui.text(MDFXLUserManual.UpdateLoop[042])
            imgui.spacing()
            imgui.text_colored(MDFXLUserManual.Warnings[101], func.convert_rgba_to_ABGR(ui.colors.safetyYellow))
            imgui.text_colored(ui.draw_line("-", 100), func.convert_rgba_to_ABGR(ui.colors.gold))
            imgui.indent(-10)
            imgui.tree_pop()
        end
        if imgui.tree_node(MDFXLUserManual.Credits.header) then
            imgui.spacing()
            imgui.indent(10)
            imgui.text_colored(ui.draw_line("-", 100), func.convert_rgba_to_ABGR(ui.colors.gold))
            imgui.text(MDFXLUserManual.Credits[050])
            imgui.text_colored(ui.draw_line("-", 100), func.convert_rgba_to_ABGR(ui.colors.gold))
            imgui.indent(-10)
            imgui.tree_pop()
        end
        imgui.indent(-15)
        imgui.spacing()
        if imgui.tree_node(MDFXLUserManual.Usage.header) then
            imgui.spacing()
            imgui.indent(10)
            imgui.text_colored(ui.draw_line("-", 100), func.convert_rgba_to_ABGR(ui.colors.gold))
            imgui.text(MDFXLUserManual.Usage[060])
            imgui.spacing()
            imgui.text(MDFXLUserManual.Usage[061])
            imgui.text_colored(ui.draw_line("-", 100), func.convert_rgba_to_ABGR(ui.colors.gold))
            imgui.indent(-10)
            imgui.tree_pop()
        end
        imgui.indent(15)
        if imgui.tree_node(MDFXLUserManual.PresetManager.header) then
            imgui.spacing()
            imgui.indent(10)
            imgui.text_colored(ui.draw_line("-", 100), func.convert_rgba_to_ABGR(ui.colors.gold))
            imgui.text(MDFXLUserManual.PresetManager[070])
            imgui.text_colored(ui.draw_line("-", 50), func.convert_rgba_to_ABGR(ui.colors.white50))
            imgui.text(MDFXLUserManual.PresetManager[071])
            imgui.spacing()
            imgui.text(MDFXLUserManual.PresetManager[072])
            imgui.spacing()
            imgui.text_colored(MDFXLUserManual.PresetManager[073], func.convert_rgba_to_ABGR(ui.colors.orange))
            imgui.text_colored(ui.draw_line("-", 50), func.convert_rgba_to_ABGR(ui.colors.white50))
            imgui.text(MDFXLUserManual.PresetManager[074])
            imgui.text_colored(ui.draw_line("-", 50), func.convert_rgba_to_ABGR(ui.colors.white50))
            imgui.text(MDFXLUserManual.PresetManager[075])
            imgui.text(MDFXLUserManual.PresetManager[076])
            imgui.spacing()
            imgui.text_colored(MDFXLUserManual.PresetManager[077], func.convert_rgba_to_ABGR(ui.colors.orange))
            imgui.text_colored(ui.draw_line("-", 50), func.convert_rgba_to_ABGR(ui.colors.white50))
            imgui.text(MDFXLUserManual.PresetManager[078])
            imgui.text_colored(ui.draw_line("-", 100), func.convert_rgba_to_ABGR(ui.colors.gold))
            imgui.indent(-10)
            imgui.tree_pop()
        end
        if imgui.tree_node(MDFXLUserManual.Editor.header) then
            imgui.spacing()
            imgui.indent(10)
            imgui.text_colored(ui.draw_line("-", 100), func.convert_rgba_to_ABGR(ui.colors.gold))
            
            imgui.text(MDFXLUserManual.Editor[100])
            imgui.spacing()
            imgui.text(MDFXLUserManual.Editor[101])
            imgui.text_colored(ui.draw_line("-", 50), func.convert_rgba_to_ABGR(ui.colors.white50))
            imgui.text(MDFXLUserManual.Editor[102])
            imgui.spacing()
            imgui.text(MDFXLUserManual.Editor[103])
            imgui.spacing()
            imgui.text(MDFXLUserManual.Editor[104])
            imgui.spacing()
            imgui.text(MDFXLUserManual.Editor[105])
            imgui.spacing()
            imgui.text(MDFXLUserManual.Editor[106])
            imgui.text_colored(ui.draw_line("-", 50), func.convert_rgba_to_ABGR(ui.colors.white50))
            imgui.text_colored(MDFXLUserManual.Editor[107], func.convert_rgba_to_ABGR(ui.colors.orange))
            imgui.text(MDFXLUserManual.Editor[108])
            imgui.spacing()
            imgui.text_colored(MDFXLUserManual.Editor[109], func.convert_rgba_to_ABGR(ui.colors.orange))
            imgui.text(MDFXLUserManual.Editor[110])
            imgui.text_colored(ui.draw_line("-", 50), func.convert_rgba_to_ABGR(ui.colors.white50))
            imgui.text_colored(MDFXLUserManual.Editor[111], func.convert_rgba_to_ABGR(ui.colors.orange))
            imgui.text(MDFXLUserManual.Editor[112])

            imgui.text_colored(ui.draw_line("-", 100), func.convert_rgba_to_ABGR(ui.colors.gold))
            imgui.indent(-10)
            imgui.tree_pop()
        end
        imgui.indent(-15)
        imgui.indent(-20)
        
        imgui.spacing()
        imgui.end_rect()
        imgui.end_window()
    end
end
local function draw_MDFXLGUI_MHWS()
    if imgui.tree_node(modName) then
        isMDFXL = true
        imgui.begin_rect()
        imgui.spacing()
        imgui.spacing()
        imgui.indent(5)
        
        if isDefaultsDumped then
            load_MDFXLEditorAndPresetGUI_MHWS()
        end
        
        if imgui.tree_node("MDF-XL: Settings") then
            imgui.begin_rect()
            imgui.spacing()
            imgui.indent(5)

            if imgui.button("Reset to Defaults") then
                wc = true
                MDFXLSettings = hk.recurse_def_settings({}, MDFXL_DefaultSettings)
                hk.reset_from_defaults_tbl(MDFXL_DefaultSettings.hotkeys)
            end
            imgui.same_line()
            changed, isUserManual = imgui.checkbox("Open MDF-XL: User Manual", isUserManual); wc = wc or changed
            if not isUserManual or imgui.begin_window("MDF-XL: User Manual", true, 0) == false  then
                isUserManual = false
            else
                draw_MDFXLUserManual()
                imgui.end_window()
            end
            imgui.spacing()

            changed, MDFXLSettings.isDebug = imgui.checkbox("Debug Mode", MDFXLSettings.isDebug); wc = wc or changed
            func.tooltip("Toggle Debug Mode. When enabled, MDF-XL will log significantly more information in the 're2_framework_log.txt' file, located in the game's root folder.\n It is recommended to leave this on.")
            changed, MDFXLSettings.isAutoSave = imgui.checkbox("Auto-Save", MDFXLSettings.isAutoSave); wc = wc or changed
            func.tooltip("Toggle the Auto-Save feature. When enabled, MDF-XL will automatically save your current material parameters based on the Auto-Save Interval setting.\n It is recommended to leave this on.")
            if MDFXLSettings.isAutoSave then
                imgui.same_line()
                changed, MDFXLSettings.showAutoSaveProgressBar = imgui.checkbox("Show Auto-Save UI", MDFXLSettings.showAutoSaveProgressBar); wc = wc or changed
                func.tooltip("When enabled, a progress bar will show up below the MDF-XL Editor checkbox.")
                imgui.push_item_width(250)
                changed, MDFXLSettings.autoSaveInterval = imgui.drag_float("Auto-Save Interval ", MDFXLSettings.autoSaveInterval, 0.1, 1.0, 120.0, "%.1f sec"); wc = wc or changed
                func.tooltip("Sets how often MDF-XL auto-saves when the Editor is open.")
                imgui.pop_item_width()
            end
            if imgui.tree_node("Editor Settings") then
                imgui.text_colored("[ Preset Settings ]", func.convert_rgba_to_ABGR(ui.colors.white50))
                imgui.spacing()
                changed, MDFXLSettings.isInheritPresetName = imgui.checkbox("Inherit Preset Name", MDFXLSettings.isInheritPresetName); wc = wc or changed
                func.tooltip("When enabled, the '[Enter Preset Name Here]' text in the Editor will be replaced by the name of the last loaded preset.")
                changed, MDFXLSettings.isAutoLoadPresetAfterSave = imgui.checkbox("Auto-Load Preset After Manual Save", MDFXLSettings.isAutoLoadPresetAfterSave); wc = wc or changed
                func.tooltip("When enabled, the newly saved preset will auto-load.")
                imgui.spacing()
                imgui.text_colored("[ Display Settings ]", func.convert_rgba_to_ABGR(ui.colors.white50))
                imgui.spacing()
                changed, MDFXLSettings.showEquipmentName = imgui.checkbox("Use Equipment Name", MDFXLSettings.showEquipmentName); wc = wc or changed
                func.tooltip("When enabled, the equipment ID will be replaced by the equipment's name (if available).")
                changed, MDFXLSettings.showMaterialCount = imgui.checkbox("Show Material Count", MDFXLSettings.showMaterialCount); wc = wc or changed
                changed, MDFXLSettings.showMaterialFavoritesCount = imgui.checkbox("Show Material Favorites Count", MDFXLSettings.showMaterialFavoritesCount); wc = wc or changed
                changed, MDFXLSettings.showMaterialParamCount = imgui.checkbox("Show Material Parameter Count", MDFXLSettings.showMaterialParamCount); wc = wc or changed
                changed, MDFXLSettings.showTextureCount = imgui.checkbox("Show Texture Count", MDFXLSettings.showTextureCount); wc = wc or changed
                changed, MDFXLSettings.showMeshName = imgui.checkbox("Show Mesh Name", MDFXLSettings.showMeshName); wc = wc or changed
                changed, MDFXLSettings.showMeshPath = imgui.checkbox("Show Mesh Path", MDFXLSettings.showMeshPath); wc = wc or changed
                changed, MDFXLSettings.showMDFPath = imgui.checkbox("Show MDF Path", MDFXLSettings.showMDFPath); wc = wc or changed
                changed, MDFXLSettings.showFinalizedPresetName = imgui.checkbox("Show Finalized Preset Name", MDFXLSettings.showFinalizedPresetName); wc = wc or changed
                changed, MDFXLSettings.showPresetPath = imgui.checkbox("Show Preset Path", MDFXLSettings.showPresetPath); wc = wc or changed
                changed, MDFXLSettings.showPresetVersion = imgui.checkbox("Show Preset Version", MDFXLSettings.showPresetVersion); wc = wc or changed
                imgui.spacing()
                imgui.text_colored("[ UI Settings ]", func.convert_rgba_to_ABGR(ui.colors.white50))
                imgui.spacing()
                imgui.push_item_width(200)
                changed, MDFXLSettings.primaryDividerLen = imgui.drag_int("Primary Divider Length", MDFXLSettings.primaryDividerLen, 1, 0, 500); wc = wc or changed
                changed, MDFXLSettings.secondaryDividerLen = imgui.drag_int("Secondary Divider Length", MDFXLSettings.secondaryDividerLen, 1, 0, 500); wc = wc or changed
                changed, MDFXLSettings.tertiaryDividerLen = imgui.drag_int("Tertiary Divider Length", MDFXLSettings.tertiaryDividerLen, 1, 0, 500); wc = wc or changed
                imgui.pop_item_width()
                imgui.spacing()
                imgui.tree_pop()
            end
            if imgui.tree_node("Preset Manager Settings") then
                imgui.text_colored("[ Display Settings ]", func.convert_rgba_to_ABGR(ui.colors.white50))
                imgui.spacing()
                changed, MDFXLSettings.presetManager.showOutfitPreset = imgui.checkbox("Show Outfit Preset", MDFXLSettings.presetManager.showOutfitPreset); wc = wc or changed
                changed, MDFXLSettings.presetManager.showHunterEquipment = imgui.checkbox("Show Hunter Armor Presets", MDFXLSettings.presetManager.showHunterEquipment); wc = wc or changed
                changed, MDFXLSettings.presetManager.showHunterArmament = imgui.checkbox("Show Hunter Weapon Presets", MDFXLSettings.presetManager.showHunterArmament); wc = wc or changed
                changed, MDFXLSettings.presetManager.showOtomoEquipment = imgui.checkbox("Show Palico Armor Presets", MDFXLSettings.presetManager.showOtomoEquipment); wc = wc or changed
                changed, MDFXLSettings.presetManager.showOtomoArmament = imgui.checkbox("Show Palico Weapon Presets", MDFXLSettings.presetManager.showOtomoArmament); wc = wc or changed
                changed, MDFXLSettings.presetManager.showPorter = imgui.checkbox("Show Seikret Presets", MDFXLSettings.presetManager.showPorter); wc = wc or changed
                changed, MDFXLSettings.presetManager.isTrimPresetNames = imgui.checkbox("Use Short Preset Names", MDFXLSettings.presetManager.isTrimPresetNames); wc = wc or changed
                func.tooltip("When enabled, Tags and the Author Name will be hidden from preset names.")
                changed, MDFXLSettings.presetManager.showEquipmentName = imgui.checkbox("Use Equipment Name", MDFXLSettings.presetManager.showEquipmentName); wc = wc or changed
                func.tooltip("When enabled, the equipment ID will be replaced by the equipment's name (if available).")
                
                imgui.spacing()
                imgui.text_colored("[ UI Settings ]", func.convert_rgba_to_ABGR(ui.colors.white50))
                imgui.spacing()
                imgui.push_item_width(200)
                changed, MDFXLSettings.presetManager.primaryDividerLen = imgui.drag_int("Primary Divider Length", MDFXLSettings.presetManager.primaryDividerLen, 1, 0, 500); wc = wc or changed
                changed, MDFXLSettings.presetManager.secondaryDividerLen = imgui.drag_int("Secondary Divider Length", MDFXLSettings.presetManager.secondaryDividerLen, 1, 0, 500); wc = wc or changed
                changed, MDFXLSettings.presetManager.menuWidth = imgui.drag_int("Menu Width", MDFXLSettings.presetManager.menuWidth, 1, 100, 500); wc = wc or changed
                if MDFXLSettings.presetManager.menuWidth < 100 then
                    MDFXLSettings.presetManager.menuWidth = 100
                end
                imgui.spacing()
                changed, MDFXLSettings.presetManager.authorButtonsPerLine = imgui.drag_int("Author Names Per Line", MDFXLSettings.presetManager.authorButtonsPerLine, 1, 1, 100); wc = wc or changed
                changed, MDFXLSettings.presetManager.tagButtonsPerLine = imgui.drag_int("Tags Per Line", MDFXLSettings.presetManager.tagButtonsPerLine, 1, 1, 100); wc = wc or changed
                imgui.pop_item_width()
                imgui.tree_pop()
            end
            if imgui.tree_node("Hotkeys") then
                imgui.text_colored("[ KBM Settings ]", func.convert_rgba_to_ABGR(ui.colors.white50))
                imgui.spacing()
                
                imgui.push_id(1)
                changed, MDFXLSettings.useModifier = imgui.checkbox("", MDFXLSettings.useModifier); wc = wc or changed
                func.tooltip("Require that you hold down this button")
                imgui.same_line()
                changed = hk.hotkey_setter("Modifier"); wc = wc or changed
                imgui.pop_id()

                changed = hk.hotkey_setter("Toggle MDF-XL Editor", MDFXLSettings.useModifier and "Modifier"); wc = wc or changed
                changed = hk.hotkey_setter("Toggle Outfit Manager", MDFXLSettings.useModifier and "Modifier"); wc = wc or changed
                changed = hk.hotkey_setter("Toggle Color Palettes", MDFXLSettings.useModifier and "Modifier"); wc = wc or changed
                changed = hk.hotkey_setter("Toggle Filter Favorites", MDFXLSettings.useModifier and "Modifier"); wc = wc or changed
                changed = hk.hotkey_setter("Toggle Back Weapons", MDFXLSettings.useModifier and "Modifier"); wc = wc or changed
                changed = hk.hotkey_setter("Clear Outfit Search", MDFXLSettings.useModifier and "Modifier"); wc = wc or changed

                imgui.spacing()

                imgui.push_id(2)
                changed, MDFXLSettings.useModifier2 = imgui.checkbox("", MDFXLSettings.useModifier2); wc = wc or changed
                func.tooltip("Require that you hold down this button")
                imgui.same_line()
                changed = hk.hotkey_setter("Secondary Modifier"); wc = wc or changed
                imgui.pop_id()
                changed = hk.hotkey_setter("Toggle Case Sensitive Search", MDFXLSettings.useModifier2 and "Secondary Modifier"); wc = wc or changed
                
                imgui.push_id(3)
                changed, MDFXLSettings.useOutfitModifier = imgui.checkbox("", MDFXLSettings.useOutfitModifier); wc = wc or changed
                func.tooltip("Require that you hold down this button")
                imgui.same_line()
                changed = hk.hotkey_setter("Outfit Change Modifier"); wc = wc or changed
                imgui.pop_id()
                changed = hk.hotkey_setter("Outfit Previous", MDFXLSettings.useOutfitModifier and "Outfit Change Modifier"); wc = wc or changed
                changed = hk.hotkey_setter("Outfit Next", MDFXLSettings.useOutfitModifier and "Outfit Change Modifier"); wc = wc or changed
                
                imgui.spacing()

                imgui.text_colored("[ GamePad Settings ]", func.convert_rgba_to_ABGR(ui.colors.white50))
                imgui.spacing()

                imgui.push_id(4)
                changed, MDFXLSettings.useOutfitPadModifier = imgui.checkbox("", MDFXLSettings.useOutfitPadModifier); wc = wc or changed
                func.tooltip("Require that you hold down this button")
                imgui.same_line()
                changed = hk.hotkey_setter("GamePad Modifier"); wc = wc or changed
                imgui.pop_id()
                changed = hk.hotkey_setter("GamePad Outfit Previous", MDFXLSettings.useOutfitPadModifier and "GamePad Modifier"); wc = wc or changed
                imgui.same_line()
                imgui.text_colored("*", func.convert_rgba_to_ABGR(ui.colors.orange))
                changed = hk.hotkey_setter("GamePad Outfit Next", MDFXLSettings.useOutfitPadModifier and "GamePad Modifier"); wc = wc or changed
                imgui.same_line()
                imgui.text_colored("*", func.convert_rgba_to_ABGR(ui.colors.orange))
                changed = hk.hotkey_setter("GamePad Toggle Back Weapons", MDFXLSettings.useOutfitPadModifier and "GamePad Modifier"); wc = wc or changed
                imgui.same_line()
                imgui.text_colored("*", func.convert_rgba_to_ABGR(ui.colors.orange))
                
                imgui.spacing()
                
                imgui.text_colored("* Weapon must be sheathed!", func.convert_rgba_to_ABGR(ui.colors.orange))
                imgui.tree_pop()
            end

            if imgui.tree_node("Stats") then
                imgui.indent(5)
                if imgui.button("Refresh Stats") then
                    MDFXLSettings.stats.equipmentDataVarCount = func.countTableElements(MDFXL)
                    MDFXLSettings.stats.textureCount = func.countTableElements(MDFXLSub.texturePaths)
                    MDFXLSettings.stats.presetCount = func.countTableElements(MDFXLSub.jsonPaths)
                    MDFXLSettings.stats.outfitPresetCount = func.countTableElements(MDFXLOutfits.Presets)
                    MDFXLSettings.stats.colorPaletteCount = func.countTableElements(MDFXLPalettes.Presets)
                end
                imgui.text("Material Data: " .. MDFXLSettings.stats.equipmentDataVarCount)
                imgui.text("Texture Data: " .. MDFXLSettings.stats.textureCount)
                imgui.text("Preset Count: " .. MDFXLSettings.stats.presetCount)
                imgui.text("Outfit Preset Count: " .. MDFXLSettings.stats.outfitPresetCount)
                imgui.text("Color Palette Count: " .. MDFXLSettings.stats.colorPaletteCount)
                imgui.indent(-5)
                imgui.tree_pop()
            end

            if changed or wc then
                json.dump_file("MDF-XL/_Settings/MDF-XL_Settings.json", MDFXLSettings)
            end

            imgui.indent(-5)
            imgui.spacing()
            imgui.end_rect(2)
            imgui.tree_pop()
        end

        if MDFXLSettings.showMDFXLEditor and (changed or wc) then
            update_PlayerEquipmentMaterialParams_MHWS(MDFXL)
            update_PlayerArmamentMaterialParams_MHWS(MDFXL)
            update_OtomoEquipmentMaterialParams_MHWS(MDFXL)
            update_OtomoArmamentMaterialParams_MHWS(MDFXL)
            update_PorterMaterialParams_MHWS(MDFXL)
        end

        imgui.indent(10)
        imgui.text_colored(modVersion .. " | " .. modUpdated, func.convert_rgba_to_ABGR(ui.colors.gold)); imgui.same_line(); imgui.text("(c) " .. modAuthor .. " ")
        imgui.indent(-10); imgui.spacing(); imgui.end_rect(); imgui.tree_pop()

        if MDFXLSettings.showMDFXLEditor then
            if MDFXLSettings.isAutoSave then
                if not wasEditorShown then
                    lastTime = os.clock()
                    autoSaveProgress = 0
                    wasEditorShown = true
                end
                tickInterval = MDFXLSettings.autoSaveInterval
                local elapsedTime = os.clock() - lastTime
                autoSaveProgress = elapsedTime / tickInterval

                if os.clock() - lastTime > tickInterval then
                    for i, chunk in pairs(MDFXLSaveDataChunks) do
                        json.dump_file(chunk.fileName, chunk.data)
                    end
                    lastTime = os.clock()
                    autoSaveProgress = 0
                    if MDFXLPalettes.showMDFXLPaletteEditor then
                        json.dump_file("MDF-XL/_Settings/MDF-XL_ColorPalettesSettings.json", MDFXLPalettes)
                    end
                    if MDFXLSettings.isDebug then
                        log.info("[MDF-XL] [Auto-Save Complete]")
                    end
                end
            elseif not MDFXLSettings.isAutoSave then
                if changed or wc then
                    for i, chunk in pairs(MDFXLSaveDataChunks) do
                        json.dump_file(chunk.fileName, chunk.data)
                    end
                    json.dump_file("MDF-XL/_Settings/MDF-XL_ColorPalettesSettings.json", MDFXLPalettes)
                end
            end
        else
            wasEditorShown = false
        end
    else
        isMDFXL = false
    end
end
-- Debug Functions
local function debug_RealEquipmentNames_MHWS()
    if isPlayerOpenEquipmentMenu then
        local debugTable = {}
        GUI080001 = GUI080001 and GUI080001:get_GameObject()
        local GUI080001_Comp = func.get_GameObjectComponent(GUI080001, "app.GUI080001")
        local equipType = GUI080001_Comp:get__EquipTypeSelect()._EquipNameTextList
        equipType = func.lua_get_array(equipType, false)
        for i, text in ipairs(equipType) do
            local name = text:get_Message()
            if not func.table_contains(debugTable, name) then
                table.insert(debugTable, name)
            end
        end
        json.dump_file("MDF-XL/_Debug/names.json", debugTable)
        isPlayerOpenEquipmentMenu = false
    end
end
--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////--
--MARK:On Frame
re.on_frame(function ()
    if reframework.get_game_name() == "mhwilds" then
        update_MDFXLViaHotkeys_MHWS()
        manage_MasterMaterialData_MHWS(MDFXL, MDFXLSub, MDFXLSaveDataChunks)
        isUpdaterBypass = false
        changed = false
        wc = false
        for i, entry in pairs(MDFXL) do
            entry.isUpdated = false
        end
    end
end)

--MARK:On Draw UI
re.on_draw_ui(function()
    if reframework.get_game_name() == "mhwilds" then
        draw_MDFXLGUI_MHWS()
    end
end)