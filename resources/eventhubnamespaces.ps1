function EventhubnamespacesScan {
    $resultsfile = ".\results\csv\Eventhubnamespaces.csv"
    $eventHubnamespaces = Get-AzEventHubNamespaceV2 -ResourceGroupName $resource_group -WarningAction SilentlyContinue
    $results = New-Object System.Collections.Generic.List[System.Object]

    #$results.Insert(0, $attempted_results)
    foreach ($eventHub in $eventHubnamespaces) {

        $firewallRules = Get-AzEventHubNetworkRuleSet -NamespaceName $eventHub.Name -ResourceGroupName $resource_group -WarningAction SilentlyContinue
        $firewallRulesStr = ""
        foreach ($rule in $firewallRules.IPRule) {
            # Supponendo che 'Name', 'StartIpAddress', 'EndIpAddress' siano proprietà della regola del firewall.
            # Modificare in base alle effettive proprietà
            $firewallRulesStr += "Effect: $($rule.Action), IP: $($rule.IPMask); "
        }
        $privateEndpoint = Get-AzEventHubPrivateEndpointConnection -NamespaceName $eventHub.Name -ResourceGroupName $resource_group

        $result = [PSCustomObject] @{
            Name                 = $eventHub.Name
            ResourceGroupName    = $resource_group
            Subscription         = $sub.Name
            networkDefaultAction = $firewallRules.DefaultAction
            IPrules              = $firewallRulesStr
            minimumTLSVersion    = $eventHub.MinimumTlsVersion
            privateEndpointState = $privateEndpoint.ConnectionState
            privateEndpointName  = $privateEndpoint.Name
            encryption           = $eventHub.KeySource
            createDate           = $eventHub.CreatedAt
        } 
        $results.Add($result) | Out-Null
    }

    $results | Export-Csv -Path $resultsfile -NoTypeInformation -Append
    
}