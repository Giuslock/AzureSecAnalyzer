function CacheredisScan {

    $resultsfile = ".\results\csv\Cacheredis.csv"
    $rediscaches = Get-AzRedisCache -ResourceGroupName $resource_group
    $results = New-Object System.Collections.Generic.List[System.Object]


    foreach ($rediscache in $rediscaches) {
        $query = "Resources 
    | where type =~ 'microsoft.cache/redis' and resourceGroup =~ '$($resource_group)' and name =~ '$($rediscache.Name)' and subscriptionId =~ '$($sub.Id)'
    | extend sku = tostring(properties.sku.name)
    | extend publicNetworkAccess = properties.publicNetworkAccess
    | extend allowAccessOnlyViaSsl = iff(properties.enableNonSslPort == true, 'No', 'Yes')
    | extend privateEndpoint = iff(array_length(properties.privateEndpointConnections) > 0, 'Yes', 'No')"

        $resource = Search-AzGraph -Query $query
        $result = [PSCustomObject] @{
            Name                  = $resource.name
            ResourceGroupName     = $resource_group
            Subscription          = $sub.Name
            Sku                   = $resource.sku
            publicNetworkAccess   = $resource.publicNetworkAccess
            privateEndpoint       = $resource.privateEndpoint
            minimumTlsVersion     = $rediscache.MinimumTlsVersion
            allowAccessOnlyViaSsl = $resource.allowAccessOnlyViaSsl
        } 
        $results.Add($result) | Out-Null
    }

    $results | Export-Csv -Path $resultsfile -NoTypeInformation -Append
    
}
function CacheredisenterpriseScan {
    $resultsfile = ".\results\csv\Cacheredis.csv"
    $rediscaches = Get-AzRedisCache -ResourceGroupName $resource_group
    $results = New-Object System.Collections.Generic.List[System.Object]


    foreach ($rediscache in $rediscaches) {
        $query = "Resources 
| where type =~ 'microsoft.cache/redis' and resourceGroup =~ '$($resource_group)' and name =~ '$($rediscache.Name)' and subscriptionId =~ '$($sub.Id)'
| project name, type, sku = tostring(properties.sku.name),allowAccessOnlyViaSsl = iff(properties.enableNonSslPort == true, 'No', 'Yes'), publicNetworkAccess = properties.publicNetworkAccess, privateEndpoint = iff(array_length(properties.privateEndpointConnections) > 0, 'Yes', 'No')"
        $resource = Search-AzGraph -Query $query
        $result = [PSCustomObject] @{
            Name                  = $resource.name
            ResourceGroupName     = $resource_group
            Subscription          = $sub.Name
            Sku                   = $resource.sku
            allowAccessOnlyViaSsl = $resource.allowAccessOnlyViaSsl
            publicNetworkAccess   = $resource.publicNetworkAccess
            privateEndpoint       = $resource.privateEndpoint
            minimumTlsVersion     = $rediscache.MinimumTlsVersion
        } 
        $results.Add($result) | Out-Null
    }

    $results | Export-Csv -Path $resultsfile -NoTypeInformation -Append
    
}
