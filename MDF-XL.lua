--/////////////////////////////////////--
local modName =  "MDF-XL"

local modAuthor = "SilverEzredes"
local modUpdated = "03/26/2025"
local modVersion = "v1.5.22"
local modCredits = "alphaZomega; praydog; Raq"

--/////////////////////////////////////--
MDFXL = true

local func = require("_SharedCore/Functions")
local ui = require("_SharedCore/Imgui")
local hk = require("Hotkeys/Hotkeys")

local changed = false
local wc = false

local renderComp = "via.render.Mesh"
local chain2Comp = "via.motion.Chain2"
local weaponComp = "app.Weapon"
local texResourceComp = "via.render.TextureResource"
local meshResourceComp = "via.render.MeshResource"
local mdfResourceComp = "via.render.MeshMaterialResource"
local chain2ResourceComp = "via.motion.Chain2Resource"

local masterPlayer = nil
local isPlayerInScene = false
local isDefaultsDumped = false
local isUpdaterBypass = false
local isNowLoading = false
local isLoadingScreenUpdater = false
local isAutoSaved = false
local isOutfitManagerBypass = false
local isMDFXL = false
local isMeshEditor = {}
local isFlagEditor = {}
local isTextureEditor = {}
local isBodyEditor = false
local isUpperBodyToggle = true
local isLowerBodyToggle = true
local isUserManual = false
local isAdvancedSearch = false
local materialParamDefaultsHolder = {}
local materialEditorParamHolder = {}
local materialEditorSubParamFloatHolder = nil
local materialEditorSubParamFloat4Holder = nil
local textureEditorStringHolder = nil
local lastLayeredWeaponStringHolder = nil
local presetName = "[Enter Preset Name Here]"
local paletteName = "[Enter Palette Name Here]"
local outfitName = "[Enter Outfit Name Here]"
local searchQuery = ""
local outfitPresetSearchQuery = ""
local presetSearchQuery = ""
local textureSearchQuery = ""
local layeredWeaponSearchQuery = ""
local lastMatParamName = ""
local lastTime = 0.0
local tickInterval = 0.0
local autoSaveProgress = 0
local coroutineProgress = 0.0
local wasEditorShown = false
local isFemale = false
local lastTransmogEntryKey = ""
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
    SaveDataPaths = {},
    playerBaseBodyUpper = {
        "ab1_left",
        "ab1_left_back",
        "ab1_right",
        "ab1_right_back",
        "ab2_left",
        "ab2_left_back",
        "ab2_right",
        "ab2_right_back",
        "ab3_left",
        "ab3_right",
        "ab3_right_back",
        "ab4_left",
        "ab4_left_back",
        "ab4_right",
        "arm_left",
        "arm_right",
        "back_left_up",
        "back_right_up",
        "breast_left",
        "breast_left_back",
        "breast_right",
        "breast_right_back",
        "chest",
        "elbow_left",
        "elbow_right",
        "hip_left",
        "hip_right",
        "index_left",
        "index_right",
        "little_left",
        "little_right",
        "middle_left",
        "middle_right",
        "neck_left",
        "neck_right",
        "palm_left",
        "palm_right",
        "ring_left",
        "ring_right",
        "shoulder_left",
        "shoulder_right",
        "thumb_left",
        "thumb_right",
        "wrist_left",
        "wrist_right",
    },
    playerBaseBodyLower = {
        "foot_left",
        "foot_right",
        "knee_left",
        "knee_right",
        "shin_left",
        "shin_right",
        "thigh_hip_left",
        "thigh_hip_right",
        "thigh_left",
        "thigh_right",
    },
    playerBaseBodyParts = {
        upper = {
            "ab1_left",
            "ab1_left_back",
            "ab1_right",
            "ab1_right_back",
            "ab2_left",
            "ab2_left_back",
            "ab2_right",
            "ab2_right_back",
            "ab3_left",
            "ab3_right",
            "ab3_right_back",
            "ab4_left",
            "ab4_left_back",
            "ab4_right",
            "arm_left",
            "arm_right",
            "back_left_up",
            "back_right_up",
            "breast_left",
            "breast_left_back",
            "breast_right",
            "breast_right_back",
            "chest",
            "elbow_left",
            "elbow_right",
            "hip_left",
            "hip_right",
            "neck_left",
            "neck_right",
            "shoulder_left",
            "shoulder_right",
        },
        lower = {
            "foot_left",
            "foot_right",
            "knee_left",
            "knee_right",
            "shin_left",
            "shin_right",
            "thigh_hip_left",
            "thigh_hip_right",
            "thigh_left",
            "thigh_right",
        },
    },
    fPlayerBaseBodyTextures = {
        skin = {
            ALBD = "Art/Model/Character/ch03/CommonTextures/skin/f_body_base_ALBD.tex",
            CLMM = "MasterMaterial/Textures/NullBlack_Alpha_MSK4.tex",
            NRRO = "Art/Model/Character/ch03/CommonTextures/skin/f_body_base_NRRO.tex",
            SALB = "Art/Model/Character/ch00/CommonTextures/SkinMap01_skin_ALB.tex",
        },
        underarmor = {
            ALBD = "Art/Model/Character/ch02/CommonTextures/inner/99/inner_99_0000_ALBD.tex",
            CLMM = "systems/rendering/NullWhite.tex",
            NRRO = "Art/Model/Character/ch02/CommonTextures/inner/99/inner_99_0000_NRRO.tex",
            SALB = "systems/rendering/NullGray.tex",
        },
    },
    mPlayerBaseBodyTextures = {
        skin = {
            ALBD = "Art/Model/Character/ch02/CommonTextures/skin/m_body_base_ALBD.tex",
            CLMM = "MasterMaterial/Textures/NullBlack_Alpha_MSK4.tex",
            NRRO = "Art/Model/Character/ch02/CommonTextures/skin/m_body_base_NRRO.tex",
            SALB = "Art/Model/Character/ch00/CommonTextures/SkinMap01_skin_ALB.tex",
        },
        underarmor = {
            ALBD = "Art/Model/Character/ch02/CommonTextures/inner/99/inner_99_0000_ALBD.tex",
            CLMM = "systems/rendering/NullWhite.tex",
            NRRO = "Art/Model/Character/ch02/CommonTextures/inner/99/inner_99_0000_NRRO.tex",
            SALB = "systems/rendering/NullGray.tex",
        },
    },
    defaultPreset = {
        Presets = {},
        currentPresetIDX = 1,
        presetVersion = "v1.00",
        Parts = {},
        Flags = {
            isForceTwoSide = false,
            isBeautyMask = true,
            isReceiveSSSSS = true,
            isShadowCastEnable = true,
        },
        Textures = {},
        TextureCount = {},
        Enabled = {},
        Materials = {},
        MaterialParamCount = {},
        MeshPath = "",
        MDFPath = "",
        MeshName = "",
        AuthorName = "",
        Tags = {
            "noTag"
        },
        EFX = {
            isEnabled = false
        },
        Transmog = {
            ID = "",
            IDX = 0,
            POS = {x = 0.0, y = 0.0, z = 0.0},
            ROT = {x = 0.0, y = 0.0, z = 0.0},
            Scale = {x = 1.0, y = 1.0, z = 1.0},
            JointType = 0,
            isOverride = false,
            isUseBaseParams = false,
        },
        isUpdated = false
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
    showFinalizedPresetName = true,
    showPresetPath = false,
    showPresetVersion = true,
    showMeshPath = false,
    showMDFPath = false,
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
    isUpperBodyUnderArmor = false,
    isLowerBodyUnderArmor = false,
    isHideTalismanEffect = false,
    isUpdateGuildCard = false,
    isHideGuildCardHunter = false,
    isHideGuildCardOtomo = false,
    isHideGuildCardPorter = false,
    isHideGuildCardGUI = false,
    isHideGuildCardOverlayGUI = false,
    isNullGuildCardBG01 = false,
    isLayeredWeaponShowOnlySelfType = true,
    isUniformScale = false,
    attachPosIncrement = 0.01,
    attachRotIncrement = 0.01,
    attachScaleIncrement = 0.1,
    version = modVersion,
    presetVersion = "v1.03",
    presetManager = {
        isTrimPresetNames = true,
        showOutfitPreset = true,
        showHunterEquipment = true,
        showHunterArmament = true,
        showOtomoEquipment = true,
        showOtomoArmament = true,
        showBaseBody = true,
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
        ["Toggle Main Weapon"] = "B",
        ["Toggle Sub Weapon"] = "B",
        ["Toggle Case Sensitive Search"] = "C",
        ["Clear Outfit Search"] = "X",
        ["Reset Last Layered Weapon"] = "Z",
        ["Outfit Change Modifier"] = "RShift",
        ["Outfit Next"] = "Next",
        ["Outfit Previous"] = "Prior",
        ["GamePad Modifier"] = "LT (L2)",
        ["GamePad Outfit Next"] = "RB (R1)",
        ["GamePad Outfit Previous"] = "LB (L1)",
        ["GamePad Toggle Main Weapon"] = "LStickPush",
        ["GamePad Toggle Sub Weapon"] = "LStickPush",
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
    matPartHighlights = {},
    texturePaths = {},
    playerSkinColorData = {},
    playerBaseBodyOrder = {},
    playerUnderArmorColorData = {
        upper = {
            0.2,
            0.2,
            0.2,
            1.0
        },
        lower = {
            0.2,
            0.2,
            0.2,
            1.0
        },
    },
}
local MDFXL_OutfitManager = {
    showMDFXLOutfitEditor = false,
    isUpdated = false,
    currentOutfitPresetIDX = 1,
    jsonPathF = [[MDF-XL\\Outfits\\Female\\.*.json]],
    jsonPathM = [[MDF-XL\\Outfits\\Male\\.*.json]],
    FPresets = {},
    MPresets = {},
    isBody = true,
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
local MDFXL_TransmogTracker = {}
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
local MDFXLTransmogTracker = hk.merge_tables({}, MDFXL_TransmogTracker) and hk.recurse_def_settings(json.load_file("MDF-XL/_Holders/MDF-XL_TransmogTracker.json") or {}, MDFXL_TransmogTracker)
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
-- Update MDFXL Master Data
for i, entry in pairs(MDFXL) do
    entry.presetVersion = MDFXL_DefaultSettings.presetVersion
    if entry.MeshName and string.find(entry.MeshName, "^it") then
        if not entry.Transmog then
            entry.Transmog = {}
        end
        
        for key, defaultValue in pairs(MDFXL_Cache.defaultPreset.Transmog) do
            if entry.Transmog[key] == nil then
                entry.Transmog[key] = defaultValue
            end
        end
    end
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
        isShadowCastEnable = nil,
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
    MDFXLData[entry].Transmog = {}
    MDFXLData[entry].Transmog = {
        ID = "",
        IDX = 0,
        POS = {},
        ROT = {},
        Scale = {},
        JointType = 0,
        isOverride = false,
        isUseBaseParams = false,
    }
    MDFXLData[entry].EFX = {
        isEnabled = false
    }
    MDFXLData[entry].isUpdated = false
end
local function get_WeaponPositionParams_MHWS(gameObject, dataTable, entry)
    local weaponData = func.get_GameObjectComponent(gameObject, weaponComp)

    if weaponData then
        local visualParam = weaponData._VisualParam
        local attachInfo = visualParam._AttachInfo

        if attachInfo then
            dataTable[entry].Transmog.isOverride = false
            dataTable[entry].Transmog.isUseBaseParams = attachInfo._UseBaseParam
            dataTable[entry].Transmog.POS = {}
            dataTable[entry].Transmog.POS = {
                x = attachInfo._Position.x,
                y = attachInfo._Position.y,
                z = attachInfo._Position.z
            }
            dataTable[entry].Transmog.ROT = {}
            dataTable[entry].Transmog.ROT = {
                x = attachInfo._Rotation.x,
                y = attachInfo._Rotation.y,
                z = attachInfo._Rotation.z
            }
            dataTable[entry].Transmog.Scale = {}
            dataTable[entry].Transmog.Scale = {
                x = attachInfo._Scale.x,
                y = attachInfo._Scale.y,
                z = attachInfo._Scale.z
            }
        end
    end
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
                                if order == "playerBaseBodyOrder" then
                                    dataTable[entry].Enabled[k] = false
                                else
                                    dataTable[entry].Enabled[k] = true
                                end
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
        dataTable[entry].Flags.isShadowCastEnable = renderMesh:get_DrawShadowCast()
        table.sort(subDataTable.texturePaths)
    end

    if order == "weaponOrder" then
        get_WeaponPositionParams_MHWS(gameObject, dataTable, entry)
    end
end
local function set_WeaponPositionParams_MHWS(weaponData, dataTable, entry)
    local visualParam = weaponData._VisualParam
    local attachInfo = visualParam._AttachInfo
    local squatInfo = visualParam._SquatttachInfo
    local porterRideInfo = visualParam._PorterRideAttachInfo
    local porterRideDashInfo = visualParam._PorterRideDashAttachInfo
    local porterRideTopSpeedInfo = visualParam._PorterRideTopSpeedAttachInfo
    local porterRideTiltLeftInfo = visualParam._PorterRideTiltLeftAttachInfo
    local porterRideTiltRightInfo = visualParam._PorterRideTiltRightAttachInfo

    if attachInfo then
        attachInfo._UseBaseParam = dataTable[entry.MeshName].Transmog.isUseBaseParams
        if dataTable[entry.MeshName].Transmog.isOverride then 
            attachInfo._UseBaseParam = false
            attachInfo._Position = Vector3f.new(dataTable[entry.MeshName].Transmog.POS.x, dataTable[entry.MeshName].Transmog.POS.y, dataTable[entry.MeshName].Transmog.POS.z)
            attachInfo._Rotation = Vector3f.new(dataTable[entry.MeshName].Transmog.ROT.x, dataTable[entry.MeshName].Transmog.ROT.y, dataTable[entry.MeshName].Transmog.ROT.z)                              
            attachInfo._Scale = Vector3f.new(dataTable[entry.MeshName].Transmog.Scale.x, dataTable[entry.MeshName].Transmog.Scale.y, dataTable[entry.MeshName].Transmog.Scale.z)
        end
    end
    if squatInfo then
        squatInfo._UseBaseParam = dataTable[entry.MeshName].Transmog.isUseBaseParams
        if dataTable[entry.MeshName].Transmog.isOverride then 
            squatInfo._UseBaseParam = false
            squatInfo._Position = Vector3f.new(dataTable[entry.MeshName].Transmog.POS.x, dataTable[entry.MeshName].Transmog.POS.y, dataTable[entry.MeshName].Transmog.POS.z)
            squatInfo._Rotation = Vector3f.new(dataTable[entry.MeshName].Transmog.ROT.x, dataTable[entry.MeshName].Transmog.ROT.y, dataTable[entry.MeshName].Transmog.ROT.z)                              
            squatInfo._Scale = Vector3f.new(dataTable[entry.MeshName].Transmog.Scale.x, dataTable[entry.MeshName].Transmog.Scale.y, dataTable[entry.MeshName].Transmog.Scale.z)
        end
    end
    if porterRideInfo then
        porterRideInfo._UseBaseParam = dataTable[entry.MeshName].Transmog.isUseBaseParams
        if dataTable[entry.MeshName].Transmog.isOverride then 
            porterRideInfo._UseBaseParam = false
            porterRideInfo._Position = Vector3f.new(dataTable[entry.MeshName].Transmog.POS.x, dataTable[entry.MeshName].Transmog.POS.y, dataTable[entry.MeshName].Transmog.POS.z)
            porterRideInfo._Rotation = Vector3f.new(dataTable[entry.MeshName].Transmog.ROT.x, dataTable[entry.MeshName].Transmog.ROT.y, dataTable[entry.MeshName].Transmog.ROT.z)                              
            porterRideInfo._Scale = Vector3f.new(dataTable[entry.MeshName].Transmog.Scale.x, dataTable[entry.MeshName].Transmog.Scale.y, dataTable[entry.MeshName].Transmog.Scale.z)
        end
    end
    if porterRideDashInfo then
        porterRideDashInfo._UseBaseParam = dataTable[entry.MeshName].Transmog.isUseBaseParams
        if dataTable[entry.MeshName].Transmog.isOverride then 
            porterRideDashInfo._UseBaseParam = false
            porterRideDashInfo._Position = Vector3f.new(dataTable[entry.MeshName].Transmog.POS.x, dataTable[entry.MeshName].Transmog.POS.y, dataTable[entry.MeshName].Transmog.POS.z)
            porterRideDashInfo._Rotation = Vector3f.new(dataTable[entry.MeshName].Transmog.ROT.x, dataTable[entry.MeshName].Transmog.ROT.y, dataTable[entry.MeshName].Transmog.ROT.z)                              
            porterRideDashInfo._Scale = Vector3f.new(dataTable[entry.MeshName].Transmog.Scale.x, dataTable[entry.MeshName].Transmog.Scale.y, dataTable[entry.MeshName].Transmog.Scale.z)
        end
    end
    if porterRideTopSpeedInfo then
        porterRideTopSpeedInfo._UseBaseParam = dataTable[entry.MeshName].Transmog.isUseBaseParams
        if dataTable[entry.MeshName].Transmog.isOverride then 
            porterRideTopSpeedInfo._UseBaseParam = false
            porterRideTopSpeedInfo._Position = Vector3f.new(dataTable[entry.MeshName].Transmog.POS.x, dataTable[entry.MeshName].Transmog.POS.y, dataTable[entry.MeshName].Transmog.POS.z)
            porterRideTopSpeedInfo._Rotation = Vector3f.new(dataTable[entry.MeshName].Transmog.ROT.x, dataTable[entry.MeshName].Transmog.ROT.y, dataTable[entry.MeshName].Transmog.ROT.z)                              
            porterRideTopSpeedInfo._Scale = Vector3f.new(dataTable[entry.MeshName].Transmog.Scale.x, dataTable[entry.MeshName].Transmog.Scale.y, dataTable[entry.MeshName].Transmog.Scale.z)
        end
    end
    if porterRideTiltLeftInfo then
        porterRideTiltLeftInfo._UseBaseParam = dataTable[entry.MeshName].Transmog.isUseBaseParams
        if dataTable[entry.MeshName].Transmog.isOverride then 
            porterRideTiltLeftInfo._UseBaseParam = false
            porterRideTiltLeftInfo._Position = Vector3f.new(dataTable[entry.MeshName].Transmog.POS.x, dataTable[entry.MeshName].Transmog.POS.y, dataTable[entry.MeshName].Transmog.POS.z)
            porterRideTiltLeftInfo._Rotation = Vector3f.new(dataTable[entry.MeshName].Transmog.ROT.x, dataTable[entry.MeshName].Transmog.ROT.y, dataTable[entry.MeshName].Transmog.ROT.z)                              
            porterRideTiltLeftInfo._Scale = Vector3f.new(dataTable[entry.MeshName].Transmog.Scale.x, dataTable[entry.MeshName].Transmog.Scale.y, dataTable[entry.MeshName].Transmog.Scale.z)
        end
    end
    if porterRideTiltRightInfo then
        porterRideTiltRightInfo._UseBaseParam = dataTable[entry.MeshName].Transmog.isUseBaseParams
        if dataTable[entry.MeshName].Transmog.isOverride then 
            porterRideTiltRightInfo._UseBaseParam = false
            porterRideTiltRightInfo._Position = Vector3f.new(dataTable[entry.MeshName].Transmog.POS.x, dataTable[entry.MeshName].Transmog.POS.y, dataTable[entry.MeshName].Transmog.POS.z)
            porterRideTiltRightInfo._Rotation = Vector3f.new(dataTable[entry.MeshName].Transmog.ROT.x, dataTable[entry.MeshName].Transmog.ROT.y, dataTable[entry.MeshName].Transmog.ROT.z)                              
            porterRideTiltRightInfo._Scale = Vector3f.new(dataTable[entry.MeshName].Transmog.Scale.x, dataTable[entry.MeshName].Transmog.Scale.y, dataTable[entry.MeshName].Transmog.Scale.z)
        end
    end
end
local function set_MaterialParams(gameObject, dataTable, entry, saveDataTable)
    local renderMesh = func.get_GameObjectComponent(gameObject, renderComp)
    local weaponData = func.get_GameObjectComponent(gameObject, weaponComp)
    
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
                            
                            if isUpdaterBypass or (matParamNames == lastMatParamName and matType) then
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
                    if (isUpdaterBypass and matName ~= "skin") or (isTextureEditor[dataTable[entry.MeshName].Materials[matName]] and matName ~= "skin") then
                        for t = 0, textureCount - 1 do
                            local textureName = renderMesh:getMaterialTextureName(j, t)
                            local textureResource = func.create_resource(texResourceComp, dataTable[entry.MeshName].Textures[matName][textureName])
                            renderMesh:setMaterialTexture(j, t, textureResource)
                        end
                    end
                end
                if isUpdaterBypass or isMeshEditor[entry.MeshName] then
                    for v = 0, #dataTable[entry.MeshName].Enabled do
                        renderMesh:setMaterialsEnable(v, dataTable[entry.MeshName].Enabled[v + 1])
                    end
                end
            end
        end
        if isUpdaterBypass or isFlagEditor[entry.MeshName] then
            renderMesh:set_ForceTwoSide(dataTable[entry.MeshName].Flags.isForceTwoSide)
            renderMesh:set_BeautyMaskFlag(dataTable[entry.MeshName].Flags.isBeautyMask)
            renderMesh:set_ReceiveSSSSSFlag(dataTable[entry.MeshName].Flags.isReceiveSSSSS)
            renderMesh:set_DrawShadowCast(dataTable[entry.MeshName].Flags.isShadowCastEnable)
        end
        local chunkID = entry.MeshName:sub(1, 4)
        if (chunkID == "ch02") or (chunkID == "ch03") then
            chunkID = entry.MeshName:sub(1, 8)
        end
        if saveDataTable[chunkID] then
            saveDataTable[chunkID].wasUpdated = true
        end
    end

    if weaponData then
        set_WeaponPositionParams_MHWS(weaponData, dataTable, entry)
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
    local OutfitPresetTable
    if isFemale then
        OutfitPresetTable = MDFXLOutfits.FPresets
    else
        OutfitPresetTable = MDFXLOutfits.MPresets
    end

    if #OutfitPresetTable > 0 then
        local selected_preset = OutfitPresetTable[MDFXLOutfits.currentOutfitPresetIDX]
        local json_filepath = ""
        if isFemale then
            json_filepath = [[MDF-XL\\Outfits\\Female\\]] .. selected_preset .. [[.json]]
        else
            json_filepath = [[MDF-XL\\Outfits\\Male\\]] .. selected_preset .. [[.json]]
        end
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
    json.dump_file("MDF-XL/_Settings/MDF-XL_OutfitManagerSettings.json", MDFXLOutfits)
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
local GUI000008 = nil
local GUI000013 = nil
local GUI010000 = nil
local GUI040200 = nil
local GUI040202 = nil
local GUI080001 = nil
local GUI090000 = nil
local GUI090001MenuIDX = 0
local GUI090001DecideIDX = 0
local GUICharIDX = 0
local GUI010300AppEditorIDX = 0
local isOtomoInScene = false
local isPorterInScene = false
local isPlayerLeftEquipmentMenu = false
local isPlayerOpenEquipmentMenu = false
local isPlayerLeftCamp = false
local isPlayerLeftSmithy = false
local isPlayerSwappedWeapons = false
local isAppearanceEditorOpen = false
local isAppearanceEditorUpdater = false
local isAppearanceSeikretEditor = false
local isWeaponDrawn = false
local isWeaponChanged = false
local isWeaponChangedCallCount = 0
local isGuildCardDrawn = false
local isPlayerBaseBodySetup = false
local isCoroutinesDone = false
local isWeaponTransmogRequest = false
local isTransmogBypass = false
local playerBaseBody = nil
local guildCardHunter = nil
local guildCardOtomo = nil
local guildCardPorter = nil
local guildCardLights = nil
local femaleBaseMesh = func.create_resource(meshResourceComp, "MDF-XL/FemaleBase/MDFXL_FPlayerBase.mesh")
local femaleBaseMDF = func.create_resource(mdfResourceComp, "MDF-XL/FemaleBase/MDFXL_FPlayerBase.mdf2")
local maleBaseMesh = func.create_resource(meshResourceComp, "MDF-XL/MaleBase/MDFXL_MPlayerBase.mesh")
local maleBaseMDF = func.create_resource(mdfResourceComp, "MDF-XL/MaleBase/MDFXL_MPlayerBase.mdf2")
local tmogResources = {}
local weaponLists = {}
local nullChain = "Art/Model/Item/it00/99/it0099_0000_0.chain2"
for ID, weapon in pairs(MDFXLDatabase.MHWS) do
    if weapon.WPType ~= nil then
        if weapon.ChainPath == "" then
            weapon.ChainPath = nullChain
        end
        tmogResources[ID] = {}
        tmogResources[ID].mesh = func.create_resource(meshResourceComp, weapon.MeshPath)
        tmogResources[ID].mdf = func.create_resource(mdfResourceComp, weapon.MeshPath:gsub("%.mesh", ".mdf2"))
        tmogResources[ID].chain2 = func.create_resource(chain2ResourceComp, weapon.ChainPath)
    end
end
for wpType = 0, 11 do
    weaponLists[wpType] = {}
    table.insert(weaponLists[wpType], {key = "", name = "None"})
    
    for key, weapon in pairs(MDFXLDatabase.MHWS) do
        if weapon.WPType == wpType then
            table.insert(weaponLists[wpType], {key = key, name = weapon.Name})
        end
    end
    
    local noneEntry = weaponLists[wpType][1]
    local sortable = {}
    for i = 2, #weaponLists[wpType] do
        table.insert(sortable, weaponLists[wpType][i])
    end
    table.sort(sortable, function(a, b) return a.name < b.name end)
    
    weaponLists[wpType] = {noneEntry}
    for _, weaponEntry in ipairs(sortable) do
        table.insert(weaponLists[wpType], weaponEntry)
    end
end
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
            GUICharIDX = GUI080001._EquipChangeType
        end
    )
    --Equipment Appearance Menu GUI
    sdk.hook(sdk.find_type_definition("app.GUI080200"):get_method("get_ID()"),
        function(args)
            local GUI080200 = sdk.to_managed_object(args[2])
            GUICharIDX = GUI080200._CharacterType
            
            local onClose = sdk.to_int64(args[3])
            local onClose2 = sdk.to_int64(args[4])
            if onClose == 0 and onClose2 ~= 0 then
                isPlayerLeftEquipmentMenu = true
            end
        end
    )
    --Camp and Smithy GUI
    sdk.hook(sdk.find_type_definition("app.GUI090001"):get_method("guiUpdate()"),
        function (args)
            local GUI090001 = sdk.to_managed_object(args[2])
            GUI090001MenuIDX = GUI090001._CurrentMenu
            GUI090001DecideIDX = GUI090001._DecideCategory
        end
    )
    sdk.hook(sdk.find_type_definition("app.GUI090001"):get_method("close()"),
    function(args)
        if (GUI090001MenuIDX == 0) or (GUI090001MenuIDX == 8) then
            isPlayerLeftCamp = true
        end
        if GUI090001MenuIDX == 6 then
            isPlayerLeftSmithy = true
        end
    end
    )
    --Appearance Editor GUI
    sdk.hook(sdk.find_type_definition("app.GUI010300"):get_method("guiUpdate()"),
        function(args)
            local GUI010300 = sdk.to_managed_object(args[2])
            GUI010300AppEditorIDX = GUI010300._SceneType
        end
    )
    sdk.hook(sdk.find_type_definition("app.GUI010300"):get_method("onClose()"),
        function(args)
            if GUI010300AppEditorIDX == 1 then
                isAppearanceEditorUpdater = true
                GUICharIDX = 0
            end
            if (GUI010300AppEditorIDX == 4) or (GUI010300AppEditorIDX == 5) then
                isAppearanceSeikretEditor = true
            end
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
    --Check if the currently equipped weapon has been changed
    sdk.hook(sdk.find_type_definition("app.cPlayerManageControl"):get_method("onChangeWeaponFromReserve()"),
        function (args)
            isWeaponChangedCallCount = isWeaponChangedCallCount + 1
            if isWeaponChangedCallCount == 1 then
                isPlayerSwappedWeapons = true
                GUICharIDX = 0
            end
        end
    )
    --Hunter Profile GUI
    sdk.hook(sdk.find_type_definition("app.GuildCardSceneController"):get_method("updateActive()"),
        function (args)
            isGuildCardDrawn = true            
        end
    )
end
--Material Param Getters
local function help_GetMaterialParams_MHWS(gameObject, gameObjectID, order, MDFXLData, MDFXLSubData, MDFXLSaveData)
    if gameObject and gameObject:get_Valid() then
        if not MDFXLData[gameObjectID] then
            setup_MDFXLTable(MDFXLData, gameObjectID)
        end
        MDFXLData[gameObjectID].isInScene = true
        MDFXLData[gameObjectID].Parts = {}
        MDFXLData[gameObjectID].Enabled = {}
        MDFXLData[gameObjectID].Materials = {}
        get_MaterialParams(gameObject, MDFXLData, gameObjectID, MDFXLSubData, order, MDFXLSaveData)
    elseif (not gameObject) or (not gameObject:get_Valid()) then
        MDFXLData[gameObjectID].isInScene = false
    end
end
local function get_PlayerEquipmentMaterialParams_MHWS(MDFXLData, MDFXLSubData)
    if not isPlayerInScene then return end
    MDFXLSubData.order = {}
    
    if playerCharacter then
        isFemale = playerCharacter:get_IsFemale()
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
        local reserveSubWeaponInsect = playerCharacter:get_ReserveWp10Insect()
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
        if reserveSubWeaponInsect then
            reserveSubWeaponInsect = reserveSubWeaponInsect:get_GameObject()
            local reserveSubWeaponInsectID = reserveSubWeaponInsect:get_Name()
            help_GetMaterialParams_MHWS(reserveSubWeaponInsect, reserveSubWeaponInsectID, "weaponOrder", MDFXLData, MDFXLSubData, MDFXLSaveDataChunks)
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
local function get_PlayerSkinData_MHWS(MDFXLSubData)
    if not isPlayerInScene then return end
    local playerTransforms = masterPlayer and masterPlayer:get_Valid() and masterPlayer:get_Object():get_Transform()
    
    if playerTransforms then
        local playerFace = playerTransforms:find("Player_Face")
        playerFace = playerFace:get_GameObject()

        if playerFace then
            local renderMesh = func.get_GameObjectComponent(playerFace, renderComp)

            if renderMesh then
                local matCount = renderMesh:get_MaterialNum()
                for j = 0, matCount - 1 do
                    local matName = renderMesh:getMaterialName(j)
                    local matParam = renderMesh:getMaterialVariableNum(j)
                    
                    if matName == "face" then
                        if matParam then
                            for k = 0, matParam - 1 do
                                local matParamNames = renderMesh:getMaterialVariableName(j, k)
                                if matParamNames == "AddColorUV" then
                                    MDFXLSubData.playerSkinColorData = {}
                                    local matTypeFloat4 = renderMesh:getMaterialFloat4(j, k)
                                    local matTypeFloat4New = {matTypeFloat4.x, matTypeFloat4.y, matTypeFloat4.z, matTypeFloat4.w}
                                    table.insert(MDFXLSubData.playerSkinColorData, matTypeFloat4New)
                                end
                            end
                        end
                    end
                end
            end
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
            if otomoHelm:get_Valid() then
                local otomoHelmID = otomoHelm:get_Name()
                help_GetMaterialParams_MHWS(otomoHelm, otomoHelmID, "otomoOrder", MDFXLData, MDFXLSubData, MDFXLSaveDataChunks)
            end
        end
        if otomoBody then
            local otomoBodyID = otomoBody:get_Name()
            if otomoBodyID == "ch05_000_0000" then return end
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
        local porterSaddle = porterCharacter:get_EquipSaddle()
        local porterRein = porterCharacter:get_EquipRein()
        local porterWeaponBag = porterCharacter:get_EquipWeaponBags()

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
        local meshName = equipment.MeshName
        local presets = equipment.Presets

        if not (
            func.table_contains(MDFXLSub.order, meshName) or 
            func.table_contains(MDFXLSub.weaponOrder, meshName) or 
            func.table_contains(MDFXLSub.otomoOrder, meshName) or 
            func.table_contains(MDFXLSub.otomoWeaponOrder, meshName) or 
            func.table_contains(MDFXLSub.porterOrder, meshName)
        ) then
            goto continue
        end

        if (equipment and equipment.isInScene and not isDefaultsDumped) or (isNowLoading and isDefaultsDumped and #presets == 0) or 
        (isPlayerLeftEquipmentMenu and #presets == 0) or (isPlayerLeftCamp and #presets == 0) or (isAppearanceEditorUpdater and #presets == 0) or 
        (isPlayerLeftSmithy and #presets == 0) or (isPlayerSwappedWeapons and #presets == 0) or (isWeaponTransmogRequest and #presets == 0) then
            json.dump_file("MDF-XL/Equipment/" .. meshName .. "/" .. meshName .. " Default.json", equipment)
            
            if MDFXLSettings.isDebug then
                log.info("[MDF-XL-JSON] [" .. meshName .. " Default Preset Dumped]")
            end
        end
        ::continue::
    end
end
local function dump_BaseBodyMaterialParamJSON_MHWS(MDFXLData)
    for _, equipment in pairs(MDFXLData) do
        local meshName = equipment.MeshName
        if (meshName == "MDFXL_FPlayerBase") or (meshName == "MDFXL_MPlayerBase") then
            json.dump_file("MDF-XL/Equipment/" .. meshName .. "/" .. meshName .. " Default.json", equipment)
            
            if MDFXLSettings.isDebug then
                log.info("[MDF-XL-JSON] [" .. meshName .. " Default Preset Dumped]")
            end
        end
    end
end
local function clear_MDFXLJSONCache_MHWS(MDFXLData, MDFXLSubData)
    for _, equipment in pairs(MDFXLData) do
        local meshName = equipment.MeshName
        if not (
            func.table_contains(MDFXLSubData.order, meshName) or 
            func.table_contains(MDFXLSubData.weaponOrder, meshName) or 
            func.table_contains(MDFXLSubData.otomoOrder, meshName) or 
            func.table_contains(MDFXLSubData.otomoWeaponOrder, meshName) or 
            func.table_contains(MDFXLSubData.porterOrder, meshName)
        ) then
            goto continue
        end
        if isWeaponTransmogRequest and not (func.table_contains(MDFXLSubData.weaponOrder, meshName)) then goto continue end

        if (equipment.isUpdated) or (isUpdaterBypass) or (not isDefaultsDumped) or (isNowLoading and not isLoadingScreenUpdater) or (isWeaponTransmogRequest) then
            local cacheKey = "MDF-XL/Equipment/" .. meshName
            MDFXLSubData.jsonPaths[cacheKey] = nil

            if MDFXLSettings.isDebug then
                log.info("[MDF-XL-JSON] [Preset path cache cleared for " .. meshName .. "]")
            end
        end
        ::continue::
    end
end
local function clear_BaseBody_MDFXLJSONCache_MHWS(MDFXLData, MDFXLSubData)
    for _, equipment in pairs(MDFXLData) do
        local meshName = equipment.MeshName
        if (meshName == "MDFXL_FPlayerBase") or (meshName == "MDFXL_MPlayerBase") then
            local cacheKey = "MDF-XL/Equipment/" .. meshName
            MDFXLSubData.jsonPaths[cacheKey] = nil

            if MDFXLSettings.isDebug then
                log.info("[MDF-XL-JSON] [Preset path cache cleared for " .. meshName .. "]")
            end
        end
    end
end
local function cache_MDFXLJSONFiles_MHWS(MDFXLData, MDFXLSubData)
    for _, equipment in pairs(MDFXLData) do
        local meshName = equipment.MeshName
        if not (
            func.table_contains(MDFXLSubData.order, meshName) or 
            func.table_contains(MDFXLSubData.weaponOrder, meshName) or 
            func.table_contains(MDFXLSubData.otomoOrder, meshName) or 
            func.table_contains(MDFXLSubData.otomoWeaponOrder, meshName) or 
            func.table_contains(MDFXLSubData.porterOrder, meshName) or
            func.table_contains(MDFXLSubData.playerBaseBodyOrder, meshName)
        ) then
            goto continue
        end
        
        if equipment then
            local json_names = equipment.Presets or {}
            local cacheKey = "MDF-XL/Equipment/" .. meshName
            
            if not MDFXLSubData.jsonPaths[cacheKey] then
                local path = [[MDF-XL\\Equipment\\]] .. meshName .. [[\\.*.json]]
                MDFXLSubData.jsonPaths[cacheKey] = fs.glob(path)
            end

            local json_filepaths = MDFXLSubData.jsonPaths[cacheKey]
            
            if json_filepaths then
                local defaultName = meshName .. " Default"
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
                            log.info("[MDF-XL-JSON] [Loaded " .. filepath .. " for "  .. meshName .. "]")
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
                            log.info("[MDF-XL-JSON] [Removed " .. name .. " from " ..meshName .. "]")
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
        ::continue::
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

    if isFemale then
        OutfitPresetTable = MDFXLOutfits.FPresets
    else
        OutfitPresetTable = MDFXLOutfits.MPresets
    end

    if OutfitPresetTable then
        local json_names = OutfitPresetTable or {}
        local json_filepaths = ""
        if isFemale then
            json_filepaths = fs.glob(MDFXLOutfits.jsonPathF)
        else
            json_filepaths = fs.glob(MDFXLOutfits.jsonPathM)
        end

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
        local meshName = equipment.MeshName
        if (meshName == "MDFXL_FPlayerBase") or (meshName == "MDFXL_MPlayerBase") then
            goto continue
        end
        if not (
            func.table_contains(MDFXLSub.order, meshName) or 
            func.table_contains(MDFXLSub.weaponOrder, meshName) or 
            func.table_contains(MDFXLSub.otomoOrder, meshName) or 
            func.table_contains(MDFXLSub.otomoWeaponOrder, meshName) or 
            func.table_contains(MDFXLSub.porterOrder, meshName)
        ) then
            goto continue
        end
        local presetTable = equipment.Presets

        for i, presetName in pairs(presetTable) do
            if presetName ~= meshName .. " Default" then
                local name = meshName
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
        ::continue::
    end
    table.sort(tagTable._AuthorList)
    table.sort(tagTable._AuthorSearchList)
    table.sort(tagTable._TagList)
    table.sort(tagTable._TagSearchList)
    json.dump_file("MDF-XL/_Holders/MDF-XL_Tags.json", tagTable)
end
--Weapon Transmog System
local function help_TransmogPlayerArmament(weaponObj, weaponData, MDFXLDatabase, MDFXLTransmogTracker, transmogID, weaponID)
    if not (weaponObj and weaponObj:get_Valid()) then 
        return false
    end
    local renderMesh = func.get_GameObjectComponent(weaponObj, renderComp)
    local chain2 = func.get_GameObjectComponent(weaponObj, chain2Comp)
    local transmogComplete = false

    local resources = tmogResources[transmogID]
    if renderMesh then
        if resources.mesh and resources.mdf then
            renderMesh:setMesh(resources.mesh)
            renderMesh:set_Material(resources.mdf)
            renderMesh:set_Enabled(false)
        end
    end

    if chain2 then
        if resources.chain2 then
            chain2:set_ChainAsset(resources.chain2)
        end
    end

    transmogComplete = true

    if transmogComplete then
        local baseWeaponID = weaponID:match("^(.-)%-%-") or weaponID

        if baseWeaponID == transmogID then
            weaponObj:set_Name(baseWeaponID)
            MDFXL[baseWeaponID].Transmog.ID = ""
        else
            weaponObj:set_Name(baseWeaponID .. "--" .. transmogID)
            lastLayeredWeaponStringHolder = baseWeaponID .. "--" .. transmogID
        end
        renderMesh:set_Enabled(true)
        if MDFXL[baseWeaponID].currentPresetIDX == 1 then
            for v = 0, #MDFXL[baseWeaponID].Enabled do
                renderMesh:setMaterialsEnable(v, true)
            end
        end
        log.info("[MDF-XL] [Transmog Complete for " .. baseWeaponID .. "]")
    end

    if not MDFXLTransmogTracker[weaponData.MeshName] then
        MDFXLTransmogTracker[weaponData.MeshName] = {}
    end
    MDFXLTransmogTracker[weaponData.MeshName].lastTransmogID = transmogID
    isUpdaterBypass = true
    return true
end
local function transmog_PlayerArmament_MHWS(MDFXLData, MDFXLDatabase, MDFXLTransmogTracker, validWeaponIDs)
    if not isPlayerInScene then return end

    for _, weaponData in pairs(MDFXLData) do
        if not func.table_contains(MDFXLSub.weaponOrder, MDFXLData[weaponData.MeshName].MeshName) then
            goto continue
        end

        if playerCharacter then
            local weaponSlots = {
                {slot = "mainWeapon", obj = playerCharacter:get_Weapon()},
                {slot = "subWeapon", obj = playerCharacter:get_SubWeapon()},
                {slot = "reserveWeapon", obj = playerCharacter:get_ReserveWeapon()},
                {slot = "reserveSubWeapon", obj = playerCharacter:get_ReserveSubWeapon()},
                {slot = "subWeaponInsect", obj = playerCharacter:get_Wp10Insect()},
                {slot = "reserveSubWeaponInsect", obj = playerCharacter:get_ReserveWp10Insect()}
            }

            local transmogID = MDFXLData[weaponData.MeshName].Transmog.ID
            if transmogID == "" then goto continue end

            for _, weaponEntry in ipairs(weaponSlots) do
                if weaponEntry.obj then
                    weaponEntry.obj = weaponEntry.obj:get_GameObject()
                    local weaponID = weaponEntry.obj:get_Name()
                    if func.table_contains(validWeaponIDs, weaponID) and weaponID == weaponData.MeshName and (isTransmogBypass or weaponID == lastTransmogEntryKey) then
                        help_TransmogPlayerArmament(weaponEntry.obj, weaponData, MDFXLDatabase, MDFXLTransmogTracker, transmogID, weaponID)
                        get_PlayerArmamentMaterialParams_MHWS(MDFXLData, MDFXLSub)
                    end
                end
            end
        end
        ::continue::
    end
    json.dump_file("MDF-XL/_Holders/MDF-XL_TransmogTracker.json", MDFXLTransmogTracker)
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
                local reserveSubWeaponInsect = playerCharacter:get_ReserveWp10Insect()
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
                if reserveSubWeaponInsect then
                    reserveSubWeaponInsect = reserveSubWeaponInsect:get_GameObject()
                    if not (reserveSubWeaponInsect and reserveSubWeaponInsect:get_Valid()) then return end
                    
                    local reserveSubWeaponInsectID = reserveSubWeaponInsect:get_Name()
                    if reserveSubWeaponInsectID == weapon.MeshName then
                        set_MaterialParams(reserveSubWeaponInsect, MDFXLData, weapon, MDFXLSaveDataChunks)
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
        if not isWeaponDrawn and GUI090001MenuIDX ~= 0 and GUI090001MenuIDX ~= 8 then
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
        
        if not isWeaponDrawn and GUI090001MenuIDX ~= 0 and GUI090001MenuIDX ~= 8 then
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
        
        if not isWeaponDrawn and GUI090001MenuIDX ~= 0 and GUI090001MenuIDX ~= 8 then
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
local function update_PlayerTalismanEffectVisibility_MHWS()
    if not masterPlayer then return end

    local talismanObject = masterPlayer and masterPlayer:get_Valid() and masterPlayer:get_Object():get_Transform():find("no_name_effect")
    if talismanObject then
        talismanObject = talismanObject:get_GameObject()
        if MDFXLSettings.isHideTalismanEffect then
            talismanObject:set_DrawSelf(false)
        else
            talismanObject:set_DrawSelf(true)
        end
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
        ::continue::
    end
end
local function update_OtomoArmamentMaterialParams_MHWS(MDFXLData)
    if not isOtomoInScene then return end
    for _, weapon in pairs(MDFXLData) do
        if not func.table_contains(MDFXLSub.otomoWeaponOrder, MDFXLData[weapon.MeshName].MeshName) then
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
        ::continue::
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
                local porterSaddle = porterCharacter:get_EquipSaddle()
                local porterRein = porterCharacter:get_EquipRein()
                local porterWeaponBag = porterCharacter:get_EquipWeaponBags()
                
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
        ::continue::
    end
end
local function update_GuildCardScene(MDFXLData)
    local scene = func.get_CurrentScene()
    if isFemale then
        guildCardHunter = scene:call("findGameObject(System.String)", "GuildCard_HunterXX")
    else
        guildCardHunter = scene:call("findGameObject(System.String)", "GuildCard_HunterXY")
    end
    guildCardOtomo = scene:call("findGameObject(System.String)", "GuildCard_Palico")
    guildCardPorter = scene:call("findGameObject(System.String)", "GuildCard_Porter")
    guildCardLights = scene:call("findGameObject(System.String)", "guildcard_Lightset")
    GUI000008 = scene:call("findGameObject(System.String)", "GUI000008")
    GUI000013 = scene:call("findGameObject(System.String)", "GUI000013")
    GUI040200 = scene:call("findGameObject(System.String)", "GUI040200")
    GUI040202 = scene:call("findGameObject(System.String)", "GUI040202")
    
    if guildCardHunter then
        if MDFXLSettings.isHideGuildCardHunter then
            guildCardHunter:set_DrawSelf(false)
        else
            guildCardHunter:set_DrawSelf(true)
        end

        if not MDFXLSettings.isHideGuildCardHunter then
            local playerTransforms = guildCardHunter and guildCardHunter:get_Valid() and guildCardHunter:get_Transform()
            local playerChildren = func.get_children(playerTransforms)
            
            for _, equipment in pairs(MDFXLData) do
                if not func.table_contains(MDFXLSub.order, MDFXLData[equipment.MeshName].MeshName) then
                    goto continue
                end
                
                for i, child in pairs(playerChildren) do
                    local childStrings = child:ToString()
                    local playerEquipment = childStrings:match("(ch[^@]+)")
                    
                    if playerEquipment == equipment.MeshName then
                        local currentEquipment = playerTransforms:find(playerEquipment)
                        local currentEquipmentID = currentEquipment:get_GameObject()

                        if not (currentEquipmentID and currentEquipmentID:get_Valid()) then return end
                        set_MaterialParams(currentEquipmentID, MDFXLData, equipment, MDFXLSaveDataChunks)
                    end
                end
                ::continue::
            end
        end
    end
    if guildCardOtomo then
        if MDFXLSettings.isHideGuildCardOtomo then
            guildCardOtomo:set_DrawSelf(false)
        else
            guildCardOtomo:set_DrawSelf(true)
        end
    end
    if guildCardPorter then
        if MDFXLSettings.isHideGuildCardPorter then
            guildCardPorter:set_DrawSelf(false)
        else
            guildCardPorter:set_DrawSelf(true)
        end
    end
    if guildCardLights then
        local lightTransform = guildCardLights:get_Transform()
        local lightChildren = func.get_children(lightTransform)

        for i, child in pairs(lightChildren) do
            local childStrings = child:ToString()
            local event05_SpotLight = childStrings:match("Event_Other05_SpotLight")
            
            if event05_SpotLight then
                local eventLight = lightTransform:find(event05_SpotLight)
                local eventLightObject = eventLight:get_GameObject()

                if eventLightObject then
                    if MDFXLSettings.isNullGuildCardBG01 then
                        eventLightObject:set_DrawSelf(false)
                    else
                        eventLightObject:set_DrawSelf(true)
                    end
                end
            end
        end 
    end
    if GUI000008 then
        if(MDFXLSettings.isHideGuildCardGUI) or (MDFXLSettings.isHideGuildCardOverlayGUI) then
            GUI000008:set_UpdateSelf(false)
            GUI000008:set_DrawSelf(false)
        else
            GUI000008:set_UpdateSelf(true)
            GUI000008:set_DrawSelf(true)
        end
    end
    if GUI000013 then
        if(MDFXLSettings.isHideGuildCardGUI) or (MDFXLSettings.isHideGuildCardOverlayGUI) then
            GUI000013:set_UpdateSelf(false)
            GUI000013:set_DrawSelf(false)
        else
            GUI000013:set_UpdateSelf(true)
            GUI000013:set_DrawSelf(true)
        end
    end
    if GUI040200 then
        if(MDFXLSettings.isHideGuildCardGUI) or (MDFXLSettings.isHideGuildCardOverlayGUI) then
            GUI040200:set_UpdateSelf(false)
            GUI040200:set_DrawSelf(false)
        else
            GUI040200:set_UpdateSelf(true)
            GUI040200:set_DrawSelf(true)
        end
    end
    if GUI040202 then
        if MDFXLSettings.isHideGuildCardGUI then
            GUI040202:set_UpdateSelf(false)
            GUI040202:set_DrawSelf(false)
        else
            GUI040202:set_UpdateSelf(true)
            GUI040202:set_DrawSelf(true)
        end
    end
    isGuildCardDrawn = false
end
--Base Body Managers
local function spawn_PlayerBaseBody_MHWS()
    if not isPlayerInScene then return end
    local scene = func.get_CurrentScene()
    if isFemale then
        playerBaseBody = scene:call("findGameObject(System.String)", "MDFXL_FPlayerBase")
    else
        playerBaseBody = scene:call("findGameObject(System.String)", "MDFXL_MPlayerBase")
    end

    if playerBaseBody == nil then
        if isFemale then
            func.spawn_gameobj("MDFXL_FPlayerBase", Vector3f.new(0,0,0), Vector4f.new(0,0,0,1), 0, {"via.render.Mesh"})
        else
            func.spawn_gameobj("MDFXL_MPlayerBase", Vector3f.new(0,0,0), Vector4f.new(0,0,0,1), 0, {"via.render.Mesh"})
        end
        isPlayerBaseBodySetup = true
    end
end
local function setup_PlayerBaseBody_MHWS(MDFXLData, MDFXLSubData)
    local scene = func.get_CurrentScene()
    if isFemale then
        playerBaseBody = scene:call("findGameObject(System.String)", "MDFXL_FPlayerBase")
    else
        playerBaseBody = scene:call("findGameObject(System.String)", "MDFXL_MPlayerBase")
    end

    if playerBaseBody then
        MDFXLSubData.playerBaseBodyOrder = {}
        local renderMesh = func.get_GameObjectComponent(playerBaseBody, renderComp)
        
        if renderMesh then
            if isFemale then
                renderMesh:setMesh(femaleBaseMesh)
                renderMesh:set_Material(femaleBaseMDF)
            else
                renderMesh:setMesh(maleBaseMesh)
                renderMesh:set_Material(maleBaseMDF)
            end
            renderMesh:set_StencilValue(1)
            renderMesh:set_BeautyMaskFlag(true)
            
            local matCount = renderMesh:get_MaterialNum()
            for j = 0, matCount - 1 do
                local matName = renderMesh:getMaterialName(j)
                local matParam = renderMesh:getMaterialVariableNum(j)
                
                if matName and matParam then
                    for k = 0, matParam - 1 do
                        local matType = renderMesh:getMaterialVariableType(j, k)
                        local matParamNames = renderMesh:getMaterialVariableName(j, k)
                        if matParamNames == "AddColorUV" and matType == 4 then
                            local vec4 = MDFXLSubData.playerSkinColorData[1]
                            renderMesh:setMaterialFloat4(j, k, Vector4f.new(vec4[1], vec4[2], vec4[3], vec4[4]))
                        end
                    end
                end
            end
        end

        local playerBaseBodyID = playerBaseBody:get_Name()
        help_GetMaterialParams_MHWS(playerBaseBody, playerBaseBodyID, "playerBaseBodyOrder", MDFXLData, MDFXLSubData, MDFXLSaveDataChunks)
        
        local playerBaseBodyTransforms = playerBaseBody:get_Transform()
        if playerBaseBodyTransforms then
            playerBaseBodyTransforms:setParent(masterPlayer:get_Object():get_Transform(), true)
            playerBaseBodyTransforms:set_SameJointsConstraint(true)
        end
    end
end
local function lateSetup_PlayerBaseBody_MHWS(MDFXLData, MDFXLSubData)
    local scene = func.get_CurrentScene()
    if isFemale then
        playerBaseBody = scene:call("findGameObject(System.String)", "MDFXL_FPlayerBase")
    else
        playerBaseBody = scene:call("findGameObject(System.String)", "MDFXL_MPlayerBase")
    end

    if playerBaseBody then
        local renderMesh = func.get_GameObjectComponent(playerBaseBody, renderComp)
        
        if renderMesh then
            if isFemale then
                for v = 0, #MDFXLData["MDFXL_FPlayerBase"].Enabled do
                    renderMesh:setMaterialsEnable(v, MDFXLData["MDFXL_FPlayerBase"].Enabled[v + 1])
                end
            else
                for v = 0, #MDFXLData["MDFXL_MPlayerBase"].Enabled do
                    renderMesh:setMaterialsEnable(v, MDFXLData["MDFXL_MPlayerBase"].Enabled[v + 1])
                end
            end
        end
    end
    isPlayerBaseBodySetup = false
end
local function update_PlayerBaseBodyUnderarmor_MHWS(gameObject)
    local renderMesh = func.get_GameObjectComponent(gameObject, renderComp)
    local textureMap = {
        ["BaseDielectricMap"] = {
            skin = {
                f = MDFXL_Cache.fPlayerBaseBodyTextures.skin.ALBD,
                m = MDFXL_Cache.mPlayerBaseBodyTextures.skin.ALBD,
            },
            underarmor = {
                f = MDFXL_Cache.fPlayerBaseBodyTextures.underarmor.ALBD,
                m = MDFXL_Cache.mPlayerBaseBodyTextures.underarmor.ALBD,
            },
        },
        ["ColorLayer_MaskMap"] = {
            skin = {
                f = MDFXL_Cache.fPlayerBaseBodyTextures.skin.CLMM,
                m = MDFXL_Cache.mPlayerBaseBodyTextures.skin.CLMM,
            },
            underarmor = {
                f = MDFXL_Cache.fPlayerBaseBodyTextures.underarmor.CLMM,
                m = MDFXL_Cache.mPlayerBaseBodyTextures.underarmor.CLMM,
            },
        },
        ["NormalRoughnessOcclusionMap"] = {
            skin = {
                f = MDFXL_Cache.fPlayerBaseBodyTextures.skin.NRRO,
                m = MDFXL_Cache.mPlayerBaseBodyTextures.skin.NRRO,
            },
            underarmor = {
                f = MDFXL_Cache.fPlayerBaseBodyTextures.underarmor.NRRO,
                m = MDFXL_Cache.mPlayerBaseBodyTextures.underarmor.NRRO,
            },
        },
        ["SkinMap"] = {
            skin = {
                f = MDFXL_Cache.fPlayerBaseBodyTextures.skin.SALB,
                m = MDFXL_Cache.mPlayerBaseBodyTextures.skin.SALB,
            },
            underarmor = {
                f = MDFXL_Cache.fPlayerBaseBodyTextures.underarmor.SALB,
                m = MDFXL_Cache.mPlayerBaseBodyTextures.underarmor.SALB,
            },
        },
    }
    local genderKey = isFemale and "f" or "m"
    
    if renderComp then
        local matCount = renderMesh:get_MaterialNum()
        if matCount then
            for j = 0, matCount - 1 do
                local matName = renderMesh:getMaterialName(j)
                if matName then
                    local textureCount = renderMesh:getMaterialTextureNum(j)
                    for t = 0, textureCount - 1 do
                        local textureName = renderMesh:getMaterialTextureName(j, t)
                        
                        if func.table_contains(MDFXL_Cache.playerBaseBodyParts.upper, matName) then
                            local upper = MDFXLSettings.isUpperBodyUnderArmor and "underarmor" or "skin"
                            local mapping = textureMap[textureName]
                            if mapping then
                                local resourceID = mapping[upper][genderKey]
                                local textureResource = func.create_resource(texResourceComp, resourceID)
                                renderMesh:setMaterialTexture(j, t, textureResource)
                            end
                        end
    
                        if func.table_contains(MDFXL_Cache.playerBaseBodyParts.lower, matName) then
                            local lower = MDFXLSettings.isLowerBodyUnderArmor and "underarmor" or "skin"
                            local mapping = textureMap[textureName]
                            if mapping then
                                local resourceID = mapping[lower][genderKey]
                                local textureResource = func.create_resource(texResourceComp, resourceID)
                                renderMesh:setMaterialTexture(j, t, textureResource)
                            end
                        end
                    end
                end
            end
        end
    end
end
local function update_PlayerBaseBody(MDFXLData)
    local scene = func.get_CurrentScene()
    if isFemale then
        playerBaseBody = scene:call("findGameObject(System.String)", "MDFXL_FPlayerBase")
    else
        playerBaseBody = scene:call("findGameObject(System.String)", "MDFXL_MPlayerBase")
    end

    if playerBaseBody then
        for _, equipment in pairs(MDFXLData) do
            if not func.table_contains(MDFXLSub.playerBaseBodyOrder, MDFXLData[equipment.MeshName].MeshName) then
                goto continue
            end
            if (MDFXLData[equipment.MeshName] and MDFXLData[equipment.MeshName].isUpdated) then
                if isFemale then
                    if equipment.MeshName == "MDFXL_FPlayerBase" then
                        set_MaterialParams(playerBaseBody, MDFXLData, equipment, MDFXLSaveDataChunks)
                        update_PlayerBaseBodyUnderarmor_MHWS(playerBaseBody)
                    end
                else
                    if equipment.MeshName == "MDFXL_MPlayerBase" then
                        set_MaterialParams(playerBaseBody, MDFXLData, equipment, MDFXLSaveDataChunks)
                        update_PlayerBaseBodyUnderarmor_MHWS(playerBaseBody)
                    end
                end
            end
            ::continue::
        end
    end
end
-- Preset Loaders
local function check_IfPartsMatch(presetParts, entryParts)
    if #presetParts ~= #entryParts then
        return false
    end
    for _, part in ipairs(presetParts) do
        local found = false
        for _, ogPart in ipairs(entryParts) do
            if part == ogPart then
                found = true
                break
            end
        end
        if not found then
            return false
        end
    end
    return true
end
local function check_DefaultOptions(preset, defaultPreset)
    for key, defaultValue in pairs(defaultPreset) do
        if preset[key] == nil then
            preset[key] = defaultValue
        elseif type(defaultValue) == "table" and type(preset[key]) == "table" then
            for subKey, subDefault in pairs(defaultValue) do
                if preset[key][subKey] == nil then
                    preset[key][subKey] = subDefault
                end
            end
        end
    end
    return preset
end
local function presetLoader_Type1(MDFXLData, MDFXLSubData, MDFXLSettingsData, entry, entryID, updateFuncsTbl)
    local selectedPreset = entry.Presets[entry.currentPresetIDX]
    if selectedPreset and selectedPreset ~= (entryID .. " Default") and entry.isInScene then
        wc = true
        local jsonPath = "MDF-XL\\Equipment\\" .. entryID .. "\\" .. selectedPreset .. ".json"
        local temp = json.load_file(jsonPath)
        if temp.Parts ~= nil then
            if MDFXLSettingsData.isDebug then
                log.info("[MDF-XL] [Auto Preset Loader Type-1: " .. entryID .. "]")
            end
            
            if check_IfPartsMatch(temp.Parts, entry.Parts) then
                if temp.presetVersion ~= MDFXLSettingsData.presetVersion then
                    temp = check_DefaultOptions(temp, MDFXL_Cache.defaultPreset)
                    log.info("[MDF-XL] [WARNING-000] [" .. entryID .. " Preset Version is outdated.]")
                    temp.presetVersion = MDFXLSettingsData.presetVersion
                end
                temp.Presets = nil
                temp.currentPresetIDX = nil

                for key, value in pairs(temp) do
                    entry[key] = value
                end
                for i, material in pairs(entry.Materials) do
                    if material["AddColorUV"] ~= nil then
                        material["AddColorUV"] = MDFXLSubData.playerSkinColorData
                    end
                    if material["Enable_VFXMaterialBlend"] ~= nil then
                        material["Enable_VFXMaterialBlend"] = {0.0}
                    end
                    if func.table_contains(MDFXL_Cache.playerBaseBodyParts.upper, i) and material["ColorLayer_B"] ~= nil then
                        local vec4 = Vector4f.new(material["ColorLayer_B"][1][1], material["ColorLayer_B"][1][2], material["ColorLayer_B"][1][3], material["ColorLayer_B"][1][4]) 
                        MDFXLSubData.playerUnderArmorColorData.upper = {vec4.x, vec4.y, vec4.z, vec4.w}
                    end
                    if func.table_contains(MDFXL_Cache.playerBaseBodyParts.lower, i) and material["ColorLayer_B"] ~= nil then
                        local vec4 = Vector4f.new(material["ColorLayer_B"][1][1], material["ColorLayer_B"][1][2], material["ColorLayer_B"][1][3], material["ColorLayer_B"][1][4]) 
                        MDFXLSubData.playerUnderArmorColorData.lower = {vec4.x, vec4.y, vec4.z, vec4.w}
                    end
                end
                entry.isUpdated = true
                isUpdaterBypass = true

                if updateFuncsTbl then
                    for _, updateFunc in ipairs(updateFuncsTbl) do
                        updateFunc(MDFXLData)
                    end
                end
            else
                log.info("[MDF-XL] [ERROR-000] [Parts do not match, skipping the update.]")
                entry.currentPresetIDX = 1
            end
        end
    else
        entry.currentPresetIDX = 1
    end
end
local function presetLoader_Type2(MDFXLData, MDFXLSubData, MDFXLSettingsData, entry, entryID, updateFuncsTbl, order)
    local lastPresetIDX = func.find_index(entry.Presets, MDFXLPresetTracker[entryID].lastPresetName)
    local selectedPreset = entry.Presets[lastPresetIDX]
    if (selectedPreset and isWeaponTransmogRequest) or (selectedPreset and selectedPreset ~= (entryID .. " Default")) then
        wc = true
        local jsonPath = "MDF-XL\\Equipment\\" .. entryID .. "\\" .. selectedPreset .. ".json"
        local temp = json.load_file(jsonPath)
        if temp.Parts ~= nil then
            if MDFXLSettingsData.isDebug then
                log.info("[MDF-XL] [Auto Preset Loader Type-2: " .. entryID .. "]")
            end
            
            if check_IfPartsMatch(temp.Parts, entry.Parts) then
                if temp.presetVersion ~= MDFXLSettingsData.presetVersion then
                    temp = check_DefaultOptions(temp, MDFXL_Cache.defaultPreset)
                    log.info("[MDF-XL] [WARNING-000] [" .. entryID .. " Preset Version is outdated.]")
                    temp.presetVersion = MDFXLSettingsData.presetVersion
                end
                temp.Presets = nil
                temp.currentPresetIDX = nil

                for key, value in pairs(temp) do
                    entry[key] = value
                end

                if order ~= "porterOrder" then
                    for i, material in pairs(entry.Materials) do
                        if material["AddColorUV"] ~= nil then
                            material["AddColorUV"] = MDFXLSubData.playerSkinColorData
                        end
                        if material["Enable_VFXMaterialBlend"] ~= nil then
                            material["Enable_VFXMaterialBlend"] = {0.0}
                        end
                        if order == "playerBaseBodyOrder" then
                            if func.table_contains(MDFXL_Cache.playerBaseBodyParts.upper, i) and material["ColorLayer_B"] ~= nil then
                                local vec4 = Vector4f.new(material["ColorLayer_B"][1][1], material["ColorLayer_B"][1][2], material["ColorLayer_B"][1][3], material["ColorLayer_B"][1][4]) 
                                MDFXLSubData.playerUnderArmorColorData.upper = {vec4.x, vec4.y, vec4.z, vec4.w}
                            end
                            if func.table_contains(MDFXL_Cache.playerBaseBodyParts.lower, i) and material["ColorLayer_B"] ~= nil then
                                local vec4 = Vector4f.new(material["ColorLayer_B"][1][1], material["ColorLayer_B"][1][2], material["ColorLayer_B"][1][3], material["ColorLayer_B"][1][4]) 
                                MDFXLSubData.playerUnderArmorColorData.lower = {vec4.x, vec4.y, vec4.z, vec4.w}
                            end
                        end
                    end
                end
                if isOutfitManagerBypass then
                    entry.currentPresetIDX = lastPresetIDX
                end
                entry.isUpdated = true
                isUpdaterBypass = true

                if updateFuncsTbl then
                    for _, updateFunc in ipairs(updateFuncsTbl) do
                        updateFunc(MDFXLData)
                    end
                end
            else
                log.info("[MDF-XL] [ERROR-000] [Parts do not match, skipping the update.]")
                entry.currentPresetIDX = 1
            end
        end
    else
        entry.currentPresetIDX = 1
    end
end
local function presetLoader_Type3(MDFXLData, MDFXLSubData, MDFXLSettingsData, entry, entryID, updateFunc, order)
    local selectedPreset = entry.Presets[entry.currentPresetIDX]
    local jsonPath = "MDF-XL\\Equipment\\" .. entryID .. "\\" .. selectedPreset .. ".json"
    local temp = json.load_file(jsonPath)
    if temp.Parts ~= nil then
        if MDFXLSettingsData.isDebug then
            log.info("[MDF-XL] [Manual Preset Loader Type-1: " .. entryID .. "]")
        end
        
        if check_IfPartsMatch(temp.Parts, entry.Parts) then
            if temp.presetVersion ~= MDFXLSettingsData.presetVersion then
                temp = check_DefaultOptions(temp, MDFXL_Cache.defaultPreset)
                log.info("[MDF-XL] [WARNING-000] [" .. entryID .. " Preset Version is outdated.]")
                temp.presetVersion = MDFXLSettingsData.presetVersion
            end
            temp.Presets = nil
            temp.currentPresetIDX = nil

            for key, value in pairs(temp) do
                entry[key] = value
            end
            for i, material in pairs(entry.Materials) do
                if material["AddColorUV"] ~= nil then
                    material["AddColorUV"] = MDFXLSubData.playerSkinColorData
                end
                if material["Enable_VFXMaterialBlend"] ~= nil then
                    material["Enable_VFXMaterialBlend"] = {0.0}
                end
                if order == "playerBaseBodyOrder" then
                    if func.table_contains(MDFXL_Cache.playerBaseBodyParts.upper, i) and material["ColorLayer_B"] ~= nil then
                        local vec4 = Vector4f.new(material["ColorLayer_B"][1][1], material["ColorLayer_B"][1][2], material["ColorLayer_B"][1][3], material["ColorLayer_B"][1][4]) 
                        MDFXLSubData.playerUnderArmorColorData.upper = {vec4.x, vec4.y, vec4.z, vec4.w}
                    end
                    if func.table_contains(MDFXL_Cache.playerBaseBodyParts.lower, i) and material["ColorLayer_B"] ~= nil then
                        local vec4 = Vector4f.new(material["ColorLayer_B"][1][1], material["ColorLayer_B"][1][2], material["ColorLayer_B"][1][3], material["ColorLayer_B"][1][4]) 
                        MDFXLSubData.playerUnderArmorColorData.lower = {vec4.x, vec4.y, vec4.z, vec4.w}
                    end
                end
            end
        else
            log.info("[MDF-XL] [ERROR-000] [Parts do not match, skipping the update.]")
            entry.currentPresetIDX = 1
        end
        if order == "playerBaseBodyOrder" then
            json.dump_file("MDF-XL/_Holders/MDF-XL_SubData.json", MDFXLSubData)
        end
    end

    if MDFXLSettingsData.isInheritPresetName then
        local trimmedName = selectedPreset:match("^(.-)__TAG") or selectedPreset:match("^(.-)__BY") or selectedPreset
        presetName = trimmedName
    end
    MDFXLPresetTracker[entryID].lastPresetName = selectedPreset
    isUpdaterBypass = true
    updateFunc(MDFXLData)
    local chunkID = entryID:sub(1, 4)
    if (chunkID == "ch02") or (chunkID == "ch03") then
        chunkID = entryID:sub(1, 8)
    end
    json.dump_file("MDF-XL/_Holders/_Chunks/MDF-XL_EquipmentData_" .. chunkID .. ".json", MDFXLSaveDataChunks[chunkID].data)
    json.dump_file("MDF-XL/_Holders/MDF-XL_PresetTracker.json", MDFXLPresetTracker)
end
local function presetLoader_Type4(MDFXLData, MDFXLSubData, MDFXLSettingsData, entry, entryID, updateFunc, order, finalPresetID)
    local savedPresetIDX = func.find_index(entry.Presets, finalPresetID)
    local selectedPreset = entry.Presets[savedPresetIDX]
    entry.currentPresetIDX = savedPresetIDX
    local jsonPath = [[MDF-XL\\Equipment\\]] .. entryID .. [[\\]] .. selectedPreset .. [[.json]]
    local temp = json.load_file(jsonPath)
    if temp.Parts ~= nil then
        if MDFXLSettingsData.isDebug then
            log.info("[MDF-XL] [Auto Preset Loader Type-3: " .. entryID .. "]")
        end
        
        if check_IfPartsMatch(temp.Parts, entry.Parts) then
            if temp.presetVersion ~= MDFXLSettingsData.presetVersion then
                temp = check_DefaultOptions(temp, MDFXL_Cache.defaultPreset)
                log.info("[MDF-XL] [WARNING-000] [" .. entryID .. " Preset Version is outdated.]")
                temp.presetVersion = MDFXLSettingsData.presetVersion
            end
            temp.Presets = nil
            temp.currentPresetIDX = nil

            for key, value in pairs(temp) do
                entry[key] = value
            end
            for i, material in pairs(entry.Materials) do
                if material["AddColorUV"] ~= nil then
                    material["AddColorUV"] = MDFXLSubData.playerSkinColorData
                end
                if material["Enable_VFXMaterialBlend"] ~= nil then
                    material["Enable_VFXMaterialBlend"] = {0.0}
                end
                if order == "playerBaseBodyOrder" then
                    if func.table_contains(MDFXL_Cache.playerBaseBodyParts.upper, i) and material["ColorLayer_B"] ~= nil then
                        local vec4 = Vector4f.new(material["ColorLayer_B"][1][1], material["ColorLayer_B"][1][2], material["ColorLayer_B"][1][3], material["ColorLayer_B"][1][4]) 
                        MDFXLSubData.playerUnderArmorColorData.upper = {vec4.x, vec4.y, vec4.z, vec4.w}
                    end
                    if func.table_contains(MDFXL_Cache.playerBaseBodyParts.lower, i) and material["ColorLayer_B"] ~= nil then
                        local vec4 = Vector4f.new(material["ColorLayer_B"][1][1], material["ColorLayer_B"][1][2], material["ColorLayer_B"][1][3], material["ColorLayer_B"][1][4]) 
                        MDFXLSubData.playerUnderArmorColorData.lower = {vec4.x, vec4.y, vec4.z, vec4.w}
                    end
                end
            end
        else
            log.info("[MDF-XL] [ERROR-000] [Parts do not match, skipping the update.]")
            entry.currentPresetIDX = 1
        end
        if order == "playerBaseBodyOrder" then
            json.dump_file("MDF-XL/_Settings/MDF-XL_Settings.json", MDFXLSettingsData)
            json.dump_file("MDF-XL/_Holders/MDF-XL_SubData.json", MDFXLSubData)
        end
    end

    MDFXLPresetTracker[entryID].lastPresetName = selectedPreset
    isUpdaterBypass = true
    updateFunc(MDFXLData)
    local chunkID = entryID:sub(1, 4)
    if (chunkID == "ch02") or (chunkID == "ch03") then
        chunkID = entryID:sub(1, 8)
    end
    json.dump_file("MDF-XL/_Holders/_Chunks/MDF-XL_EquipmentData_" .. chunkID .. ".json", MDFXLSaveDataChunks[chunkID].data)
    json.dump_file("MDF-XL/_Holders/MDF-XL_PresetTracker.json", MDFXLPresetTracker)
end
local function presetLoader_Type5(MDFXLData, MDFXLSubData, MDFXLSettingsData, entry, entryID, updateFunc, order, presetMap, filterIDX)
    entry.currentPresetIDX = presetMap[filterIDX]
                
    local selectedPreset = entry.Presets[entry.currentPresetIDX]
    local jsonPath = [[MDF-XL\\Equipment\\]] .. entryID .. [[\\]] .. selectedPreset .. [[.json]]
    local temp = json.load_file(jsonPath)
    if temp.Parts ~= nil then
        if MDFXLSettingsData.isDebug then
            log.info("[MDF-XL] [Manual Preset Loader Type-2: " .. entryID .. "]")
        end
        
        if check_IfPartsMatch(temp.Parts, entry.Parts) then
            if temp.presetVersion ~= MDFXLSettingsData.presetVersion then
                temp = check_DefaultOptions(temp, MDFXL_Cache.defaultPreset)
                log.info("[MDF-XL] [WARNING-000] [" .. entryID .. " Preset Version is outdated.]")
                temp.presetVersion = MDFXLSettingsData.presetVersion
            end
            temp.Presets = nil
            temp.currentPresetIDX = nil

            for key, value in pairs(temp) do
                entry[key] = value
            end
            for i, material in pairs(entry.Materials) do
                if material["AddColorUV"] ~= nil then
                    material["AddColorUV"] = MDFXLSubData.playerSkinColorData
                end
                if material["Enable_VFXMaterialBlend"] ~= nil then
                    material["Enable_VFXMaterialBlend"] = {0.0}
                end
                if order == "playerBaseBodyOrder" then
                    if func.table_contains(MDFXL_Cache.playerBaseBodyParts.upper, i) and material["ColorLayer_B"] ~= nil then
                        local vec4 = Vector4f.new(material["ColorLayer_B"][1][1], material["ColorLayer_B"][1][2], material["ColorLayer_B"][1][3], material["ColorLayer_B"][1][4]) 
                        MDFXLSubData.playerUnderArmorColorData.upper = {vec4.x, vec4.y, vec4.z, vec4.w}
                    end
                    if func.table_contains(MDFXL_Cache.playerBaseBodyParts.lower, i) and material["ColorLayer_B"] ~= nil then
                        local vec4 = Vector4f.new(material["ColorLayer_B"][1][1], material["ColorLayer_B"][1][2], material["ColorLayer_B"][1][3], material["ColorLayer_B"][1][4]) 
                        MDFXLSubData.playerUnderArmorColorData.lower = {vec4.x, vec4.y, vec4.z, vec4.w}
                    end
                end
            end
        else
            log.info("[MDF-XL] [ERROR-000] [Parts do not match, skipping the update.]")
            entry.currentPresetIDX = 1
        end
        if order == "weaponOrder" and temp.Transmog.ID ~= "" then
            lastTransmogEntryKey = temp.Transmog.ID
            isTransmogBypass = true
            isWeaponTransmogRequest = true
        end
        if order == "playerBaseBodyOrder" then
            json.dump_file("MDF-XL/_Holders/MDF-XL_SubData.json", MDFXLSubData)
        end
    end
    if MDFXLSettingsData.isInheritPresetName then
        local trimmedName = selectedPreset:match("^(.-)__TAG") or selectedPreset:match("^(.-)__BY") or selectedPreset
        presetName = trimmedName
    end
    if changed or wc then
       entry.isUpdated = true
    end
    MDFXLPresetTracker[entryID].lastPresetName = selectedPreset
    isUpdaterBypass = true
    
    updateFunc(MDFXLData)
    local chunkID = entryID:sub(1, 4)
    if (chunkID == "ch02") or (chunkID == "ch03") then
        chunkID = entryID:sub(1, 8)
    end
    json.dump_file("MDF-XL/_Holders/_Chunks/MDF-XL_EquipmentData_" .. chunkID .. ".json", MDFXLSaveDataChunks[chunkID].data)
    json.dump_file("MDF-XL/_Holders/MDF-XL_PresetTracker.json", MDFXLPresetTracker)
end
--Master Functions
local function manage_MasterMaterialData_MHWS(MDFXLData, MDFXLSubData, MDFXLSaveData)
    check_IfPlayerIsInScene_MHWS()
    check_IfOtomoIsInScene_MHWS()
    check_IfPorterIsInScene_MHWS()
    if masterDataCoroutine then
        local success, errorMsg = coroutine.resume(masterDataCoroutine)
        if not success then
            log.info("[MDF-XL-COR]  Master Data Coroutine error: " .. errorMsg)
            masterDataCoroutine = nil
        elseif coroutine.status(masterDataCoroutine) == "dead" then
            masterDataCoroutine = nil
        end
    end
    if loadingScreenCoroutine then
        local success, errorMsg = coroutine.resume(loadingScreenCoroutine)
        if not success then
            log.info("[MDF-XL-COR] Loading Screen Coroutine error: " .. errorMsg)
            loadingScreenCoroutine = nil
        elseif coroutine.status(loadingScreenCoroutine) == "dead" then
            loadingScreenCoroutine = nil
        end
    end
    if equipmentMenuCoroutine then
        local success, errorMsg = coroutine.resume(equipmentMenuCoroutine)
        if not success then
            log.info("[MDF-XL-COR] Equipment Menu Coroutine error: " .. errorMsg)
            equipmentMenuCoroutine = nil
        elseif coroutine.status(equipmentMenuCoroutine) == "dead" then
            equipmentMenuCoroutine = nil
        end
    end
    if outfitCoroutine then
        local success, errorMsg = coroutine.resume(outfitCoroutine)
        if not success then
            log.info("[MDF-XL-COR] Outfit coroutine error: " .. errorMsg)
            outfitCoroutine = nil
        elseif coroutine.status(outfitCoroutine) == "dead" then
            outfitCoroutine = nil
        end
    end
    if smithyCoroutine then
        local success, errorMsg = coroutine.resume(smithyCoroutine)
        if not success then
            log.info("[MDF-XL-COR] Smithy coroutine error: " .. errorMsg)
            smithyCoroutine = nil
        elseif coroutine.status(smithyCoroutine) == "dead" then
            smithyCoroutine = nil
        end
    end
    if campCoroutine then
        local success, errorMsg = coroutine.resume(campCoroutine)
        if not success then
            log.info("[MDF-XL-COR] Camp coroutine error: " .. errorMsg)
            campCoroutine = nil
        elseif coroutine.status(campCoroutine) == "dead" then
            campCoroutine = nil
        end
    end
    if transmogCoroutine then
        local success, errorMsg = coroutine.resume(transmogCoroutine)
        if not success then
            log.info("[MDF-XL-COR] Transmog coroutine error: " .. errorMsg)
            transmogCoroutine = nil
        elseif coroutine.status(transmogCoroutine) == "dead" then
            transmogCoroutine = nil
        end
    end
    --Initial Loading Screen Updater
    if isPlayerInScene and isNowLoading and not isDefaultsDumped and not isLoadingScreenUpdater and not masterDataCoroutine then
        masterDataCoroutine = coroutine.create(function()
            isTransmogBypass = true
            get_PlayerEquipmentMaterialParams_MHWS(MDFXLData, MDFXLSubData)
            coroutine.yield()
            get_PlayerArmamentMaterialParams_MHWS(MDFXLData, MDFXLSubData)
            get_PlayerSkinData_MHWS(MDFXLSubData)
            coroutine.yield()
            transmog_PlayerArmament_MHWS(MDFXLData, MDFXLDatabase, MDFXLTransmogTracker, MDFXLSubData.weaponOrder)
            coroutine.yield()
            get_OtomoEquipmentMaterialParams_MHWS(MDFXLData, MDFXLSubData)
            get_OtomoArmamentMaterialParams_MHWS(MDFXLData, MDFXLSubData)
            coroutine.yield()
            get_PorterMaterialParams_MHWS(MDFXLData, MDFXLSubData)
            spawn_PlayerBaseBody_MHWS()
            coroutine.yield()
            manage_SaveDataChunks(MDFXLData, MDFXLSaveData)
            dump_DefaultMaterialParamJSON_MHWS(MDFXLData)
            clear_MDFXLJSONCache_MHWS(MDFXLData, MDFXLSubData)
            cache_MDFXLJSONFiles_MHWS(MDFXLData, MDFXLSubData)
            coroutine.yield()
            json.dump_file("MDF-XL/_Settings/MDF-XL_Settings.json", MDFXLSettings)
            for _, chunk in pairs(MDFXLSaveData) do
                if chunk.wasUpdated then
                    json.dump_file(chunk.fileName, chunk.data)
                    chunk.wasUpdated = false
                end
            end
            json.dump_file("MDF-XL/_Holders/MDF-XL_SubData.json", MDFXLSubData)
            materialParamDefaultsHolder = func.deepcopy(MDFXLData)
            
            coroutine.yield()

            local counter = 0
            for _, equipment in pairs(MDFXLData) do
                local meshName = equipment.MeshName

                if not (
                    func.table_contains(MDFXLSubData.order, meshName) or 
                    func.table_contains(MDFXLSubData.weaponOrder, meshName) or 
                    func.table_contains(MDFXLSubData.otomoOrder, meshName) or 
                    func.table_contains(MDFXLSubData.otomoWeaponOrder, meshName) or 
                    func.table_contains(MDFXLSubData.porterOrder, meshName)
                ) then
                    goto continue
                end

                if equipment.Presets ~= nil then 
                    presetLoader_Type1(MDFXLData, MDFXLSubData, MDFXLSettings, equipment, meshName, {update_PlayerEquipmentMaterialParams_MHWS, update_PlayerArmamentMaterialParams_MHWS,
                    update_OtomoEquipmentMaterialParams_MHWS, update_OtomoArmamentMaterialParams_MHWS, update_PorterMaterialParams_MHWS})

                    if not func.table_contains(MDFXLPresetTracker, meshName) then
                        MDFXLPresetTracker[meshName] = {}
                    end
                    MDFXLPresetTracker[meshName].lastPresetName = equipment.Presets and equipment.Presets[equipment.currentPresetIDX]
                end

                counter = counter + 1
                if counter % 1 == 0 then
                    coroutine.yield()
                end
                ::continue::
            end

            for _, chunk in pairs(MDFXLSaveData) do
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
            isTransmogBypass = false
            isCoroutinesDone = true
        end)
    end
    --Subsequent Loading Screen Updater
    if isPlayerInScene and isNowLoading and isDefaultsDumped and not isLoadingScreenUpdater and not loadingScreenCoroutine then
        loadingScreenCoroutine = coroutine.create(function()
            isCoroutinesDone = false
            isTransmogBypass = true
            get_PlayerEquipmentMaterialParams_MHWS(MDFXLData, MDFXLSubData)
            coroutine.yield()
            get_PlayerArmamentMaterialParams_MHWS(MDFXLData, MDFXLSubData)
            get_PlayerSkinData_MHWS(MDFXLSubData)
            coroutine.yield()
            transmog_PlayerArmament_MHWS(MDFXLData, MDFXLDatabase, MDFXLTransmogTracker, MDFXLSubData.weaponOrder)
            coroutine.yield()
            get_OtomoEquipmentMaterialParams_MHWS(MDFXLData, MDFXLSubData)
            get_OtomoArmamentMaterialParams_MHWS(MDFXLData, MDFXLSubData)
            coroutine.yield()
            get_PorterMaterialParams_MHWS(MDFXLData, MDFXLSubData)
            spawn_PlayerBaseBody_MHWS()
            coroutine.yield()
            manage_SaveDataChunks(MDFXLData, MDFXLSaveData)
            dump_DefaultMaterialParamJSON_MHWS(MDFXLData)
            clear_MDFXLJSONCache_MHWS(MDFXLData, MDFXLSubData)
            cache_MDFXLJSONFiles_MHWS(MDFXLData, MDFXLSubData)
            coroutine.yield()
            json.dump_file("MDF-XL/_Settings/MDF-XL_Settings.json", MDFXLSettings)
            for i, chunk in pairs(MDFXLSaveData) do
                if chunk.wasUpdated then
                    json.dump_file(chunk.fileName, chunk.data)
                    chunk.wasUpdated = false
                end
            end
            json.dump_file("MDF-XL/_Holders/MDF-XL_SubData.json", MDFXLSubData)
            
            coroutine.yield()
            
            local counter = 0
            for _, equipment in pairs(MDFXLData) do
                local meshName = equipment.MeshName
                
                if not (
                    func.table_contains(MDFXLSubData.order, meshName) or 
                    func.table_contains(MDFXLSubData.weaponOrder, meshName) or 
                    func.table_contains(MDFXLSubData.otomoOrder, meshName) or 
                    func.table_contains(MDFXLSubData.otomoWeaponOrder, meshName) or 
                    func.table_contains(MDFXLSubData.porterOrder, meshName)
                ) then
                    goto continue
                end
                
                if not func.table_contains(materialParamDefaultsHolder, meshName, true) then
                    materialParamDefaultsHolder[meshName] = func.deepcopy(equipment)
                    MDFXLPresetTracker[meshName] = {}
                    MDFXLPresetTracker[meshName].lastPresetName = equipment.Presets[equipment.currentPresetIDX]
                    coroutine.yield()
                end
                
                if equipment.Presets ~= nil then
                    presetLoader_Type1(MDFXLData, MDFXLSubData, MDFXLSettings, equipment, meshName, {update_PlayerEquipmentMaterialParams_MHWS, update_PlayerArmamentMaterialParams_MHWS,
                    update_OtomoEquipmentMaterialParams_MHWS, update_OtomoArmamentMaterialParams_MHWS, update_PorterMaterialParams_MHWS})
                    
                    if not func.table_contains(MDFXLPresetTracker, meshName) then
                        MDFXLPresetTracker[meshName] = {}
                    end
                    MDFXLPresetTracker[meshName].lastPresetName = equipment.Presets[equipment.currentPresetIDX]
                end
                
                counter = counter + 1
                if counter % 1 == 0 then
                    coroutine.yield()
                end
                ::continue::
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
            isTransmogBypass = false
            isLoadingScreenUpdater = true
            isCoroutinesDone = true
        end)
    end
    --Equipment and Appearance Menu Updater
    if ((isPlayerLeftEquipmentMenu) or (isAppearanceEditorUpdater) or (isPlayerSwappedWeapons)) and isDefaultsDumped and not equipmentMenuCoroutine then
        equipmentMenuCoroutine = coroutine.create(function()
            isCoroutinesDone = false
            if not isPlayerSwappedWeapons then
                isTransmogBypass = true
            end
            if GUICharIDX == 0 then
                get_PlayerEquipmentMaterialParams_MHWS(MDFXLData, MDFXLSubData)
                get_PlayerArmamentMaterialParams_MHWS(MDFXLData, MDFXLSubData)
                coroutine.yield()
            elseif GUICharIDX == 1 then
                get_OtomoEquipmentMaterialParams_MHWS(MDFXLData, MDFXLSubData)
                get_OtomoArmamentMaterialParams_MHWS(MDFXLData, MDFXLSubData)
                coroutine.yield()
            end
            transmog_PlayerArmament_MHWS(MDFXLData, MDFXLDatabase, MDFXLTransmogTracker, MDFXLSubData.weaponOrder)
            coroutine.yield()
            manage_SaveDataChunks(MDFXLData, MDFXLSaveData)
            dump_DefaultMaterialParamJSON_MHWS(MDFXLData)
            clear_MDFXLJSONCache_MHWS(MDFXLData, MDFXLSubData)
            cache_MDFXLJSONFiles_MHWS(MDFXLData, MDFXLSubData)
            coroutine.yield()
            for i, chunk in pairs(MDFXLSaveData) do
                if chunk.wasUpdated then
                    json.dump_file(chunk.fileName, chunk.data)
                    chunk.wasUpdated = false
                end
            end
            json.dump_file("MDF-XL/_Holders/MDF-XL_SubData.json", MDFXLSubData)
            
            coroutine.yield()
            
            local counter = 0
            for _, equipment in pairs(MDFXLData) do
                local meshName = equipment.MeshName
                
                if GUICharIDX == 0 then
                    if not (func.table_contains(MDFXLSubData.order, meshName) or func.table_contains(MDFXLSubData.weaponOrder, meshName)) then
                        goto continue
                    end
                elseif GUICharIDX == 1 then
                    if not (func.table_contains(MDFXLSubData.otomoOrder, meshName) or  func.table_contains(MDFXLSubData.otomoWeaponOrder, meshName)) then
                        goto continue
                    end
                end
                
                if not func.table_contains(materialParamDefaultsHolder, meshName, true) then
                    materialParamDefaultsHolder[meshName] = func.deepcopy(equipment)
                    MDFXLPresetTracker[meshName] = {}
                    MDFXLPresetTracker[meshName].lastPresetName = equipment.Presets[equipment.currentPresetIDX]
                    coroutine.yield()
                end

                local updateFuncs = {}
                if GUICharIDX == 0 then
                    updateFuncs = {
                        update_PlayerEquipmentMaterialParams_MHWS,
                        update_PlayerArmamentMaterialParams_MHWS
                    }
                elseif GUICharIDX == 1 then
                    updateFuncs = {
                        update_OtomoEquipmentMaterialParams_MHWS,
                        update_OtomoArmamentMaterialParams_MHWS
                    }
                end

                presetLoader_Type2(MDFXLData, MDFXLSubData, MDFXLSettings, equipment, meshName, updateFuncs)
                
                counter = counter + 1
                if counter % 1 == 0 then
                    coroutine.yield()
                end
                ::continue::
            end
            
            for i, chunk in pairs(MDFXLSaveData) do
                if chunk.wasUpdated then
                    chunk.wasUpdated = false
                end
            end
            json.dump_file("MDF-XL/_Holders/MDF-XL_PresetTracker.json", MDFXLPresetTracker)
            if GUICharIDX == 0 then
                if isPlayerLeftEquipmentMenu then
                    log.info("[MDF-XL] [Player left the Equipment or Equipment Appearance Menu, MDF-XL data updated.]")
                elseif isAppearanceEditorUpdater then
                    log.info("[MDF-XL] [Player left the Appearance Editor Menu, MDF-XL data updated.]")
                elseif isPlayerSwappedWeapons then
                    log.info("[MDF-XL] [Player swapped weapons, MDF-XL data updated.]")
                end
            elseif GUICharIDX == 1 then
                log.info("[MDF-XL] [Player left the Palico Equipment or Palico Equipment Appearance Menu, MDF-XL data updated.]")
            end
            if not isPlayerSwappedWeapons then
                isTransmogBypass = false
            end
            isPlayerSwappedWeapons = false
            isAppearanceEditorUpdater = false
            isPlayerLeftEquipmentMenu = false
            isWeaponChangedCallCount = 0
            isCoroutinesDone = true
        end)
    end
    --Smithy Menu Updater
    if isPlayerLeftSmithy and isDefaultsDumped and not smithyCoroutine then
        smithyCoroutine = coroutine.create(function()
            isCoroutinesDone = false
            get_PlayerEquipmentMaterialParams_MHWS(MDFXLData, MDFXLSubData)
            get_PlayerArmamentMaterialParams_MHWS(MDFXLData, MDFXLSubData)
            coroutine.yield()
            isTransmogBypass = true
            transmog_PlayerArmament_MHWS(MDFXLData, MDFXLDatabase, MDFXLTransmogTracker, MDFXLSubData.weaponOrder)
            coroutine.yield()
            get_OtomoEquipmentMaterialParams_MHWS(MDFXLData, MDFXLSubData)
            get_OtomoArmamentMaterialParams_MHWS(MDFXLData, MDFXLSubData)
            coroutine.yield()
            
            manage_SaveDataChunks(MDFXLData, MDFXLSaveData)
            dump_DefaultMaterialParamJSON_MHWS(MDFXLData)
            clear_MDFXLJSONCache_MHWS(MDFXLData, MDFXLSubData)
            cache_MDFXLJSONFiles_MHWS(MDFXLData, MDFXLSubData)
            coroutine.yield()

            for i, chunk in pairs(MDFXLSaveData) do
                if chunk.wasUpdated then
                    json.dump_file(chunk.fileName, chunk.data)
                    chunk.wasUpdated = false
                end
            end
            json.dump_file("MDF-XL/_Holders/MDF-XL_SubData.json", MDFXLSubData)
            coroutine.yield()
            
            local counter = 0
            for _, equipment in pairs(MDFXLData) do
                local meshName = equipment.MeshName
                
                if not (
                    func.table_contains(MDFXLSubData.order, meshName) or 
                    func.table_contains(MDFXLSubData.weaponOrder, meshName) or 
                    func.table_contains(MDFXLSubData.otomoOrder, meshName) or 
                    func.table_contains(MDFXLSubData.otomoWeaponOrder, meshName)
                ) then
                    goto continue
                end
                
                if not func.table_contains(materialParamDefaultsHolder, meshName, true) then
                    materialParamDefaultsHolder[meshName] = func.deepcopy(equipment)
                    MDFXLPresetTracker[meshName] = {}
                    MDFXLPresetTracker[meshName].lastPresetName = equipment.Presets[equipment.currentPresetIDX]
                    coroutine.yield()
                end
                
                presetLoader_Type2(MDFXLData, MDFXLSubData, MDFXLSettings, equipment, meshName, {update_PlayerEquipmentMaterialParams_MHWS, update_PlayerArmamentMaterialParams_MHWS, 
                update_OtomoEquipmentMaterialParams_MHWS, update_OtomoArmamentMaterialParams_MHWS})

                counter = counter + 1
                if counter % 1 == 0 then
                    coroutine.yield()
                end
                ::continue::
            end
            
            for i, chunk in pairs(MDFXLSaveData) do
                if chunk.wasUpdated then
                    chunk.wasUpdated = false
                end
            end
            json.dump_file("MDF-XL/_Holders/MDF-XL_PresetTracker.json", MDFXLPresetTracker)
            log.info("[MDF-XL] [Player left the Smithy Menu, MDF-XL data updated.]")
           
            isPlayerLeftSmithy = false
            isCoroutinesDone = true
        end)
    end
    --Camp Menu Updater
    if ((isPlayerLeftCamp) or (isAppearanceSeikretEditor)) and isDefaultsDumped and isPlayerInScene and not campCoroutine then
        campCoroutine = coroutine.create(function()
            isCoroutinesDone = false
            get_PorterMaterialParams_MHWS(MDFXLData, MDFXLSubData)
            coroutine.yield()

            manage_SaveDataChunks(MDFXLData, MDFXLSaveData)
            coroutine.yield()
            
            dump_DefaultMaterialParamJSON_MHWS(MDFXLData)
            clear_MDFXLJSONCache_MHWS(MDFXLData, MDFXLSubData)
            cache_MDFXLJSONFiles_MHWS(MDFXLData, MDFXLSubData)
            coroutine.yield()
            
            for i, chunk in pairs(MDFXLSaveData) do
                if chunk.wasUpdated then
                    json.dump_file(chunk.fileName, chunk.data)
                    chunk.wasUpdated = false
                end
            end
            json.dump_file("MDF-XL/_Holders/MDF-XL_SubData.json", MDFXLSubData)
            coroutine.yield()

            local counter = 0
            for _, equipment in pairs(MDFXLData) do
                local meshName = equipment.MeshName

                if not func.table_contains(MDFXLSubData.porterOrder, meshName) then goto continue end

                if not func.table_contains(materialParamDefaultsHolder, meshName, true) then
                    materialParamDefaultsHolder[meshName] = func.deepcopy(equipment)
                    MDFXLPresetTracker[meshName] = {}
                    MDFXLPresetTracker[meshName].lastPresetName = equipment.Presets[equipment.currentPresetIDX]
                    coroutine.yield()
                end

                presetLoader_Type2(MDFXLData, MDFXLSubData, MDFXLSettings, equipment, meshName, {update_PorterMaterialParams_MHWS}, "porterOrder")

                counter = counter + 1
                if counter % 1 == 0 then
                    coroutine.yield()
                end
                ::continue::
            end
            for i, chunk in pairs(MDFXLSaveData) do
                if chunk.wasUpdated then
                    chunk.wasUpdated = false
                end
            end
            json.dump_file("MDF-XL/_Holders/MDF-XL_PresetTracker.json", MDFXLPresetTracker)
            if isPlayerLeftCamp then
                log.info("[MDF-XL] [Player left the Camp Menu, MDF-XL data updated.]")
                isPlayerLeftCamp = false
            elseif isAppearanceSeikretEditor then
                log.info("[MDF-XL] [Player left the Seikret Appearance Menu, MDF-XL data updated.]")
                isAppearanceSeikretEditor = false
            end
            isCoroutinesDone = true
        end)
    end
    --Outfit Preset Updater
    if isOutfitManagerBypass and not outfitCoroutine then
        outfitCoroutine = coroutine.create(function()
            isTransmogBypass = true
            isWeaponTransmogRequest = true
            manage_SaveDataChunks(MDFXLData, MDFXLSaveData)
            clear_MDFXLJSONCache_MHWS(MDFXLData, MDFXLSubData)
            cache_MDFXLJSONFiles_MHWS(MDFXLData, MDFXLSubData)
            
            local counter = 0
            for _, equipment in pairs(MDFXLData) do
                local meshName = equipment.MeshName
                
                if not ( 
                    func.table_contains(MDFXLSubData.order, meshName) or 
                    func.table_contains(MDFXLSubData.weaponOrder, meshName) or 
                    func.table_contains(MDFXLSubData.otomoOrder, meshName) or 
                    func.table_contains(MDFXLSubData.otomoWeaponOrder, meshName) or 
                    func.table_contains(MDFXLSubData.porterOrder, meshName) or 
                    func.table_contains(MDFXLSubData.playerBaseBodyOrder, meshName)
                ) then
                    goto continue
                end
                
                presetLoader_Type2(MDFXLData, MDFXLSubData, MDFXLSettings, equipment, meshName, {update_PlayerEquipmentMaterialParams_MHWS, update_PlayerArmamentMaterialParams_MHWS, 
                update_PlayerBaseBody, update_OtomoEquipmentMaterialParams_MHWS, update_OtomoArmamentMaterialParams_MHWS, update_PorterMaterialParams_MHWS})
                
                counter = counter + 1
                if counter % 1 == 0 then
                    coroutine.yield()
                end
                ::continue::
            end
            
            for _, chunk in pairs(MDFXLSaveData) do
                if chunk.wasUpdated then
                    json.dump_file(chunk.fileName, chunk.data)
                    chunk.wasUpdated = false
                end
            end
            
            json.dump_file("MDF-XL/_Holders/MDF-XL_SubData.json", MDFXLSubData)
            json.dump_file("MDF-XL/_Settings/MDF-XL_OutfitManagerSettings.json", MDFXLOutfits)
            log.info("[MDF-XL] [Outfit Preset loaded, MDF-XL data updated.]")
            isOutfitManagerBypass = false
        end)
    end
    --Sheathed Weapon and TalismanEFX Visibility Updater
    if isPlayerInScene and isDefaultsDumped then
        update_PlayerArmamentVisibility_MHWS()
        update_PlayerTalismanEffectVisibility_MHWS()
    end
    --Base Body Updater
    if isPlayerInScene and isDefaultsDumped and isPlayerBaseBodySetup then
        setup_PlayerBaseBody_MHWS(MDFXLData, MDFXLSubData)
        manage_SaveDataChunks(MDFXLData, MDFXLSaveData)
        dump_BaseBodyMaterialParamJSON_MHWS(MDFXLData)
        clear_BaseBody_MDFXLJSONCache_MHWS(MDFXLData, MDFXLSubData)
        cache_MDFXLJSONFiles_MHWS(MDFXLData, MDFXLSubData)
        lateSetup_PlayerBaseBody_MHWS(MDFXLData, MDFXLSubData)
        for i, chunk in pairs(MDFXLSaveData) do
            if chunk.wasUpdated then
                json.dump_file(chunk.fileName, chunk.data)
                chunk.wasUpdated = false
            end
        end
        for _, equipment in pairs(MDFXLData) do
            local meshName = equipment.MeshName
            if not func.table_contains(MDFXLSubData.playerBaseBodyOrder, meshName) then goto continue end
            if not func.table_contains(materialParamDefaultsHolder, meshName, true) then
                materialParamDefaultsHolder[meshName] = func.deepcopy(equipment)
                MDFXLPresetTracker[meshName] = {}
                MDFXLPresetTracker[meshName].lastPresetName = equipment.Presets[equipment.currentPresetIDX]
            end

            presetLoader_Type2(MDFXLData, MDFXLSubData, MDFXLSettings, equipment, meshName, {update_PlayerBaseBody}, "playerBaseBodyOrder")
            
            ::continue::
        end
        if isFemale then
            log.info("[MDF-XL] [Female Base Body Updated.]")
        else
            log.info("[MDF-XL] [Male Base Body Updated.]")
        end
        for i, chunk in pairs(MDFXLSaveData) do
            if chunk.wasUpdated then
                chunk.wasUpdated = false
            end
        end
        json.dump_file("MDF-XL/_Holders/MDF-XL_SubData.json", MDFXLSubData)
        json.dump_file("MDF-XL/_Holders/MDF-XL_PresetTracker.json", MDFXLPresetTracker)
        log.info("[MDF-XL] [Base Body Data Updated.]")
    end
    --Hunter Profile Updater
    if isPlayerInScene and isDefaultsDumped and isGuildCardDrawn and MDFXLSettings.isUpdateGuildCard then
        isUpdaterBypass = true
        update_GuildCardScene(MDFXLData)
    end
    --Weapon Transmog Updater
    if isPlayerInScene and isDefaultsDumped and isWeaponTransmogRequest and not transmogCoroutine then
        transmog_PlayerArmament_MHWS(MDFXLData, MDFXLDatabase, MDFXLTransmogTracker, MDFXLSubData.weaponOrder)
        transmogCoroutine = coroutine.create(function()
            isCoroutinesDone = false
            manage_SaveDataChunks(MDFXLData, MDFXLSaveData)
            dump_DefaultMaterialParamJSON_MHWS(MDFXLData)
            coroutine.yield()
            clear_MDFXLJSONCache_MHWS(MDFXLData, MDFXLSubData)
            cache_MDFXLJSONFiles_MHWS(MDFXLData, MDFXLSubData)
            coroutine.yield()
            for i, chunk in pairs(MDFXLSaveData) do
                if chunk.wasUpdated then
                    json.dump_file(chunk.fileName, chunk.data)
                    chunk.wasUpdated = false
                end
            end
            json.dump_file("MDF-XL/_Holders/MDF-XL_SubData.json", MDFXLSubData)
            coroutine.yield()
            local counter = 0
            for _, equipment in pairs(MDFXLData) do
                local meshName = equipment.MeshName
                
                if not string.find(meshName, "--") then goto continue end
                if not func.table_contains(MDFXLSubData.weaponOrder, meshName) then goto continue end
                
                if not func.table_contains(materialParamDefaultsHolder, meshName, true) then
                    materialParamDefaultsHolder[meshName] = func.deepcopy(equipment)
                    MDFXLPresetTracker[meshName] = {}
                    MDFXLPresetTracker[meshName].lastPresetName = equipment.Presets[equipment.currentPresetIDX]
                    coroutine.yield()
                end

                presetLoader_Type2(MDFXLData, MDFXLSubData, MDFXLSettings, equipment, meshName, {update_PlayerArmamentMaterialParams_MHWS})
                
                counter = counter + 1
                if counter % 1 == 0 then
                    coroutine.yield()
                end
                ::continue::
            end
            
            for i, chunk in pairs(MDFXLSaveData) do
                if chunk.wasUpdated then
                    chunk.wasUpdated = false
                end
            end
            coroutine.yield()
            json.dump_file("MDF-XL/_Holders/MDF-XL_PresetTracker.json", MDFXLPresetTracker)
            log.info("[MDF-XL] [Weapon Transmog Request Complete.]")
            isWeaponTransmogRequest = false
            isTransmogBypass = false
            isCoroutinesDone = true
        end)
    end
end
local function update_MDFXLViaHotkeys_MHWS()
    local KBM_Controls = not MDFXLSettings.useModifier or hk.check_hotkey("Modifier", true)
    local KBM_Controls2 = not MDFXLSettings.useModifier2 or hk.check_hotkey("Secondary Modifier", true)
    local KBM_OutfitChangeControls = not MDFXLSettings.useOutfitModifier or hk.check_hotkey("Outfit Change Modifier", true)
    local PAD_Controls = not MDFXLSettings.useOutfitPadModifier or hk.check_hotkey("GamePad Modifier", true)

    if (KBM_OutfitChangeControls and hk.check_hotkey("Outfit Next")) or (PAD_Controls and hk.check_hotkey("GamePad Outfit Next") and not isWeaponDrawn) then
        if isFemale then
            OutfitPresetTable = MDFXLOutfits.FPresets
        else
            OutfitPresetTable = MDFXLOutfits.MPresets
        end

        local outfitCount = func.countTableElements(OutfitPresetTable)
        MDFXLOutfits.currentOutfitPresetIDX = math.min(MDFXLOutfits.currentOutfitPresetIDX + 1, outfitCount)
        setup_OutfitChanger()
    end
    if (KBM_OutfitChangeControls and hk.check_hotkey("Outfit Previous")) or (PAD_Controls and hk.check_hotkey("GamePad Outfit Previous") and not isWeaponDrawn) then
        MDFXLOutfits.currentOutfitPresetIDX = math.max(MDFXLOutfits.currentOutfitPresetIDX - 1, 1)
        setup_OutfitChanger()
    end
    if (KBM_Controls and hk.check_hotkey("Toggle Main Weapon")) or (PAD_Controls and hk.check_hotkey("GamePad Toggle Main Weapon") and not isWeaponDrawn) then
        MDFXLSettings.isHideMainWeapon = not MDFXLSettings.isHideMainWeapon
        json.dump_file("MDF-XL/_Settings/MDF-XL_Settings.json", MDFXLSettings)
    end
    
    if (KBM_Controls and hk.check_hotkey("Toggle Sub Weapon")) or (PAD_Controls and hk.check_hotkey("GamePad Toggle Sub Weapon") and not isWeaponDrawn) then
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

    if KBM_Controls and hk.check_hotkey("Reset Last Layered Weapon") then
        for _, entryName in pairs(MDFXLSub["weaponOrder"]) do
            local entry = MDFXL[entryName]

            if entry.MeshName == lastLayeredWeaponStringHolder and not string.find(entry.MeshName, "Charm") and not string.find(entry.MeshName, "it12") and not string.find(entry.MeshName, "it13") then
                isTransmogBypass = true
                isWeaponTransmogRequest = true
                changed = true
                wc = true
                MDFXL[entry.MeshName].Transmog.ID = lastLayeredWeaponStringHolder:match("^(.-)%-%-")
                lastLayeredWeaponStringHolder = ""
            end
        end
    end
end
--Imgui Functions
local function setup_MDFXLEditorGUI_MHWS(MDFXLData, MDFXLDefaultsData, MDFXLSettingsData, MDFXLSubData, order, updateFunc, color01)
    for _, entryName in pairs(MDFXLSubData[order]) do
        local entry = MDFXLData[entryName]

        if entry then
            imgui.indent(15)
            local displayName = nil
            local baseName = entry.MeshName:match("^(.-)%-%-") or entry.MeshName
            local transmogID = entry.MeshName:match(".*%-%-(.+)$") or nil

            if MDFXLSettings.showEquipmentName and MDFXLDatabase.MHWS[entry.MeshName] then
                displayName = MDFXLDatabase.MHWS[entry.MeshName].Name
                if MDFXLSettings.showEquipmentType then
                    displayName = displayName .. " | " .. MDFXLDatabase.MHWS[entry.MeshName].Type .. " |"
                end
            else
                displayName = MDFXLDatabase.MHWS[baseName] and MDFXLDatabase.MHWS[baseName].Name or baseName
            end

            if transmogID and MDFXLDatabase.MHWS[transmogID] then
                displayName = displayName .. " > " .. MDFXLDatabase.MHWS[transmogID].Name
            end

            if imgui.tree_node(displayName) then
                imgui.begin_rect()
                imgui.spacing()
                
                imgui.text_colored("  " .. ui.draw_line("=", MDFXLSettingsData.tertiaryDividerLen) .."  ", func.convert_rgba_to_ABGR(ui.colors.white))
                imgui.indent(10)
                
                if order ~= "playerBaseBodyOrder" then
                    if imgui.button("Reset to Defaults") then
                        wc = true
                        isUpdaterBypass = true
                        MDFXLData[entry.MeshName].isUpdated = true
                        MDFXLData[entry.MeshName] = hk.recurse_def_settings({}, MDFXLDefaultsData[entry.MeshName])
                        manage_SaveDataChunks(MDFXLData, MDFXLSaveDataChunks)
                        clear_MDFXLJSONCache_MHWS(MDFXLData, MDFXLSubData)
                        cache_MDFXLJSONFiles_MHWS(MDFXLData, MDFXLSubData)
                        for i, chunk in pairs(MDFXLSaveDataChunks) do
                            if chunk.wasUpdated then
                                json.dump_file(chunk.fileName, chunk.data)
                                chunk.wasUpdated = false
                            end
                        end
                        updateFunc(MDFXLData)
                        json.dump_file("MDF-XL/_Holders/MDF-XL_SubData.json", MDFXLSubData)
                    end
                    func.tooltip("Reset all material and mesh parameters.")
                end

                if MDFXLSettingsData.showMeshName then
                    if order ~= "playerBaseBodyOrder" then
                        imgui.same_line()
                    end
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
                    imgui.pop_style_color()
                else
                    changed, MDFXLData[entry.MeshName].currentPresetIDX = imgui.combo("Preset", MDFXLData[entry.MeshName].currentPresetIDX or 1, MDFXLData[entry.MeshName].Presets); wc = wc or changed
                end
                func.tooltip("Select a file from the dropdown menu to load the variant from that file.")
                if changed then
                    presetLoader_Type3(MDFXLData, MDFXLSubData, MDFXLSettingsData, entry, entry.MeshName, updateFunc, order)
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
                    if order == "playerBaseBodyOrder" then
                        clear_BaseBody_MDFXLJSONCache_MHWS(MDFXLData, MDFXLSubData)
                    end
                    clear_MDFXLJSONCache_MHWS(MDFXLData, MDFXLSubData)
                    cache_MDFXLJSONFiles_MHWS(MDFXLData, MDFXLSubData)
                    json.dump_file("MDF-XL/_Holders/MDF-XL_SubData.json", MDFXLSubData)

                    if MDFXLSettingsData.isAutoLoadPresetAfterSave then
                        presetLoader_Type4(MDFXLData, MDFXLSubData, MDFXLSettingsData, entry, entry.MeshName, updateFunc, order, finalPresetName)
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

                if order == "weaponOrder" and not string.find(entry.MeshName, "Charm") and not string.find(entry.MeshName, "it12") and not string.find(entry.MeshName, "it13") then
                    imgui.text_colored("[ Layered Weapon ] " .. ui.draw_line("=", MDFXLSettingsData.tertiaryDividerLen - 30), func.convert_rgba_to_ABGR(ui.colors.orange))
                        if not entry.MeshName:match("^(.-)%-%-") then
                            changed, layeredWeaponSearchQuery = imgui.input_text("Weapon Search", layeredWeaponSearchQuery); wc = wc or changed
                            ui.button_CheckboxStyle("[ Aa ]", MDFXLSettings, "isSearchMatchCase", func.convert_rgba_to_ABGR(ui.colors.REFgray), func.convert_rgba_to_ABGR(ui.colors.gold), func.convert_rgba_to_ABGR(ui.colors.gold))
                            func.tooltip("Match Case")
                            imgui.same_line()
                            if imgui.button("Clear Search") then
                                layeredWeaponSearchQuery = ""
                            end
                            imgui.same_line()
                            imgui.text("Filters:")
                            imgui.same_line()
                            if imgui.button("[ Left ]") then
                                layeredWeaponSearchQuery = "(L)"
                            end
                            imgui.same_line()
                            if imgui.button("[ Right ]") then
                                layeredWeaponSearchQuery = "(R)"
                            end
                            imgui.same_line()
                            if imgui.button("[ Scabbard ]") then
                                layeredWeaponSearchQuery = "(Scabbard)"
                            end
                            imgui.same_line()
                            if imgui.button("[ Shield ]") then
                                layeredWeaponSearchQuery = "(Shield)"
                            end
                            imgui.same_line()
                            if imgui.button("[ Quiver ]") then
                                layeredWeaponSearchQuery = "(Quiver)"
                            end
                            
                            imgui.text_colored(ui.draw_line("-", math.floor(MDFXLSettingsData.primaryDividerLen / 2)), func.convert_rgba_to_ABGR(ui.colors.orange))

                            if MDFXLData[entry.MeshName].Transmog.ID ~= "" then
                                imgui.push_style_color(ui.ImGuiCol.Text, func.convert_rgba_to_ABGR(ui.colors.orange))
                                if imgui.button("[ Apply Layered Weapon ]") then
                                    isWeaponTransmogRequest = true
                                    lastTransmogEntryKey = entry.MeshName
                                end
                                imgui.pop_style_color()
                            else
                                imgui.push_style_color(ui.ImGuiCol.Text, func.convert_rgba_to_ABGR(ui.colors.white50))
                                imgui.button("[ Select a Weapon to Apply ]")
                                imgui.pop_style_color()
                            end
                            imgui.same_line()
                            changed, MDFXLSettingsData.isLayeredWeaponShowOnlySelfType = imgui.checkbox("Show Only Same Type", MDFXLSettingsData.isLayeredWeaponShowOnlySelfType); wc = wc or changed
                                    
                            imgui.spacing()
                            
                            local combos = {
                                {label = "Great Sword",         wpType = 0},
                                {label = "Sword and Shield",    wpType = 1},
                                {label = "Dual Blades",         wpType = 2},
                                {label = "Long Sword",          wpType = 3},
                                {label = "Hammer",              wpType = 4},
                                {label = "Hunting Horn",        wpType = 5},
                                {label = "Lance",               wpType = 6},
                                {label = "Gunlance",            wpType = 7},
                                {label = "Switch Axe",          wpType = 8},
                                {label = "Charge Blade",        wpType = 9},
                                {label = "Insect Glaive",       wpType = 10},
                                {label = "Bow",                 wpType = 11},
                            }
                            
                            local currentID = MDFXLData[entry.MeshName].Transmog.ID or ""
                            
                            for _, combo in ipairs(combos) do
                                if not MDFXLSettingsData.isLayeredWeaponShowOnlySelfType or (MDFXLSettingsData.isLayeredWeaponShowOnlySelfType and combo.wpType == MDFXLDatabase.MHWS[entry.MeshName].WPType) then
                                    local filteredWeapons = {}
                                    local weapons = weaponLists[combo.wpType]
                                    for i, w in ipairs(weapons) do
                                        if layeredWeaponSearchQuery == "" then
                                            table.insert(filteredWeapons, w)
                                        else
                                            local match = false
                                            if MDFXLSettingsData.isSearchMatchCase then
                                                match = string.find(w.name, layeredWeaponSearchQuery, 1, true) ~= nil
                                            else
                                                match = string.find(w.name:lower(), layeredWeaponSearchQuery:lower(), 1, true) ~= nil
                                            end
                                            if match then
                                                table.insert(filteredWeapons, w)
                                            end
                                        end
                                    end


                                    local names = {}
                                    for i, w in ipairs(filteredWeapons) do
                                        names[i] = w.name
                                    end
                                                
                                    local selectedIndex = 1
                                    for i, w in ipairs(filteredWeapons) do
                                        if w.key == currentID then
                                            selectedIndex = i
                                            break
                                        end
                                    end
                                                
                                    changed, newIDX = imgui.combo(combo.label, selectedIndex, names); wc = wc or changed
                                    if changed then
                                        local selectedWeapon = filteredWeapons[newIDX]
                                        MDFXLData[entry.MeshName].Transmog.ID = selectedWeapon.key
                                        currentID = selectedWeapon.key
                                    end
                                    imgui.spacing()
                                end
                            end
                        else
                            imgui.spacing()
                            if imgui.button("Reset to Default Weapon") then
                                isTransmogBypass = true
                                isWeaponTransmogRequest = true
                                changed = true
                                wc = true
                                MDFXLData[entry.MeshName].Transmog.ID = entry.MeshName:match("^(.-)%-%-")
                                lastTransmogEntryKey = entry.MeshName:match("^(.-)%-%-")
                            end
                            imgui.spacing()
                        end
                        if imgui.tree_node("Attach Options") then
                            imgui.spacing()
                            changed, MDFXLData[entry.MeshName].Transmog.isUseBaseParams = imgui.checkbox("Use Base Parameters", MDFXLData[entry.MeshName].Transmog.isUseBaseParams); wc = wc or changed
                            if changed and MDFXLData[entry.MeshName].Transmog.isOverride then
                                MDFXLData[entry.MeshName].Transmog.isOverride = false
                            end
                            imgui.same_line()
                            changed, MDFXLData[entry.MeshName].Transmog.isOverride = imgui.checkbox("Override", MDFXLData[entry.MeshName].Transmog.isOverride); wc = wc or changed
                            if changed and MDFXLData[entry.MeshName].Transmog.isUseBaseParams then
                                MDFXLData[entry.MeshName].Transmog.isUseBaseParams = false
                            end
                            
                            local POS = Vector3f.new(MDFXLData[entry.MeshName].Transmog.POS.x, MDFXLData[entry.MeshName].Transmog.POS.y, MDFXLData[entry.MeshName].Transmog.POS.z)
                            changed, POS = imgui.drag_float3("Position", POS, MDFXLSettingsData.attachPosIncrement, -180.0, 180.0); wc = wc or changed
                            MDFXLData[entry.MeshName].Transmog.POS.x = POS.x
                            MDFXLData[entry.MeshName].Transmog.POS.y = POS.y
                            MDFXLData[entry.MeshName].Transmog.POS.z = POS.z
                            
                            local ROT = Vector3f.new(MDFXLData[entry.MeshName].Transmog.ROT.x, MDFXLData[entry.MeshName].Transmog.ROT.y, MDFXLData[entry.MeshName].Transmog.ROT.z)
                            changed, ROT = imgui.drag_float3("Rotation", ROT, MDFXLSettingsData.attachRotIncrement, -360.0, 360.0); wc = wc or changed
                            MDFXLData[entry.MeshName].Transmog.ROT.x = ROT.x
                            MDFXLData[entry.MeshName].Transmog.ROT.y = ROT.y
                            MDFXLData[entry.MeshName].Transmog.ROT.z = ROT.z
                            
                            changed, MDFXLSettingsData.isUniformScale = imgui.checkbox("Uniform Scale", MDFXLSettingsData.isUniformScale); wc = wc or changed

                            if MDFXLSettingsData.isUniformScale then
                                local unifromScale = MDFXLData[entry.MeshName].Transmog.Scale.x
                                changed, unifromScale = imgui.drag_float("Scale", unifromScale, MDFXLSettingsData.attachScaleIncrement, 0.0, 100.0); wc = wc or changed
                                MDFXLData[entry.MeshName].Transmog.Scale.x = unifromScale
                                MDFXLData[entry.MeshName].Transmog.Scale.y = unifromScale
                                MDFXLData[entry.MeshName].Transmog.Scale.z = unifromScale
                            else
                                local Scale = Vector3f.new(MDFXLData[entry.MeshName].Transmog.Scale.x, MDFXLData[entry.MeshName].Transmog.Scale.y, MDFXLData[entry.MeshName].Transmog.Scale.z)
                                changed, Scale = imgui.drag_float3("Scale", Scale, MDFXLSettingsData.attachScaleIncrement, 0.0, 100.0); wc = wc or changed
                                MDFXLData[entry.MeshName].Transmog.Scale.x = Scale.x
                                MDFXLData[entry.MeshName].Transmog.Scale.y = Scale.y
                                MDFXLData[entry.MeshName].Transmog.Scale.z = Scale.z
                            end
                            imgui.tree_pop()
                        end
                    imgui.text_colored(ui.draw_line("=", MDFXLSettingsData.tertiaryDividerLen - 15), func.convert_rgba_to_ABGR(ui.colors.orange))    
                end
                               
                if imgui.tree_node("Mesh Editor") then
                    isMeshEditor[entry.MeshName] = true
                    imgui.spacing()
                    imgui.text_colored(ui.draw_line("=", MDFXLSettingsData.tertiaryDividerLen - 15), func.convert_rgba_to_ABGR(ui.colors.gold))
                    imgui.indent(15)
                    if imgui.tree_node("Flags") then
                        isFlagEditor[entry.MeshName] = true
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
                        if MDFXLData[entry.MeshName].Flags.isShadowCastEnable == MDFXLDefaultsData[entry.MeshName].Flags.isShadowCastEnable or MDFXLData[entry.MeshName].Flags.isShadowCastEnable ~= MDFXLDefaultsData[entry.MeshName].Flags.isShadowCastEnable then
                            changed, MDFXLData[entry.MeshName].Flags.isShadowCastEnable = imgui.checkbox("Shadow Cast", MDFXLData[entry.MeshName].Flags.isShadowCastEnable); wc = wc or changed
                            if MDFXLData[entry.MeshName].Flags.isShadowCastEnable ~= MDFXLDefaultsData[entry.MeshName].Flags.isShadowCastEnable then
                                imgui.same_line()
                                imgui.text_colored("*", func.convert_rgba_to_ABGR(ui.colors.cerulean))
                            end
                        end
                        imgui.tree_pop()
                    else
                        isFlagEditor[entry.MeshName] = false
                    end
                    
                    if order == "playerBaseBodyOrder" then
                        imgui.text_colored(ui.draw_line("-", math.floor(MDFXLSettingsData.primaryDividerLen / 2)), func.convert_rgba_to_ABGR(ui.colors.gold))

                        changed, MDFXLSettingsData.isUpperBodyUnderArmor = imgui.checkbox("Show Undershirt", MDFXLSettingsData.isUpperBodyUnderArmor); wc = wc or changed
                        imgui.same_line()
                        changed, MDFXLSettingsData.isLowerBodyUnderArmor = imgui.checkbox("Show Tights", MDFXLSettingsData.isLowerBodyUnderArmor); wc = wc or changed

                        imgui.spacing()

                        local newUpperColor = Vector4f.new(MDFXLSubData.playerUnderArmorColorData.upper[1], MDFXLSubData.playerUnderArmorColorData.upper[2], MDFXLSubData.playerUnderArmorColorData.upper[3], MDFXLSubData.playerUnderArmorColorData.upper[4])
                        changed, newUpperColor = imgui.color_edit4("Undershirt Color", newUpperColor, nil); wc = wc or changed
                        if changed then
                            for matName, matData in pairs(MDFXLData[entry.MeshName].Materials) do
                                if func.table_contains(MDFXL_Cache.playerBaseBodyParts.upper, matName) then
                                    for paramName, paramValue in pairs(matData) do
                                        if type(paramValue) == "table" and type(paramValue[1]) == "table" and paramName == "ColorLayer_B" then
                                            for i, value in ipairs(paramValue) do
                                                paramValue[i] = {newUpperColor.x, newUpperColor.y, newUpperColor.z, newUpperColor.w}
                                                lastMatParamName = "ColorLayer_B"
                                            end
                                            wc = true
                                        end
                                    end
                                end
                            end
                        end
                        MDFXLSubData.playerUnderArmorColorData.upper = {newUpperColor.x, newUpperColor.y, newUpperColor.z, newUpperColor.w}
                        
                        imgui.spacing()

                        local newLowerColor = Vector4f.new(MDFXLSubData.playerUnderArmorColorData.lower[1], MDFXLSubData.playerUnderArmorColorData.lower[2], MDFXLSubData.playerUnderArmorColorData.lower[3], MDFXLSubData.playerUnderArmorColorData.lower[4])
                        changed, newLowerColor = imgui.color_edit4("Tights Color", newLowerColor, nil); wc = wc or changed
                        if changed then
                            for matName, matData in pairs(MDFXLData[entry.MeshName].Materials) do
                                if func.table_contains(MDFXL_Cache.playerBaseBodyParts.lower, matName) then
                                    for paramName, paramValue in pairs(matData) do
                                        if type(paramValue) == "table" and type(paramValue[1]) == "table" and paramName == "ColorLayer_B" then
                                            for i, value in ipairs(paramValue) do
                                                paramValue[i] = {newLowerColor.x, newLowerColor.y, newLowerColor.z, newLowerColor.w}
                                                lastMatParamName = "ColorLayer_B"
                                            end
                                            wc = true
                                        end
                                    end
                                end
                            end
                        end
                        MDFXLSubData.playerUnderArmorColorData.lower = {newLowerColor.x, newLowerColor.y, newLowerColor.z, newLowerColor.w}
                    end

                    imgui.text_colored(ui.draw_line("-", math.floor(MDFXLSettingsData.primaryDividerLen / 2)), func.convert_rgba_to_ABGR(ui.colors.gold))
                    if imgui.button("Clear Highlights") then
                        MDFXLSubData.matPartHighlights = {}
                        json.dump_file("MDF-XL/_Holders/MDF-XL_SubData.json", MDFXLSubData)
                    end
                    
                    imgui.same_line()

                    local sortedParts = {}
                    for i, partName in ipairs(MDFXLData[entry.MeshName].Parts) do
                        table.insert(sortedParts, {index = i, name = partName})
                    end
                    table.sort(sortedParts, function(a, b)
                        return a.name < b.name
                    end)
                    
                    if imgui.button("Show All") then
                        for _, entryData in ipairs(sortedParts) do
                            MDFXLData[entry.MeshName].Enabled[entryData.index] = true
                        end
                        wc = true
                    end
                    
                    imgui.same_line()
                    
                    if imgui.button("Hide All") then
                        for _, entryData in ipairs(sortedParts) do
                            MDFXLData[entry.MeshName].Enabled[entryData.index] = false
                        end
                        wc = true
                    end
                    
                    if order == "playerBaseBodyOrder" then
                        imgui.same_line()
                        
                        if isUpperBodyToggle then
                            if imgui.button("Show Upper Body") then
                                for _, entryData in ipairs(sortedParts) do
                                    if func.table_contains(MDFXL_Cache.playerBaseBodyUpper, entryData.name) then
                                        MDFXLData[entry.MeshName].Enabled[entryData.index] = true
                                    end
                                end
                                wc = true
                                isUpperBodyToggle = false
                            end
                        else
                            if imgui.button("Hide Upper Body") then
                                for _, entryData in ipairs(sortedParts) do
                                    if func.table_contains(MDFXL_Cache.playerBaseBodyUpper, entryData.name) then
                                        MDFXLData[entry.MeshName].Enabled[entryData.index] = false
                                    end
                                end
                                wc = true
                                isUpperBodyToggle = true
                            end
                        end

                        imgui.same_line()
                        
                        if isLowerBodyToggle then
                            if imgui.button("Show Lower Body") then
                                for _, entryData in ipairs(sortedParts) do
                                    if func.table_contains(MDFXL_Cache.playerBaseBodyLower, entryData.name) then
                                        MDFXLData[entry.MeshName].Enabled[entryData.index] = true
                                    end
                                end
                                wc = true
                                isLowerBodyToggle = false
                            end
                        else
                            if imgui.button("Hide Lower Body") then
                                for _, entryData in ipairs(sortedParts) do
                                    if func.table_contains(MDFXL_Cache.playerBaseBodyLower, entryData.name) then
                                        MDFXLData[entry.MeshName].Enabled[entryData.index] = false
                                    end
                                end
                                wc = true
                                isLowerBodyToggle = true
                            end
                        end
                    end

                    imgui.spacing()

                    for _, entryData in ipairs(sortedParts) do
                        local i = entryData.index
                        local partName = entryData.name
                    
                        local enabledMeshPart = MDFXLData[entry.MeshName].Enabled[i]
                        local defaultEnabledMeshPart = MDFXLDefaultsData[entry.MeshName].Enabled[i]
                    
                        if enabledMeshPart == defaultEnabledMeshPart or enabledMeshPart ~= defaultEnabledMeshPart then
                            changed, enabledMeshPart = imgui.checkbox(partName, enabledMeshPart); wc = wc or changed
                            if imgui.begin_popup_context_item() then
                                if not func.table_contains(MDFXLSubData.matPartHighlights, partName) then
                                    if imgui.menu_item("Highlight") then
                                        wc = true
                                        table.insert(MDFXLSubData.matPartHighlights, partName)
                                        json.dump_file("MDF-XL/_Holders/MDF-XL_SubData.json", MDFXLSubData)
                                    end
                                else
                                    if imgui.menu_item("Remove Highlight") then
                                        local highlightIDX = func.find_index(MDFXLSubData.matPartHighlights, paramName)
                                        wc = true
                                        table.remove(MDFXLSubData.matPartHighlights, highlightIDX)
                                        json.dump_file("MDF-XL/_Holders/MDF-XL_SubData.json", MDFXLSubData)
                                    end
                                end
                                imgui.end_popup()
                            end
                            MDFXLData[entry.MeshName].Enabled[i] = enabledMeshPart
                            if enabledMeshPart ~= defaultEnabledMeshPart then
                                imgui.same_line()
                                imgui.text_colored("*", func.convert_rgba_to_ABGR(ui.colors.cerulean))
                            end
                            if func.table_contains(MDFXLSubData.matPartHighlights, partName) then
                                imgui.same_line()
                                imgui.text_colored("*", func.convert_rgba_to_ABGR(ui.colors.orange))
                            end
                        end
                    end
                    imgui.indent(-15)
                    imgui.text_colored(ui.draw_line("=", MDFXLSettingsData.tertiaryDividerLen - 15), func.convert_rgba_to_ABGR(ui.colors.gold))
                    imgui.tree_pop()
                else
                    isMeshEditor[entry.MeshName] = false
                end
                if order ~= "playerBaseBodyOrder" then
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
                                    elseif func.table_contains(MDFXLSubData.matPartHighlights, partName) then
                                        imgui.push_style_color(ui.ImGuiCol.Text, func.convert_rgba_to_ABGR(ui.colors.orange))
                                    else
                                        imgui.push_style_color(ui.ImGuiCol.Text, func.convert_rgba_to_ABGR(ui.colors.white))
                                    end
                                end
                            end
                            if imgui.tree_node(matName) then
                                imgui.push_id(matName)
                                imgui.pop_style_color()
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
                                                isUpdaterBypass = true
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
                                
                                if entry.TextureCount[matName] ~= 0 and matName ~= "skin" then
                                    if imgui.tree_node("Textures") then
                                        isTextureEditor[MDFXLData[entry.MeshName].Materials[matName]] = true
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
                                                    imgui.pop_style_color()
                                                end
                                                imgui.pop_id()
                                                
                                                imgui.end_rect()
                                                imgui.spacing()
                                            end
                                        end
                                        imgui.text_colored(ui.draw_line("=", MDFXLSettingsData.tertiaryDividerLen - 15), func.convert_rgba_to_ABGR(ui.colors.cerulean))
                                        imgui.tree_pop()
                                    else
                                        isTextureEditor[MDFXLData[entry.MeshName].Materials[matName]] = false
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
                                        if func.table_contains(MDFXLSubData.matParamFavorites, paramName) then
                                            imgui.pop_style_color()
                                        end
                                        imgui.end_rect()
                                        
                                    end
                                end
                                imgui.pop_id()
                                imgui.spacing()
                                imgui.tree_pop()
                            end
                        end
                        imgui.pop_style_color()
                        imgui.indent(-5)
                        imgui.text_colored(ui.draw_line("=", MDFXLSettingsData.tertiaryDividerLen - 15), func.convert_rgba_to_ABGR(ui.colors.cerulean))
                        imgui.tree_pop()
                    end
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
    if (not isDraw) or (isPlayerLeftEquipmentMenu) or (not isCoroutinesDone) or (isWeaponTransmogRequest) then return end
    
    imgui.text_colored(ui.draw_line("=", MDFXLSettingsData.presetManager.secondaryDividerLen) ..  " // " .. displayText .. " // ", func.convert_rgba_to_ABGR(color01))
    imgui.indent(10)
    if order == "playerBaseBodyOrder" then
        changed, MDFXLSettingsData.isUpperBodyUnderArmor = imgui.checkbox("Show Undershirt", MDFXLSettingsData.isUpperBodyUnderArmor); wc = wc or changed
        if changed then
            if isFemale then
                MDFXLData["MDFXL_FPlayerBase"].isUpdated = true
            else
                MDFXLData["MDFXL_MPlayerBase"].isUpdated = true
            end
            update_PlayerBaseBody(MDFXLData)
        end
        imgui.same_line()
        changed, MDFXLSettingsData.isLowerBodyUnderArmor = imgui.checkbox("Show Tights", MDFXLSettingsData.isLowerBodyUnderArmor); wc = wc or changed
        if changed then
            if isFemale then
                MDFXLData["MDFXL_FPlayerBase"].isUpdated = true
            else
                MDFXLData["MDFXL_MPlayerBase"].isUpdated = true
            end
            update_PlayerBaseBody(MDFXLData)
        end
    end
    if order == "order" then
        changed, MDFXLSettingsData.isHideTalismanEffect = imgui.checkbox("Hide Talisman EFX", MDFXLSettingsData.isHideTalismanEffect); wc = wc or changed
    end
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
        local baseName = entry.MeshName:match("^(.-)%-%-") or entry.MeshName
        local transmogID = entry.MeshName:match(".*%-%-(.+)$") or nil
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
                displayName = displayName .. " | " .. MDFXLDatabase.MHWS[entry.MeshName].Type .. " |"
            end
        else
            displayName = MDFXLDatabase.MHWS[baseName] and MDFXLDatabase.MHWS[baseName].Name or baseName
        end

        if transmogID and MDFXLDatabase.MHWS[transmogID] then
            displayName = displayName .. " > " .. MDFXLDatabase.MHWS[transmogID].Name
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
            if MDFXLPresetTracker[entry.MeshName].lastPresetName ~= nil and MDFXLPresetTracker[entry.MeshName].lastPresetName ~= entry.MeshName .. " Default" then
                imgui.push_style_color(ui.ImGuiCol.Border, func.convert_rgba_to_ABGR(color01))
                imgui.begin_rect()
                if order == "weaponOrder" and string.find(entry.MeshName, "--", 1, true) then
                    if imgui.arrow_button(_, 0) then
                        isWeaponTransmogRequest = true
                        MDFXLData[entry.MeshName].Transmog.ID = entry.MeshName:match("^(.-)%-%-")
                    end
                    if imgui.is_item_hovered() then
                        lastTransmogEntryKey = entry.MeshName
                    end
                    ui.tooltip("Reset to Default Weapon")
                    imgui.push_item_width(MDFXLSettingsData.presetManager.menuWidth - 30)
                    imgui.same_line()
                end
                changed, currentFilteredIDX = imgui.combo(displayName .. " ", currentFilteredIDX or 1, displayPresets); wc = wc or changed
                imgui.end_rect()
                imgui.pop_style_color()
            else
                if order == "weaponOrder" and string.find(entry.MeshName, "--", 1, true) then
                    if imgui.arrow_button(_, 0) then
                        isWeaponTransmogRequest = true
                        MDFXLData[entry.MeshName].Transmog.ID = entry.MeshName:match("^(.-)%-%-")
                    end
                    if imgui.is_item_hovered() then
                        lastTransmogEntryKey = entry.MeshName
                    end
                    ui.tooltip("Reset to Default Weapon")
                    imgui.push_item_width(MDFXLSettingsData.presetManager.menuWidth - 30)
                    imgui.same_line()
                end
                changed, currentFilteredIDX = imgui.combo(displayName .. " ", currentFilteredIDX or 1, displayPresets); wc = wc or changed
            end
            imgui.pop_item_width()
            if changed then
                presetLoader_Type5(MDFXLData, MDFXLSubData, MDFXLSettingsData, entry, entry.MeshName, updateFunc, order, presetIndexMap, currentFilteredIDX)
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
        if isFemale then
            OutfitPresetTable = MDFXLOutfits.FPresets
        else
            OutfitPresetTable = MDFXLOutfits.MPresets
        end

        changed, MDFXLOutfits.currentOutfitPresetIDX = imgui.combo("Outfit Preset", MDFXLOutfits.currentOutfitPresetIDX or 1, OutfitPresetTable); wc = wc or changed
        if changed then
            local selected_preset = OutfitPresetTable[MDFXLOutfits.currentOutfitPresetIDX]
            local json_filepath = ""
            if isFemale then
                json_filepath = [[MDF-XL\\Outfits\\Female\\]] .. selected_preset .. [[.json]]
            else
                json_filepath = [[MDF-XL\\Outfits\\Male\\]] .. selected_preset .. [[.json]]
            end
            local temp_parts = json.load_file(json_filepath)
            wc = true
            if temp_parts ~= nil then
                for key, value in pairs(temp_parts) do
                    MDFXLPresetTracker[key].lastPresetName = value.lastPresetName
                end
                isOutfitManagerBypass = true
                json.dump_file("MDF-XL/_Holders/MDF-XL_PresetTracker.json", MDFXLPresetTracker)
            end
            json.dump_file("MDF-XL/_Settings/MDF-XL_OutfitManagerSettings.json", MDFXLOutfits)
        end
        changed, outfitName = imgui.input_text("", outfitName); wc = wc or changed
        imgui.pop_item_width()
        imgui.same_line()
        if imgui.button("Save Outfit Preset") then
            local MDFXLOutfitData = {}
            for i, equipment in pairs(MDFXL) do
                if not func.table_contains(MDFXLSub.order, MDFXL[equipment.MeshName].MeshName) and not func.table_contains(MDFXLSub.weaponOrder, MDFXL[equipment.MeshName].MeshName)
                and not func.table_contains(MDFXLSub.otomoOrder, MDFXL[equipment.MeshName].MeshName) and not func.table_contains(MDFXLSub.otomoWeaponOrder, MDFXL[equipment.MeshName].MeshName)
                and not func.table_contains(MDFXLSub.porterOrder, MDFXL[equipment.MeshName].MeshName) and not func.table_contains(MDFXLSub.playerBaseBodyOrder, MDFXL[equipment.MeshName].MeshName) then
                    goto continue
                end

                if MDFXLPresetTracker[equipment.MeshName].lastPresetName ~= equipment.MeshName .. " Default" then
                    MDFXLOutfitData[equipment.MeshName] = {}
                    if MDFXLOutfits.isBody then
                        if func.table_contains(MDFXLSub.playerBaseBodyOrder, equipment.MeshName) then
                            MDFXLOutfitData[equipment.MeshName].lastPresetName = ""
                            MDFXLOutfitData[equipment.MeshName].lastPresetName = MDFXLPresetTracker[equipment.MeshName].lastPresetName
                        end
                    end
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
                ::continue::
            end
            if isFemale then
                json.dump_file("MDF-XL/Outfits/Female/" .. outfitName .. ".json", MDFXLOutfitData)
            else
                json.dump_file("MDF-XL/Outfits/Male/" .. outfitName .. ".json", MDFXLOutfitData)
            end
            json.dump_file("MDF-XL/_Settings/MDF-XL_OutfitManagerSettings.json", MDFXLOutfits)
            cache_MDFXLJSONFiles_MHWS(MDFXL, MDFXLSub)
        end

        imgui.spacing()
        changed, MDFXLOutfits.isBody = imgui.checkbox("Include Body", MDFXLOutfits.isBody); wc = wc or changed
        changed, MDFXLOutfits.isHunterEquipment = imgui.checkbox("Include Hunter: Armor", MDFXLOutfits.isHunterEquipment); wc = wc or changed
        changed, MDFXLOutfits.isHunterArmament = imgui.checkbox("Include Hunter: Weapon", MDFXLOutfits.isHunterArmament); wc = wc or changed
        changed, MDFXLOutfits.isOtomoEquipment = imgui.checkbox("Include Palico: Armor", MDFXLOutfits.isOtomoEquipment); wc = wc or changed
        changed, MDFXLOutfits.isOtomoArmament = imgui.checkbox("Include Palico: Weapon", MDFXLOutfits.isOtomoArmament); wc = wc or changed
        changed, MDFXLOutfits.isPorter = imgui.checkbox("Include Seikret", MDFXLOutfits.isPorter); wc = wc or changed
        if wc or changed then
            json.dump_file("MDF-XL/_Settings/MDF-XL_OutfitManagerSettings.json", MDFXLOutfits)
        end
        if isFemale then
            setup_MDFXLPresetGUI_MHWS(MDFXL, MDFXLSettings, MDFXLSub, "playerBaseBodyOrder", update_PlayerBaseBody, "Body: Female", ui.colors.highContrast.purple, MDFXLOutfits.isBody)
        else
            setup_MDFXLPresetGUI_MHWS(MDFXL, MDFXLSettings, MDFXLSub, "playerBaseBodyOrder", update_PlayerBaseBody, "Body: Male", ui.colors.highContrast.purple, MDFXLOutfits.isBody)
        end
        setup_MDFXLPresetGUI_MHWS(MDFXL, MDFXLSettings, MDFXLSub, "order", update_PlayerEquipmentMaterialParams_MHWS, "Hunter: Armor", ui.colors.gold, MDFXLOutfits.isHunterEquipment)
        setup_MDFXLPresetGUI_MHWS(MDFXL, MDFXLSettings, MDFXLSub, "weaponOrder", update_PlayerArmamentMaterialParams_MHWS, "Hunter: Weapon", ui.colors.orange, MDFXLOutfits.isHunterArmament)
        setup_MDFXLPresetGUI_MHWS(MDFXL, MDFXLSettings, MDFXLSub, "otomoOrder", update_OtomoEquipmentMaterialParams_MHWS, "Palico: Armor", ui.colors.cyan, MDFXLOutfits.isOtomoEquipment)
        setup_MDFXLPresetGUI_MHWS(MDFXL, MDFXLSettings, MDFXLSub, "otomoWeaponOrder", update_OtomoArmamentMaterialParams_MHWS, "Palico: Weapon", ui.colors.cerulean, MDFXLOutfits.isOtomoArmament)
        setup_MDFXLPresetGUI_MHWS(MDFXL, MDFXLSettings, MDFXLSub, "porterOrder", update_PorterMaterialParams_MHWS, "Seikret", ui.colors.lime, MDFXLOutfits.isPorter)
        
       
        imgui.indent(-25)
        imgui.text_colored("  [ " .. ui.draw_line("=", math.floor(MDFXLSettings.presetManager.primaryDividerLen * 0.75))  .. " ] ", func.convert_rgba_to_ABGR(ui.colors.white))
        imgui.end_rect(1)
        imgui.tree_pop()
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
local function draw_MDFXLBodyEditorGUI_MHWS()
    if imgui.begin_window("MDF-XL: Body Editor") then
        imgui.begin_rect()
        
        imgui.text_colored("[ " .. ui.draw_line("=", MDFXLSettings.primaryDividerLen)  .. " ]", func.convert_rgba_to_ABGR(ui.colors.white))
        imgui.indent(25)

        if isFemale then
            imgui.text_colored(ui.draw_line("=", MDFXLSettings.secondaryDividerLen) ..  " // Body: Female // ", func.convert_rgba_to_ABGR(ui.colors.highContrast.purple))
            setup_MDFXLEditorGUI_MHWS(MDFXL, materialParamDefaultsHolder, MDFXLSettings, MDFXLSub, "playerBaseBodyOrder", update_PlayerBaseBody, ui.colors.highContrast.purple)
        else
            imgui.text_colored(ui.draw_line("=", MDFXLSettings.secondaryDividerLen) ..  " // Body: Male // ", func.convert_rgba_to_ABGR(ui.colors.highContrast.purple))
            setup_MDFXLEditorGUI_MHWS(MDFXL, materialParamDefaultsHolder, MDFXLSettings, MDFXLSub, "playerBaseBodyOrder", update_PlayerBaseBody, ui.colors.highContrast.purple)
        end

        imgui.indent(-25)
        imgui.text_colored("[ " .. ui.draw_line("=", MDFXLSettings.primaryDividerLen)  .. " ]", func.convert_rgba_to_ABGR(ui.colors.white))

        imgui.end_rect()
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
        imgui.same_line()
        changed, isBodyEditor = imgui.checkbox("Body Editor", isBodyEditor); wc = wc or changed
        func.tooltip("Show/Hide the Body Editor.")
        if not isBodyEditor or imgui.begin_window("MDF-XL: Body Editor", true, 0) == false  then
            isBodyEditor = false
        else
            imgui.spacing()
            imgui.indent()
            
            draw_MDFXLBodyEditorGUI_MHWS()

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
        imgui.tree_pop()
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
        if isFemale then
            OutfitPresetTable = MDFXLOutfits.FPresets
        else
            OutfitPresetTable = MDFXLOutfits.MPresets
        end

        local currentOutfitPreset = OutfitPresetTable[MDFXLOutfits.currentOutfitPresetIDX]
        local filteredIDX = nil

        for _, preset in ipairs(OutfitPresetTable) do
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
            if isFemale then
                OutfitPresetTable = MDFXLOutfits.FPresets
            else
                OutfitPresetTable = MDFXLOutfits.MPresets
            end

            for i, preset in ipairs(OutfitPresetTable) do
                if preset == selected_preset then
                    MDFXLOutfits.currentOutfitPresetIDX = i
                    break
                end
            end
    
            local json_filepath = ""
            if isFemale then
                json_filepath = [[MDF-XL\\Outfits\\Female\\]] .. selected_preset .. [[.json]]
            else
                json_filepath = [[MDF-XL\\Outfits\\Male\\]] .. selected_preset .. [[.json]]
            end
            local temp_parts = json.load_file(json_filepath)
            wc = true
            if temp_parts ~= nil then
                for key, value in pairs(temp_parts) do
                    MDFXLPresetTracker[key].lastPresetName = value.lastPresetName
                end
                isOutfitManagerBypass = true
                json.dump_file("MDF-XL/_Holders/MDF-XL_PresetTracker.json", MDFXLPresetTracker)
            end
            json.dump_file("MDF-XL/_Settings/MDF-XL_OutfitManagerSettings.json", MDFXLOutfits)
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
    if isFemale then
        setup_MDFXLPresetGUI_MHWS(MDFXL, MDFXLSettings, MDFXLSub, "playerBaseBodyOrder", update_PlayerBaseBody, "Body: Female", ui.colors.highContrast.purple, MDFXLSettings.presetManager.showBaseBody)
    else
        setup_MDFXLPresetGUI_MHWS(MDFXL, MDFXLSettings, MDFXLSub, "playerBaseBodyOrder", update_PlayerBaseBody, "Body: Male", ui.colors.highContrast.purple, MDFXLSettings.presetManager.showBaseBody)
    end
    setup_MDFXLPresetGUI_MHWS(MDFXL, MDFXLSettings, MDFXLSub, "order", update_PlayerEquipmentMaterialParams_MHWS, "Hunter: Armor", ui.colors.gold, MDFXLSettings.presetManager.showHunterEquipment)
    setup_MDFXLPresetGUI_MHWS(MDFXL, MDFXLSettings, MDFXLSub, "weaponOrder", update_PlayerArmamentMaterialParams_MHWS, "Hunter: Weapon", ui.colors.orange, MDFXLSettings.presetManager.showHunterArmament)
    setup_MDFXLPresetGUI_MHWS(MDFXL, MDFXLSettings, MDFXLSub, "otomoOrder", update_OtomoEquipmentMaterialParams_MHWS, "Palico: Armor", ui.colors.cyan, MDFXLSettings.presetManager.showOtomoEquipment)
    setup_MDFXLPresetGUI_MHWS(MDFXL, MDFXLSettings, MDFXLSub, "otomoWeaponOrder", update_OtomoArmamentMaterialParams_MHWS, "Palico: Weapon", ui.colors.cerulean, MDFXLSettings.presetManager.showOtomoArmament)
    setup_MDFXLPresetGUI_MHWS(MDFXL, MDFXLSettings, MDFXLSub, "porterOrder", update_PorterMaterialParams_MHWS, "Seikret", ui.colors.lime, MDFXLSettings.presetManager.showPorter)
    imgui.text_colored(ui.draw_line("-", MDFXLSettings.presetManager.primaryDividerLen), func.convert_rgba_to_ABGR(ui.colors.white))
end
local function load_MDFXLEditorAndPresetGUI_MHWS()
    if not isCoroutinesDone then 
        coroutineProgress = coroutineProgress + 0.12
        
        imgui.push_style_color(ui.ImGuiCol.PlotHistogram, func.convert_rgba_to_ABGR(ui.colors.highContrast.blue))
        imgui.progress_bar(coroutineProgress, Vector2f.new(280, 15), string.format("Updating MDF-XL Data...", coroutineProgress * 100))
        imgui.pop_style_color()
        return 
    else
        coroutineProgress = 0.0
    end
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
            imgui.text(MDFXLUserManual.About[098])
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
            imgui.text(MDFXLUserManual.Editor[113])
            imgui.spacing()
            imgui.text(MDFXLUserManual.Editor[114])
            imgui.text(MDFXLUserManual.Editor[115])
            imgui.text(MDFXLUserManual.Editor[116])
            imgui.spacing()
            imgui.text_colored(MDFXLUserManual.Editor[117], func.convert_rgba_to_ABGR(ui.colors.orange))
            imgui.text(MDFXLUserManual.Editor[118])
            imgui.text(MDFXLUserManual.Editor[119])
            imgui.text_colored(ui.draw_line("-", 100), func.convert_rgba_to_ABGR(ui.colors.gold))
            imgui.indent(-10)
            imgui.tree_pop()
        end
        if imgui.tree_node(MDFXLUserManual.BodyEditor.header) then
            imgui.spacing()
            imgui.indent(10)
            imgui.text_colored(ui.draw_line("-", 100), func.convert_rgba_to_ABGR(ui.colors.gold))
            imgui.text(MDFXLUserManual.BodyEditor[150])
            imgui.spacing()
            imgui.text(MDFXLUserManual.BodyEditor[151])
            imgui.text_colored(ui.draw_line("-", 100), func.convert_rgba_to_ABGR(ui.colors.gold))
            imgui.indent(-10)
            imgui.tree_pop()
        end
        if imgui.tree_node(MDFXLUserManual.ColorPalettes.header) then
            imgui.spacing()
            imgui.indent(10)
            imgui.text_colored(ui.draw_line("-", 100), func.convert_rgba_to_ABGR(ui.colors.gold))
            imgui.text(MDFXLUserManual.ColorPalettes[155])
            imgui.text_colored(ui.draw_line("-", 100), func.convert_rgba_to_ABGR(ui.colors.gold))
            imgui.indent(-10)
            imgui.tree_pop()
        end
        if imgui.tree_node(MDFXLUserManual.OutfitManager.header) then
            imgui.spacing()
            imgui.indent(10)
            imgui.text_colored(ui.draw_line("-", 100), func.convert_rgba_to_ABGR(ui.colors.gold))
            imgui.text(MDFXLUserManual.OutfitManager[160])
            imgui.spacing()
            imgui.text(MDFXLUserManual.OutfitManager[161])
            imgui.text(MDFXLUserManual.OutfitManager[162])
            imgui.spacing()
            imgui.text(MDFXLUserManual.OutfitManager[163])
            imgui.spacing()
            imgui.text(MDFXLUserManual.OutfitManager[164])
            imgui.text_colored(ui.draw_line("-", 100), func.convert_rgba_to_ABGR(ui.colors.gold))
            imgui.indent(-10)
            imgui.tree_pop()
        end
        if imgui.tree_node(MDFXLUserManual.LayeredWeapons.header) then
            imgui.spacing()
            imgui.indent(10)
            imgui.text_colored(ui.draw_line("-", 100), func.convert_rgba_to_ABGR(ui.colors.gold))
            imgui.text(MDFXLUserManual.LayeredWeapons[165])
            imgui.spacing()
            imgui.text(MDFXLUserManual.LayeredWeapons[166])
            imgui.text_colored(ui.draw_line("-", 100), func.convert_rgba_to_ABGR(ui.colors.gold))
            imgui.indent(-10)
            imgui.tree_pop()
        end
        imgui.indent(-15)
        imgui.spacing()
        if imgui.tree_node(MDFXLUserManual.PackagingPresets.header) then
            imgui.spacing()
            imgui.indent(10)
            imgui.text_colored(ui.draw_line("-", 100), func.convert_rgba_to_ABGR(ui.colors.gold))
            imgui.text(MDFXLUserManual.PackagingPresets[170])
            imgui.text(MDFXLUserManual.PackagingPresets[171])
            imgui.spacing()
            imgui.text(MDFXLUserManual.PackagingPresets[172])
            imgui.spacing()
            imgui.text(MDFXLUserManual.PackagingPresets[173])
            imgui.text(MDFXLUserManual.PackagingPresets[174])
            imgui.push_id(175)
            imgui.push_item_width(500)
            imgui.input_text("", MDFXLUserManual.Links[297])
            imgui.pop_id()
            imgui.text_colored(ui.draw_line("-", 100), func.convert_rgba_to_ABGR(ui.colors.gold))
            imgui.indent(-10)
            imgui.tree_pop()
        end
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
                changed, MDFXLSettings.attachPosIncrement = imgui.drag_float("Attach Position Increment", MDFXLSettings.attachPosIncrement, 0.001, 0.0, 100.0); wc = wc or changed
                changed, MDFXLSettings.attachRotIncrement = imgui.drag_float("Attach Rotation Increment", MDFXLSettings.attachRotIncrement, 0.001, 0.0, 100.0); wc = wc or changed
                changed, MDFXLSettings.attachScaleIncrement = imgui.drag_float("Attach Scale Increment", MDFXLSettings.attachScaleIncrement, 0.001, 0.0, 100.0); wc = wc or changed
                imgui.spacing()
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
                changed, MDFXLSettings.presetManager.showBaseBody = imgui.checkbox("Show Base Body Presets", MDFXLSettings.presetManager.showBaseBody); wc = wc or changed
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
                imgui.same_line()
                imgui.text_colored("*", func.convert_rgba_to_ABGR(ui.colors.gold))
                changed = hk.hotkey_setter("Toggle Color Palettes", MDFXLSettings.useModifier and "Modifier"); wc = wc or changed
                imgui.same_line()
                imgui.text_colored("*", func.convert_rgba_to_ABGR(ui.colors.gold))
                changed = hk.hotkey_setter("Toggle Filter Favorites", MDFXLSettings.useModifier and "Modifier"); wc = wc or changed
                imgui.same_line()
                imgui.text_colored("*", func.convert_rgba_to_ABGR(ui.colors.gold))
                changed = hk.hotkey_setter("Toggle Main Weapon", MDFXLSettings.useModifier and "Modifier"); wc = wc or changed
                imgui.same_line()
                imgui.text_colored("**", func.convert_rgba_to_ABGR(ui.colors.orange))
                changed = hk.hotkey_setter("Toggle Sub Weapon", MDFXLSettings.useModifier and "Modifier"); wc = wc or changed
                imgui.same_line()
                imgui.text_colored("**", func.convert_rgba_to_ABGR(ui.colors.orange))
                changed = hk.hotkey_setter("Clear Outfit Search", MDFXLSettings.useModifier and "Modifier"); wc = wc or changed
                changed = hk.hotkey_setter("Reset Last Layered Weapon", MDFXLSettings.useModifier and "Modifier"); wc = wc or changed
                imgui.same_line()
                imgui.text_colored("*", func.convert_rgba_to_ABGR(ui.colors.gold))

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
                imgui.text_colored("**", func.convert_rgba_to_ABGR(ui.colors.orange))
                changed = hk.hotkey_setter("GamePad Outfit Next", MDFXLSettings.useOutfitPadModifier and "GamePad Modifier"); wc = wc or changed
                imgui.same_line()
                imgui.text_colored("**", func.convert_rgba_to_ABGR(ui.colors.orange))
                changed = hk.hotkey_setter("GamePad Toggle Main Weapon", MDFXLSettings.useOutfitPadModifier and "GamePad Modifier"); wc = wc or changed
                imgui.same_line()
                imgui.text_colored("**", func.convert_rgba_to_ABGR(ui.colors.orange))
                changed = hk.hotkey_setter("GamePad Toggle Sub Weapon", MDFXLSettings.useOutfitPadModifier and "GamePad Modifier"); wc = wc or changed
                imgui.same_line()
                imgui.text_colored("**", func.convert_rgba_to_ABGR(ui.colors.orange))
                
                imgui.spacing()

                imgui.text_colored("[ Legend ]", func.convert_rgba_to_ABGR(ui.colors.white50))
                imgui.spacing()

                imgui.text_colored("* MDF-XL Editor must be open.", func.convert_rgba_to_ABGR(ui.colors.gold))
                imgui.text_colored("** Weapon must be sheathed.", func.convert_rgba_to_ABGR(ui.colors.orange))
                
                imgui.tree_pop()
            end
            if imgui.tree_node("Hunter Profile") then
                imgui.indent(5)
                if imgui.button("Update Hunter Profile Scene") then
                    MDFXLSettings.isUpdateGuildCard = true
                else
                    MDFXLSettings.isUpdateGuildCard = false
                end
                changed, MDFXLSettings.isHideGuildCardGUI = imgui.checkbox("Hide All GUI", MDFXLSettings.isHideGuildCardGUI);wc = wc or changed
                changed, MDFXLSettings.isHideGuildCardOverlayGUI = imgui.checkbox("Hide Overlay GUI", MDFXLSettings.isHideGuildCardOverlayGUI);wc = wc or changed
                changed, MDFXLSettings.isNullGuildCardBG01 = imgui.checkbox("Hide Scene-01 Background", MDFXLSettings.isNullGuildCardBG01);wc = wc or changed
                imgui.spacing()
                changed, MDFXLSettings.isHideGuildCardHunter = imgui.checkbox("Hide Hunter", MDFXLSettings.isHideGuildCardHunter);wc = wc or changed
                changed, MDFXLSettings.isHideGuildCardOtomo = imgui.checkbox("Hide Palico", MDFXLSettings.isHideGuildCardOtomo);wc = wc or changed
                changed, MDFXLSettings.isHideGuildCardPorter = imgui.checkbox("Hide Seikret", MDFXLSettings.isHideGuildCardPorter);wc = wc or changed
                imgui.indent(-5)
                imgui.tree_pop()
            end
            if imgui.tree_node("Stats") then
                imgui.indent(5)
                if imgui.button("Refresh Stats") then
                    MDFXLSettings.stats.equipmentDataVarCount = func.countTableElements(MDFXL)
                    MDFXLSettings.stats.textureCount = func.countTableElements(MDFXLSub.texturePaths)
                    MDFXLSettings.stats.presetCount = func.countTableElements(MDFXLSub.jsonPaths)
                    if isFemale then
                        OutfitPresetTable = MDFXLOutfits.FPresets
                    else
                        OutfitPresetTable = MDFXLOutfits.MPresets
                    end
                    MDFXLSettings.stats.outfitPresetCount = func.countTableElements(OutfitPresetTable)
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
                hk.update_hotkey_table(MDFXLSettings.hotkeys)
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
            update_PlayerBaseBody(MDFXL)
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
--MARK:On Reset Script
re.on_script_reset(function()
    materialParamDefaultsHolder = {}
    MDFXLSub.jsonPaths = {}
    playerBaseBody = nil
end)