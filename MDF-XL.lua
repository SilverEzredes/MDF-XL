--/////////////////////////////////////--
local modName =  "MDF-XL"

local modAuthor = "SilverEzredes"
local modUpdated = "01/20/2025"
local modVersion = "v1.4.54"
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
    matchEquip = "(ch[^@]+)",
    matchWeapon = "(Wp[^@]+)",
    matchItem = "(it[^@]+)",
    PorterMatch = {"Saddle[^@]+", "Body[^@]+"},
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
    isAutoSave = true,
    showAutoSaveProgressBar = true,
    autoSaveInterval = 30.0,
    isSearchMatchCase = false,
    isFilterFavorites = false,
    isInheritPresetName = true,
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
        ["Toggle Case Sensitive Search"] = "C",
        ["Clear Outfit Search"] = "X",
        ["Outfit Change Modifier"] = "RShift",
        ["Outfit Next"] = "Next",
        ["Outfit Previous"] = "Prior",
        ["Outfit Change Pad Modifier"] = "LT (L2)",
        ["Outfit Pad Next"] = "LUp",
        ["Outfit Pad Previous"] = "LDown",
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
            if MDFXLSettings.isDebug then
                log.info("[MDF-XL] [" .. formattedMeshPath .. "]")
            end
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
            if MDFXLSettings.isDebug then
                log.info("[MDF-XL] [" .. formattedMDFPath .. "]")
            end
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
                    for t = 0, textureCount - 1 do
                        local textureName = renderMesh:getMaterialTextureName(j, t)
                        local textureResource = func.create_resource(texResourceComp, dataTable[entry.MeshName].Textures[matName][textureName])
                        renderMesh:setMaterialTexture(j, t, textureResource)
                    end
                end
                for v = 0, #dataTable[entry.MeshName].Enabled do
                    renderMesh:setMaterialsEnable(v, dataTable[entry.MeshName].Enabled[v + 1])
                end
                renderMesh:set_ForceTwoSide(dataTable[entry.MeshName].Flags.isForceTwoSide)
                renderMesh:set_BeautyMaskFlag(dataTable[entry.MeshName].Flags.isBeautyMask)
                renderMesh:set_ReceiveSSSSSFlag(dataTable[entry.MeshName].Flags.isReceiveSSSSS)
            end
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
        if (chunkID == "ch02") or (chunkID == "ch03") then
            chunkID = key:sub(1, 8)
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

local entityComp = "app.PlayerEntityManager"
local masterOtomo = nil
local masterPorter = nil
local GUI010000 = nil
local GUI080001 = nil
local GUI090000 = nil
local isOtomoInScene = false
local isPorterInScene = false
local isPlayerLeftEquipmentMenu = false
local isPlayerOpenEquipmentMenu = false
local isPlayerLeftCamp = false
local isAppearanceEditorOpen = false
local isAppearanceEditorUpdater = false
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
    sdk.hook(sdk.find_type_definition("app.GUI090001"):get_method("closeRequest()"),
        function(args)
            isPlayerLeftCamp = true
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
end
--Material Param Getters
local function get_PlayerEquipmentMaterialParams_MHWS(MDFXLData, MDFXLSubData)
    if not isPlayerInScene then return end

    local playerTransforms = masterPlayer and masterPlayer:get_Valid() and masterPlayer:get_Object():get_Transform()
    local playerChildren = func.get_children(playerTransforms)
    MDFXLSubData.order = {}

    for i, child in pairs(playerChildren) do
        local childStrings = child:ToString()
        local playerEquipment = childStrings:match(MDFXL_Cache.matchEquip)

        if playerEquipment then
            local currentEquipment = playerTransforms:find(playerEquipment)
            local currentEquipmentID = currentEquipment:get_GameObject()

            if not MDFXLData[playerEquipment] then
                setup_MDFXLTable(MDFXLData, playerEquipment)
            end

            if currentEquipmentID and currentEquipmentID:get_Valid() then
                MDFXLData[playerEquipment].isInScene = true
                MDFXLData[playerEquipment].Parts = {}
                MDFXLData[playerEquipment].Enabled = {}
                MDFXLData[playerEquipment].Materials = {}
                get_MaterialParams(currentEquipmentID, MDFXLData, playerEquipment, MDFXLSubData, "order", MDFXLSaveDataChunks)
            else
                MDFXLData[playerEquipment].isInScene = false
            end
        end
    end
end
local function get_PlayerArmamentMaterialParams_MHWS(MDFXLData, MDFXLSubData)
    if not isPlayerInScene then return end

    local playerTransforms = masterPlayer and masterPlayer:get_Valid() and masterPlayer:get_Object():get_Transform()
    local playerHunter = masterPlayer and masterPlayer:get_Valid() and masterPlayer:get_Object()
    local playerChildren = func.get_children(playerTransforms)
    MDFXLSubData.weaponOrder = {}
    
    for i, child in pairs(playerChildren) do
        local childStrings = child:ToString()
        local playerArmament = childStrings:match(MDFXL_Cache.matchWeapon)

        if playerArmament then
            local currentArmament = playerTransforms:find(playerArmament)

            if currentArmament then
                local currentArmamentTransforms = currentArmament and currentArmament:get_Valid() and currentArmament:get_GameObject():get_Transform()
                local currentArmamentChildren = func.get_children(currentArmamentTransforms)

                if currentArmamentChildren ~= nil then
                    for j, child2 in pairs(currentArmamentChildren) do
                        local child2Strings = child2:ToString()
                        local playerWeapon = child2Strings:match(MDFXL_Cache.matchItem)

                        if playerWeapon then
                            local currentWeapon = currentArmamentTransforms:find(playerWeapon)
                            local currentWeaponID = currentWeapon:get_GameObject()
                               
                            if not MDFXLData[playerWeapon] then
                                setup_MDFXLTable(MDFXLData, playerWeapon)
                            end
                            if currentWeaponID and currentWeaponID:get_Valid() then
                                MDFXLData[playerWeapon].isInScene = true
                                MDFXLData[playerWeapon].Parts = {}
                                MDFXLData[playerWeapon].Enabled = {}
                                MDFXLData[playerWeapon].Materials = {}
                                
                                get_MaterialParams(currentWeaponID, MDFXLData, playerWeapon, MDFXLSubData, "weaponOrder", MDFXLSaveDataChunks)
                            elseif (not currentWeaponID) or (not currentWeaponID:get_Valid()) then
                                MDFXLData[playerWeapon].isInScene = false
                            end
                        end
                    end
                end
            end
        end
    end

    if playerHunter then
        local playerEntity = func.get_GameObjectComponent(playerHunter, entityComp)

        if playerEntity then
            local weaponInsect = playerEntity._Character:get_Wp10Insect()
            if weaponInsect == nil then return end
            weaponInsect = weaponInsect and weaponInsect:get_GameObject()
            local weaponInsectName = weaponInsect:get_Name()

            if not MDFXLData[weaponInsectName] then
                setup_MDFXLTable(MDFXLData, weaponInsectName)
            end
            if weaponInsect and weaponInsect:get_Valid() then
                MDFXLData[weaponInsectName].isInScene = true
                MDFXLData[weaponInsectName].Parts = {}
                MDFXLData[weaponInsectName].Enabled = {}
                MDFXLData[weaponInsectName].Materials = {}
                
                get_MaterialParams(weaponInsect, MDFXLData, weaponInsectName, MDFXLSubData, "weaponOrder", MDFXLSaveDataChunks)
            elseif (not weaponInsect) or (not weaponInsect:get_Valid()) then
                MDFXLData[weaponInsectName].isInScene = false
            end
        end
    end
end
local function get_OtomoEquipmentMaterialParams_MHWS(MDFXLData, MDFXLSubData)
    if not isOtomoInScene then return end
    local otomoTransforms = masterOtomo and masterOtomo:get_Valid() and masterOtomo:get_Character():get_GameObject():get_Transform()
    local otomoChildren = func.get_children(otomoTransforms)
    MDFXLSubData.otomoOrder = {}

    for i, child in pairs(otomoChildren) do
        local childStrings = child:ToString()
        local otomoEquipment = childStrings:match(MDFXL_Cache.matchEquip)

        if otomoEquipment then
            local currentEquipment = otomoTransforms:find(otomoEquipment)
            local currentEquipmentID = currentEquipment:get_GameObject()
            
            if not MDFXLData[otomoEquipment] then
                setup_MDFXLTable(MDFXLData, otomoEquipment)
            end

            if currentEquipmentID and currentEquipmentID:get_Valid() then
                MDFXLData[otomoEquipment].isInScene = true
                MDFXLData[otomoEquipment].Parts = {}
                MDFXLData[otomoEquipment].Enabled = {}
                MDFXLData[otomoEquipment].Materials = {}
                
                get_MaterialParams(currentEquipmentID, MDFXLData, otomoEquipment, MDFXLSubData, "otomoOrder", MDFXLSaveDataChunks)
            elseif (not currentEquipmentID) or (not currentEquipmentID:get_Valid()) then
                MDFXLData[otomoEquipment].isInScene = false
            end
        end
    end
end
local function get_OtomoArmamentMaterialParams_MHWS(MDFXLData, MDFXLSubData)
    if not isOtomoInScene then return end
    local otomoGameObject = masterOtomo and masterOtomo:get_Valid() and masterOtomo:get_Character():get_GameObject()
    MDFXLSubData.otomoWeaponOrder = {}

    if otomoGameObject then
        local otomoCharacter = func.get_GameObjectComponent(otomoGameObject, "app.OtomoCharacter")

        if otomoCharacter then
            local otomoWeapon = otomoCharacter:get_WeaponGameObject()
            local otomoWeaponID = otomoWeapon:get_Name()
            if otomoWeapon and otomoWeapon:get_Valid() then
                if not MDFXLData[otomoWeaponID] then
                    setup_MDFXLTable(MDFXLData, otomoWeaponID)
                end
                MDFXLData[otomoWeaponID].isInScene = true
                MDFXLData[otomoWeaponID].Parts = {}
                MDFXLData[otomoWeaponID].Enabled = {}
                MDFXLData[otomoWeaponID].Materials = {}
                get_MaterialParams(otomoWeapon, MDFXLData, otomoWeaponID, MDFXLSubData, "otomoWeaponOrder", MDFXLSaveDataChunks)
            elseif (not otomoWeapon) or (not otomoWeapon:get_Valid()) then
                MDFXLData[otomoWeaponID].isInScene = false
            end
        end
    end
end
local function get_PorterMaterialParams_MHWS(MDFXLData, MDFXLSubData)
    if not isPorterInScene then return end
    
    local porterTransforms = masterPorter and masterPorter:get_Valid() and masterPorter:get_Object():get_Transform()
    local porterChildren = func.get_children(porterTransforms)
    MDFXLSubData.porterOrder = {}

    for i, child in pairs(porterChildren) do
        local childStrings = child:ToString()
        
        for j, pattern in ipairs(MDFXL_Cache.PorterMatch) do
            local porterEquipment = childStrings:match(pattern)
            
            if porterEquipment then
                local currentEquipment = porterTransforms:find(porterEquipment)
                local currentEquipmentID = currentEquipment:get_GameObject()
                local renderMesh = func.get_GameObjectComponent(currentEquipmentID, renderComp)

                if renderMesh then
                    local nativesMesh = renderMesh:getMesh():ToString()
                    nativesMesh = nativesMesh and nativesMesh:match(MDFXL_Cache.matchMesh)

                    if not MDFXLData[nativesMesh] then
                        setup_MDFXLTable(MDFXLData, nativesMesh)
                    end

                    if currentEquipmentID and currentEquipmentID:get_Valid() then
                        MDFXLData[nativesMesh].isInScene = true
                        MDFXLData[nativesMesh].Parts = {}
                        MDFXLData[nativesMesh].Enabled = {}
                        MDFXLData[nativesMesh].Materials = {}

                        get_MaterialParams(currentEquipmentID, MDFXLData, nativesMesh, MDFXLSubData, "porterOrder", MDFXLSaveDataChunks)
                    elseif (not currentEquipmentID) or (not currentEquipmentID:get_Valid()) then
                        MDFXLData[nativesMesh].isInScene = false
                    end
                end
            end
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
        if (MDFXLData[equipment.MeshName] and MDFXLData[equipment.MeshName].isUpdated) then
            local playerTransforms = masterPlayer and masterPlayer:get_Valid() and masterPlayer:get_Object():get_Transform()
            local playerChildren = func.get_children(playerTransforms)
            
            for i, child in pairs(playerChildren) do
                local childStrings = child:ToString()
                local playerEquipment = childStrings:match(MDFXL_Cache.matchEquip)
                
                if playerEquipment == equipment.MeshName then
                    local currentEquipment = playerTransforms:find(playerEquipment)
                    local currentEquipmentID = currentEquipment:get_GameObject()

                    if not (currentEquipmentID and currentEquipmentID:get_Valid()) then return end
                    set_MaterialParams(currentEquipmentID, MDFXLData, equipment, MDFXLSaveDataChunks)
                end
            end
        end
    end
end
local function update_PlayerArmamentMaterialParams_MHWS(MDFXLData)
    if not isPlayerInScene then return end
    for _, weapon in pairs(MDFXLData) do
        if (MDFXLData[weapon.MeshName] and MDFXLData[weapon.MeshName].isUpdated) then
            local playerTransforms = masterPlayer and masterPlayer:get_Valid() and masterPlayer:get_Object():get_Transform()
            local playerHunter = masterPlayer and masterPlayer:get_Valid() and masterPlayer:get_Object()
            local playerChildren = func.get_children(playerTransforms)
            
            for i, child in pairs(playerChildren) do
                local childStrings = child:ToString()
                local playerArmament = childStrings:match(MDFXL_Cache.matchWeapon)

                if playerArmament then
                    local currentArmament = playerTransforms:find(playerArmament)
        
                    if currentArmament then
                        local currentArmamentTransforms = currentArmament and currentArmament:get_Valid() and currentArmament:get_GameObject():get_Transform()
                        local currentArmamentChildren = func.get_children(currentArmamentTransforms)

                        if currentArmamentChildren ~= nil then
                            for j, child2 in pairs(currentArmamentChildren) do
                                local child2Strings = child2:ToString()
                                local playerWeapon = child2Strings:match(MDFXL_Cache.matchItem)

                                if playerWeapon == weapon.MeshName then
                                    local currentWeapon = currentArmamentTransforms:find(playerWeapon)
                                    local currentWeaponID = currentWeapon:get_GameObject()
                            
                                    if not (currentWeaponID and currentWeaponID:get_Valid()) then return end
                                    set_MaterialParams(currentWeaponID, MDFXLData, weapon, MDFXLSaveDataChunks)
                                end
                            end
                        end
                    end
                end
            end

            if playerHunter then
                local playerEntity = func.get_GameObjectComponent(playerHunter, entityComp)
        
                if playerEntity then
                    local weaponInsect = playerEntity._Character:get_Wp10Insect()
                    if weaponInsect == nil then return end
                    weaponInsect = weaponInsect and weaponInsect:get_GameObject()
                    local weaponInsectName = weaponInsect:get_Name()
                    if weaponInsectName == weapon.MeshName then
                        if not weaponInsect and weaponInsect:get_Valid() then return end
                        set_MaterialParams(weaponInsect, MDFXLData, weapon, MDFXLSaveDataChunks)
                    end
                end
            end
        end
    end
end
local function update_OtomoEquipmentMaterialParams_MHWS(MDFXLData)
    if not isOtomoInScene then return end
    for _, equipment in pairs(MDFXLData) do
        if (MDFXLData[equipment.MeshName] and MDFXLData[equipment.MeshName].isUpdated) then
            local otomoTransforms = masterOtomo and masterOtomo:get_Valid() and masterOtomo:get_Character():get_GameObject():get_Transform()
            local otomoChildren = func.get_children(otomoTransforms)
            
            for i, child in pairs(otomoChildren) do
                local childStrings = child:ToString()
                local otomoEquipment = childStrings:match(MDFXL_Cache.matchEquip)
                
                if otomoEquipment == equipment.MeshName then
                    local currentEquipment = otomoTransforms:find(otomoEquipment)
                    local currentEquipmentID = currentEquipment:get_GameObject()
                
                    if not (currentEquipmentID and currentEquipmentID:get_Valid()) then return end
                    set_MaterialParams(currentEquipmentID, MDFXLData, equipment, MDFXLSaveDataChunks)
                end
            end
        end
    end
end
local function update_OtomoArmamentMaterialParams_MHWS(MDFXLData)
    if not isOtomoInScene then return end
    for _, weapon in pairs(MDFXLData) do
        if (MDFXLData[weapon.MeshName] and MDFXLData[weapon.MeshName].isUpdated) then
            local otomoGameObject = masterOtomo and masterOtomo:get_Valid() and masterOtomo:get_Character():get_GameObject()

            if otomoGameObject then
                local otomoCharacter = func.get_GameObjectComponent(otomoGameObject, "app.OtomoCharacter")
        
                if otomoCharacter then
                    local otomoWeapon = otomoCharacter:get_WeaponGameObject()
                    local otomoWeaponID = otomoWeapon:get_Name()
                    if otomoWeaponID == weapon.MeshName then
                        set_MaterialParams(otomoWeapon, MDFXLData, weapon, MDFXLSaveDataChunks)
                    end
                end
            end
        end
    end
end
local function update_PorterMaterialParams_MHWS(MDFXLData)
    if not isPorterInScene then return end
    for _, equipment in pairs(MDFXLData) do
        if (MDFXLData[equipment.MeshName] and MDFXLData[equipment.MeshName].isUpdated) then
            local porterTransforms = masterPorter and masterPorter:get_Valid() and masterPorter:get_Object():get_Transform()
            local porterChildren = func.get_children(porterTransforms)

            for i, child in pairs(porterChildren) do
                local childStrings = child:ToString()
        
                for j, pattern in ipairs(MDFXL_Cache.PorterMatch) do
                    local porterEquipment = childStrings:match(pattern)
                    
                    if porterEquipment then
                        local currentEquipment = porterTransforms:find(porterEquipment)
                        local currentEquipmentID = currentEquipment:get_GameObject()
                        local renderMesh = func.get_GameObjectComponent(currentEquipmentID, renderComp)
        
                        if renderMesh then
                            local nativesMesh = renderMesh:getMesh():ToString()
                            nativesMesh = nativesMesh and nativesMesh:match(MDFXL_Cache.matchMesh)

                            if nativesMesh == equipment.MeshName then
                                set_MaterialParams(currentEquipmentID, MDFXLData, equipment, MDFXLSaveDataChunks)
                            end
                        end
                    end
                end
            end
        end
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
                            log.info("[MDF-XL] [Auto Preset Loader: " .. equipment.MeshName .. " --- " .. #temp_parts.Parts .. " ]")
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
                            log.info("[MDF-XL] [Auto Preset Loader: " .. equipment.MeshName .. " --- " .. #temp_parts.Parts .. " ]")
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
        get_PlayerEquipmentMaterialParams_MHWS(MDFXLData, MDFXLSubData)
        get_PlayerArmamentMaterialParams_MHWS(MDFXLData, MDFXLSubData)
        get_OtomoEquipmentMaterialParams_MHWS(MDFXLData, MDFXLSubData)
        get_OtomoArmamentMaterialParams_MHWS(MDFXLData, MDFXLSubData)
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
                        log.info("[MDF-XL] [Auto Preset Loader: " .. equipment.MeshName .. " --- " .. #temp_parts.Parts .. " ]")
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
        log.info("[MDF-XL] [Player left the Equipment Menu, MDF-XL data updated.]")
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
                        log.info("[MDF-XL] [Auto Preset Loader: " .. equipment.MeshName .. " --- " .. #temp_parts.Parts .. " ]")
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
                        log.info("[MDF-XL] [Auto Preset Loader: " .. equipment.MeshName .. " --- " .. #temp_parts.Parts .. " ]")
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
                        log.info("[MDF-XL] [Auto Preset Loader: " .. equipment.MeshName .. " --- " .. #temp_parts.Parts .. " ]")
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
end
local function update_MDFXLViaHotkeys_MHWS()
    local KBM_controls = not MDFXLSettings.useModifier or hk.check_hotkey("Modifier", true)
    local KBM_controls2 = not MDFXLSettings.useModifier2 or hk.check_hotkey("Secondary Modifier", true)
    local KBM_outfitChangeControls = not MDFXLSettings.useOutfitModifier or hk.check_hotkey("Outfit Change Modifier", true)
    local PAD_outfitChangeControls = not MDFXLSettings.useOutfitPadModifier or hk.check_hotkey("Outfit Change Pad Modifier", true)

    if (KBM_outfitChangeControls and hk.check_hotkey("Outfit Next")) or (PAD_outfitChangeControls and hk.check_hotkey("Outfit Pad Next")) then
        local outfitCount = func.countTableElements(MDFXLOutfits.Presets)
        MDFXLOutfits.currentOutfitPresetIDX = math.min(MDFXLOutfits.currentOutfitPresetIDX + 1, outfitCount)
        setup_OutfitChanger()
    end
    if (KBM_outfitChangeControls and hk.check_hotkey("Outfit Previous")) or (PAD_outfitChangeControls and hk.check_hotkey("Outfit Pad Previous")) then
        MDFXLOutfits.currentOutfitPresetIDX = math.max(MDFXLOutfits.currentOutfitPresetIDX - 1, 1)
        setup_OutfitChanger()
    end

    if KBM_controls and hk.check_hotkey("Toggle MDF-XL Editor") and isMDFXL then
        MDFXLSettings.showMDFXLEditor = not MDFXLSettings.showMDFXLEditor
    end
    if KBM_controls and hk.check_hotkey("Clear Outfit Search") and isMDFXL then
        outfitPresetSearchQuery = ""
    end
    if KBM_controls2 and hk.check_hotkey("Toggle Case Sensitive Search") and isMDFXL then
        MDFXLSettings.isSearchMatchCase = not MDFXLSettings.isSearchMatchCase
    end

    if not MDFXLSettings.showMDFXLEditor then return end

    if KBM_controls and hk.check_hotkey("Toggle Filter Favorites") then
        MDFXLSettings.isFilterFavorites = not MDFXLSettings.isFilterFavorites
    end
    
    if KBM_controls and hk.check_hotkey("Toggle Outfit Manager") then
        MDFXLOutfits.showMDFXLOutfitEditor = not MDFXLOutfits.showMDFXLOutfitEditor
    end
    
    if KBM_controls and hk.check_hotkey("Toggle Color Palettes") then
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
                
                imgui.text_colored("  " .. ui.draw_line("=", 130) .."  ", func.convert_rgba_to_ABGR(ui.colors.white))
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

                changed, MDFXLData[entry.MeshName].currentPresetIDX = imgui.combo("Preset", MDFXLData[entry.MeshName].currentPresetIDX or 1, MDFXLData[entry.MeshName].Presets); wc = wc or changed
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
                    imgui.spacing()
                    imgui.text_colored(ui.draw_line("=", 100), func.convert_rgba_to_ABGR(ui.colors.gold))
                    imgui.indent(15)

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
                    imgui.text_colored(ui.draw_line("-", 75), func.convert_rgba_to_ABGR(ui.colors.gold))
                    if imgui.tree_node("Flags") then
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
                    end
                    imgui.indent(-15)
                    imgui.text_colored(ui.draw_line("=", 100), func.convert_rgba_to_ABGR(ui.colors.gold))
                    imgui.tree_pop()
                end
                
                if imgui.tree_node("Material Editor") then
                    imgui.spacing()
                    imgui.text_colored(ui.draw_line("=", 100), func.convert_rgba_to_ABGR(ui.colors.cerulean))
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
                        if imgui.tree_node(matName) then
                            imgui.push_id(matName)
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
                                    imgui.text_colored(ui.draw_line("=", 115), func.convert_rgba_to_ABGR(ui.colors.cerulean))

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
                                                local realIndex = func.find_index(MDFXLSubData.texturePaths, selectedTexture)
                                                
                                                if realIndex then
                                                    MDFXLData[entry.MeshName].Textures[matName][texName] = MDFXLSubData.texturePaths[realIndex]
                                                end
                                                wc = true
                                            end
                                            if currentData ~= originalData then
                                                imgui.indent(-35)
                                            end
                                            imgui.pop_id(); imgui.pop_style_color(); imgui.end_rect(); imgui.spacing()
                                        end
                                    end
                                    imgui.text_colored(ui.draw_line("=", 115), func.convert_rgba_to_ABGR(ui.colors.cerulean))
                                    imgui.tree_pop()
                                end
                                imgui.text_colored(ui.draw_line("-", 75), func.convert_rgba_to_ABGR(ui.colors.cerulean))
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
                                                    local index = func.find_index(MDFXLSubData.matParamFavorites, paramName)
                                                    if index then
                                                        wc = true
                                                        table.remove(MDFXLSubData.matParamFavorites, index)
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
                                                    local index = func.find_index(MDFXLSubData.matParamFavorites, paramName)
                                                    if index then
                                                        wc = true
                                                        table.remove(MDFXLSubData.matParamFavorites, index)
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
                            imgui.pop_id(); imgui.spacing(); imgui.tree_pop()
                        end
                    end
                    imgui.indent(-5)
                    imgui.text_colored(ui.draw_line("=", 100), func.convert_rgba_to_ABGR(ui.colors.cerulean))
                    imgui.tree_pop()
                end

                if changed or wc then
                    MDFXLData[entry.MeshName].isUpdated = true
                end
                imgui.indent(-10)
                imgui.text_colored("  " .. ui.draw_line("=", 130) .."  ", func.convert_rgba_to_ABGR(ui.colors.white))
                imgui.end_rect(); imgui.tree_pop()
            end
            imgui.text_colored("  " .. ui.draw_line("-", 150) .."  ", func.convert_rgba_to_ABGR(color01))
            imgui.indent(-15)
        end
    end
end
local function setup_MDFXLPresetGUI_MHWS(MDFXLData, MDFXLSettingsData, MDFXLSubData, order, updateFunc, displayText, color01, isDraw)
    if not isDraw then return end

    imgui.text_colored(ui.draw_line("=", 60) ..  " // " .. displayText .. " // ", func.convert_rgba_to_ABGR(color01))
    imgui.indent(10)
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
            imgui.push_item_width(450)
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
        imgui.text_colored("  [ " .. ui.draw_line("=", 80)  .. " ] ", func.convert_rgba_to_ABGR(ui.colors.white))
        imgui.spacing()
        imgui.indent(25)

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
        imgui.text_colored("  [ " .. ui.draw_line("=", 80)  .. " ] ", func.convert_rgba_to_ABGR(ui.colors.white))
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
        
        imgui.text_colored("[ " .. ui.draw_line("=", 150)  .. " ]", func.convert_rgba_to_ABGR(ui.colors.white))
        
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
        
        imgui.text_colored(ui.draw_line("=", 95) ..  " // Hunter: Armor // ", func.convert_rgba_to_ABGR(ui.colors.gold))
        setup_MDFXLEditorGUI_MHWS(MDFXL, materialParamDefaultsHolder, MDFXLSettings, MDFXLSub, "order", update_PlayerEquipmentMaterialParams_MHWS, ui.colors.gold)

        imgui.text_colored(ui.draw_line("=", 95) ..  " // Hunter: Weapon // ", func.convert_rgba_to_ABGR(ui.colors.orange))
        setup_MDFXLEditorGUI_MHWS(MDFXL, materialParamDefaultsHolder, MDFXLSettings, MDFXLSub, "weaponOrder", update_PlayerArmamentMaterialParams_MHWS, ui.colors.orange)

        imgui.text_colored(ui.draw_line("=", 95) ..  " // Palico: Armor // ", func.convert_rgba_to_ABGR(ui.colors.cyan))
        setup_MDFXLEditorGUI_MHWS(MDFXL, materialParamDefaultsHolder, MDFXLSettings, MDFXLSub, "otomoOrder", update_OtomoEquipmentMaterialParams_MHWS, ui.colors.cyan)

        imgui.text_colored(ui.draw_line("=", 95) ..  " // Palico: Weapon // ", func.convert_rgba_to_ABGR(ui.colors.cerulean))
        setup_MDFXLEditorGUI_MHWS(MDFXL, materialParamDefaultsHolder, MDFXLSettings, MDFXLSub, "otomoWeaponOrder", update_OtomoArmamentMaterialParams_MHWS, ui.colors.cerulean)

        imgui.text_colored(ui.draw_line("=", 95) ..  " // Seikret // ", func.convert_rgba_to_ABGR(ui.colors.lime))
        setup_MDFXLEditorGUI_MHWS(MDFXL, materialParamDefaultsHolder, MDFXLSettings, MDFXLSub, "porterOrder", update_PorterMaterialParams_MHWS, ui.colors.lime)

        imgui.indent(-10)
        imgui.text_colored("[ " .. ui.draw_line("=", 150)  .. " ]", func.convert_rgba_to_ABGR(ui.colors.white))
        imgui.end_rect()
        imgui.end_window()
    end
end
local function draw_MDFXLPresetGUI_MHWS()
    imgui.text_colored(ui.draw_line("-", 120), func.convert_rgba_to_ABGR(ui.colors.white))
    
    if MDFXLSettings.presetManager.showOutfitPreset then
        imgui.indent(10)
        imgui.push_item_width(400); imgui.push_id(10)
        changed, outfitPresetSearchQuery = imgui.input_text("", outfitPresetSearchQuery); wc = wc or changed
        imgui.pop_id(); imgui.pop_item_width(); imgui.same_line()
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
        imgui.push_item_width(450)
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
        imgui.push_item_width(390)
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
    imgui.text_colored(ui.draw_line("-", 120), func.convert_rgba_to_ABGR(ui.colors.white))
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
                changed, MDFXLSettings.isInheritPresetName = imgui.checkbox("Inherit Preset Name", MDFXLSettings.isInheritPresetName); wc = wc or changed
                func.tooltip("When enabled, the '[Enter Preset Name Here]' text in the Editor will be replaced by the name of the last loaded preset.")
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
                imgui.tree_pop()
            end
            if imgui.tree_node("Preset Manager Settings") then
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
                imgui.push_item_width(200)
                changed, MDFXLSettings.presetManager.authorButtonsPerLine = imgui.drag_int("Author Names Per Line", MDFXLSettings.presetManager.authorButtonsPerLine, 1, 1, 100); wc = wc or changed
                changed, MDFXLSettings.presetManager.tagButtonsPerLine = imgui.drag_int("Tags Per Line", MDFXLSettings.presetManager.tagButtonsPerLine, 1, 1, 100); wc = wc or changed
                imgui.pop_item_width()
                imgui.tree_pop()
            end
            if imgui.tree_node("Hotkeys") then
                imgui.text_colored(ui.draw_line("-", 50), func.convert_rgba_to_ABGR(ui.colors.white50))
                
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
                changed = hk.hotkey_setter("Clear Outfit Search", MDFXLSettings.useModifier and "Modifier"); wc = wc or changed

                imgui.spacing()

                imgui.push_id(2)
                changed, MDFXLSettings.useModifier2 = imgui.checkbox("", MDFXLSettings.useModifier2); wc = wc or changed
                func.tooltip("Require that you hold down this button")
                imgui.same_line()
                changed = hk.hotkey_setter("Secondary Modifier"); wc = wc or changed
                imgui.pop_id()
                changed = hk.hotkey_setter("Toggle Case Sensitive Search", MDFXLSettings.useModifier2 and "Secondary Modifier"); wc = wc or changed
                
                imgui.text_colored(ui.draw_line("-", 50), func.convert_rgba_to_ABGR(ui.colors.white50))
                imgui.push_id(3)
                changed, MDFXLSettings.useOutfitModifier = imgui.checkbox("", MDFXLSettings.useOutfitModifier); wc = wc or changed
                func.tooltip("Require that you hold down this button")
                imgui.same_line()
                changed = hk.hotkey_setter("Outfit Change Modifier"); wc = wc or changed
                imgui.pop_id()
                changed = hk.hotkey_setter("Outfit Previous", MDFXLSettings.useOutfitModifier and "Outfit Change Modifier"); wc = wc or changed
                changed = hk.hotkey_setter("Outfit Next", MDFXLSettings.useOutfitModifier and "Outfit Change Modifier"); wc = wc or changed
                
                imgui.spacing()

                imgui.push_id(4)
                changed, MDFXLSettings.useOutfitPadModifier = imgui.checkbox("", MDFXLSettings.useOutfitPadModifier); wc = wc or changed
                func.tooltip("Require that you hold down this button")
                imgui.same_line()
                changed = hk.hotkey_setter("Outfit Change Pad Modifier"); wc = wc or changed
                imgui.pop_id()
                changed = hk.hotkey_setter("Outfit Pad Previous", MDFXLSettings.useOutfitPadModifier and "Outfit Change Pad Modifier"); wc = wc or changed
                changed = hk.hotkey_setter("Outfit Pad Next", MDFXLSettings.useOutfitPadModifier and "Outfit Change Pad Modifier"); wc = wc or changed
                imgui.text_colored(ui.draw_line("-", 50), func.convert_rgba_to_ABGR(ui.colors.white50))
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
