# Secrets demo

The purpose of this demo is to show the use of [secrets components](https://docs.dapr.io/developing-applications/building-blocks/secrets/) locally and in the cloud. 

Open the _demo_secrets.code-workspace_ file and click the **Open Workspace** button in the lower right corner. This will reload your Codespace and scope your Explorer to just the folders needed for this demo. 

To provision the infrastructure before the demo execute the following command in the terminal. This code is automatically run by the _demo.ps1_ script if the `-env` parameter is passed and *AZURE_KEY_VAULT_NAME* environment variable is not found. 

```
./demo.ps1 -deployOnly
``` 

The workspace consists of one top level folder _Secrets_. The components sub folder contains components for local, Azure, and AWS. These folders allow you to show the difference between that default components (local) and the components in the other folders. The point to make comparing the files is that as long as the name of the component does not change the code will work no matter what backing service is used.

The core of the demo is in the _sampleRequests.http_ file. At the top of the file are two _demo.ps1_ commands. One for running the requests against local resources and one for running against the cloud resources. Copy the desired command and run it in the terminal. This will start Dapr pointing to the appropriate components for the demo. The Dapr run command issued is output if you want to explain during the demo.

## Running local
```
dapr run --app-id local --dapr-http-port 3500 --components-path ./components
```

## Running in azure
```
dapr run --app-id azure --dapr-http-port 3500 --components-path ./components/azure
```

## Running in aws
```
dapr run --app-id aws --dapr-http-port 3500 --components-path ./components/aws
```

Click the Send Request button above each the request to execute it. 

When you are done with the demo you can clean up the cloud resources by running the _cleanUp.ps1_ script using the following commands: 

```
./cleanUp.ps1
```