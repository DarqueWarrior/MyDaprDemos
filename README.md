# My Dapr Demos

This repo is a collection of demos of the [Dapr](https://dapr.io) building blocks. Each demo provides a local and cloud based configuration to demonstrate the ability to run on multiple platforms. They are self contained and automatically provision the required infrastructure using the provided Bicep files.

Demo | Building Blocks | Local | Cloud | Language
--- | --- | --- | --- | ---:
[Binding](./Binding) | [Bindings](https://docs.dapr.io/developing-applications/building-blocks/bindings/) | File Share | Azure Storage | HTTP
[Observability](./Observability) | [Observability](https://docs.dapr.io/developing-applications/building-blocks/observability/) | Zipkin | Azure Application Insights | C#, HTTP
[PubSub](./PubSub) | [Publish & Subscribe](https://docs.dapr.io/developing-applications/building-blocks/pubsub/) <br> [State management](https://docs.dapr.io/developing-applications/building-blocks/state-management/) | Redis <br> Redis | Azure Service Bus <br> Azure SQL Server | C#, HTTP
[Secrets](./Secrets) | [Secrets management](https://docs.dapr.io/developing-applications/building-blocks/secrets/) | Local | Azure Key Vault | HTTP
[StateStore](./StateStore) | [State management](https://docs.dapr.io/developing-applications/building-blocks/state-management/) | Redis | Azure Cosmos DB | HTTP
## Usage

The easiest way to use these demos is with [CodeSpaces](https://github.com/features/codespaces). This repo is configured to create a CodeSpace with all the required tools. Simply fork this repo and setup the Codespace secrets and assign them to your fork.

To run these locally clone the repo and install all the required tools listed below. Then start a PowerShell terminal and log into the Azure with the Azure CLI.

### Requirements

All the software below can be installed on macOS, Windows and Linux

- [Dapr v1.4](https://docs.dapr.io/getting-started/)
- [PowerShell v7.1.4](https://github.com/powershell/powershell)
  - [PowerShell-Yaml v0.4.2](https://www.powershellgallery.com/packages/powershell-yaml/0.4.2)
- [Visual Studio Code v1.60.2](https://visualstudio.microsoft.com/)
  - [Dapr extension v0.5.0](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-dapr)
  - [REST Client extension v0.24.5](https://marketplace.visualstudio.com/items?itemName=humao.rest-client)
  - [PowerShell extension v2021.9.0](https://marketplace.visualstudio.com/items?itemName=ms-vscode.PowerShell)
  - [C# extension v1.23.15](https://marketplace.visualstudio.com/items?itemName=ms-dotnettools.csharp)
  - [Redis extension v1.2.8](https://marketplace.visualstudio.com/items?itemName=cweijan.vscode-redis-client)
- [Azure CLI v2.27.2](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
- [.NET v6](https://dotnet.microsoft.com/download/dotnet/6.0)
  - [Tye v0.10.0](https://github.com/dotnet/tye)
- [Docker](https://www.docker.com/products/docker-desktop)

## Create Codespace Secrets

To create the Codespace secrets you will need an Azure service principal, tenant and subscription id.

### Create Service Principal

When the Codespace is created it runs a script to log in to the Azure CLI. It uses a service principal and needs the appid, password and tenant all of which are returned when you create a service principal. You can use an existing service principal or create a new one using the command below. You can learn more on the [Create an Azure service principal with the Azure CLI](https://docs.microsoft.com/en-us/cli/azure/create-an-azure-service-principal-azure-cli) page.

```
az ad sp create-for-rbac --name DaprServicePrincipal

{
  "appId": "00000000-0000-0000-0000-000000000000",
  "displayName": "DaprServicePrincipal",
  "name": "00000000-0000-0000-0000-000000000000",
  "password": "000000.0000000000.000000000-000000",
  "tenant": "00000000-0000-0000-0000-000000000000"
}

```

Save this information because there is no way to retrieve it again.

You will also need the id of the subscription you want to use. You can retrieve that running the following command.

```
az account show -o json

{
  "environmentName": "AzureCloud",
  "homeTenantId": "00000000-0000-0000-0000-000000000000",
  "id": "00000000-0000-0000-0000-000000000000",
  "isDefault": true,
  "managedByTenants": [],
  "name": "Subscription Name",
  "state": "Enabled",
  "tenantId": "00000000-0000-0000-0000-000000000000"
}

```

### Set Codespace secrets

With the appId, password, and tenant from the service principal and the id from the subscription you can set the Codespace secrets. You can learn how to set them on the [Managing encrypted secrets for your codespaces](https://docs.github.com/en/codespaces/managing-your-codespaces/managing-encrypted-secrets-for-your-codespaces) page. Make sure you assign them permission to the fork of this repository.

![codespace secrets](./.images/CodespaceSecrets.png)

## Running Demos

All the scripts in the repository are PowerShell scripts. When using Codespaces the terminal should default to PowerShell, if not type `pwsh` to switch.

```
$ pwsh
```

If running locally on macOS, Windows or Linux install [PowerShell](https://github.com/powershell/powershell).

Each demo has a workspace file in the root folder. Select the workspace for the demo you want to run and click the *Open Workspace* button in the lower right corner.

![open workspace](./.images/OpenWorkspace.png)

This will reload your Codespace and scope your Explorer to just the folders needed for this demo.

When you are ready to load another workspace select **Open Workspace...** from the file menu.

![open workspace](./.images/OpenWorkspaceFileMenu.png)

In the root of each demo workspace is a _demo.ps1_ file. From a terminal execute this file to load the _sampleRequest.http_ file and issue the `dapr run` command. The _demo.ps1_ file can accept a `-cloud` switch to run the demo against cloud resources. When the `-cloud` switch is used the script will provision the cloud resources if needed. The required cloud infrastructure can be deployed ahead of time by running the _demo.ps1_ with the `-deployOnly` switch. The script uses the Azure CLI to deploy a [bicep](https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/overview) file to deploy the required infrastructure.

 To encourage best practices the [components are all configured using secret stores](https://docs.dapr.io/operations/components/component-secrets/). After the infrastructure is deployed the script will collect all the information needed to configure the components and write the data to a _local_secrets.json_ file or in environment variables. The file or environment variables are read in a secret store component used to configure the other components. The _local_secrets.json_ file is listed in the .gitignore file of the repository so they are not accidentally committed.

 To delete your cloud resources ane restore the repository to pre-demo state run the _cleanUp.ps1_ file in the root of each workspace.

 See the README.md files in each demo folder for instructions on how to run the demo.