# windows-dev-playbook
Windows setup and configuration for development.

## Contents
- [Features](#features)
- [Installation](#installation)
- [Included Applications](#included-applications)

## Features
- **Software**
    - Ensures Bloatware is removed (see default config for a complete list of Bloatware).
    - Ensure software and packages selected by the user are installed via Chocolatey.
    - Obsidian notes are synced to Google Drive.
    - Docker Desktop is installed and configured to use WSL2.
- **Windows apps & features**
    - Ensures the Optional Windows Features chosen by the user are installed and enabled.
    - Ensures WSL2 distro selected by the user is installed and enabled.
- **Windows Settings**
    - Explorer
    - Start Menu
    - General
        - Ensures mouse acceleration is disabled.
        - Reverse mouse scrolling direction (Natural Mode).
        - Enable long file paths.
        - Shortcuts remapped using `PowerToys`. Settings are synced to OneDrive.
- **Terminal Settings**
    - Ensures `Starship` is used as default PowerShell theme engine.
    - Ensures `JetBrainsMono Nerd Font` is used as default font.

## Installation
1. Clone this repository to your local machine.
2. Start a PowerShell terminal as an **Administrator** within the repository and run: `.\bootstrap.ps1`
3. Change PowerShell font to JetBrains Mono Nerd Font.
    - right-click on the title bar of the PowerShell window
    - select `Properties`
    - select the `Font` tab
    - select `JetBrainsMono Nerd Font` from the list of fonts
4. Open VSCode settings and update the following settings:
    - `terminal.integrated.fontFamily` to `JetBrainsMono Nerd Font`
5. Install Apple iCloud from the Microsoft Store. Sync Obsidian vault with Google Drive.
6. Configure PowerToys to use the settings located in `C:\Users\{{ user }}\OneDrive\Documents\PowerToys`.
7. Configure Docker Desktop to use WSL2.
8. Follow NVidia GPU Acceleration setup instructions [here](https://docs.nvidia.com/cuda/wsl-user-guide/index.html). Container images can be found [here](https://catalog.ngc.nvidia.com).
9. Tailscale VPN.

## Included Applications
Packages (installed via Chocolatey):
- Git
- VSCode
- Docker Desktop
- Google Chrome
- Google Drive
- Apple iCloud
- Obsidian
- Starship
- JetBrains Mono Nerd Font
- PowerToys
- NVIDIA Game Ready Driver
