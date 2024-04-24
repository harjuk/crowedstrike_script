Set-Location C:\Users\abitton\Desktop\CrowedStrike-AdirScript

$logFilePath = ".\log\log_crowedstrike_008.log"
$pathToPCList = ".\bin\pcList.txt"
$exe_install_file = ".\bin\WindowsSensor.exe"
$install_command = 'WindowsSensor.exe /install /quiet /norestart GROUPING_TAGS="Labs" CID=3F16D8100B9948B897F190F0310D207E-3B'
$pathToIpOutput = ".\bin\ToPing.txt"
$pathToInfoScraper = ".\bin\info_scraper.ps1"

"==================================================" | Out-File $logFilePath
(" $(Get-Date) [] [ START OF LOG - INFO ] Start of Log: " + [string](Get-Date)) | Add-Content $logFilePath 
"==================================================" | Add-Content $logFilePath

$ErrorActionPreference = "Stop"
try {
    "==================================================" | Add-Content $logFilePath
    "[INFO] $(Get-Date) [] Loading List of Hosts from $($pathToPCList)....." | Add-Content $logFilePath
    $hostnames = Get-Content $pathToPCList -ErrorAction Stop
    "[INFO] $(Get-Date) [] Loaded Host Successfully from $($pathToPCList)."  | Add-Content $logFilePath
    "==================================================" | Add-Content $logFilePath
}
catch {
    "==================================================" | Add-Content $logFilePath
    "[ERROR] $(Get-Date) [] !!!!!"  | Add-Content $logFilePath
    "[ERROR] $(Get-Date) [] Couldn't Read Hosts from $($pathToPCList)." | Add-Content $logFilePath
    "[ERROR] $(Get-Date) [] Make sure that Path is readable by the user account running the script: '$($env:USERNAME)@$($env:USERDOMAIN)'"  | Add-Content $logFilePath
    "==================================================" | Add-Content $logFilePath
}
$ErrorActionPreference = "Continue"

$hostnames = Get-Content $pathToPCList

Clear-Content $pathToIpOutput

$iCount = 1

foreach ($hostname1 in $hostnames){
    "[COUNTER] $(Get-Date) [] Run #$($iCount) on Host $($hostname1)" | Add-Content $logFilePath
    if(Test-Connection ([System.Net.Dns]::GetHostAddresses($hostname1).IPAddressToString) -Quiet -Count 1){
        "[INFO] $(Get-Date) [] $($hostname1) @ $([System.Net.Dns]::GetHostAddresses($hostname1).IPAddressToString) is Alive !" | Add-Content $logFilePath

        "[INFO] $(Get-Date) [] Copying the CrowedStrike Installation to the Host......." | Add-Content $logFilePath

        $ErrorActionPreference = "Stop"
        try {
            Copy-Item $exe_install_file ("\\$($hostname1)\c$\Teva\")
            "[INFO] $(Get-Date) [] CrowedStrike Installation has copied OK to Host: $($hostname1)"| Add-Content $logFilePath
            Copy-Item $pathToInfoScraper ("\\$($hostname1)\c$\Teva\")
            "[INFO] $(Get-Date) [] Information Scraper Module has copied OK to Host: $($hostname1)"| Add-Content $logFilePath
        }
        catch {
            "[ERROR] $(Get-Date) [] !!!!!"  | Add-Content $logFilePath
            "[ERROR] $(Get-Date) [] Couldn't Copy the Inner Module & Installation File to the Host: $($hostname1)"  | Add-Content $logFilePath
        }
        $ErrorActionPreference = "Continue"

        "[INFO] $(Get-Date) [] Setting Execution Policy to the remote Host...."  | Add-Content $logFilePath
        .\bin\PsExec.exe \\$hostname1 powershell "Set-ExecutionPolicy Unrestricted" 
        

        $ErrorActionPreference = "Stop"
        try {
            "[INFO] $(Get-Date) [] DONE!"  | Add-Content $logFilePath
            "[INFO] $(Get-Date) [] Executing CrowedStrike Installation on the remote Host...."  | Add-Content $logFilePath
            .\bin\PsExec.exe \\$hostname1 powershell -file C:\Teva\info_scraper.ps1
            $statusOfInstall = Get-Content "\\$($hostname1)\c$\Teva\CrowsStrike_Report_From_Host_" + $hostname1 + ".txt"
            
            if($statusOfInstall[7] -eq "Installed OK"){
                "[INFO] $(Get-Date) [] This was installed OK" | Add-Content $logFilePath
            }else{
                "[WARNING] $(Get-Date) [] This was not installed or there was an issue reading the status." | Add-Content $logFilePath
                "[INFO] $(Get-Date) [] Trying to install CrowdStrike Now....." | Add-Content $logFilePath
                .\bin\PsExec.exe \\$hostname1 powershell -d $install_command
            }
            "[INFO] $(Get-Date) [] CrowdStrike Was Installed." | Add-Content $logFilePath
            $statusOfInstall | Add-Content $logFilePath
            "==================================================" | Add-Content $logFilePath
        }
        catch {
            "[ERROR] $(Get-Date) [] !!!!!"  | Add-Content $logFilePath
            "[ERROR] $(Get-Date) [] Couldn't Run the Inner Module at the Host: $($hostname1) @ $([System.Net.Dns]::GetHostAddresses($hostname1).IPAddressToString)"  | Add-Content $logFilePath
            "==================================================" | Add-Content $logFilePath
        }
        $ErrorActionPreference = "Continue"

    }else{
        "[ERROR] $(Get-Date) [] Client $($hostname1) is not online or isn't accesable."  | Add-Content $logFilePath
        "==================================================" | Add-Content $logFilePath
    }
    $iCount ++
}
