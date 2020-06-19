Clear-Host

function Get-RegistryEntries {
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
    
    [CmdletBinding()]
    param (
        $ComputerName = $env:COMPUTERNAME, #default $ComputerName to local PC
        $SiteName = (Get-ChildItem -Path "HKLM:\SOFTWARE\Wow6432Node\The Software Group\Meridian\DBBroker\").PSChildName, #default $SiteName to entry in DBBroker for local PC
        $WhichAction = 'All' #default $WhichAction to 'All'
    )

    #Display information to user as to what ComputerName, SiteName, and Action is being run
    Write-Host "Computer Name: $ComputerName" -ForegroundColor Green
    Write-Host "Site Name: $SiteName" -ForegroundColor Green
    Write-Host "Action Selected: $WhichAction`n" -ForegroundColor Green

    <#*****************Get-ItemProperty 'HKLM:\SOFTWARE\Tyler Technologies\IMS\Console\' DO THIS SON #>
    
    #If WhichAction is DBBroker or All, retrieve DBBroker entries
    if ($WhichAction -in ('DBBroker', 'All')) {
        Write-Host "DBbroker Justice Entries..." -ForegroundColor Yellow
        Get-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\The Software Group\Meridian\DBBroker\$SiteName\Justice"
    }
    #If WhichAction is IMS or All, retrieve DBBroker entries    
    if ($WhichAction -in ('IMS', 'All')) {
        Write-Host "IMS Service Entries..." -ForegroundColor Yellow
        Get-ItemProperty -Path "HKLM:\SOFTWARE\Tyler Technologies\IMS\Service"
        #HKLM:\SOFTWARE\Tyler Technologies\IMS\Service
        #HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\TylerIMS\Parameters
    }
    #If WhichAction is Email or All, retrieve DBBroker entries    
    if ($WhichAction -in ('Email', 'All')) {
        Write-Host "Job Processing E-mail Entries..." -ForegroundColor Yellow
        Get-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\The Software Group\Meridian\Job Processing\Tasks\TYLTaskNotifyEmail\$SiteName"
    }
}#end function


do {
    $ynquest = Read-Host "Do you want to run all defaults for localhost (Y)es or (N)o?"

    #If yes is selected, call function passing no values
    if ($ynquest -eq 'y') {
        Get-RegistryEntries
    }

    #If no is selected, get information from user
    elseif ($ynquest -eq 'n') {
        #Get $CN value from user for ComputerName
        $CN = (Read-Host "What ComputerName(s by comma) do you want to retrieve entries from?  (D)efault for $env:COMPUTERNAME").split(',') | ForEach-Object {$_.trim()}

        #If not the local computer, get the remote computer's default DBBroker entry
        if ($CN -ne $env:COMPUTERNAME -and $CN -ne 'd') {
            $SN = @()
            foreach ($name in $CN) {
                $SN += (Invoke-Command -ComputerName $name -ScriptBlock {(Get-ChildItem -Path "HKLM:\SOFTWARE\Wow6432Node\The Software Group\Meridian\DBBroker\").PSChildName})
            }
        }

        else {
            #Else use localhost's default DBBroker entry
            $SN = (Get-ChildItem -Path "HKLM:\SOFTWARE\Wow6432Node\The Software Group\Meridian\DBBroker\").PSChildName
        }

        #Get $SN value from user for SiteName
        $SN = Read-Host "What SiteName do you want to retrieve entries from?  (D)efault for $SN"

        #Get $WA value from user for WhichAction
        do {
            $WA = Read-Host "What Action do you want to execute: (D)BBroker, (I)MS, (E)mail or (A)ll?"
            if ($WA -eq 'D') {$WA = 'DBBroker'}
            elseif ($WA -eq 'I') {$WA = 'IMS'}
            elseif ($WA -eq 'E') {$WA = 'Email'}
            elseif ($WA -eq 'A') {$WA = 'All'}
            else {Write-Warning "Invalid entry, please enter D, I, E, or A"}
        } until ($WA -in ('DBBroker', 'IMS', 'Email', 'All'))

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
            #Invoke-Command -ComputerName $CN -ScriptBlock ${Function:Get-RegistryEntries}
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

Write-Host "Press [ENTER] to exit..."
$x = Read-Host

#Invoke-Command -ComputerName CJSUPPORTAPP3, CJSUPPORTJOB3 -ScriptBlock ${Function:Get-RegistryEntries}