# Bindings demo

The purpose of this demo is to show the use of [binding components](https://docs.dapr.io/developing-applications/building-blocks/bindings/) locally and in the cloud. 

Open the `binding.code-workspace` file and click the “Open Workspace” button in the lower right corner. This will reload your Codespace and scope your Explorer to just the folders needed for this demo. 

From the terminal execute the following commands to deploy the infrastructure and create the local_secrets.json file. 

```
pwsh
cd ./deploy/
./setup.ps1
``` 

The workspace consists of one top level folder _Binding_. This folder holds the _azureComponents_, _components_, _deploy_, and _tempfiles_ folders. The _azureComponents_ and _components_ folders are in the workspace so you can show the difference between a local component and a component configured for the cloud. The component in the _azureComponents_ folder is configured to use [Azure Blob Storage](https://docs.dapr.io/reference/components-reference/supported-bindings/blobstorage/) while the local component is configured to use local file storage. The point to make comparing the files is that as long as the name of the component does not change the code will work no matter what backing service is used. 

The core of the demo is in the sampleRequests.http file. At the top of the file are two Dapr run commands. One for running the requests against local resources and one for running against the cloud resources. Copy the desired command and run it in the terminal. This will start Dapr pointing to the appropriate components for the demo. Click the Send Request button above each of the requests to execute them. Make sure the correct @itemName is also commented out or in. The metadata for the two stores are different.

When running locally you can expand the _tempfiles_ folder to show the data being stored and deleted.

When you are done with the demo you can clean up the cloud resources by running the tear down scripts using the following commands: 

```
cd ./deploy/
./teardown.ps1
```