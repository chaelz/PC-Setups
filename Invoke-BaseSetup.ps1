<#
.SYNOPSIS
	Base Setup script for new PCs. Assists in mass deployments. 
.DESCRIPTION
    Call this PC from a batch file with the settings already configured. 
	Be sure to configure the Install-Apps section with any applications to install.
.INPUTS
    OfficeVersion - Accepted Inputs: Business64 Business32 ProPlus64 ProPlus32
	SSID - SSID to join, string
	PSK - PSK for SSID, string
	LocalAdminPW - PW for Local Admin
	AgentMSI - Agent MSI name / location
	LocationID - Location ID - Required for Connectwise Automate agents. 
	NewName - New PC Name
	DomainName - Domain to join
	AdminPass - Domain Admin PW
.OUTPUTS
    None
.NOTES
    File Name      : Setup-Base.ps1
    Author         : Charlie Hall - charlie@chaelz.com
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory)] [string]$SSID,
    [Parameter(Mandatory)] [string]$PSK,
    [Parameter(Mandatory)] [string]$LocalAdminPW,
    [Parameter(Mandatory)] [string]$AgentMSI,
    [Parameter(Mandatory)] [string]$LocationID,
    [Parameter(Mandatory)] [string]$NewName,
    [ValidateSet('Business64', 'Business32', 'ProPlus64', 'ProPlus32')] [Parameter(Mandatory)] [string]$OfficeVersion,
    [Parameter(Mandatory)] [string]$PresentWorkingDir,
    [Parameter(Mandatory)] [string]$ServerAddress,
    [Parameter(Mandatory)] [string]$ServerPass,
    [Parameter(ParameterSetName = 'Domain', Mandatory = $false)] [switch]$DomainJoined,
    [Parameter(ParameterSetName = 'Domain', Mandatory = $false)] [string]$DomainName,
    [Parameter(ParameterSetName = 'Domain', Mandatory = $false)] [string]$AdminPass


)

function Get-TemplateFunction {

    <# 
		Set Parameters and Variables
	#>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] [string]$ParamName,
	
        [Parameter(Mandatory)]
        [string]$ParamName2
    )

    <# 
		Begin Function Execution
	#>
}


function Set-PowerOptions {
    <# 
		Begin Function Execution
	#>

    #capture the active scheme GUID
    $activeScheme = cmd /c "powercfg /getactivescheme"
    $regEx = '(\{){0,1}[0-9a-fA-F]{8}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{12}(\}){0,1}'
    $asGuid = [regex]::Match($activeScheme, $regEx).Value

    #relative GUIDs for Lid Close settings
    $pwrGuid = '4f971e89-eebd-4455-a8de-9e59040e7347'
    $lidClosedGuid = '5ca83367-6e45-459f-a27b-476b1d01c936'

    # DC Value // On Battery // 1 = sleep
    cmd /c "powercfg /setdcvalueindex $asGuid $pwrGuid $lidClosedGuid 1"
    #AC Value // While plugged in // 0 = do nothing
    cmd /c "powercfg /setacvalueindex $asGuid $pwrGuid $lidClosedGuid 0"

    #apply settings
    cmd /c "powercfg /s $asGuid"

    # sets power options to Never
    powercfg.exe -x -monitor-timeout-ac 0
    powercfg.exe -x -monitor-timeout-dc 0
    powercfg.exe -x -disk-timeout-ac 0
    powercfg.exe -x -disk-timeout-dc 0
    powercfg.exe -x -standby-timeout-ac 0
    powercfg.exe -x -standby-timeout-dc 0
    powercfg.exe -x -hibernate-timeout-ac 0
    powercfg.exe -x -hibernate-timeout-dc 0
}

function Set-WirelessNetwork {
    <# 
		Set Parameters and Variables
	#>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$SSID,
	
        [Parameter(Mandatory)]
        [string]$PSK
    )

    <# 
		Begin Function Execution
	#>
    $guid = New-Guid
    $HexArray = $ssid.ToCharArray() | foreach-object { [System.String]::Format("{0:X}", [System.Convert]::ToUInt32($_)) }
    $HexSSID = $HexArray -join ""
    @"
<?xml version="1.0"?>
<WLANProfile xmlns="http://www.microsoft.com/networking/WLAN/profile/v1">
	<name>$($SSID)</name>
	<SSIDConfig>
		<SSID>
			<hex>$($HexSSID)</hex>
			<name>$($SSID)</name>
		</SSID>
	</SSIDConfig>
	<connectionType>ESS</connectionType>
	<connectionMode>auto</connectionMode>
	<MSM>
		<security>
			<authEncryption>
				<authentication>WPA2PSK</authentication>
				<encryption>AES</encryption>
				<useOneX>false</useOneX>
			</authEncryption>
			<sharedKey>
				<keyType>passPhrase</keyType>
				<protected>false</protected>
				<keyMaterial>$($PSK)</keyMaterial>
			</sharedKey>
		</security>
	</MSM>
	<MacRandomization xmlns="http://www.microsoft.com/networking/WLAN/profile/v3">
		<enableRandomization>false</enableRandomization>
		<randomizationSeed>1451755948</randomizationSeed>
	</MacRandomization>
</WLANProfile>
"@ | out-file "$($ENV:TEMP)\$guid.SSID"

    netsh wlan add profile filename="$($ENV:TEMP)\$guid.SSID" user=all
    netsh wlan connect name=$SSID
    Remove-Item "$($ENV:TEMP)\$guid.SSID" -Force
}

function Install-Office {
    <# 
		Set Parameters and Variables
	#>
    [CmdletBinding()]
    param(
        [ValidateSet('Business64', 'Business32', 'ProPlus64', 'ProPlus32')]
        [Parameter(Mandatory)]
        [string]$OfficeVersion
    )
    <# 
		Begin Function Execution
	#>
    Write-Host('Uninstalling Office pre-installs')
    &.\ODT\setup.exe /configure .\ODT\uninstall.xml

    Switch ($OfficeVersion) {
        # Start Install Switch
        "Business64" {
            Write-Host('Installing Office 365 Business (64-bit)'); &.\ODT\setup.exe /configure .\ODT\business64bit.xml; break
        }
        "Business32" {
            Write-Host('Installing Office 365 Business (32-bit)'); &.\ODT\setup.exe /configure .\ODT\business32bit.xml; break
        }
        "ProPlus64" {
            Write-Host('Installing Office 365 ProPlus (64-bit)'); &.\ODT\setup.exe /configure .\ODT\proplus64bit.xml; break
        }
        "ProPlus32" {
            Write-Host('Installing Office 365 ProPlus (32-bit)'); &.\ODT\setup.exe /configure .\ODT\proplus32bit.xml; break
        }
    } # End Switch
}

function Install-Apps {	
    <# 
		Begin Function Execution
	#>
    # Example listed below, change as necessary. 

    If (Test-Path('AdditionalApps.ps1')) {
        Write-Host('Starting Additional Apps')
        &.\AdditionalApps.ps1

    }
    Else {
        Write-Host('AdditionalApps.ps1 not found. App section completed. ')
    }

}

function Install-Agent {
    <# 
		Set Parameters and Variables
	#>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$AgentMSI,

        [Parameter(Mandatory)]
        [string]$LocationID
    )

    <# 
		Begin Function Execution
	#>
    while (-NOT(Test-Path('C:\Windows\LTSvc\LTSVC.exe'))) {
        Write-Host('Beginning Agent Install')
        msiexec /i $AgentMSI /passive /norestart SERVERADDRESS=$ServerAddress SERVERPASS=$ServerPass LOCATION=$LocationID
        Start-Sleep -Seconds 15
    }
}

function Set-LocalAdmin {
    <# 
		Set Parameters and Variables
	#>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$LocalAdminPW
    )
    $SecureLocalPW = ConvertTo-SecureString $LocalAdminPW -AsPlainText -Force
    <# 
		Begin Function Execution
	#>
    Write-Host('Setting Local Admin up')
    Set-LocalUser -Name 'ProSuiteAdmin' -Description 'MainSpring ProSuite local admin account' -Password $SecureLocalPW
}

function Join-Domain {
    <# 
		Set Parameters and Variables
	#>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$NewName,
	
        [Parameter(Mandatory)]
        [string]$DomainName,
		
        [Parameter(Mandatory)]
        [string]$AdminPass
    )
    $AdminUsername = "$DomainName\mainspring"
    $Pass = $AdminPass | ConvertTo-SecureString -asPlainText -Force
    $Cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $AdminUsername, $Pass
    <# 
		Begin Function Execution
	#>
    try {
        Write-Host("Renaming to $NewName and joining $DomainName")
        Add-Computer -NewName $NewName -domainname $DomainName -Credential $Cred -Restart
    }
    catch {
        Write-Host("Domain join failed. Attempting again in 10 seconds.")
        Start-Sleep -Seconds 10
        Join-Domain -NewName $NewName -DomainName $DomainName -AdminPass $AdminPass
    }
}

function Rename-PC {
    <# 
		Set Parameters and Variables
	#>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$NewName
    )

    <# 
		Begin Function Execution
	#>
    
    Rename-Computer -NewName $NewName -Force -Restart
}

function Initialize-BaseSetup {
    <# 
		Begin Function Execution
	#>
    tzutil /s "Eastern Standard Time"
    if (Test-Path('C:\Program Files\Dell\CommandUpdate\dcu-cli.exe')) { 
        &'C:\Program Files\Dell\CommandUpdate\dcu-cli.exe' /configure -scheduleAction=DownloadInstallAndNotify
        &'C:\Program Files\Dell\CommandUpdate\dcu-cli.exe' /scan -updateSeverity='critical,security,recommended,optional'
        &'C:\Program Files\Dell\CommandUpdate\dcu-cli.exe' /applyUpdates -updateSeverity='critical,security,recommended,optional' -reboot=disable
    }
    if (Test-Path('C:\Program Files\Dell\DellOptimizer\do-cli.exe')) {
        &'C:\Program Files\Dell\DellOptimizer\do-cli.exe' /configure -name=ProximitySensor.State -value=False
        &'C:\Program Files\Dell\DellOptimizer\do-cli.exe' /configure -name=ProximitySensor.WalkAwayLock -value=False
    }
}

<#
	Begin Main Funcion Execution
#>

Set-WirelessNetwork -SSID $SSID -PSK $PSK
Start-Sleep -Seconds 10

Set-PowerOptions
Start-Sleep -Seconds 5

Initialize-BaseSetup

Set-Location $PresentWorkingDir
Write-Host("Set location to $PresentWorkingDir")
Start-Sleep -Seconds 10

Install-Office -OfficeVersion $OfficeVersion

Install-Apps

Install-Agent -AgentMSI $AgentMSI -LocationID $LocationID
Set-LocalAdmin -LocalAdminPW $LocalAdminPW

# FINAL COMMAND - PC RESTARTS AT THE END

if ($DomainJoined) {
    Join-Domain -NewName $NewName -DomainName $DomainName -AdminPass $AdminPass
}
else {
    Rename-PC -NewName $NewName
}

