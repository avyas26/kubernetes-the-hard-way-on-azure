# Provisioning Azure infrastructure using Terraform

### Terraform Installation

Download [Terraform](https://www.terraform.io/downloads.html) and [Install](https://learn.hashicorp.com/tutorials/terraform/install-cli) the binary.
Add the appropiate environment variables as per the installation video.

> Validate the installation by checking the version

```shell
terraform.exe --version
```
> Output

```shell
Terraform v0.12.29
```

### Download the terraform configuration file and execute to create the required infrastructure

Create a directory to download the terraform configuration file.

```shell
{
mkdir terraform
cd terraform
}
```

Download the config file.

```shell
wget https://raw.githubusercontent.com/vyasanand/kubernetes-the-hard-way-on-azure/master/config/deployresources.tf
```
> Verify the file is downloaded

```shell
ls
deployresources.tf
```

Run the below command to validate the plan. Change the loc variable to deploy to another location.

```shell
terraform.exe plan -var 'loc=southeastasia'
```
> Output

```shell
Plan: 24 to add, 0 to change, 0 to destroy.
```

Run the below command to execute the plan. Change the loc variable to deploy to another location.
It will prompt for input for which enter the value ```yes```

```shell
terraform.exe apply -var 'loc=southeastasia'
```
> Output

```shell
Plan: 24 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes
. 
. <Skipping the extra part here>
.
Apply complete! Resources: 24 added, 0 changed, 0 destroyed.
```

Go to the [verification](02-compute-resources.md#verification) section and perform the steps to validate the connectivity.
