<#function ResourcesList {
    #resources query
    $query = "Resources
    | where resourceGroup =~ '$($resource_group)' and subscriptionId =~ '$($sub.Id)'
    | where type =~ 'Microsoft.AnalysisServices/servers' 
    or type =~ 'microsoft.apimanagement/service'
    or type =~ 'Microsoft.Automation/automationaccounts'
    or type =~ 'Microsoft.BotService/botServices'
    or type =~ 'Microsoft.Cache/Redis'
    or type =~ 'Microsoft.Cache/RedisEnterprise'
    or type =~ 'Microsoft.Compute/disks' 
    or type =~ 'Microsoft.Compute/virtualMachines'
    or type =~ 'Microsoft.CognitiveServices/accounts'
    or type =~ 'Microsoft.CognitiveServices/formRecognizer' 
    or type =~ 'Microsoft.Databricks/workspaces' 
    or type =~ 'Microsoft.DataFactory/factories'
    or type =~ 'Microsoft.DocumentDB/databaseAccounts' 
    or type =~ 'Microsoft.EventHub/namespaces' 
    or type =~ 'Microsoft.KeyVault/vaults' 
    or type =~ 'Microsoft.Network/networkSecurityGroups' 
    or type =~ 'Microsoft.Sql/servers' 
    or type =~ 'Microsoft.Sql/servers/databases' 
    or type =~ 'Microsoft.Synapse/workspaces' 
    or type =~ 'Microsoft.Storage/storageAccounts' 
    or type =~ 'Microsoft.Web/sites' 
    or type =~ 'Microsoft.Web/sites/functions' 
    or type =~ 'Microsoft.DBforPostgreSQL/servers' 
    or type =~ 'Microsoft.DBforPostgreSQL/flexibleServers' 
    | project name, type, kind, location, resourceGroup"

    
    #query on graph
    $resources = Search-AzGraph -Query $query
    if ($resources.Count -eq 0) {
        Write-Host "Empty RG"
        return 0
    }
    else {
        $results = @()
        foreach ($resource in $resources) {
            if ($resource.name -ne "master") {
                $result = [PSCustomObject] @{
                    Name              = $resource.name
                    Type              = $resource.type
                    Kind              = $resource.kind
                    Location          = $resource.location
                    ResourceGroupName = $resource_group
                    Subscription      = $sub.Name
                    Note              = ""
                } 
                $results += $result
            }

            if ($resource.type -eq "microsoft.analysisservices/servers") {
                $analysisService = 1
            }
            if ($resource.type -eq "microsoft.automation/automationaccounts") {
                $automationAccounts = 1
            }
            if ($resource.type -eq "Microsoft.BotService/botServices") {
                $botServices = 1
            }
        
        
        }
    
        if ($analysisService = 1) {
            Write-Host "Checking Analysis Services..."
            AnalysisServicesScan
        }
        if ($automationAccounts = 1) {
            Write-Host "Checking Automation Accounts..."
            automationAccountScan
        }
        if ($botServices = 1) {
            Write-Host "Checking Bot Services..."
            BotServiceScan
        }

        #results export
        $results | Export-Excel -Path $resultsfile -WorksheetName "Azure Resources" -AutoSize -TitleBold -TableStyle Medium7 -Append
        return 1
    }#>
    


function ResourcesList {
    $resultsfile = ".\results\csv\1.azure_resources.csv"
    # resources that have a function integrated
    $resourcefunctions = @(
        'Microsoft.AnalysisServices/servers', 
        'microsoft.apimanagement/service',
        'Microsoft.Automation/automationaccounts',
        'Microsoft.BotService/botServices',
        'Microsoft.Cache/Redis',
        'Microsoft.Cache/RedisEnterprise',
        'Microsoft.Compute/disks' ,
        'Microsoft.DocumentDB/databaseAccounts' ,
        'Microsoft.EventHub/namespaces' ,
        'Microsoft.KeyVault/vaults' ,
        'Microsoft.Sql/servers' ,
        'Microsoft.Storage/storageAccounts' ,
        'Microsoft.Web/sites' ,
        'Microsoft.DBforPostgreSQL/servers' ,
        'Microsoft.DBforPostgreSQL/flexibleServers'
        # ... and the rest of your resource types
    )
        
    $query = "Resources
        | where resourceGroup =~ '$($resource_group)' and subscriptionId =~ '$($sub.Id)'
        | project name, type, sku,kind, location, resourceGroup"
    
    # query on graph
    $resources = Search-AzGraph -Query $query -First 1000
    if ($resources.Count -eq 0) {
        Write-Host "Empty RG"
    }
    else {
        $results = @()
        $resourcefunctionFlags = @{}
        foreach ($resource in $resources) {
            if ($resource.name -ne "master") {
                $result = [PSCustomObject] @{
                    Name              = $resource.name
                    Type              = $resource.type
                    Kind              = $resource.kind
                    Sku               = $resource.sku
                    Location          = $resource.location
                    ResourceGroupName = $resource_group
                    Subscription      = $sub.Name
                    Note              = ""
                } 
                $results += $result
            }
                
            if ($resourcefunctions -contains $resource.type) {
                $resourcefunctionFlags[$resource.type] = $true
            }
        }
    
        foreach ($resourcefunction in $resourcefunctions) {
            if ($resourcefunctionFlags[$resourcefunction]) {
                # build the function name based on the resource type
                $functionName = ($resourcefunction -replace "Microsoft.|microsoft." -replace "/", "") + "Scan"
                $functionName = [System.Globalization.CultureInfo]::CurrentCulture.TextInfo.ToTitleCase($functionName)
                Write-Host "Checking $resourcefunction..."
                & $functionName -ErrorAction Ignore
            }
        }
    
    
        # results export
        $results | Export-Csv -Path $resultsfile -NoTypeInformation -Append
    }
}
    
