# Set PowerShell execution policy to RemoteSigned for the current user
$ExecutionPolicy = Get-ExecutionPolicy -Scope CurrentUser
if ($ExecutionPolicy -eq "RemoteSigned") {
    Write-Verbose "Execution policy is already set to RemoteSigned for the current user, skipping..." -Verbose
}
else {
    Write-Verbose "Setting execution policy to RemoteSigned for the current user..." -Verbose
    Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
}

####################################################################################################
# Remove bloatware
####################################################################################################

# Reads list of apps from file and removes them for all user accounts and from the OS image.
function SanitiseAppsFromFile {
    param (
        $appsFilePath
    )

    $appsList = @()

    Write-Output "> Removing default selection of apps..."

    # Get list of apps from file at the path provided, and remove them one by one
    Foreach ($app in (Get-Content -Path $appsFilePath | Where-Object { $_ -notmatch '^#.*' -and $_ -notmatch '^\s*$' } )) { 
        # Remove any spaces before and after the Appname
        $app = $app.Trim()

        # Remove any comments from the Appname
        if (-not ($app.IndexOf('#') -eq -1)) {
            $app = $app.Substring(0, $app.IndexOf('#'))
        }
        # Remove any remaining spaces from the Appname
        if (-not ($app.IndexOf(' ') -eq -1)) {
            $app = $app.Substring(0, $app.IndexOf(' '))
        }
        
        $appString = $app.Trim('*')
        $appsList += $appString
    }

    return $appsList
}

function RemoveApps {
    param (
        $appsList
    )

    Foreach ($app in $appsList) {
        # Remove install app for all existing users
        Write-Output "Attempting to removing $app..."
        $app = '*' + $app + '*'
        Get-AppxPackage -Name $app -AllUsers | Remove-AppxPackage -AllUsers

        # Remove provisioned app from OS image, so the app won't be installed for any new users
        Get-AppxProvisionedPackage -Online | Where-Object { $_.PackageName -like $app } | ForEach-Object { Remove-ProvisionedAppxPackage -Online -AllUsers -PackageName $_.PackageName }
    }
}

# Set the path to the file containing the list of apps to remove and remove them
$appsFilePath = "applist.txt"
$appsList = SanitiseAppsFromFile $appsFilePath
RemoveApps $appsList


####################################################################################################
# Windows Subsystem for Linux (WSL)
####################################################################################################

# Install WSL2
if ([bool](Get-Command -Name 'wsl' -ErrorAction SilentlyContinue)) {
    Write-Verbose "WSL is already installed." -Verbose
}
else {
    Write-Verbose "Installing WSL..." -Verbose
    wsl --install
}

# Set default distro to Ubuntu (WSL2)
# This fixes an issue with Airbyte 
Write-Verbose "Setting default WSL distro to Ubuntu..." -Verbose
wsl --setdefault Ubuntu

####################################################################################################
# Chocolatey
####################################################################################################

# Install chocolatey
if ([bool](Get-Command -Name 'choco' -ErrorAction SilentlyContinue)) {
    Write-Verbose "Chocolatey is already installed, skip installation." -Verbose
}
else {
    Write-Verbose "Installing Chocolatey..." -Verbose
    Set-ExecutionPolicy Bypass -Scope Process -Force; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
}

# Install packages with Chocolatey
# Full list of packages can be found at https://chocolatey.org/packages
$packages = @(
    "git", 
    "vscode", 
    "docker-desktop",
    "docker-compose",
    "googlechrome",
    "googledrive", # sync obsidian notes
    "obsidian",
    "starship",
    "nerd-fonts-jetbrainsmono",
    "powertoys"
)

if ([bool](Get-Command -Name 'choco' -ErrorAction SilentlyContinue)) {
    Write-Verbose "Installing Packages..." -Verbose
    choco install -y $packages

}

####################################################################################################
# Terminal
####################################################################################################

# Initialize Starship
if (-not (Test-Path -Path $PROFILE)) {
    New-Item -ItemType File -Path $PROFILE -Force
}

# Add Starship to the PowerShell profile if it's not already there
$starshipExe = (Get-ChildItem -Path "C:\Program Files", "C:\Program Files (x86)" -Filter "starship.exe" -Recurse -ErrorAction SilentlyContinue).FullName
$starshipInit = "Invoke-Expression (&'$starshipExe' init powershell)" 

if ((Get-Content -Path $PROFILE) -notcontains $starshipInit) {
    Add-Content -Path $PROFILE -Value $starshipInit
}


####################################################################################################
# Enable Long Paths in Windows
####################################################################################################

Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" -Name "LongPathsEnabled" -Value 1


####################################################################################################
# Reverse Vertical Mouse Scroll
####################################################################################################

Get-PnpDevice -Class Mouse -PresentOnly -Status OK | ForEach-Object {
    "$($_.Name): $($_.DeviceID)"
    # 0 - Move up so you see contents below (Default Mode, Windows behavior)
    # 1 - Move down so you can see contents above (Natural Mode, Mac behavior, reverse mode)
    $mode = 1
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Enum\$($_.DeviceID)\Device Parameters" -Name FlipFlopWheel -Value $mode
}

# Restart the system for the changes to take effect
shutdown.exe /r /t 0