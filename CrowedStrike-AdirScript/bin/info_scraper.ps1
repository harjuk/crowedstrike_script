$hostnameThis = hostname

$outputSamepl1 = Get-WMiObject -Class Win32_Product | Where-Object {$_.Name -like "CrowdStrike*"} | Select-Object Name, Version ;

$(
    ("Host: $($hostnameThis)")
    "==========="
    "Current Date and Time:"
    Get-Date 
    "==========="
    "=================================================="
    if($null -ne $outputSamepl1)
    {
        "Installed OK";
        "Current CrowdStrike Set Installed: "
        Get-WMiObject -Class Win32_Product | Where-Object {$_.Name -like "CrowdStrike*"} | Select-Object Name, Version
        "=================================================="
    }
    else
    {
        write-host "Error, Couldn't Find CrowdStrike Installed on this Machine."
    }

) *>&1 > (("\\$($hostnameThis)\c$\Teva\CrowsStrike_Report_From_Host_" + $hostnameThis + ".txt"))