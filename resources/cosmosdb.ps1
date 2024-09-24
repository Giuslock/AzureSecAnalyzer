function DocumentdbdatabaseaccountsScan {
    $resultsfile = ".\results\csv\Cosmosdbs.csv"
    $cosmosDBs = Get-AzCosmosDBAccount -ResourceGroupName $resource_group

    $results = New-Object System.Collections.Generic.List[System.Object]

    foreach ($cosmosDB in $cosmosDBs) {
        $query = "Resources
| where type =~ 'Microsoft.DocumentDB/databaseAccounts' and resourceGroup =~ '$($resource_group)' and name =~ '$($cosmosDB.Name)' and subscriptionId =~ '$($sub.Id)'
| extend privateEndpoint = iff(array_length(properties.privateEndpointConnections) > 0, 'Yes', 'No')
| extend backupPolicy = iff(isnotempty(properties.backupPolicy), 'Yes', 'No')
| extend accessFrom = iif((properties.ipRules != '[]') and (properties.publicNetworkAccess == 'Enabled'), 'Selected networks', iif(((properties.ipRules == '[]') or isempty(properties.ipRules)) and (properties.publicNetworkAccess == 'Enabled'), 'All networks (Need Check)', iif((properties.publicNetworkAccess) == 'Disabled', 'Disabled', '')))"

        $resource = Search-AzGraph -Query $query

        $result = [PSCustomObject] @{
            Name              = $cosmosDB.Name
            ResourceGroupName = $resource_group
            Subscription      = $sub.Name
            Kind              = $cosmosDB.Kind
            networking        = $resource.accessFrom
            privateEndpoint   = $resource.privateEndpoint
            backup            = $resource.backupPolicy
            KeyVaultUri       = $cosmosDB.KeyVaultKeyUri
        } 
        $results.Add($result) | Out-Null
    }

    $results | Export-Csv -Path $resultsfile -NoTypeInformation -Append
    
}

