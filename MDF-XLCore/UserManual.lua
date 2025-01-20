local MDFXLUserManual = {
    Generic = {
        header = " [ USER MANUAL ] 01/20/2025 |",
    },
    About = {
        header = "1. ABOUT",
        [000] = "MDF-XL is a runtime material editor inspired by alphaZomega's EMV Engine.\nBuilt with a robust preset system, allowing a high level of compatibility and customization without any file editing.",
        [001] = "Supported Games:",
        [002] = "- Monster Hunter Wilds",
        [003] = "- Dragon's Dogma 2",
        [099] = "For support or anything RE Engine modding related join the discord server linked below.",
    },
    Install = {
        header = "1.1 Install",
        [010] = "Requirements:\n\nREFramework (latest nightly)\n_ScriptCore (v1.1.8+)",
        [011] = "Download the latest REF nightly build from here:",
        [012] = "If you are not using VR, only copy the 'dinput8.dll' into your game's root folder.",
        [013] = "Download the latest version of _ScriptCore from here:",
        [014] = "You can install the mod manually by copying the 'reframework' folder into your game's root folder or\ninstall the mod with Fluffy Mod Manager like any other mod.",
        [015] = "Install Order:\n\n 1. REFramework\n 2. _ScriptCore\n 3. MDF-XL\n 4. Any mod utilizing MDF-XL",
        [016] = "If you are reading this, chances are you've successfully installed the mod.",
    },
    Troubleshooting = {
        header = "1.2 Troubleshooting",
        [020] = "I'm getting a ScriptRunner Error Message when I boot up the game. It mentions something about hotkeys.",
        [021] = "You're either missing _ScriptCore, or your version of _ScriptCore is outdated.\nMDF-XL requires _ScriptCore version 1.1.8+.",
        [022] = "MDF-XL used to work, but now I'm getting 1 FPS and ScriptRunner mentions something about a nil value.",
        [023] = "MDF-XL encountered an issue it couldn't handle. If restarting the game doesn't resolve the problem navigate to\n'[PathToYourSteamLibrary]/steamapps/common/[GameName]/reframework/data/MDF-XL' and delete the '_Holders' folder.",
        [024] = "I've selected a preset but it loaded the default preset instead.",
        [025] = "This happens when the preset that you are trying to load doesn't match the material count or material names of the selected equipment.",
        [099] = "If none of the above, then contact me on the Modding Haven Discord Server, or submit a bug report."
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
        [042] = "Monster Hunter Wilds:\n - Loading Screens\n - Closing the Equipment Menu\n - Exiting a Pop-Up Camp\n - Leaving the Appearance Menu",
    },
    Credits = {
        header = "1.5 Credits",
        [050] = "praydog for creating REFramework.\n\nalphaZomega for his work on EMV Engine, which heavily inspired this tool and for his guidance.\n\nMembers of the Modding Haven Discord Server for testing and feedback.",
    },
    Usage = {
        header = "2. USAGE",
        [060] = "MDF-XL has two main components the Editor and the Preset Manager.\nThe settings menu under 'REFramework > Script Generated UI > MDF-XL' provides multiple customization options for both tools,\nsuch as changing hotkeys or hiding certain UI elements.",
        [061] = "Most options in the settings menu have a tooltip explaining their purpose, unless they are self-explanatory.\nHotkeys won't work unless the MDF-XL tab is open. (Excluding the hotkeys used for Outfit Preset switching.)\nThis is by design to avoid interfering with other mods.",
    },
    PresetManager = {
        header = "2.1 Preset Manager",
        [070] = "This is what takes up most of the MDF-XL tab, starting with the Outfit Preset search bar.\nOutfit Presets function as 'Master' Presets, they allow you to apply multiple Presets simultaneously and can be switched between using hotkeys.\n(Presets affect only a single piece of equipment and are grouped by equipment type and name.)",
        [071] = "Keyboard and Mouse:\n\nRight Shift + Page Up\nRight Shift + Page Down",
        [072] = "Gamepad:\n\nLT (L2) + DPad Up\nLT (L2) + DPad Down",
        [073] = "Hotkeys can be customized under 'MDF-XL > MDF-XL: Settings > Hotkeys'",
        [074] = "Advanced Search allows you to filter presets by tags or the author's name.\nYou can also use the search bar to filter presets in the same way as you would for Outfit Presets. Tags are optional, and some presets might not have any.",
        [075] = "Every piece of gear or equipment has a 'Default Preset.' These are auto-generated, and their purpose is to allow you to reset the appearance of the gear.\nThe Default Preset is always listed first and is named something like 'ch_03_001_002 Default' essentially the equipment ID followed by Default.",
        [076] = "Equipment ID is also used in place of the Equipment Name for the drop-down menus if the Equipment Name is not available.\nThe Equipment Name is followed by the Equipment Type, such as '1A' or '2B.'",
        [077] = "Equipment Types",
        [078] = "Monster Hunter Wilds:\n\n1A = Male A\n1B = Male B\n\n2A = Female A\n2B = Female B\n\n3 = Left-Handed Weapon\n4 = Right-Handed Weapon\n5 = Two-Handed Weapon\n6 = Weapon Accessory\n\n7 = Palico\n8 = Palico Weapon",
    },
    Links = {
        [200] = "https://github.com/praydog/REFramework-nightly/releases",
        [201] = "[Placeholder text for MHWS _ScriptCore link]",
        [202] = "https://www.nexusmods.com/dragonsdogma2/mods/30",
        [298] = "https://www.fluffyquack.com",
        [299] = "https://discord.gg/modding-haven-718224210270617702"
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