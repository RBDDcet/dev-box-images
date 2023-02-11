# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.


Param(
    [Parameter(Mandatory=$true)]
    [string]$PackageId,

    [Parameter(Mandatory=$true)]
    [string]$PackageArgs
)

function Show-Notification {
    [cmdletbinding()]
    Param (
        [string]
        $ToastTitle,

        [string]
        [parameter(ValueFromPipeline)]
        $ToastText
    )

    [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] > $null
    $Template = [Windows.UI.Notifications.ToastNotificationManager]::GetTemplateContent([Windows.UI.Notifications.ToastTemplateType]::ToastText02)

    $RawXml = [xml] $Template.GetXml()
    ($RawXml.toast.visual.binding.text|where {$_.id -eq "1"}).AppendChild($RawXml.CreateTextNode($ToastTitle)) > $null
    ($RawXml.toast.visual.binding.text|where {$_.id -eq "2"}).AppendChild($RawXml.CreateTextNode($ToastText)) > $null

    $SerializedXml = New-Object Windows.Data.Xml.Dom.XmlDocument
    $SerializedXml.LoadXml($RawXml.OuterXml)

    $Toast = [Windows.UI.Notifications.ToastNotification]::new($SerializedXml)
    $Toast.Tag = "AZBake"
    $Toast.Group = "AZBake"
    $Toast.ExpirationTime = [DateTimeOffset]::Now.AddMinutes(1)

    $Notifier = [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier("AZBake")
    $Notifier.Show($Toast);
}


if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process PowerShell -WindowStyle Hidden -Verb RunAs "-NoProfile -ExecutionPolicy Bypass -Command `"cd '$pwd'; & '$PSCommandPath';`"";
    exit;
}

#Check if folder exists
$LogDir = "C:\Temp"
if (-not (Test-Path -LiteralPath $LogDir)) {
    New-Item -Path $LogDir -ItemType Directory -ErrorAction Stop | Out-Null #-Force
}

$Log = Join-Path -Path $LogDir -ChildPath "chocouserinstall.log"
if (-not (Test-Path -LiteralPath $Log)) {
    New-Item -Path $Log -ItemType File -ErrorAction Stop | Out-Null #-Force
}

# Check if package is installed
$toastTitle = "DevBox User Install"
Show-Notification -ToastTitle $toastTitle -ToastText "Checking for $PackageId"
Add-Content -Path $log -Value "Checking for ${$PackageId}: $(Get-Date)"
$current = & choco.exe list --exact $PackageId --local-only --limit-output

if (-not $current) {
    Show-Notification -ToastTitle $toastTitle -ToastText "Installing $PackageId"
    Add-Content -Path $log -Value "Begin installing ${$PackageId}: $(Get-Date)"
    & choco install $PackageId $PackageArgs
    if ($LASTEXITCODE -ne 0) {
        Show-Notification -ToastTitle $toastTitle -ToastText "Failed Installing $PackageId"
        Add-Content -Path $log -Value "Failed to install ${$PackageId}: $(Get-Date)"
        return 1
    }
    Show-Notification -ToastTitle $toastTitle -ToastText "Finished installing $PackageId"
    Add-Content -Path $log -Value "Finished installing ${$PackageId}: $(Get-Date)"
}
else {
    Show-Notification -ToastTitle $toastTitle -ToastText "$PackageId already installed."
    Add-Content -Path $log -Value "${$PackageId} already installed: $(Get-Date)"
}