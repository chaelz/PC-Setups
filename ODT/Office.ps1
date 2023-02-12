# Run as Admin
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
	Start-Process PowerShell -Verb RunAs "-NoProfile -ExecutionPolicy Bypass -Command `"cd '$pwd'; & '$PSCommandPath';`"";
	exit;
}

function Menu { # Begin Menu function
	Clear-Host
	$Choice = Read-Host 'Please Choose:
1: Uninstall Office 365 (all installs)
2: Install Business (64-bit)
3: Install Business (32-bit)
4: Install ProPlus (64-bit)
5: Install ProPlus (32-bit)
6: Download ProPlus 64
'
    Switch($Choice) { # Start Switch - choose your script. Add new choices here for future changes to audit. 
		"1" {Write-Host('Uninstalling Office. Please wait.'); &.\setup.exe /configure .\uninstall.xml; break}
		"2" {Write-Host('Installing Office 365 Business (64-bit)'); &.\setup.exe /configure business64bit.xml; break}
		"3" {Write-Host('Installing Office 365 Business (32-bit)'); &.\setup.exe /configure business32bit.xml; break}
		"4" {Write-Host('Installing Office 365 ProPlus (64-bit)'); &.\setup.exe /configure proplus64bit.xml; break}
        "5" {Write-Host('Installing Office 365 ProPlus (32-bit)'); &.\setup.exe /configure proplus32bit.xml; break}
        "6" {Write-Host('Downloading Office 365 ProPlus (64-bit)'); &.\setup.exe /download proplus64bit.xml; break}
		default {Write-Host "Invalid input."}
	} # End Switch
	$Continue = Read-Host 'Run another?'
	If ($Continue -NotLike 'n') { 
		return $true
	} Else { 
		return $false
	}
} # End Menu function

$L = $true
While ($L -eq $true) {
    $L = Menu
}