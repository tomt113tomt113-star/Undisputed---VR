# Undisputed VR
Updated build 2026-11-05 for Windows x64

## Fresh Steam install
1. Install Undisputed on Steam. Use Steam's Browse local files command to find the folder containing Undisputed.exe.
2. Extract the entire ZIP to a writable folder. Close Undisputed and run Install.cmd from the extracted folder. Paste the game folder when prompted.
3. Keep Steam signed in and start SteamVR with your headset connected. Run Start-VR.cmd from the extracted folder.
4. Start an offline fight and follow the round-one controller calibration prompt.

Keep the extracted folder for launching and uninstalling. The first VR launch can take longer while BepInEx generates game bindings and may need internet access to obtain Unity support libraries. This release includes the version-specific loader compatibility fix for the Steam build tested on 2026-11-05 (Unity 2022.3.45f1). The installer and VR launcher check the GameAssembly.dll fingerprint. If Steam installs a different build, it needs a compatible release.

## Included settings and features
The compiled plugin includes the current tracked gloves and forearms, first-person camera, motion punching and contact handling, guard calibration, haptics, VR menus, rope HUD and damage notifications, first-person glove replays, knockdown count, round transitions, Turner Gym-VR venue - optimised for performance.

F6 recentres, F7 captures guard calibration, F8 toggles motion punching, F9 toggles first-person view, and F10 opens the VR resolution panel. Mod config and diagnostic logs live under BepInEx in the game folder.

Normal Steam launch leaves the loader disabled. To remove the mod, close Undisputed and run Uninstall.cmd. It moves the installed mod files into an archive in the extracted folder. The installer refuses to overwrite an existing loader or other conflicting files.

BepInEx, Unity Doorstop, the bundled runtime and OpenVR are included. See THIRD_PARTY_NOTICES.md and the accompanying licenses.
