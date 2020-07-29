# Prerequisites

## Microsoft Azure

This tutorial leverages [Microsoft Azure](https://azure.microsoft.com) to streamline provisioning of the compute infrastructure required to bootstrap a Kubernetes cluster from ground up. You can [Sign up](https://azure.microsoft.com/free/) for $200 in free credits. 
In Azure Free Trial there is a limit of 4 Cores available, therefore we will create 4 nodes (2 controllers and 2 workers).

### Install the Microsoft Azure CLI 2.0

In this lab we will be using [MobaXterm](https://mobaxterm.mobatek.net/) to run the Azure CLI. Follow the [documentation](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-windows?view=azure-cli-latest&tabs=azure-cli) to Install Azure CLI on Windows.

> MobaXterm has local terminal features that allow to run Unix commands on your local Windows computer [Start Local Terminal](https://mobaxterm.mobatek.net/documentation.html#2_2)

Verify the Microsoft Azure CLI 2.0 version is 2.1.0 or higher:

```shell
az version
```
> output

```shell
{
  "azure-cli": "2.7.0",
  "azure-cli-command-modules-nspkg": "2.0.3",
  "azure-cli-core": "2.7.0",
  "azure-cli-nspkg": "3.0.4",
  "azure-cli-telemetry": "1.0.4",
  "extensions": {}
}
```
NOTE: If you face issues in launching the Azure CLI, check for PATH environment variable. It should have the CLI path set.
      For example: ``` export PATH="$PATH:/drives/c/Program Files (x86)/Microsoft SDKs/Azure/CLI2/wbin" ```

### Create a default Resource Group in a location

In this lab I will be creating resources in `southeastasia` location, within a resource group named `kubernetes`. 
To create this resource group, run the following command:

```shell
az group create -n kubernetes -l southeastasia
```

> Use the `az account list-locations` command to view additional locations.

Next: [Provisioning Compute Resources](02-compute-resources.md)
