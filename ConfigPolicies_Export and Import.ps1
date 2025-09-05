#########################################################################################################
# Script Name: ConfigPolicies_Export and Import.ps1                                                     #
# Description: This script is used to export and import Settings Catalog                                #
# and Device Configuration policies from Intune using the Graph API                                     #
# Author: Khris Harper                                                                                  #
# Date Create: 09/05/2025                                                                               #
# Date Updated: 09/05/2025                                                                              #
# Version: 1.0.0                                                                                        #
# Note: This script requires the Microsoft.Graph.Intune module and the                                  #
#  Microsoft.Graph.Beta.DeviceManagement module to beinstalled. If you haven't already                  #
#  installed the module, see this guide:                                                                #
# https://learn.microsoft.com/en-us/powershell/microsoftgraph/installation?view=graph-powershell-1.0    #
#########################################################################################################

#Module Import
Import-Module Microsoft.Graph.Beta.DeviceManagement

#Functions!!
Function Get-SettingsCatalogPolicy() {

    <#
.SYNOPSIS
This function is used to get Settings Catalog policies from the Graph API REST interface
.DESCRIPTION
The function connects to the Graph API Interface and gets any Settings Catalog policies
.EXAMPLE
Get-SettingsCatalogPolicy
Returns any Settings Catalog policies configured in Intune
Get-SettingsCatalogPolicy -Platform windows10
Returns any Windows 10 Settings Catalog policies configured in Intune
Get-SettingsCatalogPolicy -Platform macOS
Returns any MacOS Settings Catalog policies configured in Intune
.NOTES
NAME: Get-SettingsCatalogPolicy
#>

    [cmdletbinding()]

    param
    (
        [parameter(Mandatory = $false)]
        [ValidateSet("windows10", "macOS")]
        [ValidateNotNullOrEmpty()]
        [string]$Platform
    )

    $graphApiVersion = "beta"
    $SettingInfo = @()

    if ($Platform) {
        
        $Resource = "deviceManagement/configurationPolicies?`$filter=platforms has '$Platform' and technologies has 'mdm'"

    }

    else {

        $Resource = "deviceManagement/configurationPolicies?`$filter=technologies has 'mdm'"

    }

    try {

        $uri = "https://graph.microsoft.com/$graphApiVersion/$($Resource)"
        #(Invoke-MgGraphRequest -Uri $uri  -Method Get).Value
        $Response = Invoke-MgGraphRequest -Uri $uri -Method Get -outputtype PSObject
        $NextLink = $Response."@odata.nextLink"
        $SettingInfo = $Response.value
        while ($NextLink -ne $null) {

            $Response = Invoke-MgGraphRequest -Uri $NextLink  -Method Get -outputtype PSObject
            $NextLink = $Response."@odata.nextLink"
            $SettingInfo += $Response.value

        }
        $SettingInfo
    }

    catch {

        $ex = $_.Exception
        $errorResponse = $ex.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($errorResponse)
        $reader.BaseStream.Position = 0
        $reader.DiscardBufferedData()
        $responseBody = $reader.ReadToEnd();
        Write-Host "Response content:`n$responseBody" -f Red
        Write-Error "Request to $Uri failed with HTTP Status $($ex.Response.StatusCode) $($ex.Response.StatusDescription)"
        write-host
        break

    }

}

####################################################
Function Get-DeviceConfigPolicy() {

    <#
.SYNOPSIS
This function is used to get Settings Catalog policies from the Graph API REST interface
.DESCRIPTION
The function connects to the Graph API Interface and gets any Settings Catalog policies
.EXAMPLE
Get-SettingsCatalogPolicy
Returns any Settings Catalog policies configured in Intune
Get-SettingsCatalogPolicy -Platform windows10
Returns any Windows 10 Settings Catalog policies configured in Intune
Get-SettingsCatalogPolicy -Platform macOS
Returns any MacOS Settings Catalog policies configured in Intune
.NOTES
NAME: Get-SettingsCatalogPolicy
#>

    [cmdletbinding()]

    $Resource = "deviceManagement/deviceConfigurations"

    try {

        $uri = "https://graph.microsoft.com/$graphApiVersion/$($Resource)"
        $Response = Invoke-MgGraphRequest -Uri $uri -Method Get -outputtype PSObject
        $NextLink = $Response."@odata.nextLink"
        $SettingInfo = $Response
        while ($NextLink -ne $null) {

            $Response = Invoke-MgGraphRequest -Uri $NextLink  -Method Get -outputtype PSObject
            $NextLink = $Response."@odata.nextLink"
            $SettingInfo += $Response

        }
        $SettingInfo
    }

    catch {

        $ex = $_.Exception
        $errorResponse = $ex.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($errorResponse)
        $reader.BaseStream.Position = 0
        $reader.DiscardBufferedData()
        $responseBody = $reader.ReadToEnd();
        Write-Host "Response content:`n$responseBody" -f Red
        Write-Error "Request to $Uri failed with HTTP Status $($ex.Response.StatusCode) $($ex.Response.StatusDescription)"
        write-host
        break

    }

}

####################################################

Function Get-SettingsCatalogPolicySettings() {

    <#
.SYNOPSIS
This function is used to get Settings Catalog policy Settings from the Graph API REST interface
.DESCRIPTION
The function connects to the Graph API Interface and gets any Settings Catalog policy Settings
.EXAMPLE
Get-SettingsCatalogPolicySettings -policyid policyid
Returns any Settings Catalog policy Settings configured in Intune
.NOTES
NAME: Get-SettingsCatalogPolicySettings
#>

    [cmdletbinding()]

    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $policyid
    )

    $graphApiVersion = "beta"
    $Resource = "deviceManagement/configurationPolicies('$policyid')/settings?`$expand=settingDefinitions"

    try {

        $uri = "https://graph.microsoft.com/$graphApiVersion/$($Resource)"

        $Response = (Invoke-MgGraphRequest -Uri $uri -Method Get)

        $AllResponses = $Response.value
     
        $ResponseNextLink = $Response."@odata.nextLink"

        while ($ResponseNextLink -ne $null) {

            $Response = (Invoke-MgGraphRequest -Uri $ResponseNextLink  -Method Get)
            $ResponseNextLink = $Response."@odata.nextLink"
            $AllResponses += $Response.value

        }

        return $AllResponses

    }

    catch {

        $ex = $_.Exception
        $errorResponse = $ex.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($errorResponse)
        $reader.BaseStream.Position = 0
        $reader.DiscardBufferedData()
        $responseBody = $reader.ReadToEnd();
        Write-Host "Response content:`n$responseBody" -f Red
        Write-Error "Request to $Uri failed with HTTP Status $($ex.Response.StatusCode) $($ex.Response.StatusDescription)"
        write-host
        break

    }

}

####################################################

Function Get-DeviceConfigPolicySettings() {

    <#
.SYNOPSIS
This function is used to get Device Config policy Settings from the Graph API REST interface
.DESCRIPTION
The function connects to the Graph API Interface and gets any Device Config policy Settings
.EXAMPLE

Returns any Device Config policy Settings configured in Intune
#>

    [cmdletbinding()]

    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $policyid
    )

    $graphApiVersion = "beta"
    $Resource = "deviceManagement/configurationPolicies('$policyid')/settings?`$expand=settingDefinitions"

    try {

        $uri = "https://graph.microsoft.com/$graphApiVersion/$($Resource)"

        $Response = (Invoke-MgGraphRequest -Uri $uri -Method Get)

        $AllResponses = $Response.value
     
        $ResponseNextLink = $Response."@odata.nextLink"

        while ($ResponseNextLink -ne $null) {

            $Response = (Invoke-MgGraphRequest -Uri $ResponseNextLink  -Method Get)
            $ResponseNextLink = $Response."@odata.nextLink"
            $AllResponses += $Response.value

        }

        return $AllResponses

    }

    catch {

        $ex = $_.Exception
        $errorResponse = $ex.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($errorResponse)
        $reader.BaseStream.Position = 0
        $reader.DiscardBufferedData()
        $responseBody = $reader.ReadToEnd();
        Write-Host "Response content:`n$responseBody" -f Red
        Write-Error "Request to $Uri failed with HTTP Status $($ex.Response.StatusCode) $($ex.Response.StatusDescription)"
        write-host
        break

    }

}

####################################################

Function Export-JSONData() {

    <#
.SYNOPSIS
This function is used to export JSON data returned from Graph
.DESCRIPTION
This function is used to export JSON data returned from Graph
.EXAMPLE
Export-JSONData -JSON $JSON
Export the JSON inputted on the function
.NOTES
NAME: Export-JSONData
#>

    param (

        $JSON,
        $ExportPath

    )

    try {

        if ($JSON -eq "" -or $JSON -eq $null) {

            write-host "No JSON specified, please specify valid JSON..." -f Red

        }

        elseif (!$ExportPath) {

            write-host "No export path parameter set, please provide a path to export the file" -f Red

        }

        elseif (!(Test-Path $ExportPath)) {

            write-host "$ExportPath doesn't exist, can't export JSON Data" -f Red

        }

        else {

            $JSON1 = ConvertTo-Json $JSON -Depth 20

            $JSON_Convert = $JSON1 | ConvertFrom-Json

            $displayName = $JSON_Convert.name

            # Updating display name to follow file naming conventions - https://msdn.microsoft.com/en-us/library/windows/desktop/aa365247%28v=vs.85%29.aspx
            $DisplayName = $DisplayName -replace '\<|\>|:|"|/|\\|\||\?|\*', "_"

            $FileName_JSON = "$DisplayName" + "_" + $(get-date -f dd-MM-yyyy-H-mm-ss) + ".json"
            $ExportPath = "$ExportPath\SettingsCatalog"
            write-host "Export Path:" "$ExportPath"

            $JSON1 | Set-Content -LiteralPath "$ExportPath\$FileName_JSON"
            write-host "JSON created in $ExportPath\$FileName_JSON..." -f cyan
            
        }

    }

    catch {

        $_.Exception

    }

}

####################################################

Function Test-JSON(){

<#
.SYNOPSIS
This function is used to test if the JSON passed to a REST Post request is valid
.DESCRIPTION
The function tests if the JSON passed to the REST Post is valid
.EXAMPLE
Test-JSON -JSON $JSON
Test if the JSON is valid before calling the Graph REST interface
.NOTES
NAME: Test-AuthHeader
#>

param (

$JSON

)

    try {

    $TestJSON = ConvertFrom-Json $JSON -ErrorAction Stop
    $validJson = $true

    }

    catch {

    $validJson = $false
    $_.Exception

    }

    if (!$validJson){
    
    Write-Host "Provided JSON isn't in valid JSON format" -f Red
    break

    }

}

####################################################
Function Add-SettingsCatalogPolicy(){

<#
.SYNOPSIS
This function is used to add a Settings Catalog policy using the Graph API REST interface
.DESCRIPTION
The function connects to the Graph API Interface and adds a Settings Catalog policy
.EXAMPLE
Add-SettingsCatalogPolicy -JSON $JSON
Adds a Settings Catalog policy in Endpoint Manager
.NOTES
NAME: Add-SettingsCatalogPolicy
#>

[cmdletbinding()]

param
(
    [parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    $JSON
)

$graphApiVersion = "Beta"
$Resource = "deviceManagement/configurationPolicies"

    try {

        if($JSON -eq "" -or $JSON -eq $null){

        write-host "No JSON specified, please specify valid JSON for the Endpoint Security Disk Encryption Policy..." -f Red

        }

        else {

        Test-JSON -JSON $JSON

        $uri = "https://graph.microsoft.com/$graphApiVersion/$($Resource)"
        Invoke-MgGraphRequest -Uri $uri -Method Post -Body $JSON -ContentType "application/json"

        }

    }
    
    catch {

    $ex = $_.Exception
    $errorResponse = $ex.Response.GetResponseStream()
    $reader = New-Object System.IO.StreamReader($errorResponse)
    $reader.BaseStream.Position = 0
    $reader.DiscardBufferedData()
    $responseBody = $reader.ReadToEnd();
    Write-Host "Response content:`n$responseBody" -f Red
    Write-Error "Request to $Uri failed with HTTP Status $($ex.Response.StatusCode) $($ex.Response.StatusDescription)"
    write-host
    break

    }

}

####################################################

$ExportPath = Read-Host -Prompt "Please specify a path to export the policy data to e.g. C:\IntuneOutput"

# If the directory path doesn't exist prompt user to create the directory
$ExportPath = $ExportPath.replace('"', '')

if (!(Test-Path "$ExportPath")) {

    Write-Host
    Write-Host "Path '$ExportPath' doesn't exist, do you want to create this directory? Y or N?" -ForegroundColor Yellow

    $Confirm = read-host

    if ($Confirm -eq "y" -or $Confirm -eq "Y") {
        Write-Host "Create Directories..." -ForegroundColor Green
        new-item -ItemType Directory -Path "$ExportPath" | Out-Null
        Write-Host "Creating Sub Directories..." -ForegroundColor Green
        new-item -ItemType Directory -Path "$ExportPath\SettingsCatalog" | Out-Null
        new-item -ItemType Directory -Path "$ExportPath\DeviceConfiguration" | Out-Null

    }

    else {

        Write-Host "Creation of directory path was cancelled..." -ForegroundColor Red
        Write-Host
        break

    }

} Else {
    if (!(Test-Path "$ExportPath\SettingsCatalog")) {
        Write-Host "Creating Sub Directories..." -ForegroundColor Green
        new-item -ItemType Directory -Path "$ExportPath\SettingsCatalog" | Out-Null
    }
    if (!(Test-Path "$ExportPath\DeviceConfiguration")) {
        Write-Host "Creating Sub Directories..." -ForegroundColor Green
        new-item -ItemType Directory -Path "$ExportPath\DeviceConfiguration" | Out-Null
    }
}

####################################################
#This will run for Settings Catalog Policies
$Policies = Get-SettingsCatalogPolicy

if ($Policies) {

    foreach ($policy in $Policies) {

        Write-Host $policy.name -ForegroundColor Yellow

        $AllSettingsInstances = @()

        $policyid = $policy.id
        $Policy_Technologies = $policy.technologies
        $Policy_Platforms = $Policy.platforms
        $Policy_Name = $Policy.name
        $Policy_Description = $policy.description

        $PolicyBody = New-Object -TypeName PSObject

        Add-Member -InputObject $PolicyBody -MemberType 'NoteProperty' -Name 'name' -Value "$Policy_Name"
        Add-Member -InputObject $PolicyBody -MemberType 'NoteProperty' -Name 'description' -Value "$Policy_Description"
        Add-Member -InputObject $PolicyBody -MemberType 'NoteProperty' -Name 'platforms' -Value "$Policy_Platforms"
        Add-Member -InputObject $PolicyBody -MemberType 'NoteProperty' -Name 'technologies' -Value "$Policy_Technologies"

        # Checking if policy has a templateId associated
        if ($policy.templateReference.templateId) {

            Write-Host "Found template reference" -f Cyan
            $templateId = $policy.templateReference.templateId

            $PolicyTemplateReference = New-Object -TypeName PSObject

            Add-Member -InputObject $PolicyTemplateReference -MemberType 'NoteProperty' -Name 'templateId' -Value $templateId

            Add-Member -InputObject $PolicyBody -MemberType 'NoteProperty' -Name 'templateReference' -Value $PolicyTemplateReference

        }

        $SettingInstances = Get-SettingsCatalogPolicySettings -policyid $policyid

        $Instances = $SettingInstances.settingInstance

        foreach ($object in $Instances) {

            $Instance = New-Object -TypeName PSObject

            Add-Member -InputObject $Instance -MemberType 'NoteProperty' -Name 'settingInstance' -Value $object
            $AllSettingsInstances += $Instance

        }

        Add-Member -InputObject $PolicyBody -MemberType 'NoteProperty' -Name 'settings' -Value @($AllSettingsInstances)

        Export-JSONData -JSON $PolicyBody -ExportPath "$ExportPath"
        Write-Host
        
    }

}

else {

    Write-Host "No Settings Catalog policies found..." -ForegroundColor Red
    Write-Host

}


$graphApiVersion = "beta"
$Resource = "deviceManagement/deviceConfigurations"
$uri = "https://graph.microsoft.com/$graphApiVersion/$($Resource)"
$TestPull = Invoke-MgGraphRequest -Uri $uri -Method Get -outputtype PSObject
$TestValues = $TestPull | select -expandproperty value
$TestNames = $TestValues | select -expandproperty displayname
foreach($X in $TestNames){
    $Secret = $null
    $Value = $null
    
    write-host $X
    $Y = $TestValues | where {$_.displayName -eq $X}
    $omasettings = $Y.omasettings
    if ($omasettings -ne $null) {
        $encrypted = $omasettings | select -ExpandProperty isEncrypted
        if($encrypted -contains $true) {
            $Secret = $Y.omasettings.secretReferenceValueId
            $ID = $Y.id
            $Resource = "deviceManagement/deviceConfigurations/$($ID)/getOmaSettingPlaintextValue(secretReferenceValueId='$($Secret)')"
            $uri = "https://graph.microsoft.com/$graphApiVersion/$($Resource)"
            $Response = Invoke-MgGraphRequest -Uri $uri -Method Get -outputtype PSObject
            $Value = $Response.value
            $newOMASettings = @()
            $newOMASetting = @{}
            $newOmaSetting.'@odata.type' = $omaSettings.'@odata.type'
            $newOmaSetting.displayName = $omaSettings.displayName
            $newOmaSetting.description = $omaSettings.description
            $newOmaSetting.omaUri = $omaSettings.omaUri
            $newOmaSetting.value = $Value
            $newOmaSettings += $newOmaSetting
            ($TestValues | where {$_.displayName -eq $X}).omasettings = @()
            ($TestValues | where {$_.displayName -eq $X}).omasettings = $newOmaSettings
            

        } Else {
        
            $newOMASettings = @()
            $newOMASetting = @{}
            $newOmaSetting.'@odata.type' = $omaSettings.'@odata.type'
            $newOmaSetting.displayName = $omaSettings.displayName
            $newOmaSetting.description = $omaSettings.description
            $newOmaSetting.omaUri = $omaSettings.omaUri
            $newOmaSetting.value = $omaSettings.value
            $newOmaSettings += $newOmaSetting
            (($TestPull).value | where {$_.displayName -eq $X}).omasettings = @()
            (($TestPull).value | where {$_.displayName -eq $X}).omasettings = $newOmaSettings
        }
    }
    $DisplayName = $X -replace '\<|\>|:|"|/|\\|\||\?|\*', "_"

    $FileName_JSON = "$DisplayName" + "_" + $(get-date -f dd-MM-yyyy-H-mm-ss) + ".json"
    $DeviceExportPath = "$ExportPath\DeviceConfiguration"
    $TestValues = ($TestPull).value
    $Name = $X
    $TestValues | Where {$_.DisplayName -eq $Name} | convertto-json | Out-File -LiteralPath $DeviceExportPath\$FileName_JSON -Force
    
}

write-host "Completed all export tasks, disconnecting from Graph..." -f Green
Disconnect-MgGraph
write-host "Disconnected from Graph..." -f Green
write-host
Write-Host "Running Connect-MgGraph to connect to NEW tenant, please authenticate..." -ForegroundColor Green
Connect-MgGraph
Write-Host
write-host "Connected, running import tasks now..." -f Green
write-host 

#Device Config Import

write-host "Starting Device Configuration Import..." -f Green
write-host
$graphApiVersion = "Beta"
$Resource = "deviceManagement/deviceconfigurations"
$JSON_Files = Get-ChildItem -Path "$ExportPath\DeviceConfiguration" -Filter *.json | select -ExpandProperty Name
foreach($X in $JSON_Files){
    $JSON_Data = gc "$ExportPath\DeviceConfiguration\$X"
    $JSON_Convert = $JSON_Data | ConvertFrom-Json | Select-Object -Property * -ExcludeProperty id,createdDateTime,lastModifiedDateTime,version,supportsScopeTags,secretReferenceValueId

    $DisplayName = $JSON_Convert.displayname

    $JSON_Output = $JSON_Convert | ConvertTo-Json -Depth 20
                
    write-host
    write-host "Settings Catalog Policy '$DisplayName' Found..." -ForegroundColor Yellow
    write-host
    $JSON_Output
    write-host
    Write-Host "Adding Settings Catalog Policy '$DisplayName'" -ForegroundColor Yellow
    $uri = "https://graph.microsoft.com/$graphApiVersion/$($Resource)"
    Invoke-MgGraphRequest -Uri $uri -Method Post -Body $JSON_Output -ContentType "application/json"
    write-host
}


#Settings Catalog Import

write-host "Starting Settings Catalog Import..." -f Green
write-host
$JSON_Files = Get-ChildItem -Path "$ExportPath\SettingsCatalog" -Filter *.json | select -ExpandProperty Name
foreach($X in $JSON_Files){
    $JSON_Data = gc "$ExportPath\SettingsCatalog\$X"
    $JSON_Convert = $JSON_Data | ConvertFrom-Json | Select-Object -Property * -ExcludeProperty id,createdDateTime,lastModifiedDateTime,version,supportsScopeTags,secretReferenceValueId

    $DisplayName = $JSON_Convert.name

    $JSON_Output = $JSON_Convert | ConvertTo-Json -Depth 20
                
    write-host
    write-host "Settings Catalog Policy '$DisplayName' Found..." -ForegroundColor Yellow
    write-host
    $JSON_Output
    write-host
    Write-Host "Adding Settings Catalog Policy '$DisplayName'" -ForegroundColor Yellow
    Add-SettingsCatalogPolicy -JSON $JSON_Output
    write-host
}
write-host "Completed all import tasks, disconnecting from Graph..." -f Green
Disconnect-MgGraph
write-host "Disconnected from Graph..." -f Green
write-host
write-host "Script completed..." -f Green

