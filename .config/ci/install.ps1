# SPDX-License-Identifier: GPL-2.0-only
# This file is part of Scapy
# See https://scapy.net/ for more information

# Install packages needed for the CI on Windows

# Install npcap and windump
& "$PSScriptRoot\windows\InstallNpcap.ps1"
& "$PSScriptRoot\windows\InstallWindumpNpcap.ps1"

# Install wireshark
$maxAttempts = 3
$attempt = 0
do {
    $attempt++
    choco install -y wireshark
    if ($LASTEXITCODE -eq 0) { break }
    if ($attempt -lt $maxAttempts) {
        Write-Host "Wireshark installation failed, retrying in $([int](15 * $attempt)) seconds..."
        Start-Sleep -Seconds ([int](15 * $attempt))
    }
} while ($attempt -lt $maxAttempts)
if ($LASTEXITCODE -ne 0) {
    throw "Wireshark installation failed after $maxAttempts attempts"
}

# Add to PATH
echo "C:\Program Files\Wireshark;C:\Program Files\Windump" | Out-File -FilePath $env:GITHUB_PATH -Encoding utf8 -Append

# Update pip & setuptools & wheel (tox uses those)
python -m pip install --upgrade pip setuptools wheel --ignore-installed

# Make sure tox is installed and up to date
python -m pip install -U tox --ignore-installed
