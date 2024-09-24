function ApimanagementserviceScan {
    $resultsfile = ".\results\csv\Apimanagementservice.csv"

    $apimanagements = Get-AzApiManagement -ResourceGroupName $resource_group

    $results = New-Object System.Collections.Generic.List[System.Object]

    foreach ($apimanagement in $apimanagements) {
        
        $publicIpAddressesStr = [String]::Join(", ", ($apimanagement.PublicIPAddresses | ForEach-Object { "'$($_.Trim())" }))
        
        $privateEndpointConnectionsStr = ""
        foreach ($connection in $apimanagement.PrivateEndpointConnections) {
            $privateEndpointConnectionsStr += "Name: $($connection.Name), Provisioning State: $($connection.ProvisioningState); "
        }

        $result = [PSCustomObject] @{
            Name                = $apimanagement.Name
            ResourceGroupName   = $resource_group
            Subscription        = $sub.Name
            Tier                = $apimanagement.Sku
            publicNetworkAccess = $apimanagement.PublicNetworkAccess
            publicIpAddresses   = $publicIpAddressesStr
            privateEndpoint     = $privateEndpointConnectionsStr
            disableGateway      = $apimanagement.DisableGateway
            publisherEmail      = $apimanagement.PublisherEmail
            creationDate        = $apimanagement.CreatedTimeUtc
        } 

        $results.Add($result) | Out-Null
    }

    $results | Export-Csv -Path $resultsfile -NoTypeInformation -Append
}
