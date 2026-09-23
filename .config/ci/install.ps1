# SPDX-License-Identifier: GPL-2.0-only
# This file is part of Scapy
# See https://scapy.net/ for more information

# Install packages needed for the CI on Windows

# Install npcap and windump
& "$PSScriptRoot\windows\InstallNpcap.ps1"
& "$PSScriptRoot\windows\InstallWindumpNpcap.ps1"

# Install wireshark with retry loop for transient failures
$maxAttempts = 3
$wiresharkInstalled = $false
for ($attempt = 1; $attempt -le $maxAttempts; $attempt++) {
    Write-Host "Attempt $attempt of $maxAttempts to install Wireshark..."
    choco install -y wireshark
    if ($LASTEXITCODE -eq 0) {
        $wiresharkInstalled = $true
        break
    }
    Write-Host "Wireshark installation failed (attempt $attempt). Retrying in $(15 * $attempt)s..."
    Start-Sleep -Seconds (15 * $attempt)
}
if (-not $wiresharkInstalled) {
    Write-Host "Failed to install Wireshark after $maxAttempts attempts."
    exit 1
}

# Add to PATH
echo "C:\Program Files\Wireshark;C:\Program Files\Windump" | Out-File -FilePath $env:GITHUB_PATH -Encoding utf8 -Append

# Update pip & setuptools & wheel (tox uses those)
python -m pip install --upgrade pip setuptools wheel --ignore-installed

# Make sure tox is installed and up to date
python -m pip install -U tox --ignore-installed
