function DbforpostgresqlserversScan {
    $resultsfile = ".\results\csv\Dbforpostgresqlservers.csv"
    $query = "Resources
    | where resourceGroup =~ '$($resource_group)' and type =~ 'microsoft.dbforpostgresql/servers' and subscriptionId =~ '$($sub.Id)'
    | extend private_endpoint = iff(array_length(properties.privateEndpointConnections) > 0, 'Yes', 'No')
    | extend tlsversion = (properties.minimalTlsVersion)
    | extend byokEnforcement = (properties.byokEnforcement)
    | extend sslEnforcement = (properties.sslEnforcement)
    | extend publicNetworkAccess = (properties.publicNetworkAccess)
    | project name,type,private_endpoint,tlsversion,byokEnforcement,sslEnforcement,publicNetworkAccess"   
    

    $results = New-Object System.Collections.Generic.List[System.Object]
    $resources = Search-AzGraph -Query $query

    foreach ($resource in $resources) {
        $firewallRules = Get-AzPostgreSqlFirewallRule -ResourceGroupName $resource_group -ServerName $resource.name
        $firewallRulesStr = ""
        foreach ($rule in $firewallRules) {
            # Supponendo che 'Name', 'StartIpAddress', 'EndIpAddress' siano proprietà della regola del firewall.
            # Modificare in base alle effettive proprietà
            $firewallRulesStr += "Name: $($rule.Name), Start IP: $($rule.StartIPAddress), End IP: $($rule.EndIPAddress); "
        }


        $result = [PSCustomObject] @{
            Name                = $resource.name
            ResourceGroupName   = $resource_group
            Subscription        = $sub.Name
            publicNetworkAccess = $resource.publicNetworkAccess
            firewallRules       = $firewallRulesStr
            privateEndpoint     = $resource.private_endpoint
            tlsversion          = $resource.tlsversion
            byokEnforcement     = $resource.byokEnforcement
            sslEnforcement      = $resource.sslEnforcement
        } 
        $results.Add($result) | Out-Null
    }
    # Esegue la query su Azure Resource Graph e stampa i risultati della query
    $results | Export-Csv -Path $resultsfile -NoTypeInformation -Append
}

function DbforpostgresqlflexibleserversScan {

    $resultsfile = ".\results\csv\Dbforpostgresqlflexibleservers.csv"
    $query = "Resources
    | where resourceGroup =~ '$($resource_group)' and type =~ 'microsoft.dbforpostgresql/flexibleservers' and subscriptionId =~ '$($sub.Id)'
    | extend publicNetworkAccess = (properties.network.publicNetworkAccess)"

    $results = New-Object System.Collections.Generic.List[System.Object]
    $resources = Search-AzGraph -Query $query

    foreach ($resource in $resources) {
        $firewallRules = Get-AzPostgreSqlFlexibleServerFirewallRule -ResourceGroupName $resource_group -ServerName $resource.name
        $firewallRulesStr = ""
        foreach ($rule in $firewallRules) {
            # Supponendo che 'Name', 'StartIpAddress', 'EndIpAddress' siano proprietà della regola del firewall.
            # Modificare in base alle effettive proprietà
            $firewallRulesStr += "Name: $($rule.Name), Start IP: $($rule.StartIPAddress), End IP: $($rule.EndIPAddress); "
        }
        $result = [PSCustomObject] @{
            Name                = $resource.name
            ResourceGroupName   = $resource_group
            Subscription        = $sub.Name
            publicNetworkAccess = $resource.publicNetworkAccess
            firewallRules       = $firewallRulesStr
        } 
        $results.Add($result) | Out-Null
    }
    # Esegue la query su Azure Resource Graph e stampa i risultati della query
    $results | Export-Csv -Path $resultsfile -NoTypeInformation -Append
    
}
