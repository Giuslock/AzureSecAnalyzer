#Imports
$scriptPath = ".\resources\"
$scriptFiles = Get-ChildItem -Path $scriptPath -Filter "*.ps1" -File

foreach ($file in $scriptFiles) {
    try {
        Write-Host "Importing script: $($file.Name)"
        . $file.FullName
    }
    catch {
        Write-Host "Failed to import script: $($file.Name). Error: $_"
    }
}



#output file

Remove-Item -Path ".\results\csv\*" -Force -ErrorAction SilentlyContinue
Remove-Item -Path ".\results\output.xlsx" -Force -ErrorAction SilentlyContinue
#start time for performance
$startTime = Get-Date



$mode = Read-Host "Enter the mode (t=tenant, s=subscription, r=resource group):"

switch ($mode) {
    't' { $mode = "tenant" }
    's' { $mode = "subscription" }
    'r' { $mode = "resourcegroup" }
    default {
        Write-Host "Invalid mode. Please enter one of the available options."
        exit
    }
}

Write-Host "Selected mode: $mode"




if ($mode -eq "resourcegroup" ) {
    $contenuto = Get-Content -Path ".\variables.txt" -Raw
    Invoke-Expression $contenuto
    $sub = Get-AzSubscription -SubscriptionName $subscription
    Set-AzContext $sub.Id | Out-Null

    #function call
    ResourcesList
}
elseif ($mode -eq "subscription") {
    $contenuto = Get-Content -Path ".\variables.txt" | Where-Object { $_ -match '\$subscription' }
    Invoke-Expression $contenuto

    $sub = Get-AzSubscription -SubscriptionName $subscription
    Set-AzContext $sub.Id | Out-Null

    $resource_groups = Get-AzResourceGroup
    $i = 1
    foreach ($resource_group in $resource_groups) {
        Write-Host "RG $($i) di $($resource_groups.Count), $($resource_group.ResourceGroupName)"
        $resource_group = $resource_group.ResourceGroupName
        #finding resources
        ResourcesList
        $i += 1
    }

}
elseif ($mode -eq "tenant") {

    $subs = Get-AzSubscription
    $s = 1
    foreach ($sub in $subs) {
        Set-AzContext $sub.Id | Out-Null
        Write-Host "Sub $($s) di $($subs.Count), $($sub.Name)"

        $resource_groups = Get-AzResourceGroup
        $i = 1
        foreach ($resource_group in $resource_groups) {
            Write-Host "RG $($i) di $($resource_groups.Count), $($resource_group.ResourceGroupName)"
            $resource_group = $resource_group.ResourceGroupName
            #finding resources
            ResourcesList
            $i += 1
        }
        $s += 1
    }
}

# Import the CSV files and export them as sheets in an Excel file
Write-Output "Creating Excel file..."
$csvFiles = Get-ChildItem -Path ".\results\csv\" -Filter "*.csv"
foreach ($csvFile in $csvFiles) {
    $data = Import-Csv -Path $csvFile.FullName
    $data | Export-Excel -Path ".\results\output.xlsx" -WorksheetName $csvFile.BaseName -AutoSize -TitleBold -TableStyle Medium7 -Append
}
#time of procedure
$endTime = Get-Date
$elapsedTime = $endTime - $startTime
Write-Output "Time elapsed: $($elapsedTime.TotalSeconds) seconds"