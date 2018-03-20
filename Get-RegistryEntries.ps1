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
        $WhichAction = 'All'
    )
    write-host "Computer Name: $ComputerName" -ForegroundColor Green
    write-host "Site Name: $SiteName" -ForegroundColor Green
    write-host "Action Selected: $WhichAction`n" -ForegroundColor Green


    if ($WhichAction -in ('DBBroker', 'All')) {
        Write-Host "DBbroker Justice Entries..." -ForegroundColor Yellow
        #Get-ChildItem -Path "HKLM:\SOFTWARE\Wow6432Node\The Software Group\Meridian\DBBroker\$SiteName"
        Get-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\The Software Group\Meridian\DBBroker\$SiteName\Justice"
        
    }

    if ($WhichAction -in ('IMS', 'All')) {
        Write-Host "IMS Service Entries..." -ForegroundColor Yellow        
        #Get-ChildItem -Path "HKLM:\SOFTWARE\Tyler Technologies\IMS\"
        Get-Itemproperty -Path "HKLM:\SOFTWARE\Tyler Technologies\IMS\Service"        
    }
    #Invoke-Command -ComputerName $COMPUTERNAME -Command {Get-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\The Software Group\Meridian\DBBroker\$SITENAME\Justice"}
}

do {
    $ynquest = Read-Host "Do you want to run all defaults for localhost (Y)es or (N)o?"

    if ($ynquest -eq 'y') {
        Get-RegistryEntries
    }
    elseif ($ynquest -eq 'n') {
        $CN = Read-Host "What ComputerName do you want to retrieve entries from?  (D)efault for $env:COMPUTERNAME"

        $SN = (Get-ChildItem -Path "HKLM:\SOFTWARE\Wow6432Node\The Software Group\Meridian\DBBroker\").PSChildName
        $SN = Read-Host "What SiteName do you want to retrieve entries from?  (D)efault for $SN"

        do {
            $WA = Read-Host "What Action Yo (D)BBroker, (I)MS, or (A)ll?"
            if ($WA -eq 'D') {$WA = 'DBBroker'}
            elseif ($WA -eq 'I') {$WA = 'IMS'}
            elseif ($WA -eq 'A') {$WA = 'All'}
            else {Write-Warning "Invalid entry, please enter D, I, or A"}
        } until ($WA -in ('DBBroker', 'IMS', 'All'))

        if ($CN -eq 'D' -and $SN -eq 'D') {
            Get-RegistryEntries -WhichAction $WA
        }
        elseif ($CN -eq 'D') {
            Get-RegistryEntries -SiteName $SN -WhichAction $WA
        }
        elseif ($SN -eq 'D') {
            Get-RegistryEntries -ComputerName $CN -WhichAction $WA
        }
        #if ($SN -eq 'D') {$SN = (Get-ChildItem -Path "HKLM:\SOFTWARE\Wow6432Node\The Software Group\Meridian\DBBroker\").PSChildName}
        else {
            Get-RegistryEntries -ComputerName $CN -SiteName $SN -WhichAction $WA
        }
    }
    
    else {
        Write-Warning "Invalid entry, please enter Y or N"
    }
} until ($ynquest -in ('y', 'n'))