local MDFXLUserManual = {
    Generic = {
        header = " [ USER MANUAL ] 03/26/2025 |",
    },
    About = {
        header = "1. ABOUT",
        [000] = "MDF-XL is a runtime material editor inspired by alphaZomega's EMV Engine.\nThis tool aims to extend equipment and weapon customization.\nBuilt with a robust preset system, allowing a high level of compatibility without any file editing.",
        [001] = "Supported Games:",
        [002] = "- Monster Hunter Wilds",
        [003] = "- Dragon's Dogma 2",
        [098] = "All edits made through MDF-XL are applied on the client side.",
        [099] = "For support or anything RE Engine modding related join the discord server linked below.",
    },
    Install = {
        header = "1.1 Install",
        [010] = "Requirements:\n\nREFramework (latest nightly)\n_ScriptCore (v1.2.00+)",
        [011] = "Download the latest REF nightly build from here:",
        [012] = "If you are not using VR, only copy the 'dinput8.dll' into your game's root folder.",
        [013] = "Download the latest version of _ScriptCore from here:",
        [014] = "You can install the mod manually by copying the 'reframework' and 'natives' folders into your game's root folder or\ninstall the mod with Fluffy Mod Manager like any other mod.",
        [015] = "Install Order:\n\n 1. REFramework\n 2. _ScriptCore\n 3. MDF-XL\n 4. Any mod utilizing MDF-XL",
        [016] = "If you are reading this, chances are you've successfully installed the mod.",
    },
    Troubleshooting = {
        header = "1.2 Troubleshooting",
        [020] = "I'm getting a ScriptRunner Error Message when I boot up the game. It mentions something about hotkeys.",
        [021] = "You're either missing _ScriptCore, or your version of _ScriptCore is outdated.\nMDF-XL requires _ScriptCore version 1.2.00+.",
        [022] = "MDF-XL used to work, but now I'm getting 1 FPS and ScriptRunner mentions something about a nil value.",
        [023] = "MDF-XL encountered an issue it couldn't handle. If restarting the game doesn't resolve the problem navigate to\n'[PathToYourSteamLibrary]/steamapps/common/[GameName]/reframework/data/MDF-XL' and delete the '_Holders' folder.",
        [024] = "I've selected a preset but it loaded the default preset instead.",
        [025] = "This happens when the preset that you are trying to load doesn't match the material count or material names of the selected equipment.",
        [099] = "If none of the above, then contact SilverEzredes on the Haven's Night Discord Server, or submit a bug report."
    },
    ReportingABug = {
        header = "1.3 Reporting a Bug",
        [030] = "If you are experiencing crashes or bugs, upload a screenshot of the error under 'REFramework Window > ScriptRunner'\nalong with your 're2_framework_log.txt' from the game's root folder.",
        [031] = "By default Debug Mode is enabled, this will ensure that any errors are logged.\nHowever, the log is cleared on every game startup so make sure to upload the log right after encountering an error.",
    },
    UpdateLoop = {
        header = "1.4 Update Loop",
        [040] = "Depending on the game MDF-XL updates during different game events. The first update is always passed on the initial loading screen.",
        [041] = "Update Events",
        [042] = "Monster Hunter Wilds:\n - Loading Screens\n - Closing the Equipment Menu\n - Exiting a Pop-Up Camp\n - Leaving the Appearance Menu\n - Closing the Smithy Menu",
    },
    Credits = {
        header = "1.5 Credits",
        [050] = "praydog for creating REFramework.\n\nalphaZomega for his work on EMV Engine, which heavily inspired this tool and for his guidance.\n\nRaq for his help, testing and feedback.\n\nMembers of the Haven's Night Discord Server for testing and feedback.",
    },
    Usage = {
        header = "2. USAGE",
        [060] = "MDF-XL has two main components the Editor and the Preset Manager.\nThe settings menu under 'REFramework > Script Generated UI > MDF-XL' provides multiple customization options for both tools,\nsuch as changing hotkeys or hiding certain UI elements.",
        [061] = "Most options in the settings menu have a tooltip explaining their purpose, unless they are self-explanatory.\nHotkeys won't work unless the MDF-XL tab is open. (Excluding the hotkeys used for Outfit Preset switching.)\nThis is by design to avoid interfering with other mods.",
    },
    PresetManager = {
        header = "2.1 Preset Manager",
        [070] = "This is what takes up most of the MDF-XL tab, starting with the Outfit Preset search bar.\nOutfit Presets function as 'Master' Presets, they allow you to apply multiple Presets simultaneously and can be switched between using hotkeys.\n\nWhile Presets affect only a single piece of equipment and are grouped by equipment type and name.",
        [071] = "Keyboard and Mouse:\n\nRight Shift + Page Up\nRight Shift + Page Down",
        [072] = "Gamepad:\n\nLT (L2) + LB(L1) *\nLT (L2) + RB (R1) *\n\n* Weapon must be sheathed!",
        [073] = "Hotkeys can be customized under 'MDF-XL > MDF-XL: Settings > Hotkeys'",
        [074] = "Advanced Search allows you to filter presets by tags or the author's name.\nYou can also use the search bar to filter presets in the same way as you would for Outfit Presets. Tags are optional, and some presets might not have any.",
        [075] = "Every piece of gear or equipment has a 'Default Preset.' These are auto-generated, and their purpose is to allow you to reset the appearance of the gear.\nThe Default Preset is always listed first and is named something like 'ch_03_001_002 Default' essentially the equipment ID followed by Default.",
        [076] = "Equipment ID is also used in place of the Equipment Name for the drop-down menus if the Equipment Name is not available.\nThe Equipment Name is followed by the Equipment Type, such as '1A' or '2B'.",
        [077] = "Equipment Types:",
        [078] = "Monster Hunter Wilds\n\n1A = Male A\n1B = Male B\n\n2A = Female A\n2B = Female B\n\n3 = Left-Handed Weapon\n4 = Right-Handed Weapon\n5 = Two-Handed Weapon\n6 = Weapon Accessory\n\n7 = Palico\n8 = Palico Weapon",
    },
    Editor = {
        header = "2.2 Editor",
        [100] = "This is where you can customize the currently equipped gear. It is also where you can save Presets and make Outfit Presets.\nThe layout is the same as the Preset Manager's, and there are several display settings available under 'MDF-XL > MDF-XL: Settings > Editor Settings'.",
        [101] = "You have the option to change Presets here as well however, there's no Preset search function and presets are displayed using their full names.\nIf you want your changes to the materials and submeshes to remain you must save them to a preset!",
        [102] = "- Name:\nThis is the field where you input the Preset's name.",
        [103] = "- Tags:\nThis is the field where you input tags for your Preset (Optional).\nTags must be separated by commas, and you're limited to five tags per preset. Leaving 'noTag' in the field will result in no tags being included in the Finalized Preset Name.",
        [104] = "- Author:\nThis is the field where you input your name (Optional).",
        [105] = "- Save Preset:\nClicking this button saves your preset to its proper location. Hovering over the 'Save Preset' button will display this location.\nAlternatively, you can enable 'Show Preset Path' in the settings. Saving a preset will also update the preset list for the given equipment.\nNext to it, you can see the Finalized Preset Name, which is limited to 200 characters.",
        [106] = "- MESH/MDF Path:\nDisplays the location of the MESH and MDF files for the given equipment in the game files.",
        [107] = "Mesh Editor:",
        [108] = "Allows you to hide or unhide parts of the equipment based on the materials. If a part has been changed, a blue asterisk will appear after the part name.\nRight-clicking on a submesh's name brings up a context menu that lets you highlight the submesh in the Material Editor.\nDisabled submeshes will appear grayed out in the Material Editor.",
        [109] = "Flags:",
        [110] = "Allows you to toggle different flags for the mesh, these affect all parts of the mesh.",
        [111] = "Material Editor:",
        [112] = "Allows you to change the material parameters and textures of the currently equipped gear.\nIf a parameter has been changed, a blue asterisk will appear next to the parameter name and the parameter will be offset to the side.\n\nThe number of material parameters varies from material to material, as it depends on the Master Material.",
        [113] = "To manage the large number of material parameters, MDF-XL includes built-in copy, paste, reset and filter functions.",
        [114] = "You can copy-paste on two different levels.\nThe first is at the material level, where right-clicking the material name allows you to copy and paste all material parameters.\nHere, you can also reset all material parameters for that material using the 'Reset' option.",
        [115] = "The second is at the material parameter level, where right-clicking the material parameter's name allows you to\ncopy, paste and reset the parameter value, you can also mark a parameter as favorite.",
        [116] = "Parameters marked as favorites will be highlighted in gold and can be quickly accessed using the 'Filter: Favorites' option below the search bar.",
        [117] = "Textures:",
        [118] = "Each material has its own Texture Menu, where you can change the textures used by that material.\nMost functions, such as copy, paste, and reset are also available for textures, along with a set of pre-made filters.\n(In a few cases, the Texture Menu might not be available for a material this is either done on purpose or the material doesn't use any textures.)",
        [119] = "The texture list is compiled from the textures MDF-XL encounters during its getter functions.\nThis means it doesn't include every texture in the game but will grow over time as you unlock new gear.",
    },
    BodyEditor = {
        header = "2.3 Body Editor",
        [150] = "Allows you to toggle different body parts to fill gaps created by hiding submeshes.\nIt uses a customized version of the Mesh Editor, and the Material Editor is not available here.",
        [151] = "However, in the customized Mesh Editor you can opt to use Underclothes and change their color.\nThe Base Body is a fully custom game object included with MDF-XL, meaning the undercloth colors from the appearance editor or equipment appearance are not tracked.",
    },
    ColorPalettes = {
        header = "2.4 Color Palette Editor",
        [155] = "A utility tool that lets you create color palettes and save them as presets. These colors can be copied for use in the Material Editor.\nRight click on the Color Name to access a context menu."
    },
    OutfitManager = {
        header = "2.5 Outfit Manager",
        [160] = "Allows you to create Outfit Presets.",
        [161] = "Outfit Presets allow you to apply multiple presets at once. When building an Outfit Preset, you'll have access to a mirrored version of the Preset Manager.\nHowever, not everything you see will be saved; equipment with the Default Preset selected will be ignored, along with the current state of sheathed weapons and underclothes options.",
        [162] = "You can customize what to include in the Outfit Preset by toggling the 'Include XYZ' options in the Outfit Manager.\nFor example, if you have presets loaded for your Palico and Seikret but don't want them included in the Outfit Preset, simply turn off the 'Include Palico' and 'Include Seikret' options.",
        [163] = "Outfit Presets are grouped by the Hunter's gender.\nThis means you'll have access to a different list of Outfit Presets depending on whether you play as a male or female Hunter.",
        [164] = "When loading an Outfit Preset, only the gear stored in the preset will be affected.\nFor example, if an Outfit Preset contains data for the Hunter's Armor but not for weapons, loading it won't override your current weapon presets since no weapon preset data was stored in the Outfit Preset."
    },
    LayeredWeapons = {
        header = "2.6 Layered Weapons",
        [165] = "Added in MDF-XL version 1.5.15. Currently not available for Light Bowguns, Heavy Bowguns and Palico Weapons.",
        [166] = "Layered Weapons work as a sort of 'Sub-Preset' for a Preset.\nTo allow the Auto-Preset Loader to work with these Sub-Presets, you must first save a preset for the original weapon,\nafter selecting a weapon in the Layered Weapon menus but before actually applying it."
    },
    PackagingPresets = {
        header = "3. Packaging Presets as Mods",
        [170] = "MDF-XL presets can be packaged into a mod for Fluffy Mod Manager without much work, as almost everything you need is generated through MDF-XL's UI in-game.",
        [171] = "For example, if you have an Outfit Preset and two Presets you'd like to bundle into a mod your mod folder would look something like this:",
        [172] = "ModName/\n|-- modinfo.ini\n|-- thumbnail.png\n  |__ reframework/\n    |__ data/\n      |__ MDF-XL/\n        |__ Outfits/\n          |__ Female/\n            |__ OutfitName-001.json\n        |__ Equipment/\n          |__ equipment_id_001/\n            |__ PresetName-001.json\n          |__ equipment_id_002/\n            |__ PresetName-002.json",
        [173] = "If you're unsure of the exact paths of your presets, you can enable 'Show Preset Path' in the Editor settings.",
        [174] = "More general information about packaging mods can be found on the RE Engine Modding Wiki:",
    },
    Links = {
        [200] = "https://github.com/praydog/REFramework-nightly/releases",
        [201] = "https://www.nexusmods.com/monsterhunterwilds/mods/87",
        [202] = "https://www.nexusmods.com/dragonsdogma2/mods/30",
        [297] = "https://github.com/Havens-Night/REEngine-Modding-Documentation/wiki",
        [298] = "https://www.fluffyquack.com",
        [299] = "https://discord.gg/9Vr2SJ3"
    },
    Errors = {
        [000] = "[ERROR-000]\nCould not load material data from the selected preset.\nThe material count or names in the preset do not match those of the selected equipment.",
        [001] = "[ERROR-001]\nName cannot be empty.",
        [002] = "[ERROR-002]\nFinalized Preset Name is too long.",
        [099] = "[ERROR-099]\nHow?",
    },
    Warnings = {
        [100] = "[WARNING-100]\nPreset Version is outdated.",
        [101] = "[WARNING-101]\n\nIf you use the 'Reset Scripts' option under 'REFramework > ScriptRunner,' MDF-XL's logic will also be reset.\nThis means you won't be able to access the Editor or Preset Manager. To resolve this, you must go through a loading screen.",
    },
}

return MDFXLUserManual