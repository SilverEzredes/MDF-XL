--/////////////////////////////////////--
-- MDF XL Docs

-- Author: SilverEzredes
-- Updated: 04/20/2024
-- Version: v1.0.0

--/////////////////////////////////////--
local func = require("_SharedCore\\Functions")

local function MDFXL_Docs_Chapter_01()
    if imgui.tree_node("1.1 - Overview") then
        imgui.spacing()
        imgui.indent(10)
        imgui.text("MDF-XL is a runtime material editor with a preset system that allows for a high level of customization with excellent compatibility.")
        imgui.spacing()
        imgui.text("MDF-XL consists of three main components: MDF-XL, MDF-XL Editor, and the MDF-XL Outfit Manager.")
        imgui.spacing()
        imgui.text("[MDF-XL] This is the menu under Script Generated UI in the REF UI, where you can change the preset of your armor and change some of the tool settings.")
        imgui.spacing()
        imgui.text("[MDF-XL Editor] This is where you can access the Material and Mesh Editors. The Material Editor allows you to modify the material parameters, such as color, of your currently equipped armor.\nThe Mesh Editor allows you to hide or unhide parts of your armor, and this is where you can save presets.")
        imgui.spacing()
        imgui.text("[MDF-XL Outfit Manager] This is where you can save all your currently applied presets to an outfit preset, allowing you to load multiple presets at once.")
        imgui.spacing()
        imgui.indent(-10)
        imgui.tree_pop()
    end
    if imgui.tree_node("1.2 - Reporting a bug") then
        imgui.spacing()
        imgui.indent(10)
        imgui.text("If you're experiencing crashes or technical difficulties, please upload a screenshot of the error under 'ScriptRunner' along with your")
        imgui.text_colored("re2_framework_log.txt", 0xFF00BBFF)
        func.tooltip("[YourSteamLibrary/steamapps/common/Dragons Dogma 2/re2_framework_log.txt]\nThe same folder where the DD2.exe can be found.")
        imgui.same_line()
        imgui.text("file from the game's root folder.")
        imgui.spacing()
        imgui.text("If the error is specific to a mesh or material, please enable Debug Mode in the MDF-XL settings before\nuploading your re2_framework_log.txt. Debug Mode is disabled by default.")
        imgui.spacing()
        imgui.indent(-10)
        imgui.tree_pop()
    end
    if imgui.tree_node("1.3 - Troubleshooting") then
        imgui.spacing()
        imgui.indent(10)
        imgui.text("I'm getting a ScriptRunner Error Message when I boot up the game. It mentions something about hotkeys.")
        imgui.indent(15)
        imgui.text("You're either missing one of the requirements, which is _ScriptCore, or your version of _ScriptCore is outdated.\nMDF-XL requires _ScriptCore version 1.1.3 or newer.")
        imgui.indent(-15)
        imgui.spacing()
        imgui.spacing()
        imgui.text("MDF-XL used to work, but now I'm getting 2 FPS, and ScriptRunner mentions something about a nil value.")
        imgui.indent(15)
        imgui.text("MDF-XL encountered an issue it couldn't handle. If restarting the game doesn't resolve the problem, navigate to\n[YourSteamLibrary/steamapps/common/Dragons Dogma 2/reframework/data/MDF-XL/] and delete the '__Holders' folder.")
        imgui.indent(-15)
        imgui.spacing()
        imgui.spacing()
        imgui.text("If none of the above, then contact me on the Modding Haven discord server, or submit a bug report.")
        imgui.spacing()
        imgui.indent(-10)
        imgui.tree_pop()
    end
    if imgui.tree_node("1.4 - FAQ") then
        imgui.spacing()
        imgui.indent(10)
        imgui.text("Q: Will this affect random NPCs in the game world?")
        imgui.text("A: No, it won't. Everything is only applied to the player.")
        imgui.spacing()
        imgui.text("Q: How can I edit my main pawn's outfit?")
        imgui.text("A: You can't at the moment.")
        imgui.spacing()
        imgui.text("Q: Will you add support for X?")
        imgui.text("A: I won't promise anything, but I'd like to add support for weapons.")
        imgui.spacing()
        imgui.text("Q: Will this mod affect performance?")
        imgui.text("A: The only noticeable performance impact is during loading screens when everything must be applied.")
        imgui.spacing()
        imgui.indent(-10)
        imgui.tree_pop()
    end
    if imgui.tree_node("1.5 - Credits") then
        imgui.spacing()
        imgui.indent(10)
        imgui.text("praydog for creating REFramework.")
        imgui.text("alphaZomega for his work on EMV, which heavily inspired this tool, and for his guidance.")
        imgui.text("koune_samson, baronbeefbowl, b00marrows, Dimpleboob, mellamocarlos, hakz01, darckray, jenya66, lupercal2024, tempjen_90619 and others for testing.")
        imgui.spacing()
        imgui.indent(-10)
        imgui.tree_pop()
    end
end

local function MDFXL_Docs_Chapter_02()
    if imgui.tree_node("2.1 - Installation") then
        imgui.spacing()
        imgui.indent(10)
        imgui.text("Install Order:\n1. REFramework\n2. _ScriptCore\n3. MDF-XL\n4. Any mod utilizing MDF-XL")
        imgui.spacing()
        imgui.indent(-10)
        imgui.tree_pop()
    end
    if imgui.tree_node("2.2 - MDF-XL") then
        imgui.spacing()
        imgui.indent(10)
        imgui.text("As mentioned in 1.1, this is the menu accessible under Script Generated UI in the REF UI. Most mod users will only need to use this interface.\nStarting from the top:")
        imgui.spacing()
        imgui.indent(15)
        imgui.text("'Update Preset Lists' allows you to manually refresh the currently cached presets for your equipment by pressing the button.")
        imgui.spacing()
        imgui.text("'Open MDF-XL - Outfit Manager', opens the Outfit Manager.")
        imgui.spacing()
        imgui.text("'Open MDF-XL - Editor', opens the Editor.")
        imgui.spacing()
        imgui.text("The search bar allows you to search for presets or outfit presets, it's case-sensitive.")
        imgui.spacing()
        imgui.text("'Outfit Preset' the dropdown menu for the outfit presets, select a file from the dropdown menu to load the presets from that file.")
        imgui.spacing()
        imgui.text("'[Armor Type]' the dropdown menus for the different types of armor presets, select a file from the dropdown menu to load the settings from that file.\nThe presets displayed in these menus are always the ones that can be applied to your currently equipped gear.")
        imgui.text("'Default Presets' are generated during the initial loading screen and remain unchanged unless you manually 'Reset Scripts' in the ScriptRunner.")
        imgui.text("'Current Presets' are generated when you exit the inventory or pause menu, and they are updated each time you leave those menus.")
        imgui.spacing()
        imgui.text("'MDF-XL User Manual' opening that is how you got here.")
        imgui.spacing()
        imgui.text("'MDF-XL Settings' various options for the tool, with tooltips available for some of them.")
        imgui.indent(-15)
        imgui.spacing()
        imgui.indent(-10)
        imgui.tree_pop()
    end
    if imgui.tree_node("2.3 - MDF-XL - Editor") then
        imgui.spacing()
        imgui.indent(10)
        imgui.text("As mentioned in 1.1, this is the menu where you can access the Material and Mesh Editors.\nStarting from the top:")
        imgui.spacing()
        imgui.indent(15)
        imgui.text("'Update Preset Lists' allows you to manually refresh the currently cached presets for your equipment by pressing the button.")
        imgui.spacing()
        imgui.text("'Mesh Name' displays the mesh name of the currently equipped armor type. Can be toggled in the settings.")
        imgui.spacing()
        imgui.text("'Material Count' displays the number of materials used by currently equipped armor type. Can be toggled in the settings.")
        imgui.spacing()
        imgui.text("'Preset' the currently active preset for that armor type. Functions the same way as in the MDF-XL menu.")
        imgui.text("'[Enter Preset Name Here]' is where you can input the name of your preset. It's recommended to avoid using special characters.")
        imgui.text("'Save Preset' saves the current preset to '[PresetName].json' found in [Dragons Dogma 2/reframework/data/MDF-XL/[ArmorType]/[SubArmorType]/[MeshName]/[PresetName].json]\nThe tooltip will tell you the exact path.")
        imgui.spacing()
        imgui.text("'Mesh Path' displays the mesh path of the currently equipped armor in the game files. Can be toggled in the settings.")
        imgui.spacing()
        imgui.text("'MDF Path' displays the mdf path of the currently equipped armor in the game files. Can be toggled in the settings.")
        imgui.spacing()
        imgui.text("'Mesh Editor' allows you to hide or unhide parts of the currently equipped armor. If changed, an asterisk(*) will appear next to the submesh name.\nIf Emissive Highlighting is enabled in the settings hovering over a submesh will highlight it in white.")
        imgui.spacing()
        imgui.text("'Material Editor' allows you to adjust the parameters of the materials for the currently equipped armor.\nIf changed, an asterisk(*) will appear next to the material parameter name and the parameter will be offset to the side.")
        imgui.text("The search bar lets you quickly search for material parameters by their name, it's case-sensitive.")
        imgui.spacing()
        imgui.text("When the dropdown menu for the material name is open, right-clicking it brings up a context menu that allows you to copy/paste all material parameters, or to reset all material parameters.")
        imgui.text("Right-clicking the [Material Parameter Name] button will bring up a context menu that lets you copy/paste the selected material parameter, or to reset the material parameter.\nYou can also reset the material parameter by left-clicking the [Material Parameter Name] button.")
        imgui.indent(-15)
        imgui.spacing()
        imgui.indent(-10)
        imgui.tree_pop()
    end
    if imgui.tree_node("2.4 - MDF-XL - Outfit Manager") then
        imgui.spacing()
        imgui.indent(10)
        imgui.text("Similar to the MDF-XL window, but unlike that window, changing a preset here does not apply immediately. This is intentional to allow for quickly building outfit presets.\n[Save Outfit Preset] save the current preset to '[OutfitPresetName].json' found in [Dragons Dogma 2/reframework/data/MDF-XL/_Outfits/[OutfitPresetName].json")
        imgui.spacing()
        imgui.indent(-10)
        imgui.tree_pop()
    end
    if imgui.tree_node("2.5 - Packing an MDF-XL Mod") then
        imgui.spacing()
        imgui.indent(10)
        imgui.text("You only need to pack your presets, you can include multiple presets in the same archive.\nPresets can be found in [Dragons Dogma 2/reframework/data/MDF-XL/[ArmorType]/[SubArmorType]/[MeshName]/[PresetName].json]\nOutfit Presets can be found in [Dragons Dogma 2/reframework/data/MDF-XL/_Outfits/[OutfitPresetName].json]")
        imgui.spacing()
        imgui.indent(-10)
        imgui.tree_pop()
    end
end

local function MDFXL_Docs_Chapter_03()
    imgui.spacing()
    imgui.indent(10)
    imgui.text("[BaseColor]                 - ALBD tint. | Vec4 RGBA")
    imgui.text("[BaseDetail_TilingScale]    - Detail map tiling scale. | Float")
    imgui.text("[BrainwashRate]             - Dragonsplague overlay toggle. | Float 0.0 - 1.0")
    imgui.text("[Brainwash_Color]           - Dragonsplague overlay color. | Vec4 RGBA")
    imgui.text("[DragonGrade_Enable]        - Wyrmfire overlay toggle. | Float 0.0 - 1.0")
    imgui.text("[Emissive_Enable]           - Emissive toggle. | Float 0.0 - 1.0")
    imgui.text("[EmissiveColor1]            - Primary emissive color. | Vec4 RGBA")
    imgui.text("[EmissiveColor2]            - Secondary emissive color. | Vec4 RGBA")
    imgui.text("[Enable_ExtraPatternMap]    - True color replacer toggle. | Float 0.0 - 1.0")
    imgui.text("[ExtraPatternMap_Color]     - The color of true color replacer. | Vec4 RGBA")
    imgui.spacing()
    imgui.indent(-10)
    imgui.tree_pop()
end

docs = {
    MDFXL_Docs_Chapter_01 = MDFXL_Docs_Chapter_01,
    MDFXL_Docs_Chapter_02 = MDFXL_Docs_Chapter_02,
    MDFXL_Docs_Chapter_03 = MDFXL_Docs_Chapter_03,
}
return docs