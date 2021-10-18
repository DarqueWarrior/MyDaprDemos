# Publish & subscribe messaging demo

## Abstract

The purpose of this demo is to show the use of [Pub/sub components](https://docs.dapr.io/reference/components-reference/supported-pubsub/) locally and in the cloud. 

Open the _demo_pubsub.code-workspace_ file and click the **Open Workspace** button in the lower right corner. This will reload your Codespace and scope your Explorer to just the folders needed for this demo. 

To provision the infrastructure before the demo execute the following command in the terminal. This code is automatically run by the _demo.ps1_ script if the `-env` parameter is passed and *./components/azure/local_secrets.json* file is not found.

```
./demo.ps1 -deployOnly
``` 

The workspace consists of one top level folder _PubSub_. This folder holds the _components/azure_, _components_, _deploy_, and _src_ folders. The _components/azure_ and _components_ folders are in the workspace so you can show the difference between a local component and a component configured for the cloud. The component in the _components/azure_ folder is configured to use [Azure Service Bus](https://docs.dapr.io/reference/components-reference/supported-pubsub/setup-azure-servicebus/) while the local component is configured to use Redis. The point to make comparing the files is that as long as the name of the component does not change the code will work no matter what backing service is used. 

## Running Demo

The core of the demo is in the _sampleRequests.http_ file. At the top of the file are two _demo.ps1_ commands. One for running the requests against local resources and one for running against the cloud resources. Copy the desired command and run it in the terminal. This will start Dapr pointing to the appropriate components for the demo. The Dapr run command issued is output if you want to explain during the demo.

## Running local
```
 ./demo.ps1
```

## Running in azure
```
 ./demo.ps1 -env azure
```

## Running in aws
```
 ./demo.ps1 -env aws
```

Click the Send Request button above each of the requests to execute them.

## Debug Demo

This demo uses the [Dapr Extension](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-dapr) to enable F5 debugging. 

Set breakpoints on lines 9 and 12 of _src/Program.cs_. Select **Run** from the **View** menu then select either the **Dapr Local** or **Dapr Cloud** launch configuration and press _F5_. This will start the code and attach the debugger.

Using the _sampleRequests.http_ file click the Send Request button above each of the requests to execute them. Notice with each click the appropriate breakpoint is hit. 

## Clean Up Demo

When you are done with the demo you can clean up the cloud resources by running the _cleanUp.ps1_ script using the following commands: 

```
./cleanUp.ps1
```

If you get port errors run:

```
lsof -i  
```

And kill the pid running daprd.