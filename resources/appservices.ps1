function WebsitesScan {

    $resultsfile = ".\results\csv\Websites.csv"
    $sites = Get-AzWebApp -ResourceGroupName $resource_group

    $results = New-Object System.Collections.Generic.List[System.Object]

    foreach ($site in $sites) {
        $query = "Resources
| where type == 'microsoft.web/sites' and resourceGroup =~ '$($resource_group)' and name =~ '$($site.Name)' and subscriptionId =~ '$($sub.Id)'
| extend privateEndpoint = iff(array_length(properties.privateEndpointConnections) > 0, 'Yes', 'No')
| project name, privateEndpoint, kind, state = properties.state, HTTPSonly = properties.httpsOnly, FTPSstate = properties.ftpsState, publicNetworkAccess = properties.publicNetworkAccess"

        $resource = Search-AzGraph -Query $query

        $result = [PSCustomObject] @{
            Name                = $site.Name
            ResourceGroupName   = $resource_group
            Subscription        = $sub.Name
            Kind                = $resource.kind
            State               = $resource.state
            publicNetworkAccess = $(Get-AzWebAppAccessRestrictionConfig -Name $site.Name -ResourceGroupName $resource_group).MainSiteAccessRestrictions.RuleName
            privateEndpoint     = $resource.privateEndpoint
            HTTPSonly           = $resource.HTTPSonly
            FTPSstate           = $site.SiteConfig.FtpsState
            minTLSVersion       = $site.SiteConfig.MinTlsVersion | ForEach-Object { "'$($_.Trim())" }
            lastUpdate          = $site.LastModifiedTimeUtc
        } 
        $results.Add($result) | Out-Null
    }

    $results | Export-Csv -Path $resultsfile -NoTypeInformation -Append
    
}

