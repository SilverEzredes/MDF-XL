local MDFXLUserManual = {
    Generic = {
        updated = "12/27/2024 |"
    },
    About = {
        header = "1. ABOUT",
        [000] = "MDF-XL is a runtime material editor inspired by alphaZomega's EMV Engine.\nBuilt with a robust preset system, allowing a high level of compatibility and customization without requiring file editing.",
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
        [015] = "If you are reading this, chances are you've successfully installed the mod.",
    },
    Troubleshooting = {
        header = "1.2 Troubleshooting",
        [020] = "I'm getting a ScriptRunner Error Message when I boot up the game. It mentions something about hotkeys.",
        [021] = "You're either missing _ScriptCore, or your version of _ScriptCore is outdated.\nMDF-XL requires _ScriptCore version 1.1.8+.",
        [022] = "MDF-XL used to work, but now I'm getting 1 FPS and ScriptRunner mentions something about a nil value.",
        [023] = "MDF-XL encountered an issue it couldn't handle. If restarting the game doesn't resolve the problem navigate to\n[PathToYourSteamLibrary]/steamapps/common/[GameName]/reframework/data/MDF-XL and delete the '_Holders' folder.",
        [024] = "I've clicked on a preset but it loaded the default preset instead.",
        [025] = "This happens when the preset that you are trying to load doesn't match the material count or material names of the selected equipment.\nAn error message should popup in the MDF-XL Console (Disabled by default but you can enable it in the MDF-XL Settings.)",
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
        [042] = "Monster Hunter Wilds:\n - Loading Screens\n - Leaving the Equipment Menu\n - Exiting the Camp\n - Leaving the Appearance Menu",
    },
    Credits = {
        header = "1.5 Credits",
        [050] = "praydog for creating REFramework.\n\nalphaZomega for his work on EMV Engine, which heavily inspired this tool and for his guidance.\n\nMembers of the Modding Haven Discord Server for testing and feedback.",
    },
    Links = {
        [200] = "https://github.com/praydog/REFramework-nightly/releases",
        [201] = "[Place Holder for MHWS _ScriptCore link]",
        [202] = "https://www.nexusmods.com/dragonsdogma2/mods/30",
        [299] = "https://discord.gg/modding-haven-718224210270617702"
    },
    Errors = {
        [000] = "[ERROR-000]\nCould not load material data from the selected preset.\nThe material count or names in the preset do not match those of the selected equipment. ",
    },
    Warnings = {
        [100] = "[WARNING-100]\nPreset Version is outdated.",
    },
}

return MDFXLUserManual