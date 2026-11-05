# Third-party components

- **BepInEx 6.0.0-be.791+b782da4**: official Unity IL2CPP Windows x64 distribution. Source: https://github.com/BepInEx/BepInEx/tree/b782da4 . Distribution: https://builds.bepinex.dev/projects/bepinex_be/791 . LGPL-2.1; accompanying dependencies retain their upstream licenses.
- **Unity Doorstop 4.6.0**: included with BepInEx, used as `winhttp.dll`. Source and configuration: https://github.com/NeighTools/UnityDoorstop . LGPL-2.1.
- **OpenVR v2.5.1**: C# bindings and matching Windows x64 native API library from Valve. Source: https://github.com/ValveSoftware/openvr/tree/v2.5.1 . BSD 3-Clause; full license in `vendor/OpenVR-LICENSE.txt` and the plugin package.
- **.NET runtime**: included in the official BepInEx distribution; licenses and notices follow the original runtime distribution. Source: https://github.com/dotnet/runtime . MIT and upstream third-party notices.
- **Build reference assemblies only**: Unity IL2CPP bindings were initially inspected from https://github.com/NewUnityModder/UnityVRMod and then replaced with the installed game's generated BepInEx interop references. UnityVRMod and UUVR code are not included in the compiled plugin. The prototype does not require either mod at runtime.

The new plugin code is provided under the MIT license in `LICENSE.txt`. Game files, generated game wrappers and extracted game metadata are not included in the distributed source/package.
The included Il2CppInterop runtime has a build-specific class initialization resolver adjustment for this game version.
