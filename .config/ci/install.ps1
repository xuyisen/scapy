# SPDX-License-Identifier: GPL-2.0-only
# This file is part of Scapy
# See https://scapy.net/ for more information

# Install packages needed for the CI on Windows

# Install npcap and windump
& "$PSScriptRoot\windows\InstallNpcap.ps1"
& "$PSScriptRoot\windows\InstallWindumpNpcap.ps1"

# Install wireshark with retry logic for transient failures
$maxRetries = 3
$retryDelay = 30  # seconds
$attempt = 0
$wiresharkInstalled = $false

do {
    $attempt++
    Write-Host "Installing Wireshark (attempt $attempt of $maxRetries)..."
    choco install -y wireshark
    if ($LASTEXITCODE -eq 0) {
        $wiresharkInstalled = $true
        Write-Host "Wireshark installed successfully."
    } else {
        Write-Host "Wireshark installation failed with exit code $LASTEXITCODE."
        if ($attempt -lt $maxRetries) {
            Write-Host "Waiting $retryDelay seconds before retrying..."
            Start-Sleep -Seconds $retryDelay
        } else {
            Write-Host "All $maxRetries attempts failed."
        }
    }
} while (-not $wiresharkInstalled -and $attempt -lt $maxRetries)

if (-not $wiresharkInstalled) {
    throw "Failed to install Wireshark after $maxRetries attempts."
}

# Add to PATH
echo "C:\Program Files\Wireshark;C:\Program Files\Windump" | Out-File -FilePath $env:GITHUB_PATH -Encoding utf8 -Append

# Update pip & setuptools & wheel (tox uses those)
python -m pip install --upgrade pip setuptools wheel --ignore-installed

# Make sure tox is installed and up to date
python -m pip install -U tox --ignore-installed
