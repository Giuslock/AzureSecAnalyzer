function SqlserversScan {
    $resultsfile2 = ".\results\csv\Sqlservers.csv"
    $resultsfile = ".\results\csv\Sqldatabases.csv"
    $query_sqlserver = "Resources
| where resourceGroup =~ '$($resource_group)' and type =~ 'Microsoft.Sql/servers' and subscriptionId =~ '$($sub.Id)'
| extend type = tostring(type)
| extend tls_min_version = tostring(properties.minimalTlsVersion)
| extend private_endpoint = iff(array_length(properties.privateEndpointConnections) > 0, 'Yes', 'No')
| extend deny_public_network_access = tostring(properties.publicNetworkAccess)
| extend authentication = tostring(properties.administrators.login)"


    $sqlServers = Get-AzSqlServer -ResourceGroupName $resource_group


    #results list
    $results = New-Object System.Collections.Generic.List[System.Object]
    $results2 = New-Object System.Collections.Generic.List[System.Object]
    $sqlServers = Search-AzGraph -Query $query_sqlserver

    foreach ($sqlServer in $sqlServers) {
    
        $tde = Get-AzSqlServerTransparentDataEncryptionProtector -ServerName $sqlServer.name -ResourceGroupName $resource_group
        $audit = Get-AzSqlServerAudit -ServerName $sqlServer.name -ResourceGroupName $resource_group
        $result2 = [PSCustomObject] @{
            ServerName              = $sqlServer.name
            ResourceGroupName       = $resource_group
            Subscription            = $sub.Name
            TDEStatus               = $tde.Type
            audit                   = $audit.LogAnalyticsTargetState
            tlsMinVersion           = $sqlServer.tls_min_version | ForEach-Object { "'$($_.Trim())" }
            privateEndpoint         = $sqlServer.private_endpoint
            denyPublicNetworkAccess = $sqlServer.deny_public_network_access
            authentication          = $sqlServer.authentication
            
        }

        $results2.Add($result2) | Out-Null




        #Sql databases module
        $sqlDbs = Get-AzSqlDatabase -ServerName $sqlServer.name -ResourceGroupName $resource_group -WarningAction SilentlyContinue

        if ($sqlDbs.Count -gt 0) {

            #Transparent data encryption for sqldbs
            foreach ($sqlDb in $sqlDbs) {
                if ($sqlDb.DatabaseName -eq "master") {
                    continue
                }
    
                $tdeStatus = Get-AzSqlDatabaseTransparentDataEncryption -DatabaseName $sqlDb.DatabaseName -ServerName $sqlServer.name -ResourceGroupName $resource_group
                $result = [PSCustomObject] @{
                    ServerName        = $sqlDb.ServerName
                    DatabaseName      = $sqlDb.DatabaseName
                    ResourceGroupName = $resource_group
                    Subscription      = $sub.Name
                    status            = $sqlDb.Status
                    TDEStatus         = $tdeStatus.State
                    creationDate      = $sqlDb.CreationDate                    
                } 
                $results.Add($result) | Out-Null
            }
        }
    }
    #results export
    $results | Export-Csv -Path $resultsfile -NoTypeInformation -Append
    $results2 | Export-Csv -Path $resultsfile2 -NoTypeInformation -Append
    
}


