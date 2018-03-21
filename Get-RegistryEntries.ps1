<#
.Synopsis
Get the registry entries specified.

.Description
The Get-RegistryEntries function...

.Parameter something

.Example
Get-RegistryEntries -ComputerName PC1 -SiteName TXPROD -WhichAction All

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
        $ComputerName = $env:COMPUTERNAME, #default $ComputerName to local PC
        $SiteName = (Invoke-Command -ComputerName $ComputerName -ScriptBlock {(Get-ChildItem -Path "HKLM:\SOFTWARE\Wow6432Node\The Software Group\Meridian\DBBroker\").PSChildName}), #default $SiteName to entry in DBBroker for local PC
        $WhichAction = 'All' #default $WhichAction to 'All'
    )

    #Display information to user as to what ComputerName, SiteName, and Action is being run
    Write-Host "Computer Name: $ComputerName" -ForegroundColor Green
    Write-Host "Site Name: $SiteName" -ForegroundColor Green
    Write-Host "Action Selected: $WhichAction`n" -ForegroundColor Green
    
    #If WhichAction is DBBroker or All, retrieve DBBroker entries
    if ($WhichAction -in ('DBBroker', 'All')) {
        Write-Host "DBbroker Justice Entries..." -ForegroundColor Yellow
        Invoke-Command -ComputerName $ComputerName -ScriptBlock {param($SITE)
            Get-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\The Software Group\Meridian\DBBroker\$SITE\Justice"
        } -ArgumentList $SiteName
    }

    #If WhichAction is IMS or All, retrieve IMS entries
    if ($WhichAction -in ('IMS', 'All')) {
        Write-Host "IMS Service Entries..." -ForegroundColor Yellow
        #Get-Itemproperty -Path "HKLM:\SOFTWARE\Tyler Technologies\IMS\Service"
        Invoke-Command -ComputerName $ComputerName -ScriptBlock {Get-ItemProperty -Path "HKLM:\SOFTWARE\Tyler Technologies\IMS\Service"}
    }
    <#
    if ($ComputerName -ne $env:COMPUTERNAME) {
        Write-Host 'Invoking Command to Remote Computer' -ForegroundColor Red
        if ($WhichAction -in ('DBBroker', 'All')) {
            Write-Host "DBbroker Justice Entries..." -ForegroundColor Yellow
            Invoke-Command -ComputerName $ComputerName -ScriptBlock {param($SITE)
                Get-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\The Software Group\Meridian\DBBroker\$SITE\Justice"
            } -ArgumentList $SiteName
        }
        if ($WhichAction -in ('IMS', 'All')) {
            Write-Host "IMS Service Entries..." -ForegroundColor Yellow
            #Get-Itemproperty -Path "HKLM:\SOFTWARE\Tyler Technologies\IMS\Service"
            Invoke-Command -ComputerName $ComputerName -ScriptBlock {Get-ItemProperty -Path "HKLM:\SOFTWARE\Tyler Technologies\IMS\Service"}
        }
    }

    else {
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
    }
    #>
} #end function


do {
    $ynquest = Read-Host "Do you want to run all defaults for localhost (Y)es or (N)o?"

    #If yes is selected, call function passing no values
    if ($ynquest -eq 'y') {
        Get-RegistryEntries
    }

    #If no is selected, get information from user
    elseif ($ynquest -eq 'n') {
        #Get $CN value from user for ComputerName
        $CN = Read-Host "What ComputerName do you want to retrieve entries from?  (D)efault for $env:COMPUTERNAME"

        #If not the local computer, get the remote computer's default DBBroker entry
        if ($CN -ne $env:COMPUTERNAME) {
            $SN = Invoke-Command -ComputerName $CN -ScriptBlock {(Get-ChildItem -Path "HKLM:\SOFTWARE\Wow6432Node\The Software Group\Meridian\DBBroker\").PSChildName}
        }
        else {
            $SN = (Get-ChildItem -Path "HKLM:\SOFTWARE\Wow6432Node\The Software Group\Meridian\DBBroker\").PSChildName
        }

        #Get $SN value from user for SiteName   
        $SN = Read-Host "What SiteName do you want to retrieve entries from?  (D)efault for $SN"

        #Get $WA value from user for WhichAction
        do {
            $WA = Read-Host "What Action do you want to execute: (D)BBroker, (I)MS, or (A)ll?"
            if ($WA -eq 'D') {$WA = 'DBBroker'}
            elseif ($WA -eq 'I') {$WA = 'IMS'}
            elseif ($WA -eq 'A') {$WA = 'All'}
            else {Write-Warning "Invalid entry, please enter D, I, or A"}
        } until ($WA -in ('DBBroker', 'IMS', 'All'))

        #If all defaults, call function and pass WhichAction
        if ($CN -eq 'D' -and $SN -eq 'D') {
            Get-RegistryEntries -WhichAction $WA
        }
        #If ComputerName is default, pass SiteName and WhichAction to function
        elseif ($CN -eq 'D') {
            Get-RegistryEntries -SiteName $SN -WhichAction $WA
        }
        #If SiteName is default, pass ComputerName and WhichAction to function        
        elseif ($SN -eq 'D') {
            Get-RegistryEntries -ComputerName $CN -WhichAction $WA
        }
        #If no defaults, pass all values to function
        else {
            Get-RegistryEntries -ComputerName $CN -SiteName $SN -WhichAction $WA
        }
    }

    #Error Catching, neither Y or N was entered
    else {
        Write-Warning "Invalid entry, please enter Y or N"
    }
} until ($ynquest -in ('y', 'n'))