<#
.Synopsis
Get the registry entries specified.

.Description
The Get-RegistryEntries function...

.Parameter something


.Example


.Notes


.Link

#>

clear-host
#$SiteName = 'CJSUPPORTLAB2'
#$ComputerName = 'CJSUPPORTAPP3'
#$WhichAction = 'X'

function Get-RegistryEntries {
    [CmdletBinding()]
    param (
        $ComputerName = $env:COMPUTERNAME,
        $SiteName = (Get-ChildItem -Path "HKLM:\SOFTWARE\Wow6432Node\The Software Group\Meridian\DBBroker\").PSChildName,
        $WhichAction = 'Both'
    )
    write-host "Computer Name: $ComputerName" -ForegroundColor Green
    write-host "Site Name: $SiteName" -ForegroundColor Green
    write-host "Which Action: $WhichAction`n" -ForegroundColor Green


    if ($WhichAction -in ('DBBroker', 'Both')) {
        Write-Host "DBbroker Justice Entries..." -ForegroundColor Yellow
        #Get-ChildItem -Path "HKLM:\SOFTWARE\Wow6432Node\The Software Group\Meridian\DBBroker\$SiteName"
        Get-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\The Software Group\Meridian\DBBroker\$SiteName\Justice"
        
    }

    if ($WhichAction -in ('IMS', 'Both')) {
        Write-Host "IMS Service Entries..." -ForegroundColor Yellow        
        #Get-ChildItem -Path "HKLM:\SOFTWARE\Tyler Technologies\IMS\"
        Get-Itemproperty -Path "HKLM:\SOFTWARE\Tyler Technologies\IMS\Service"        
    }
    #Invoke-Command -ComputerName $COMPUTERNAME -Command {Get-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\The Software Group\Meridian\DBBroker\$SITENAME\Justice"}
}

do {
    $ynquest = Read-Host "Do you want to run all defaults (y)es or (n)o?"

    if ($ynquest -eq 'y') {
        Get-RegistryEntries
    }
    elseif ($ynquest -eq 'n') {
        $CN = Read-Host "What ComputerName do you want to retrieve entries from?  (D)efault for $env:COMPUTERNAME"

        $SN = (Get-ChildItem -Path "HKLM:\SOFTWARE\Wow6432Node\The Software Group\Meridian\DBBroker\").PSChildName
        $SN = Read-Host "What SiteName do you want to retrieve entries from?  (D)efault for $SN"

        if ($CN -eq 'D') {$CN = $env:COMPUTERNAME}
        if ($SN -eq 'D') {$SN = (Get-ChildItem -Path "HKLM:\SOFTWARE\Wow6432Node\The Software Group\Meridian\DBBroker\").PSChildName}
        #$CN

        do {
            $WA = Read-Host "What Action Yo (D)BBroker, (I)MS, or (B)oth"
            if ($WA -eq 'D') {$WA = 'DBBroker'}
            elseif ($WA -eq 'I') {$WA = 'IMS'}
            elseif ($WA -eq 'B') {$WA = 'Both'}
    
        } until ($WA -in ('DBBroker', 'IMS', 'Both'))

        Get-RegistryEntries -ComputerName $CN -SiteName $SN -WhichAction $WA
    }
} until ($ynquest -in ('y', 'n'))