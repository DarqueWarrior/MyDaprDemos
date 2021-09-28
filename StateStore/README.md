# State management demo

The purpose of this demo is to show the use of [state store components](https://docs.dapr.io/developing-applications/building-blocks/state-management/) locally and in the cloud. 

Open the _demo_statestore.code-workspace_ file and click the **Open Workspace** button in the lower right corner. This will reload your Codespace and scope your Explorer to just the folders needed for this demo. 

To provision the infrastructure before the demo execute the following command in the terminal. This code is automatically run by the _demo.ps1_ script if the -cloud switch is passed and *./azureComponents/local_secrets.json* file is not found.

```
./demo.ps1 -deployOnly
``` 

The workspace consists of two top level folders _StateStore_ and _components_. The components folder is the folder installed during the `dapr init` run during the creation of the Codespace. This folder holds the default components pointing at [Redis](https://docs.dapr.io/reference/components-reference/supported-state-stores/setup-redis/). This folder is in the workspace so you can show the difference between that default component and the component in the _StateStore/azureComponents_ folder. The component in the _azureComponents_ folder is configured to use [Azure CosmosDB](https://docs.dapr.io/reference/components-reference/supported-state-stores/setup-azure-cosmosdb/). The point to make comparing the files is that as long as the name of the component does not change the code will work no matter what backing service is used. 

The core of the demo is in the _sampleRequests.http_ file. At the top of the file are two _demo.ps1_ commands. One for running the requests against local resources and one for running against the cloud resources. Copy the desired command and run it in the terminal. This will start Dapr pointing to the appropriate components for the demo. The Dapr run command issued is output if you want to explain during the demo.

Running local
```
dapr run --app-id local --dapr-http-port 3500
```

Running in cloud
```
dapr run --app-id cloud --dapr-http-port 3500 --components-path ./azureComponents
```

Click the Send Request button above each of the requests to execute them. 

When running locally against Redis you can use the Redis Visual Studio Code extension installed in the Codespace to see the state being stored there. 

When you are done with the demo you can clean up the cloud resources by running the _cleanUp.ps1_ script using the following commands: 

```
./cleanUp.ps1
```