function AnalysisservicesserversScan {
    $resultsfile = ".\results\csv\Analysisservicesservers.csv"
    $analysisServiceServers = Get-AzAnalysisServicesServer -ResourceGroupName $resource_group

    $results = New-Object System.Collections.Generic.List[System.Object]

    foreach ($analysisServiceServer in $analysisServiceServers) {
        $firewallRules = $analysisServiceServer.FirewallConfig.FirewallRules
        $firewallRulesStr = ""
        foreach ($rule in $firewallRules) {
            # Supponendo che 'Name', 'StartIpAddress', 'EndIpAddress' siano proprietà della regola del firewall.
            # Modificare in base alle effettive proprietà
            $firewallRulesStr += "Name: $($rule.FirewallRuleName), Start IP: $($rule.RangeStart), End IP: $($rule.RangeEnd); "
        }
        $administratorsStr = [String]::Join(", ", $analysisServiceServer.AsAdministrators)
        
        $result = [PSCustomObject] @{
            Name                 = $analysisServiceServer.name
            ResourceGroupName    = $resource_group
            Subscription         = $sub.Name
            ServerFullName       = $analysisServiceServer.ServerFullName
            State                = $analysisServiceServer.State
            FirewallRules        = $firewallRulesStr
            EnablePowerBIService = $analysisServiceServer.FirewallConfig.EnablePowerBIService
            Backup               = $analysisServiceServer.BackupBlobContainerUri
            Administrators       = $administratorsStr
        }
        $results.Add($result) | Out-Null
    }

    $results | Export-Csv -Path $resultsfile -NoTypeInformation -Append
}
