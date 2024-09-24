function ResourceGroupScan {
    #finding resources
    if(ResourcesList) {
        # analysis services
    if ($(Get-AzAnalysisServicesServer -ResourceGroupName $resource_group)) {
        Write-Host "Checking Analysis Services..."
        AnalysisServicesScan
    }

    if ($(Get-AzAutomationAccount -ResourceGroupName $resource_group)) {
        Write-Host "Checking Automation Accounts..."
        AutomationAccountScan
    }

    if ($(Get-AzResource -ResourceType "Microsoft.BotService/botServices" -ResourceGroupName $resource_group)) {
        Write-Host "Checking Bot Services..."
        BotServiceScan
    }


    if ($(Get-AzApiManagement -ResourceGroupName $resource_group)) {
        Write-Host "Checking Api Management Services..."
        ApimanagementScan
    }

    # app services
    if ($(Get-AzWebApp -ResourceGroupName $resource_group)) {
        Write-Host "Checking AppServices..."
        AppServicesScan
    }

    # CosmosDB
    if ($(Get-AzCosmosDBAccount -ResourceGroupName $resource_group)) {
        Write-Host "Checking CosmosDBs..."
        CosmosDBScan    
    }

    # azure cache for redis
    if ($(Get-AzRedisCache -ResourceGroupName $resource_group)) {
        Write-Host "Checking RedisCaches..."
        RedisCacheScan
    }

    # disks
    if ($(Get-AzDisk -ResourceGroupName $resource_group)) {
        Write-Host "Checking Disks..."
        DisksScan
    }
    
    if ($(Get-AzEventHubNamespace -ResourceGroupName $resource_group -WarningAction SilentlyContinue)) {
        Write-Host "Checking Event Hub Namespaces..."
        EventHubNamespacesScan
    }

    # keyVaults
    if ($(Get-AzKeyVault -ResourceGroupName $resource_group)) {
        Write-Host "Checking KeyVaults..."
        KeyVaultsScan    
    }

    if ($(Get-AzPostgreSqlServer -ResourceGroupName $resource_group)) {
        Write-Host "Checking PostgreSQL Single Servers..."
        PostgreSQLSinglesScan    
    }

    if ($(Get-AzPostgreSqlFlexibleServer -ResourceGroupName $resource_group)) {
        Write-Host "Checking PostgreSQL Flexible Servers..."
        PostgreSQLFlexibleScan    
    }


    #sql server and sqldb
    if ($(Get-AzSqlServer -ResourceGroupName $resource_group)) {
        Write-Host "Checking SQLServersandDBs..."
        SQLServerandDBScan
    }


    #storage accounts
    if ($(Get-AzStorageAccount -ResourceGroupName $resource_group)) {
        Write-Host "Checking StorageAccounts..."
        StorageAccountsScan
    }
    }
 
}