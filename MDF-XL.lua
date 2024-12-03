--/////////////////////////////////////--
local modName =  "MDF-XL"

local modAuthor = "SilverEzredes"
local modUpdated = "12/02/2024"
local modVersion = "v1.4.02"
local modCredits = "alphaZomega; praydog"

--/////////////////////////////////////--
local func = require("_SharedCore/Functions")
local ui = require("_SharedCore/Imgui")
local hk = require("Hotkeys/Hotkeys")

local changed = false
local wc = false
local lastTime = 0.0
local tickInterval = 0.0
local autoSaveProgress = 0
local wasEditorShown = false

local playerManager = sdk.get_managed_singleton("app.PlayerManager")
local otomoManager = sdk.get_managed_singleton("app.OtomoManager")
local porterManager = sdk.get_managed_singleton("app.PorterManager")
local renderComp = "via.render.Mesh"
local texResource = "via.render.TextureResource"
local entityComp = "app.PlayerEntityManager"
local GUI010000 = nil
local GUI080001 = nil
local GUI090000 = nil
local masterPlayer = nil
local masterOtomo = nil
local masterPorter = nil
local isPlayerInScene = false
local isOtomoInScene = false
local isPorterInScene = false
local isDefaultsDumped = false
local isUpdaterBypass = false
local isNowLoading = false
local isLoadingScreenUpdater = false
local isAutoSaved = false
local isPlayerLeftEquipmentMenu = false
local isPlayerOpenEquipmentMenu = false
local isPlayerLeftCamp = false
local isAppearanceEditorOpen = false
local isAppearanceEditorUpdater = false
local isOutfitManagerBypass = false
local isMDFXL = false
local MDFXL_MaterialParamDefaultsHolder = {}
local MDFXL_MaterialEditorParamHolder = {}
local MDFXL_MaterialEditorSubParamFloatHolder = nil
local MDFXL_MaterialEditorSubParamFloat4Holder = nil
local MDFXL_TextureEditorStringHolder = nil
local presetName = "[Enter Preset Name Here]"
local paletteName = "[Enter Palette Name Here]"
local outfitName = "[Enter Outfit Name Here]"
local searchQuery = ""
local presetSearchQuery = ""
local textureSearchQuery = ""
local lastMatParamName = ""

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
    showPresetPath = false,
    showPresetVersion = true,
    showMeshPath = true,
    showMDFPath = true,
    showConsole = false,
    isAutoSave = true,
    showAutoSaveProgressBar = true,
    autoSaveInterval = 5.0,
    isSearchMatchCase = false,
    isFilterFavorites = false,
    isInheritPresetName = true,
    consoleErrorText = "",
    consoleWarningText = "",
    version = modVersion,
    presetVersion = "v1.00-Demo",
    presetManager = {
        showOutfitPreset = true,
        showHunterEquipment = true,
        showHunterArmament = true,
        showOtomoEquipment = true,
        showOtomoArmament = true,
        showPorter = true,
        showEquipmentName = true,
        showEquipmentType = true,
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
local MDFXLConsole = {
    errors = {
        [000] = "[ERROR-000]\nCould not load material data from the selected preset.\nThe material count or names in the preset do not match those of the selected equipment. ",
    },
    warnings = {
        [100] = "[WARNING-100]\nPreset Version is outdated.",
    },
}
local MDFXLDatabase = {
    MHWS = {},
}
MDFXLDatabase.MHWS = require("MDF-XLCore/MHWS_Database")
local MDFXL = hk.merge_tables({}, MDFXL_Master) and hk.recurse_def_settings(json.load_file("MDF-XL/_Holders/MDF-XL_EquipmentData.json") or {}, MDFXL_Master)
local MDFXLSub = hk.merge_tables({}, MDFXL_Sub) and hk.recurse_def_settings(json.load_file("MDF-XL/_Holders/MDF-XL_SubData.json") or {}, MDFXL_Sub)
local MDFXLPresetTracker = hk.merge_tables({}, MDFXL_PresetTracker) and hk.recurse_def_settings(json.load_file("MDF-XL/_Holders/MDF-XL_PresetTracker.json") or {}, MDFXL_PresetTracker)
local MDFXLSettings = hk.merge_tables({}, MDFXL_DefaultSettings) and hk.recurse_def_settings(json.load_file("MDF-XL/_Settings/MDF-XL_Settings.json") or {}, MDFXL_DefaultSettings)
local MDFXLPalettes = hk.merge_tables({}, MDFXL_ColorPalettes) and hk.recurse_def_settings(json.load_file("MDF-XL/_Settings/MDF-XL_ColorPalettesSettings.json") or {}, MDFXL_ColorPalettes)
local MDFXLOutfits = hk.merge_tables({}, MDFXL_OutfitManager) and hk.recurse_def_settings(json.load_file("MDF-XL/_Settings/MDF-XL_OutfitManagerSettings.json") or {}, MDFXL_OutfitManager)
hk.setup_hotkeys(MDFXLSettings.hotkeys)
--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////--
--MARK: MHWilds
--Generic getters and checks
local function get_PlayerManager_MHWS()
    if playerManager == nil then playerManager = sdk.get_managed_singleton("app.PlayerManager") end
	return playerManager
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
    
    if playerManager then
        masterPlayer = playerManager:getMasterPlayer()
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
    sdk.hook(sdk.find_type_definition("app.GUI090001"):get_method("onClose()"),
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
            if func.table_contains(MDFXL_Cache.AppearanceMenu, currentMenu) and isAppearanceEditorOpen then
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
    MDFXLData[entry].isUpdated = false
end
local function get_MaterialParams(gameObject, dataTable, entry, subDataTable, order)
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
        for matName, _ in pairs(dataTable[entry].Materials) do
            local found = false
            for j = 0, matCount - 1 do
                if matName == renderMesh:getMaterialName(j) then
                    found = true
                    break
                end
            end
            if not found then
                dataTable[entry].Materials[matName] = nil
            end
        end
        local newPartNames = {}
        for j = 0, matCount - 1 do
            local matName = renderMesh:getMaterialName(j)
            if matName then
                table.insert(newPartNames, matName)
            end
        end
        for partIDX, partName in ipairs(dataTable[entry].Parts) do
            if not func.table_contains(newPartNames, partName) then
                table.remove(dataTable[entry].Parts, partIDX)
                table.remove(dataTable[entry].Enabled, partIDX)
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
                                        if not func.table_contains(dataTable[entry].Materials[matName][matParamNames], matTypeFloat) then
                                            table.insert(dataTable[entry].Materials[matName][matParamNames], matTypeFloat)
                                        end
                                    elseif matType == 4 then
                                        local matTypeFloat4 = renderMesh:getMaterialFloat4(j, k)
                                        local matTypeFloat4New = {matTypeFloat4.x, matTypeFloat4.y, matTypeFloat4.z, matTypeFloat4.w}
                                        local contains = false
                                        for _, value in ipairs(dataTable[entry].Materials[matName][matParamNames]) do
                                            if #value == 4 then
                                                value[1] = matTypeFloat4New[1]
                                                value[2] = matTypeFloat4New[2]
                                                value[3] = matTypeFloat4New[3]
                                                value[4] = matTypeFloat4New[4]
                                                contains = true
                                                break
                                            end
                                        end
                                    
                                        if not contains then
                                            table.insert(dataTable[entry].Materials[matName][matParamNames], matTypeFloat4New)
                                        end
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
                get_MaterialParams(currentEquipmentID, MDFXLData, playerEquipment, MDFXLSubData, "order")
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
                                
                                get_MaterialParams(currentWeaponID, MDFXLData, playerWeapon, MDFXLSubData, "weaponOrder")
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
                
                get_MaterialParams(weaponInsect, MDFXLData, weaponInsectName, MDFXLSubData, "weaponOrder")
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
                
                get_MaterialParams(currentEquipmentID, MDFXLData, otomoEquipment, MDFXLSubData, "otomoOrder")
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
                get_MaterialParams(otomoWeapon, MDFXLData, otomoWeaponID, MDFXLSubData, "otomoWeaponOrder")
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

                        get_MaterialParams(currentEquipmentID, MDFXLData, nativesMesh, MDFXLSubData, "porterOrder")
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
        if (equipment and equipment.isInScene and not isDefaultsDumped) or (isPlayerLeftEquipmentMenu and #equipment.Presets == 0) or (isPlayerLeftCamp and #equipment.Presets == 0) then
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
                MDFXLSubData.jsonPaths[cacheKey] =  fs.glob(path)
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
                            log.info("[MDF-XL] [Loaded " .. filepath .. " for "  .. equipment.MeshName .. "]")
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
                            log.info("[MDF-XL] [Removed " .. name .. " from " ..equipment.MeshName .. "]")
                        end
                        table.remove(json_names, i)
                    end
                end
            else
                if MDFXLSettings.isDebug then
                    log.info("[MDF-XL] [No MDF-XL JSON files found.]")
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
                    if MDFXLSettings.isDEBUG then
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
                    if MDFXLSettings.isDEBUG then
                        log.info("[MDF-XL-JSON] [Removed " .. name .. " from MDF-XL Color Palettes]")
                    end
                    table.remove(json_names, i)
                end
            end
        else
            if MDFXLSettings.isDEBUG then
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
                    if MDFXLSettings.isDEBUG then
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
                    if MDFXLSettings.isDEBUG then
                        log.info("[MDF-XL-JSON] [Removed " .. name .. " from MDF-XL Outfit Manager]")
                    end
                    table.remove(json_names, i)
                end
            end
        else
            if MDFXLSettings.isDEBUG then
                log.info("[MDF-XL-JSON] [No MDF-XL Outfit Manager JSON files found]")
            end
        end
    end
end
--Material Param Setters
local function set_MaterialParams(gameObject, dataTable, entry)
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
                        local textureResource = func.create_resource(texResource, dataTable[entry.MeshName].Textures[matName][textureName])
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
                    set_MaterialParams(currentEquipmentID, MDFXLData, equipment)
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
                                    set_MaterialParams(currentWeaponID, MDFXLData, weapon)
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
                        set_MaterialParams(weaponInsect, MDFXLData, weapon)
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
                    set_MaterialParams(currentEquipmentID, MDFXLData, equipment)
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
                        set_MaterialParams(otomoWeapon, MDFXLData, weapon)
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
                local patterns = {"Saddle[^@]+", "Body[^@]+"}
        
                for j, pattern in ipairs(patterns) do
                    local porterEquipment = childStrings:match(pattern)
                    
                    if porterEquipment then
                        local currentEquipment = porterTransforms:find(porterEquipment)
                        local currentEquipmentID = currentEquipment:get_GameObject()
                        local renderMesh = func.get_GameObjectComponent(currentEquipmentID, renderComp)
        
                        if renderMesh then
                            local nativesMesh = renderMesh:getMesh():ToString()
                            nativesMesh = nativesMesh and nativesMesh:match(MDFXL_Cache.matchMesh)

                            if nativesMesh == equipment.MeshName then
                                set_MaterialParams(currentEquipmentID, MDFXLData, equipment)
                            end
                        end
                    end
                end
            end
        end
    end
end
--Master Functions
local function manage_MasterMaterialData_MHWS(MDFXLData, MDFXLSubData)
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
        dump_DefaultMaterialParamJSON_MHWS(MDFXLData)
        clear_MDFXLJSONCache_MHWS(MDFXLData, MDFXLSubData)
        cache_MDFXLJSONFiles_MHWS(MDFXLData, MDFXLSubData)
        json.dump_file("MDF-XL/_Settings/MDF-XL_Settings.json", MDFXLSettings)
        json.dump_file("MDF-XL/_Holders/MDF-XL_EquipmentData.json", MDFXLData)
        json.dump_file("MDF-XL/_Holders/MDF-XL_SubData.json", MDFXLSubData)
        MDFXL_MaterialParamDefaultsHolder = func.deepcopy(MDFXLData)

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
                            MDFXLSettings.consoleWarningText = MDFXLConsole.warnings[100] .. "\n" .. equipment.MeshName .. " | " .. selected_preset
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
        clear_MDFXLJSONCache_MHWS(MDFXLData, MDFXLSubData)
        cache_MDFXLJSONFiles_MHWS(MDFXLData, MDFXLSubData)
        json.dump_file("MDF-XL/_Settings/MDF-XL_Settings.json", MDFXLSettings)
        json.dump_file("MDF-XL/_Holders/MDF-XL_EquipmentData.json", MDFXLData)
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
                            MDFXLSettings.consoleWarningText = MDFXLConsole.warnings[100] .. "\n" .. equipment.MeshName .. " | " .. selected_preset
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
        dump_DefaultMaterialParamJSON_MHWS(MDFXLData)
        clear_MDFXLJSONCache_MHWS(MDFXLData, MDFXLSubData)
        cache_MDFXLJSONFiles_MHWS(MDFXLData, MDFXLSubData)
        json.dump_file("MDF-XL/_Holders/MDF-XL_EquipmentData.json", MDFXLData)
        json.dump_file("MDF-XL/_Holders/MDF-XL_SubData.json", MDFXLSubData)

        for _, equipment in pairs(MDFXLData) do
            if not func.table_contains(MDFXL_MaterialParamDefaultsHolder, MDFXLData[equipment.MeshName]) then
                MDFXL_MaterialParamDefaultsHolder[equipment.MeshName] = func.deepcopy(MDFXLData[equipment.MeshName])
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
                        MDFXLSettings.consoleWarningText = MDFXLConsole.warnings[100] .. "\n" .. equipment.MeshName .. " | " .. selected_preset
                    end
                end
            elseif selected_preset == nil or {} then
                MDFXLData[equipment.MeshName].currentPresetIDX = 1
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
        clear_MDFXLJSONCache_MHWS(MDFXLData, MDFXLSubData)
        cache_MDFXLJSONFiles_MHWS(MDFXLData, MDFXLSubData)
        json.dump_file("MDF-XL/_Holders/MDF-XL_EquipmentData.json", MDFXLData)
        json.dump_file("MDF-XL/_Holders/MDF-XL_SubData.json", MDFXLSubData)

        for _, equipment in pairs(MDFXLData) do
            if not func.table_contains(MDFXL_MaterialParamDefaultsHolder, MDFXLData[equipment.MeshName]) then
                MDFXL_MaterialParamDefaultsHolder[equipment.MeshName] = func.deepcopy(MDFXLData[equipment.MeshName])
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
                        MDFXLSettings.consoleWarningText = MDFXLConsole.warnings[100] .. "\n" .. equipment.MeshName .. " | " .. selected_preset
                    end
                end
            elseif selected_preset == nil or {} then
                MDFXLData[equipment.MeshName].currentPresetIDX = 1
            end
        end
        json.dump_file("MDF-XL/_Holders/MDF-XL_PresetTracker.json", MDFXLPresetTracker)
        log.info("[MDF-XL] [Player left the Appearance Menu, MDF-XL data updated.]")
        isAppearanceEditorUpdater = false
    end
    --Camp Menu Updater
    if isPlayerLeftCamp and isDefaultsDumped and isPlayerInScene then
        get_PorterMaterialParams_MHWS(MDFXLData, MDFXLSubData)
        dump_DefaultMaterialParamJSON_MHWS(MDFXLData)
        clear_MDFXLJSONCache_MHWS(MDFXLData, MDFXLSubData)
        cache_MDFXLJSONFiles_MHWS(MDFXLData, MDFXLSubData)
        json.dump_file("MDF-XL/_Holders/MDF-XL_EquipmentData.json", MDFXLData)
        json.dump_file("MDF-XL/_Holders/MDF-XL_SubData.json", MDFXLSubData)

        for _, equipment in pairs(MDFXLData) do
            if not func.table_contains(MDFXL_MaterialParamDefaultsHolder, MDFXLData[equipment.MeshName]) then
                MDFXL_MaterialParamDefaultsHolder[equipment.MeshName] = func.deepcopy(MDFXLData[equipment.MeshName])
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
                        MDFXLSettings.consoleWarningText = MDFXLConsole.warnings[100] .. "\n" .. equipment.MeshName .. " | " .. selected_preset
                    end
                end
            elseif selected_preset == nil or {} then
                MDFXLData[equipment.MeshName].currentPresetIDX = 1
            end
        end
        json.dump_file("MDF-XL/_Holders/MDF-XL_PresetTracker.json", MDFXLPresetTracker)
        log.info("[MDF-XL] [Player left the Camp Menu, MDF-XL data updated.]")
        isPlayerLeftCamp = false
    end
    --Outfit Preset Updater
    if isOutfitManagerBypass then
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
                        MDFXLSettings.consoleWarningText = MDFXLConsole.warnings[100] .. "\n" .. equipment.MeshName .. " | " .. selected_preset
                    end
                end
            elseif selected_preset == nil or {} then
                MDFXLData[equipment.MeshName].currentPresetIDX = 1
            end
            
        end
        json.dump_file("MDF-XL/_Holders/MDF-XL_EquipmentData.json", MDFXLData)
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
        presetSearchQuery = ""
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
                
                imgui.text_colored("  " .. ui.draw_line("=", 130) .."  ", func.convert_rgba_to_AGBR(ui.colors.white))
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
                    ui.textButton_ColoredValue("Mesh Name:", entry.MeshName, func.convert_rgba_to_AGBR(ui.colors.gold))
                end

                if MDFXLSettingsData.showMaterialCount then
                    imgui.same_line()
                    ui.textButton_ColoredValue("Material Count:", #entry.Parts, func.convert_rgba_to_AGBR(ui.colors.cerulean))
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
    
                            for _, part in ipairs(temp_parts.Parts) do
                                log.info("[MDF-XL] [Preset Part Name: " .. part .. " ]")
                            end
                            for _, part in ipairs(MDFXLData[entry.MeshName].Parts) do
                                log.info("[MDF-XL] [Original Part Name: " .. part .. " ]")
                            end
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
                            MDFXLSettingsData.consoleErrorText = MDFXLConsole.errors[000] .. "\n" .. entry.MeshName .. " | " .. selected_preset
                        end
                        if temp_parts.presetVersion ~= MDFXLSettingsData.presetVersion then
                            log.info("[MDF-XL] [WARNING-000] [" .. entry.MeshName .. " Preset Version is outdated.]")
                            MDFXLSettingsData.consoleWarningText = MDFXLConsole.warnings[100] .. "\n" .. entry.MeshName .. " | " .. selected_preset
                        end
                    end

                    if MDFXLSettingsData.isInheritPresetName then
                        presetName = selected_preset
                    end
                    MDFXLPresetTracker[entry.MeshName].lastPresetName = selected_preset
                    isUpdaterBypass = true
                    updateFunc(MDFXLData)
                    json.dump_file("MDF-XL/_Holders/MDF-XL_EquipmentData.json", MDFXLData)
                    json.dump_file("MDF-XL/_Holders/MDF-XL_PresetTracker.json", MDFXLPresetTracker)
                end

                imgui.push_id(_)
                changed, presetName = imgui.input_text("", presetName); wc = wc or changed
                imgui.pop_id()
                imgui.same_line()
                if imgui.button("Save Preset") then
                    json.dump_file("MDF-XL/Equipment/".. entry.MeshName .. "/" .. presetName .. ".json", MDFXLData[entry.MeshName])
                    log.info("[MDF-XL] [Preset with the name: " .. presetName .. " saved for " ..  entry.MeshName .. ".]")
                    MDFXLData[entry.MeshName].isUpdated = true
                    clear_MDFXLJSONCache_MHWS(MDFXLData, MDFXLSubData)
                    cache_MDFXLJSONFiles_MHWS(MDFXLData, MDFXLSubData)
                    json.dump_file("MDF-XL/_Holders/MDF-XL_SubData.json", MDFXLSubData)
                end
                func.tooltip("Save the current parameters of the " ..  entry.MeshName .. " to " .. presetName .. ".json found in [MonsterHunterWilds/reframework/data/MDF-XL/Equipment/"..  entry.MeshName .. "]")

                imgui.spacing()

                if MDFXLSettingsData.showPresetPath and #MDFXLData[entry.MeshName].Parts > 0 then
                    imgui.input_text("Preset Path", "MonsterHunterWilds/reframework/data/MDF-XL/Equipment/".. entry.MeshName .. "/" .. presetName .. ".json")
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
                    imgui.text_colored(ui.draw_line("=", 100), func.convert_rgba_to_AGBR(ui.colors.gold))
                    imgui.indent(15)

                    for i, partName in ipairs(MDFXLData[entry.MeshName].Parts) do
                        local enabledMeshPart =  MDFXLData[entry.MeshName].Enabled[i]
                        local defaultEnabledMeshPart = MDFXLDefaultsData[entry.MeshName].Enabled[i]
        
                        if enabledMeshPart == defaultEnabledMeshPart or enabledMeshPart ~= defaultEnabledMeshPart then
                            changed, enabledMeshPart = imgui.checkbox(partName, enabledMeshPart); wc = wc or changed
                            MDFXLData[entry.MeshName].Enabled[i] = enabledMeshPart
                            if enabledMeshPart ~= defaultEnabledMeshPart then
                                imgui.same_line()
                                imgui.text_colored("*", func.convert_rgba_to_AGBR(ui.colors.cerulean))
                            end
                        end
                    end
                    imgui.text_colored(ui.draw_line("-", 75), func.convert_rgba_to_AGBR(ui.colors.gold))
                    if imgui.tree_node("Flags") then
                        if MDFXLData[entry.MeshName].Flags.isForceTwoSide == MDFXLDefaultsData[entry.MeshName].Flags.isForceTwoSide or MDFXLData[entry.MeshName].Flags.isForceTwoSide ~= MDFXLDefaultsData[entry.MeshName].Flags.isForceTwoSide then
                            changed, MDFXLData[entry.MeshName].Flags.isForceTwoSide = imgui.checkbox("Force Two Side", MDFXLData[entry.MeshName].Flags.isForceTwoSide); wc = wc or changed
                            if MDFXLData[entry.MeshName].Flags.isForceTwoSide ~= MDFXLDefaultsData[entry.MeshName].Flags.isForceTwoSide then
                                imgui.same_line()
                                imgui.text_colored("*", func.convert_rgba_to_AGBR(ui.colors.cerulean))
                            end
                        end
                        if MDFXLData[entry.MeshName].Flags.isBeautyMask == MDFXLDefaultsData[entry.MeshName].Flags.isBeautyMask or MDFXLData[entry.MeshName].Flags.isBeautyMask ~= MDFXLDefaultsData[entry.MeshName].Flags.isBeautyMask then
                            changed, MDFXLData[entry.MeshName].Flags.isBeautyMask = imgui.checkbox("Beauty Mask", MDFXLData[entry.MeshName].Flags.isBeautyMask); wc = wc or changed
                            if MDFXLData[entry.MeshName].Flags.isBeautyMask ~= MDFXLDefaultsData[entry.MeshName].Flags.isBeautyMask then
                                imgui.same_line()
                                imgui.text_colored("*", func.convert_rgba_to_AGBR(ui.colors.cerulean))
                            end
                        end
                        if MDFXLData[entry.MeshName].Flags.isReceiveSSSSS == MDFXLDefaultsData[entry.MeshName].Flags.isReceiveSSSSS or MDFXLData[entry.MeshName].Flags.isReceiveSSSSS ~= MDFXLDefaultsData[entry.MeshName].Flags.isReceiveSSSSS then
                            changed, MDFXLData[entry.MeshName].Flags.isReceiveSSSSS = imgui.checkbox("Receive SSSSS Flag", MDFXLData[entry.MeshName].Flags.isReceiveSSSSS); wc = wc or changed
                            if MDFXLData[entry.MeshName].Flags.isReceiveSSSSS ~= MDFXLDefaultsData[entry.MeshName].Flags.isReceiveSSSSS then
                                imgui.same_line()
                                imgui.text_colored("*", func.convert_rgba_to_AGBR(ui.colors.cerulean))
                            end
                        end
                        imgui.tree_pop()
                    end
                    imgui.indent(-15)
                    imgui.text_colored(ui.draw_line("=", 100), func.convert_rgba_to_AGBR(ui.colors.gold))
                    imgui.tree_pop()
                end
                
                if imgui.tree_node("Material Editor") then
                    imgui.spacing()
                    imgui.text_colored(ui.draw_line("=", 100), func.convert_rgba_to_AGBR(ui.colors.cerulean))
                    changed, searchQuery = imgui.input_text("Param Search", searchQuery); wc = wc or changed
                    ui.button_CheckboxStyle("[ Aa ]", MDFXLSettings, "isSearchMatchCase", func.convert_rgba_to_AGBR(ui.colors.REFgray), func.convert_rgba_to_AGBR(ui.colors.gold), func.convert_rgba_to_AGBR(ui.colors.gold))
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
                        ui.textButton_ColoredValue("", favCount .. " ", func.convert_rgba_to_AGBR(ui.colors.gold))
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
                                    MDFXL_MaterialEditorParamHolder = func.deepcopy(MDFXLData[entry.MeshName].Materials[matName])
                                    wc = true
                                end
                                if imgui.menu_item("Paste") then
                                    local copiedParams = MDFXL_MaterialEditorParamHolder
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
                                ui.textButton_ColoredValue("Parameter Count:", entry.MaterialParamCount[matName], func.convert_rgba_to_AGBR(ui.colors.cerulean))
                            end
                            if MDFXLSettingsData.showTextureCount then
                                imgui.same_line()
                                ui.textButton_ColoredValue("Texture Count:", entry.TextureCount[matName], func.convert_rgba_to_AGBR(ui.colors.cerulean))
                            end
                            
                            if entry.TextureCount[matName] ~= 0 then
                                if imgui.tree_node("Textures") then
                                    imgui.text_colored(ui.draw_line("=", 115), func.convert_rgba_to_AGBR(ui.colors.cerulean))

                                    changed, textureSearchQuery = imgui.input_text("Texture Search", textureSearchQuery); wc = wc or changed
                                    ui.button_CheckboxStyle("[ Aa ]", MDFXLSettings, "isSearchMatchCase", func.convert_rgba_to_AGBR(ui.colors.REFgray), func.convert_rgba_to_AGBR(ui.colors.gold), func.convert_rgba_to_AGBR(ui.colors.gold))
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
                                                MDFXL_TextureEditorStringHolder = MDFXLData[entry.MeshName].Textures[matName][texName]
                                                    wc = true
                                                end
                                                if MDFXL_TextureEditorStringHolder ~= nil then
                                                    if imgui.menu_item("Paste") then
                                                        MDFXLData[entry.MeshName].Textures[matName][texName] = MDFXL_TextureEditorStringHolder
                                                        wc = true
                                                    end
                                                end
                                                imgui.end_popup()
                                            end
                                            if currentData ~= originalData then
                                                imgui.same_line()
                                                imgui.text_colored("*", func.convert_rgba_to_AGBR(ui.colors.cerulean))
                                                imgui.push_style_color(ui.imguiStyle.text, func.convert_rgba_to_AGBR(ui.colors.cerulean))
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
                                    imgui.text_colored(ui.draw_line("=", 115), func.convert_rgba_to_AGBR(ui.colors.cerulean))
                                    imgui.tree_pop()
                                end
                                imgui.text_colored(ui.draw_line("-", 75), func.convert_rgba_to_AGBR(ui.colors.cerulean))
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
                                        imgui.push_style_color(ui.imguiStyle.rectangleFrame, func.convert_rgba_to_AGBR(ui.colors.gold))
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
                                                    MDFXL_MaterialEditorSubParamFloat4Holder = paramValue[1]
                                                    MDFXL_MaterialEditorSubParamFloatHolder = nil
                                                else
                                                    MDFXL_MaterialEditorSubParamFloat4Holder = nil
                                                    MDFXL_MaterialEditorSubParamFloatHolder = paramValue[1]
                                                end
                                                wc = true
                                            end
                                            if imgui.menu_item("Paste") then
                                                wc = true
                                                if type(paramValue[1]) == "table" then
                                                    if MDFXL_MaterialEditorSubParamFloat4Holder ~= nil then
                                                        paramValue[1] = MDFXL_MaterialEditorSubParamFloat4Holder
                                                    end
                                                else
                                                    if MDFXL_MaterialEditorSubParamFloatHolder ~= nil then
                                                        paramValue[1] = MDFXL_MaterialEditorSubParamFloatHolder
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
                                            imgui.text_colored("*", func.convert_rgba_to_AGBR(ui.colors.gold))
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
                                                    MDFXL_MaterialEditorSubParamFloat4Holder = paramValue[1]
                                                    MDFXL_MaterialEditorSubParamFloatHolder = nil
                                                else
                                                    MDFXL_MaterialEditorSubParamFloat4Holder = nil
                                                    MDFXL_MaterialEditorSubParamFloatHolder = paramValue[1]
                                                end
                                                wc = true
                                            end
                                            if imgui.menu_item("Paste") then
                                                wc = true
                                                if type(paramValue[1]) == "table" then
                                                    if MDFXL_MaterialEditorSubParamFloat4Holder ~= nil then
                                                        paramValue[1] = MDFXL_MaterialEditorSubParamFloat4Holder
                                                    end
                                                else
                                                    if MDFXL_MaterialEditorSubParamFloatHolder ~= nil then
                                                        paramValue[1] = MDFXL_MaterialEditorSubParamFloatHolder
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
                                            imgui.text_colored("*", func.convert_rgba_to_AGBR(ui.colors.gold))
                                        end
                                        imgui.same_line()
                                        imgui.text_colored("*", func.convert_rgba_to_AGBR(ui.colors.cerulean))
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
                    imgui.text_colored(ui.draw_line("=", 100), func.convert_rgba_to_AGBR(ui.colors.cerulean))
                    imgui.tree_pop()
                end

                if changed or wc then
                    MDFXLData[entry.MeshName].isUpdated = true
                end
                imgui.indent(-10)
                imgui.text_colored("  " .. ui.draw_line("=", 130) .."  ", func.convert_rgba_to_AGBR(ui.colors.white))
                imgui.end_rect(); imgui.tree_pop()
            end
            imgui.text_colored("  " .. ui.draw_line("-", 150) .."  ", func.convert_rgba_to_AGBR(color01))
            imgui.indent(-15)
        end
    end
end
local function setup_MDFXLPresetGUI_MHWS(MDFXLData, MDFXLSettingsData, MDFXLSubData, order, updateFunc, displayText, color01, isDraw)
    if not isDraw then return end
    imgui.text_colored(ui.draw_line("=", 60) ..  " // " .. displayText .. " // ", func.convert_rgba_to_AGBR(color01))
    imgui.indent(10)
    for _, entryName in pairs(MDFXLSubData[order]) do
        local entry = MDFXLData[entryName]
        local displayName = nil
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
            if MDFXLPresetTracker[entry.MeshName].lastPresetName ~= entry.MeshName .. " Default" then
                imgui.push_style_color(ui.imguiStyle.rectangleFrame, func.convert_rgba_to_AGBR(color01))
                imgui.begin_rect(); imgui.push_item_width(450)
                changed, MDFXLData[entry.MeshName].currentPresetIDX = imgui.combo(displayName .. " ", MDFXLData[entry.MeshName].currentPresetIDX or 1, MDFXLData[entry.MeshName].Presets); wc = wc or changed
                imgui.end_rect(); imgui.pop_item_width()
                imgui.pop_style_color(1)
            else
                imgui.push_item_width(450)
                changed, MDFXLData[entry.MeshName].currentPresetIDX = imgui.combo(displayName .. " ", MDFXLData[entry.MeshName].currentPresetIDX or 1, MDFXLData[entry.MeshName].Presets); wc = wc or changed
                imgui.pop_item_width()
            end
            if changed then
                local selected_preset = MDFXLData[entry.MeshName].Presets[MDFXLData[entry.MeshName].currentPresetIDX]
                local json_filepath = [[MDF-XL\\Equipment\\]] ..entry.MeshName .. [[\\]] .. selected_preset .. [[.json]]
                local temp_parts = json.load_file(json_filepath)
                
                if temp_parts.Parts ~= nil then
                    if MDFXLSettingsData.isDebug then
                        log.info("[MDF-XL] [Preset Loader: " .. entry.MeshName .. " --- " .. #temp_parts.Parts .. " ]")

                        for _, part in ipairs(temp_parts.Parts) do
                            log.info("[MDF-XL] [Preset Part Name: " .. part .. " ]")
                        end
                        for _, part in ipairs(MDFXLData[entry.MeshName].Parts) do
                            log.info("[MDF-XL] [Original Part Name: " .. part .. " ]")
                        end
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
                        MDFXLSettingsData.consoleErrorText = MDFXLConsole.errors[000] .. "\n" .. entry.MeshName .. " | " .. selected_preset
                    end
                    if temp_parts.presetVersion ~= MDFXLSettingsData.presetVersion then
                        log.info("[MDF-XL] [WARNING-000] [" .. entry.MeshName .. " Preset Version is outdated.]")
                        MDFXLSettingsData.consoleWarningText = MDFXLConsole.warnings[100] .. "\n" .. entry.MeshName .. " | " .. selected_preset
                    end
                end

                if MDFXLSettingsData.isInheritPresetName then
                    presetName = selected_preset
                end
                if changed or wc then
                    MDFXLData[entry.MeshName].isUpdated = true
                end
                MDFXLPresetTracker[entry.MeshName].lastPresetName = selected_preset
                isUpdaterBypass = true
                updateFunc(MDFXLData)
                json.dump_file("MDF-XL/_Holders/MDF-XL_EquipmentData.json", MDFXLData)
                json.dump_file("MDF-XL/_Holders/MDF-XL_PresetTracker.json", MDFXLPresetTracker)
            end
        end
    end
    imgui.indent(-10)
end
local function draw_MDFXLOutfitManagerGUI_MHWS()
    if imgui.begin_window("MDF-XL: Outfit Manager") then
        imgui.begin_rect()
        imgui.text_colored("  [ " .. ui.draw_line("=", 80)  .. " ] ", func.convert_rgba_to_AGBR(ui.colors.white))
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
        imgui.text_colored("  [ " .. ui.draw_line("=", 80)  .. " ] ", func.convert_rgba_to_AGBR(ui.colors.white))
        imgui.end_rect(1)
        imgui.end_window()
    end
end
local function draw_MDFXLPaletteGUI_MHWS()
    if imgui.begin_window("MDF-XL: Color Palette Editor") then
        imgui.begin_rect()
        imgui.text_colored("  [ " .. ui.draw_line("=", 60)  .. " ] ", func.convert_rgba_to_AGBR(ui.colors.white))
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
        if MDFXL_MaterialEditorSubParamFloat4Holder ~= nil then
            if imgui.button("Add New Color from Clipboard") then
                table.insert(MDFXLPalettes.colors, {name = "Color " .. MDFXLPalettes.newColorIDX, value = {MDFXL_MaterialEditorSubParamFloat4Holder[1], MDFXL_MaterialEditorSubParamFloat4Holder[2], MDFXL_MaterialEditorSubParamFloat4Holder[3], MDFXL_MaterialEditorSubParamFloat4Holder[4]}})
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
                        MDFXL_MaterialEditorSubParamFloat4Holder = color.value
                        MDFXL_MaterialEditorSubParamFloatHolder = nil
                    end
                    wc = true
                end
                if MDFXL_MaterialEditorSubParamFloat4Holder ~= nil then
                    if imgui.menu_item("Paste") then
                        if type(color.value) == "table" then
                            color.value = MDFXL_MaterialEditorSubParamFloat4Holder
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
        imgui.text_colored("  [ " .. ui.draw_line("=", 60)  .. " ] ", func.convert_rgba_to_AGBR(ui.colors.white))
        imgui.end_rect(1)
        imgui.end_window()
    end
end
local function draw_MDFXLEditorGUI_MHWS()
    if imgui.begin_window("MDF-XL: Editor") then
        imgui.begin_rect()
        
        imgui.text_colored("  [ " .. ui.draw_line("=", 150)  .. " ] ", func.convert_rgba_to_AGBR(ui.colors.white))
        
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
            ui.textButton_ColoredValue("Preset Version :", MDFXLSettings.presetVersion, func.convert_rgba_to_AGBR(ui.colors.gold))
        end

        imgui.indent(-25)
        
        imgui.text_colored("  [ " .. ui.draw_line("=", 90) ..  " // Hunter: Armor // " .. ui.draw_line("=", 10) .. " ] ", func.convert_rgba_to_AGBR(ui.colors.gold))
        setup_MDFXLEditorGUI_MHWS(MDFXL, MDFXL_MaterialParamDefaultsHolder, MDFXLSettings, MDFXLSub, "order", update_PlayerEquipmentMaterialParams_MHWS, ui.colors.gold)

        imgui.text_colored("  [ " .. ui.draw_line("=", 90) ..  " // Hunter: Weapon // " .. ui.draw_line("=", 10) .. " ] ", func.convert_rgba_to_AGBR(ui.colors.orange))
        setup_MDFXLEditorGUI_MHWS(MDFXL, MDFXL_MaterialParamDefaultsHolder, MDFXLSettings, MDFXLSub, "weaponOrder", update_PlayerArmamentMaterialParams_MHWS, ui.colors.orange)

        imgui.text_colored("  [ " .. ui.draw_line("=", 90) ..  " // Palico: Armor // " .. ui.draw_line("=", 10) .. " ] ", func.convert_rgba_to_AGBR(ui.colors.cyan))
        setup_MDFXLEditorGUI_MHWS(MDFXL, MDFXL_MaterialParamDefaultsHolder, MDFXLSettings, MDFXLSub, "otomoOrder", update_OtomoEquipmentMaterialParams_MHWS, ui.colors.cyan)

        imgui.text_colored("  [ " .. ui.draw_line("=", 90) ..  " // Palico: Weapon // " .. ui.draw_line("=", 10) .. " ] ", func.convert_rgba_to_AGBR(ui.colors.cerulean))
        setup_MDFXLEditorGUI_MHWS(MDFXL, MDFXL_MaterialParamDefaultsHolder, MDFXLSettings, MDFXLSub, "otomoWeaponOrder", update_OtomoArmamentMaterialParams_MHWS, ui.colors.cerulean)

        imgui.text_colored("  [ " .. ui.draw_line("=", 90) ..  " // Seikret // " .. ui.draw_line("=", 10) .. " ] ", func.convert_rgba_to_AGBR(ui.colors.lime))
        setup_MDFXLEditorGUI_MHWS(MDFXL, MDFXL_MaterialParamDefaultsHolder, MDFXLSettings, MDFXLSub, "porterOrder", update_PorterMaterialParams_MHWS, ui.colors.lime)

        imgui.text_colored("  [ " .. ui.draw_line("=", 150)  .. " ] ", func.convert_rgba_to_AGBR(ui.colors.white))
        imgui.end_rect()
        imgui.end_window()
    end
end
local function draw_MDFXLPresetGUI_MHWS()
    imgui.text_colored(ui.draw_line("-", 120), func.convert_rgba_to_AGBR(ui.colors.white))
    
    if MDFXLSettings.presetManager.showOutfitPreset then
        imgui.indent(10)
        imgui.push_item_width(400); imgui.push_id(10)
        changed, presetSearchQuery = imgui.input_text("", presetSearchQuery); wc = wc or changed
        imgui.pop_id(); imgui.pop_item_width(); imgui.same_line()
        ui.button_CheckboxStyle("[ Aa ]", MDFXLSettings, "isSearchMatchCase", func.convert_rgba_to_AGBR(ui.colors.REFgray), func.convert_rgba_to_AGBR(ui.colors.gold), func.convert_rgba_to_AGBR(ui.colors.gold))
        func.tooltip("Match Case")
        imgui.same_line()
        imgui.text("Outfit Search")

        local filteredPresets = {}
        local currentOutfitPreset = MDFXLOutfits.Presets[MDFXLOutfits.currentOutfitPresetIDX]
        local filteredIDX = nil

        for _, preset in ipairs(MDFXLOutfits.Presets) do
            if presetSearchQuery == "" then
                table.insert(filteredPresets, preset)
            else
                local match
                if MDFXLSettings.isSearchMatchCase then
                    match = preset:find(presetSearchQuery, 1, true)
                else
                    match = preset:lower():find(presetSearchQuery:lower(), 1, true)
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
    setup_MDFXLPresetGUI_MHWS(MDFXL, MDFXLSettings, MDFXLSub, "order", update_PlayerEquipmentMaterialParams_MHWS, "Hunter: Armor", ui.colors.gold, MDFXLSettings.presetManager.showHunterEquipment)
    setup_MDFXLPresetGUI_MHWS(MDFXL, MDFXLSettings, MDFXLSub, "weaponOrder", update_PlayerArmamentMaterialParams_MHWS, "Hunter: Weapon", ui.colors.orange, MDFXLSettings.presetManager.showHunterArmament)
    setup_MDFXLPresetGUI_MHWS(MDFXL, MDFXLSettings, MDFXLSub, "otomoOrder", update_OtomoEquipmentMaterialParams_MHWS, "Palico: Armor", ui.colors.cyan, MDFXLSettings.presetManager.showOtomoEquipment)
    setup_MDFXLPresetGUI_MHWS(MDFXL, MDFXLSettings, MDFXLSub, "otomoWeaponOrder", update_OtomoArmamentMaterialParams_MHWS, "Palico: Weapon", ui.colors.cerulean, MDFXLSettings.presetManager.showOtomoArmament)
    setup_MDFXLPresetGUI_MHWS(MDFXL, MDFXLSettings, MDFXLSub, "porterOrder", update_PorterMaterialParams_MHWS, "Seikret", ui.colors.lime, MDFXLSettings.presetManager.showPorter)
    imgui.text_colored(ui.draw_line("-", 120), func.convert_rgba_to_AGBR(ui.colors.white))
end
local function load_MDFXLEditorAndPresetGUI_MHWS()
    changed, MDFXLSettings.showMDFXLEditor = imgui.checkbox("Open MDF-XL: Editor", MDFXLSettings.showMDFXLEditor); wc = wc or changed
    func.tooltip("Show/Hide the MDF-XL Editor.")
    if not MDFXLSettings.showMDFXLEditor or imgui.begin_window("MDF-XL: Editor", true, 0) == false  then
        MDFXLSettings.showMDFXLEditor = false
        lastMatParamName = ""
        if isAutoSaved then
            json.dump_file("MDF-XL/_Holders/MDF-XL_EquipmentData.json", MDFXL)
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
        imgui.push_style_color(ui.imguiStyle.progressBarForeground, func.convert_rgba_to_AGBR(ui.colors.gold))
        imgui.progress_bar(autoSaveProgress, Vector2f.new(150, 5))
        imgui.pop_style_color()
    end

    if MDFXLSettings.showConsole then
        imgui.begin_rect()
        imgui.text("[ MDF-XL: Console ] " .. ui.draw_line("-", 40))
        if imgui.button("Clear Log") then
            MDFXLSettings.consoleErrorText = ""
            MDFXLSettings.consoleWarningText = ""
        end
        imgui.indent(5)
        imgui.spacing()

        imgui.text_colored(MDFXLSettings.consoleErrorText, func.convert_rgba_to_AGBR(ui.colors.deepRed))
        imgui.text_colored(MDFXLSettings.consoleWarningText, func.convert_rgba_to_AGBR(ui.colors.safetyYellow))

        imgui.spacing()
        imgui.indent(-5)
        imgui.text(ui.draw_line("-", 68))
        imgui.end_rect(1)
    end

    draw_MDFXLPresetGUI_MHWS()
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
            
            imgui.spacing()

            changed, MDFXLSettings.isDebug = imgui.checkbox("Debug Mode", MDFXLSettings.isDebug); wc = wc or changed
            func.tooltip("Toggle Debug Mode. When enabled, MDF-XL will log significantly more information in the 're2_framework_log.txt' file, located in the game's root folder.\n It is recommended to leave this on.")
            changed, MDFXLSettings.showConsole = imgui.checkbox("Show Console", MDFXLSettings.showConsole); wc = wc or changed
            changed, MDFXLSettings.isAutoSave = imgui.checkbox("Auto-Save", MDFXLSettings.isAutoSave); wc = wc or changed
            func.tooltip("Toggle the Auto-Save feature. When enabled, MDF-XL will automatically save your current material parameters based on the Auto-Save Interval setting.\n It is recommended to leave this on.")
            if MDFXLSettings.isAutoSave then
                imgui.same_line()
                changed, MDFXLSettings.showAutoSaveProgressBar = imgui.checkbox("Show Auto-Save UI", MDFXLSettings.showAutoSaveProgressBar); wc = wc or changed
                imgui.push_item_width(250)
                changed, MDFXLSettings.autoSaveInterval = imgui.drag_float("Auto-Save Interval ", MDFXLSettings.autoSaveInterval, 0.1, 1.0, 120.0, "%.1f sec"); wc = wc or changed
                imgui.pop_item_width()
            end
            if imgui.tree_node("Editor Settings") then
                changed, MDFXLSettings.isInheritPresetName = imgui.checkbox("Inherit Preset Name", MDFXLSettings.isInheritPresetName); wc = wc or changed
                func.tooltip("If enabled the '[Enter Preset Name Here]' text in the MDF-XL: Editor will be replaced by the name of the last loaded preset.")
                changed, MDFXLSettings.showEquipmentName = imgui.checkbox("Show Equipment Name", MDFXLSettings.showEquipmentName); wc = wc or changed
                changed, MDFXLSettings.showMaterialCount = imgui.checkbox("Show Material Count", MDFXLSettings.showMaterialCount); wc = wc or changed
                changed, MDFXLSettings.showMaterialFavoritesCount = imgui.checkbox("Show Material Favorites Count", MDFXLSettings.showMaterialFavoritesCount); wc = wc or changed
                changed, MDFXLSettings.showMaterialParamCount = imgui.checkbox("Show Material Parameter Count", MDFXLSettings.showMaterialParamCount); wc = wc or changed
                changed, MDFXLSettings.showTextureCount = imgui.checkbox("Show Texture Count", MDFXLSettings.showTextureCount); wc = wc or changed
                changed, MDFXLSettings.showMeshName = imgui.checkbox("Show Mesh Name", MDFXLSettings.showMeshName); wc = wc or changed
                changed, MDFXLSettings.showMeshPath = imgui.checkbox("Show Mesh Path", MDFXLSettings.showMeshPath); wc = wc or changed
                changed, MDFXLSettings.showMDFPath = imgui.checkbox("Show MDF Path", MDFXLSettings.showMDFPath); wc = wc or changed
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
                changed, MDFXLSettings.presetManager.showEquipmentName = imgui.checkbox("Show Equipment Name", MDFXLSettings.presetManager.showEquipmentName); wc = wc or changed
                imgui.tree_pop()
            end
            if imgui.tree_node("Hotkeys") then
                imgui.text(ui.draw_line("-", 50))
                
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
                
                imgui.text(ui.draw_line("-", 50))
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
                imgui.text(ui.draw_line("-", 50))
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
            if imgui.tree_node("Credits") then
                imgui.indent(5)
                imgui.text(modCredits .. " ")
                imgui.unindent()
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
        imgui.text_colored(modVersion .. " | " .. modUpdated, func.convert_rgba_to_AGBR(ui.colors.gold)); imgui.same_line(); imgui.text("(c) " .. modAuthor .. " ")
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
                    json.dump_file("MDF-XL/_Holders/MDF-XL_EquipmentData.json", MDFXL)
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
                    json.dump_file("MDF-XL/_Holders/MDF-XL_EquipmentData.json", MDFXL)
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
    end
end
--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////--
--MARK:On Frame
re.on_frame(function ()
    if reframework.get_game_name() == "mhwilds" then
        update_MDFXLViaHotkeys_MHWS()
        manage_MasterMaterialData_MHWS(MDFXL, MDFXLSub)
        isUpdaterBypass = false
        changed = false
        wc = false
        for i, entry in pairs(MDFXL) do
            entry.isUpdated = false
        end
        debug_RealEquipmentNames_MHWS()
        isPlayerOpenEquipmentMenu = false
    end
end)

--MARK:On Draw UI
re.on_draw_ui(function()
    if reframework.get_game_name() == "mhwilds" then
        draw_MDFXLGUI_MHWS()
    end
end)