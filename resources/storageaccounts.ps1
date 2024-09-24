function StoragestorageaccountsScan {
    $resultsfile = ".\results\csv\Storageaccounts.csv"
    $query = "Resources 
| where type =~ 'Microsoft.Storage/storageAccounts' and subscriptionId =~ '$($sub.Id)'
| where resourceGroup =~ '$($resource_group)'
| extend networkDefaultAction = tostring(properties.networkAcls.defaultAction)
| extend ipRules=properties.networkAcls.ipRules
| extend creationDate=tostring(properties.creationTime)
| extend tlsVersion=tostring(properties.minimumTlsVersion)
| extend privateEndpoint=iff(array_length(properties.privateEndpointConnections) > 0, 'Yes', 'No')
| extend blobPublicAccess=tostring(properties.allowBlobPublicAccess)
| extend encryptionKey=properties.encryption.keySource
| extend secureTransfer=tostring(properties.supportsHttpsTrafficOnly)
| extend trustedServicesAccess=tostring(properties.networkAcls.bypass)"

    $results = New-Object System.Collections.Generic.List[System.Object]
    $resources = Search-AzGraph -Query $query

    foreach ($resource in $resources) {

        $firewallRulesStr = ""
        foreach ($rule in $resource.ipRules) {
            $firewallRulesStr += "Effect: $($rule.Action), IP: $($rule.value); "
        }

        $result = [PSCustomObject] @{
            Name                  = $resource.name
            ResourceGroupName     = $resource_group
            Subscription          = $sub.Name
            TLS                   = $resource.tlsVersion
            privateEndpoint       = $resource.privateEndpoint
            networkDefaultAction  = $resource.networkDefaultAction
            ipRules               = $firewallRulesStr
            blobPublicAccess      = $resource.blobPublicAccess
            encryptionKeySource   = $resource.encryptionKey
            secureTransfer        = $resource.secureTransfer
            trustedServicesAccess = $resource.trustedServicesAccess
            creationDate          = $resource.creationDate
        } 
    
        $results.Add($result) | Out-Null
    }

    #results export
    $results | Export-Csv -Path $resultsfile -NoTypeInformation -Append
    
}

