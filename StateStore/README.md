# State management demo

The purpose of this demo is to show the use of [state store components](https://docs.dapr.io/developing-applications/building-blocks/state-management/) locally and in the cloud. 

Open the `statestore.code-workspace` file and click the “Open Workspace” button in the lower right corner. This will reload your Codespace and scope your Explorer to just the folders needed for this demo. 

From the terminal execute the following commands to deploy the infrastructure and create the local_secrets.json file. 

```
pwsh
cd ./deploy/
./setup.ps1
``` 

The workspace consists of two top level folders _StateStore_ and _components_. The components folder is the folder installed during the `dapr init` run during the creation of the Codespace. This folder holds the default components pointing at [Redis](https://docs.dapr.io/reference/components-reference/supported-state-stores/setup-redis/). This folder is in the workspace so you can show the difference between that default component and the component in the _StateStore/azureComponents_ folder. The component in the _azureComponents_ folder is configured to use [Azure CosmosDB](https://docs.dapr.io/reference/components-reference/supported-state-stores/setup-azure-cosmosdb/). The point to make comparing the files is that as long as the name of the component does not change the code will work no matter what backing service is used. 

The core of the demo is in the sampleRequests.http file. At the top of the file are two Dapr run commands. One for running the requests against local resources and one for running against the cloud resources. Copy the desired command and run it in the terminal. This will start Dapr pointing to the appropriate components for the demo. Click the Send Request button above each of the requests to execute them. 

When running locally against Redis you can use the Redis Visual Studio Code extension installed in the Codespace to see the state being stored there. 

When you are done with the demo you can clean up the cloud resources by running the tear down scripts using the following commands: 

```
cd ./deploy/
./teardown.ps1
```