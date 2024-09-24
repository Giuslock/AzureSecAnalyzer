function KeyvaultvaultsScan {
    $resultsfile = ".\results\csv\Keyvaults.csv"
    $query = "Resources
| where resourceGroup =~ '$($resource_group)' and type =~ 'microsoft.keyvault/vaults' and subscriptionId =~ '$($sub.Id)'
| extend public_network_access = tostring(properties.publicNetworkAccess)
| extend networkDefaultAction = tostring(properties.networkAcls.defaultAction)
| extend ipRules = properties.networkAcls.ipRules
| extend private_endpoint = iff(array_length(properties.privateEndpointConnections) > 0, 'Yes', 'No')
| extend enableSoftDelete = tostring(properties.enableSoftDelete)
| extend soft_delete_days = tostring(properties.softDeleteRetentionInDays)
| extend purge_protection = tostring(properties.enablePurgeProtection)
| extend enableRbacAuthorization = tostring(properties.enableRbacAuthorization)"


    $results = New-Object System.Collections.Generic.List[System.Object]
    $resources = Search-AzGraph -Query $query

    foreach ($resource in $resources) {

        $firewallRulesStr = ""
        foreach ($rule in $resource.ipRules) {
            $firewallRulesStr += " IP: $($rule.value); "
        }

        $result = [PSCustomObject] @{
            Name                    = $resource.name
            ResourceGroupName       = $resource_group
            Subscription            = $sub.Name
            publicNetworkAccess     = $resource.public_network_access
            networkDefaultAction    = $resource.networkDefaultAction
            ipRules                 = $firewallRulesStr
            privateEndpoint         = $resource.private_endpoint
            enableSoftDelete        = $resource.enableSoftDelete
            softDeleteDays          = $resource.soft_delete_days
            purgeProtection         = $resource.purge_protection
            enableRbacAuthorization = $resource.enableRbacAuthorizationF
        } 
        $results.Add($result) | Out-Null
    }
    # Esegue la query su Azure Resource Graph e stampa i risultati della query
    $results | Export-Csv -Path $resultsfile -NoTypeInformation -Append
    
}

