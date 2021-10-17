# DevOps demo

The purpose of this demo is to show how to deploy a Daprized application to a cloud based Kubernetes Service, using the [Dapr tool installer](https://github.com/marketplace/actions/dapr-tool-installer) GitHub Action. 

Open the _demo_devops.code-workspace_ file and click the **Open Workspace** button in the lower right corner. This will reload your Codespace and scope your Explorer to just the folders needed for this demo. 

To provision the infrastructure before the demo execute the following command in the terminal. This code is automatically run by the _demo.ps1_ script if the `-env` parameter is passed and *./components/local/local_secrets.json* file is not found.

```
./demo.ps1 -deployOnly
``` 

The workspace consists of one top level folders _DevOps_. The components folder is the folder installed during the `dapr init` run during the creation of the Codespace. This folder holds the default components pointing at [Redis](https://docs.dapr.io/reference/components-reference/supported-state-stores/setup-redis/). This folder is in the workspace so you can show the difference between that default component and the component in the _DevOps/components/azure_ folder. The component in the _components/azure_ folder is configured to use [Azure CosmosDB](https://docs.dapr.io/reference/components-reference/supported-state-stores/setup-azure-cosmosdb/). The point to make comparing the files is that as long as the name of the component does not change the code will work no matter what backing service is used. 

## Set Actions secrets

For the GitHub Actions workflow to succeed you must configure the following secrets. These are **not** the CodeSpaces secrets you set earlier. These are set as _Repository secrets_. Review [Configure Azure credentials as GitHub Secret](https://github.com/marketplace/actions/azure-cli-action#configure-azure-credentials-as-github-secret) to set your **AZURE_CREDENTIALS** secret. 

![codespace secrets](../.images/ActionsSecrets.png)

Running this demo will deploy the application to a Kubernetes cluster or run locally using [Project Tye](https://github.com/dotnet/tye). To show the demo running use the _PORTS_ tab to Open port **5000** with running local or **k3d-Demo (30000)** when running with k8s in a browser.

Running local
```
./demo.ps1 -env K8s
```

Running in cloud
![codespace secrets](../.images/RunWorkflow.png)

When you are done with the demo you can clean up the cloud resources by running the _cleanUp.ps1_ script using the following commands: 

```
./cleanUp.ps1
```