# Uninstall Launchy installed by install.ps1:
#   irm https://raw.githubusercontent.com/halfmoonvic/launchy/main/uninstall.ps1 | iex
#
# Closes Launchy, deletes the install folder (LAUNCHY_INSTALL_DIR if set, as
# for install.ps1) and the Start Menu and Startup shortcuts pointing at it.
# Settings in %APPDATA%\Launchy are kept, so a reinstall picks them up again.

# Wrapped in a function so that a failure doesn't close the shell running iex
function Uninstall-Launchy {
    $ErrorActionPreference = 'Stop'

    $installDir = if ($env:LAUNCHY_INSTALL_DIR) { $env:LAUNCHY_INSTALL_DIR } else { Join-Path $env:LOCALAPPDATA 'Programs\Launchy' }
    $exe = Join-Path $installDir 'Launchy.exe'
    if (-not (Test-Path $exe)) {
        Write-Host "Launchy is not installed in $installDir"
        return
    }

    $running = @(Get-Process Launchy -ErrorAction SilentlyContinue | Where-Object { $_.Path -eq $exe })
    if ($running) {
        Write-Host 'Closing the running Launchy'
        $running | Stop-Process -Force
        $running | Wait-Process -Timeout 10 -ErrorAction SilentlyContinue
    }

    # install.ps1 adds Launchy.lnk to the Start Menu; a Startup shortcut may
    # have been added by hand under any name, so match on the target
    $shell = New-Object -ComObject WScript.Shell
    foreach ($folder in 'Programs', 'Startup') {
        $dir = [Environment]::GetFolderPath($folder)
        Get-ChildItem $dir -Filter *.lnk -Recurse -ErrorAction SilentlyContinue |
            Where-Object { $shell.CreateShortcut($_.FullName).TargetPath -eq $exe } |
            ForEach-Object {
                Write-Host "Removing $($_.FullName)"
                Remove-Item -LiteralPath $_.FullName -Force
            }
    }

    Write-Host "Removing $installDir"
    Remove-Item -LiteralPath $installDir -Recurse -Force

    $settings = Join-Path $env:APPDATA 'Launchy'
    if (Test-Path $settings) {
        Write-Host "Launchy uninstalled. Its settings are still in $settings; delete that folder to remove them too."
    }
    else {
        Write-Host 'Launchy uninstalled.'
    }
}

Uninstall-Launchy
