# AzureSecAnalyzer

AzureSecAnalyzer is a PowerShell project that checks the security settings of Azure resources.
## Table of Contents

- [Prerequisites](#prerequisites)
- [Usage](#usage)
- [Supported Resources](#supported-resources)
  - [Analysis Services](#analysis-services)
  - [App Services](#app-services)
  - [Azure Cache for Redis](#azure-cache-for-redis)
  - [Cosmos DB](#cosmos-db)
  - [Disks](#disks)
  - [Event Hub Namespaces](#event-hub-namespaces)
  - [Key Vaults](#key-vaults)
  - [PostgreSQL Flexible Servers](#postgresql-flexible-servers)
  - [PostgreSQL Single Servers](#postgresql-single-servers)
  - [SQL Database](#sql-database)
  - [SQL Server](#sql-server)
  - [Storage Accounts](#storage-accounts)
- [Output Format](#output-format)
- [Contributing](#contributing)
- [License](#license)


## Prerequisites

To use AzureSecAnalyzer, you need to have the `Export-Excel` PowerShell module installed. Additionally, you will also need the `Az` module installed. 

You can install both modules by running the following commands:

```powershell
Install-Module -Name ImportExcel
Install-Module -Name Az
```


## Usage

To use AzureSecAnalyzer, follow the steps below:

1. Launch the PowerShell script by running `launch.ps1`.
2. Select the mode:
   - If you choose **Subscription**, you will be prompted to enter the name of the subscription. Open the `variables.txt` file and enter the subscription name.
   - If you choose **Resource Group**, you will be prompted to enter both the subscription name and the resource group name. Open the `variables.txt` file and enter the subscription and resource group names.
   - If you choose **Tenant**, no additional input is required. This information should be known in advance.
3. Save the `variables.txt` file.
4. The script will perform the security settings check based on the selected mode and the values specified in the `variables.txt` file.
5. Once the script completes, the results will be saved in the `azure_resources.xlsx` file.

For the Resource Group mode, it supports 1000 resources per RG


### Example

```powershell
.\launch.ps1
```

These commands run AzureSecAnalyzer.

## Supported Resources

### Analysis Services

- Firewall control
- Backup

### Api Management

### Applied Ai Services
#### Bot services

### Automation Accounts

### App Services

- HTTPS only
- Private Endpoint
- Public Network Access

### Azure Cache for Redis

- Access Only Via SSL
- Public Network Access
- Private Endpoint
- Minimum TLS Version


### Cosmos DB

- Backup
- Networking
- Private Endpoint

### Disks

- Encryption

### Event Hub Namespaces

- Private Endpoint
- Public Network Access
- Encryption

### Key Vaults

- Private Endpoint
- Public Network Access
- Soft Delete Days
- Purge Protection

### Postgresql Flexible Servers
- Public Network Access
- Firewall Rules 

### Postgresql Single Servers
- Public Network Access
- Firewall Rules
- Private Endpoint
- TLS Version
- Byok Enforcement
- SSL Enforcement

### SQL Databases

- Transparent Data Encryption

### SQL Servers

- Auditing
- Authentication
- Private Endpoint
- Public Network Access
- TLS version
- Transparent Data Encryption

### Storage Accounts

- Blob Public Access
- Encryption Key
- Network Access
- Private Endpoint
- Secure Transfer
- TLS version
- Trusted Services Access



If you would like to see support for additional Azure resources or output formats, please create an issue on this repository or submit a pull request with the necessary changes.

## Output Format

AzureSecAnalyzer outputs its results in the `.xlsx` format, which allows for clear and comprehensive assessments. This format is recommended for analyzing the security settings as it provides easy sorting, filtering, and visualization of results.

To generate the output in the desired format, simply run the `launch.ps1` script when launching AzureSecAnalyzer.

The generated `.xlsx` file provides a structured overview of the security settings for various Azure resources, allowing you to identify potential vulnerabilities and take appropriate measures to mitigate risks. It supports all the resources listed in the [Supported Resources](#supported-resources) section, ensuring a thorough analysis of your Azure environment.

Take advantage of the intuitive Excel features to explore and interpret the assessment results conveniently. With the power of Excel, you can gain insights and make informed decisions to enhance the security posture of your Azure resources.

## Contributing

We welcome contributions from the community! If you would like to contribute to AzureSecAnalyzer, please create a pull request with your proposed changes.

If you encounter any issues or have any suggestions for improvement, please create an issue on this repository.

## License

AzureSecAnalyzer is licensed under the [GNU General Public License v3.0](LICENSE). You are free to use, modify, and distribute this software in compliance with the terms and conditions of the license.
