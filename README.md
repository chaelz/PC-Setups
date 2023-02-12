# PC-Setups

Developed by Charlie Hall for MainSpring.
Written primarily to automate the process of PC setups and create a standard image for clients.
While tools like MDT are useful, they are rarely usable across a variety of different computers, and require specific setups for drivers and other minute configurations. This approach allows for a bit more flexibility in what you need to do. Don't want to join a WiFi network? Comment that line out. Have a complex setup for an application? Slap it in the AdditionalApps file.

The primary function of this is via the Invoke-BaseSetup.ps1 file. I call this file from a .bat file that I configure with the necessary settings per client. See Example.bat for an example. This allows for me to set the execution policy as needed, and auto run the script as an admin.

## Invoke-BaseSetup.ps1

| Parameters    | Notes                                                      |
| ------------- | ---------------------------------------------------------- |
| OfficeVersion | Accepted Inputs: Business64 Business32 ProPlus64 ProPlus32 |
| SSID          | SSID to join, string                                       |
| PSK           | PSK for SSID, string                                       |
| LocalAdminPW  | PW for Local Admin                                         |
| AgentMSI      | Agent MSI name / location                                  |
| LocationID    | Location ID - Required for Connectwise Automate agents.    |
| NewName       | New PC Name                                                |
| DomainName    | Domain to join                                             |
| AdminPass     | Domain Admin PW                                            |
| ServerAddress | Necessary for CWA installs.                                |
| ServerPass    | Necessary for CWA installs.                                |
