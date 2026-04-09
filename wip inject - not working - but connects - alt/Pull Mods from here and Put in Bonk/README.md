# BL4-Mod

## Overview
This injection-style mod for Borderlands 4 extends the experience through DLL entry hooks, custom GUI layers, and auxiliary tools. The repository bundles engine interceptions, an ImGui interface, configuration files, and minimal dependencies such as minhook. Refer to `README_zh.md` for the Chinese version.

## Dependencies
- Windows 10/11 host environment
- Visual Studio 2022 or a compatible MSVC toolset
- Game version verified to be compatible with this mod (re-check after every update)

## Build & Deploy
1. Open `Bl4.sln` in Visual Studio, target `x64 Release`, and build.
2. Copy the generated DLL (typically under `x64/Release`) into the game root.
3. Launch the game through your injector/launcher so it loads the DLL, then fine-tune behavior via files in the `Config` directory.

## Usage
- Restart the game after editing any configuration files so changes take effect.
- Trigger the ImGui overlay with the configured hotkey to adjust assists or check status.
- Hooks rely on the `minhook`, `Hooks`, and `Utils` modules for memory interception and data I/O.

## Contact
Development and maintenance happen within the `GUI`, and supporting directories; reading the source is the primary way to learn more.
