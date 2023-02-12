<#
.SYNOPSIS
.DESCRIPTION
    Use this file as a custom installer file. If you have the silent installers, you can use this to 
.INPUTS
    None
.OUTPUTS
    Anything written here. 
.NOTES
    File Name      : AdditionalApps.ps1
    Author         : Charlie Hall - charlie@chaelz.com
#>
Write-Host('Starting CWM install')
Start-Process 'msiexec' -ArgumentList '-i ConnectWise-Internet-Client.msi /passive' -Wait
Start-Sleep 15