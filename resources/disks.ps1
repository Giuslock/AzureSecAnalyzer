function ComputedisksScan {
    $resultsfile = ".\results\csv\Disks.csv"

    $disks = Get-AzDisk -ResourceGroupName $resource_group

    $results = New-Object System.Collections.Generic.List[System.Object]


    foreach ($disk in $disks) {
        $result = [PSCustomObject] @{
            Name              = $disk.Name
            ResourceGroupName = $resource_group
            Subscription      = $sub.Name
            encryptionType    = $disk.Encryption.Type
            GBsize            = $disk.DiskSizeGB
            diskState         = $disk.DiskState
            timeCreated       = $disk.TimeCreated
        } 
        $results.Add($result) | Out-Null
    }

    $results | Export-Csv -Path $resultsfile -NoTypeInformation -Append
    
}
