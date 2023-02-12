<#
.SYNOPSIS
.DESCRIPTION
    
.INPUTS
    
.OUTPUTS
    
.NOTES
    File Name      : 
#>
Write-Host('Starting Wrike install')
Start-Process 'msiexec' -ArgumentList '-i ConnectWise-Internet-Client.msi /passive' -Wait
Start-Sleep 15