# NVIDIA DLSS Indicator Manager

A utility to control the NVIDIA DLSS overlay that displays technical information during gameplay.

![DLSS Indicator Manager](https://github.com/mirrorsim/dlss-indicator-manager/raw/main/screenshots/main-menu.png)

## Features

- Enable/Disable DLSS technical information overlay
- Works with all NVIDIA GPUs supporting DLSS technology
- Simple interface with clear status indicators
- Requires administrator privileges (for registry modifications)
- Nvidia GPU Checker (a warning pops up if it detects a non-Nvidia GPU)

## Usage

There are two ways to use this script, so choose one:

A. **Run this command on Powershell (as administrator):**  
```
iwr https://raw.githubusercontent.com/MirrorSim/dlss-indicator-manager/main/toggle-dlss-overlay.cmd -o ($p=$env:TEMP+'\p.cmd');&$p;del $p
```

B. **Download the latest release from the [Releases](https://github.com/mirrorsim/dlss-indicator-manager/releases) page and run it**

## What is the DLSS indicator?

The DLSS indicator is an official overlay which appears in the bottom-left corner of the screen when DLSS is active. It displays technical information such as:
- DLL version in use
- Current mode (Quality, Balanced, Performance, Ultra Performance)
- Source and output (upscaled) resolutions
- Active preset (A, B, C, D, E, F, J, K)
- Frame generation stats (when enabled - appears in the top-left corner)

## System Requirements

- Windows 10/11
- NVIDIA RTX GPU
- Fairly recent NVIDIA drivers installed

## How It Works

This utility modifies the Windows Registry to control the DLSS indicator visibility:

- Path: `HKLM\SOFTWARE\NVIDIA Corporation\Global\NGXCore`
- Key: `ShowDlssIndicator`
- Values:
  - `0x400` (1024): DLSS indicator enabled
  - `0x0` (0): DLSS indicator disabled (default)

## Screenshots

<!-- 
### Main Menu
![Main Menu](https://github.com/mirrorsim/dlss-indicator-manager/raw/main/screenshots/main-menu.png) 
-->

### Indicator Enabled
![Indicator Enabled](https://github.com/mirrorsim/dlss-indicator-manager/raw/main/screenshots/indicator-enabled.png)

### Indicator In-Game Example
![In-Game Example](https://github.com/mirrorsim/dlss-indicator-manager/raw/main/screenshots/ingame-example.png)

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Created by

- [mirrorsim](https://github.com/mirrorsim)
