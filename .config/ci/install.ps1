# SPDX-License-Identifier: GPL-2.0-only
# This file is part of Scapy
# See https://scapy.net/ for more information

# Install packages needed for the CI on Windows

# Install npcap and windump
& "$PSScriptRoot\windows\InstallNpcap.ps1"
& "$PSScriptRoot\windows\InstallWindumpNpcap.ps1"

# Install wireshark with retry logic for transient failures
$maxRetries = 3
$retryDelay = 15
$attempt = 0
$installed = $false
while ($attempt -lt $maxRetries -and -not $installed) {
    $attempt++
    Write-Host "Attempt $attempt of $maxRetries to install Wireshark..."
    try {
        choco install -y wireshark --force
        if ($LASTEXITCODE -eq 0) {
            $installed = $true
            Write-Host "Wireshark installed successfully on attempt $attempt."
        } else {
            Write-Host "choco install exited with code $LASTEXITCODE on attempt $attempt."
            if ($attempt -lt $maxRetries) {
                Write-Host "Waiting $retryDelay seconds before retry..."
                Start-Sleep -Seconds $retryDelay
            }
        }
    } catch {
        Write-Host "Exception on attempt $attempt : $_"
        if ($attempt -lt $maxRetries) {
            Write-Host "Waiting $retryDelay seconds before retry..."
            Start-Sleep -Seconds $retryDelay
        }
    }
}
if (-not $installed) {
    Write-Error "Failed to install Wireshark after $maxRetries attempts."
    exit 1
}

# Add to PATH
echo "C:\Program Files\Wireshark;C:\Program Files\Windump" | Out-File -FilePath $env:GITHUB_PATH -Encoding utf8 -Append

# Update pip & setuptools & wheel (tox uses those)
python -m pip install --upgrade pip setuptools wheel --ignore-installed

# Make sure tox is installed and up to date
python -m pip install -U tox --ignore-installed
