function AutomationautomationaccountsScan {
    
    $resultsfile = ".\results\csv\Automationaccounts.csv"
    $automationaccounts = Get-AzAutomationAccount -ResourceGroupName $resource_group
    $results = New-Object System.Collections.Generic.List[System.Object]
    

    foreach ($automationaccount in $automationaccounts) {
        $query = "Resources 
    | where type =~ 'microsoft.automation/automationaccounts' and resourceGroup =~ '$($resource_group)' and name =~ '$($automationaccount.AutomationAccountName)' and subscriptionId =~ '$($sub.Id)'
    | extend sku = tostring(properties.sku.name)
    | extend privateEndpoint = iff(array_length(properties.privateEndpointConnections) > 0, 'Yes', 'No')
    | extend encryption = tostring(properties.encryption.keySource)"
        $resource = Search-AzGraph -Query $query
        $runAsCredentials = Get-AzAutomationCredential -ResourceGroupName $resource_group -AutomationAccountName $automationaccount.AutomationAccountName
        $result = [PSCustomObject] @{
            Name                = $resource.name
            ResourceGroupName   = $resource_group
            Subscription        = $sub.Name
            Sku                 = $resource.sku
            publicNetworkAccess = $automationaccount.PublicNetworkAccess
            privateEndpoint     = $resource.privateEndpoint
            runAs               = $runAsCredentials.Name
            encryptionSource    = $resource.encryption
            creationTime        = $automationaccount.CreationTime
        } 
        $results.Add($result) | Out-Null
    }

    $results | Export-Csv -Path $resultsfile -NoTypeInformation -Append
    
}