function BotservicebotservicesScan {
    $resultsfile = ".\results\csv\Botservices.csv"
    $botServices = Get-AzResource -ResourceType "Microsoft.BotService/botServices" -ResourceGroupName $resource_group
    $results = New-Object System.Collections.Generic.List[System.Object]
    foreach ($botService in $botServices) {
        $query = "Resources
    | where type == 'microsoft.botservice/botservices' and resourceGroup =~ '$($resource_group)' and name =~ '$($botService.Name)' and subscriptionId =~ '$($sub.Id)'
    | extend displayName = properties.displayName
    | extend description = properties.description
    | extend publicNetworkAccess = properties.publicNetworkAccess
    | extend privateEndpoint = iff(array_length(properties.privateEndpointConnections) > 0, 'Yes', 'No')
    | extend endpoint = properties.endpoint
    | extend isCmekEnabled = properties.isCmekEnabled
    | extend cmekEncryptionStatus = properties.cmekEncryptionStatus
    | extend cmekKeyVaultUrl = properties.cmekKeyVaultUrl"

        $resource = Search-AzGraph -Query $query

        $result = [PSCustomObject] @{
            Name                 = $botService.Name
            ResourceGroupName    = $resource_group
            Subscription         = $sub.Name
            Type                 = "Bot Service"
            Kind                 = $resource.kind
            DisplayName          = $resource.displayName
            Description          = $resource.description
            publicNetworkAccess  = $resource.publicNetworkAccess
            privateEndpoint      = $resource.privateEndpoint
            isCmekEnabled        = $resource.isCmekEnabled
            cmekEncryptionStatus = $resource.cmekEncryptionStatus
            cmekKeyVaultUrl      = $resource.cmekKeyVaultUrl
        } 
        $results.Add($result) | Out-Null
    }

    $results | Export-Csv -Path $resultsfile -NoTypeInformation -Append

}