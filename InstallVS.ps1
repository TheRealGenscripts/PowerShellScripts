# Get the directory of the script
$scriptDirectory = Split-Path -Parent $MyInvocation.MyCommand.Definition

Write-Host "Installing Visual Studio Certificates ..."

# Install Certification Files
$certFilesPath = Join-Path -Path $scriptDirectory -ChildPath "certificates" # Replace with your folder name containing the certificate files
if (Test-Path $certFilesPath) {
    $certFiles = Get-ChildItem -Path $certFilesPath -Filter *.cer
    foreach ($certFile in $certFiles) {
        Import-Certificate -FilePath $certFile.FullName -CertStoreLocation Cert:\\LocalMachine\\Root
    }
}

Write-Host "Visual Studio Certificates installed."

# Load Windows Forms assembly
Add-Type -AssemblyName System.Windows.Forms

# Display a warning about the long install time
$dialogResult = [System.Windows.Forms.MessageBox]::Show("The installation of Visual Studio might take a long time depending on what workloads and components you are installing. Do you want to continue?", "Warning", [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Warning)

# Check the user's choice
if ($dialogResult -eq [System.Windows.Forms.DialogResult]::No) {
    Write-Host "Installation cancelled by the user."
    exit
}

Write-Host "Installing Visual Studio 2022. This may take a while ..."

# Install Visual Studio 2022
$vsInstallerPath = Join-Path -Path $scriptDirectory -ChildPath "VisualStudioSetup.exe" # Replace with your Visual Studio installer name
Start-Process -Wait $vsInstallerPath -ArgumentList '--quiet'

Write-Host "Searching for Visual Studio Extensions ..."

# Install Extensions
$vsixFilesPath = Join-Path -Path $scriptDirectory -ChildPath "extensions" # Replace with your folder name containing the VSIX files
if (Test-Path $vsixFilesPath) {

# Display a warning about the long install time for extensions
$dialogResult = [System.Windows.Forms.MessageBox]::Show("The installation of extensions may take a while if you have a lot of extensions. Do you want to continue?", "Warning", [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Warning)

# Check the user's choice
if ($dialogResult -eq [System.Windows.Forms.DialogResult]::Yes) {
    Write-Host "Installing Extensions ..."

    $vsixFiles = Get-ChildItem -Path $vsixFilesPath -Filter *.vsix
    foreach ($vsixFile in $vsixFiles) {
        Start-Process -FilePath "C:\\Program Files\\Microsoft Visual Studio\\2022\\Community\\Common7\\IDE\\VSIXInstaller.exe" -ArgumentList "/q", "`"$($vsixFile.FullName)`"" -Wait
Write-Host "Installed $vsixFile extension"
    }
}
}

# Import .vssettings File
$vsSettingsFile = Get-ChildItem -Path $scriptDirectory -Filter *.vssettings | Select-Object -First 1
if ($vsSettingsFile -ne $null) {

# Ask if they want to import previous settings
$dialogResult = [System.Windows.Forms.MessageBox]::Show("Found Settings file ($vsSettingsFile) import?", "Warning", [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Warning)

# Check the user's choice
if ($dialogResult -eq [System.Windows.Forms.DialogResult]::Yes) {
Write-Host "Restoring Visual Studio settings from $vsSettingsFile. Don't forget to close Visual Studio to end the script."
    Start-Process -FilePath "C:\\Program Files\\Microsoft Visual Studio\\2022\\Community\\Common7\\IDE\\devenv.exe" -ArgumentList "/ResetSettings", "`"$($vsSettingsFile.FullName)`"" -Wait
}
}
