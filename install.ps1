# Install or update Launchy from the latest GitHub release:
#   irm https://raw.githubusercontent.com/halfmoonvic/launchy/main/install.ps1 | iex
#
# Installs to %LOCALAPPDATA%\Programs\Launchy (set LAUNCHY_INSTALL_DIR to
# change it), adds a Start Menu shortcut and starts Launchy. Installing over
# an existing copy keeps its settings, including a portable launchy.ini next
# to Launchy.exe. Works in Windows PowerShell 5.1 and PowerShell 7.
# uninstall.ps1 removes it again.

# Wrapped in a function so that a failure doesn't close the shell running iex
function Install-Launchy {
    $ErrorActionPreference = 'Stop'
    # Invoke-WebRequest is many times slower with the progress bar in 5.1
    $ProgressPreference = 'SilentlyContinue'
    # 5.1 may default to TLS 1.0, which GitHub refuses
    [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12

    $repo = 'halfmoonvic/launchy'
    $installDir = if ($env:LAUNCHY_INSTALL_DIR) { $env:LAUNCHY_INSTALL_DIR } else { Join-Path $env:LOCALAPPDATA 'Programs\Launchy' }

    $release = Invoke-RestMethod "https://api.github.com/repos/$repo/releases/latest" -UseBasicParsing
    $asset = $release.assets | Where-Object { $_.name -like '*-win32.zip' } | Select-Object -First 1
    if (-not $asset) { throw "Release $($release.tag_name) has no win32 zip" }
    Write-Host "Installing $($release.name) to $installDir"

    $temp = Join-Path ([IO.Path]::GetTempPath()) ('launchy-' + [Guid]::NewGuid())
    New-Item -ItemType Directory $temp | Out-Null
    try {
        $zip = Join-Path $temp $asset.name
        Invoke-WebRequest $asset.browser_download_url -OutFile $zip -UseBasicParsing
        Expand-Archive $zip -DestinationPath $temp
        # The zip holds a single Launchy folder
        $source = Join-Path $temp 'Launchy'

        # A running Launchy keeps its exe and DLLs locked
        $exe = Join-Path $installDir 'Launchy.exe'
        $running = @(Get-Process Launchy -ErrorAction SilentlyContinue | Where-Object { $_.Path -eq $exe })
        if ($running) {
            Write-Host 'Closing the running Launchy'
            $running | Stop-Process -Force
            $running | Wait-Process -Timeout 10 -ErrorAction SilentlyContinue
        }

        # Copy over rather than replace the folder, so that a portable
        # launchy.ini, launchy.db and history.db stay put
        New-Item -ItemType Directory -Force $installDir | Out-Null
        Copy-Item "$source\*" $installDir -Recurse -Force
    }
    finally {
        Remove-Item $temp -Recurse -Force -ErrorAction SilentlyContinue
    }

    $shell = New-Object -ComObject WScript.Shell
    $shortcut = $shell.CreateShortcut((Join-Path ([Environment]::GetFolderPath('Programs')) 'Launchy.lnk'))
    $shortcut.TargetPath = $exe
    $shortcut.WorkingDirectory = $installDir
    $shortcut.Save()

    # Started from an elevated shell, Launchy would run as administrator and
    # so would everything it launches; Explorer starts it as the normal user
    $admin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if ($admin) { Start-Process explorer.exe "`"$exe`"" }
    else { Start-Process $exe -WorkingDirectory $installDir }
    Write-Host "Launchy $($release.tag_name) installed and started. Press Alt+Space to show it."
}

Install-Launchy
