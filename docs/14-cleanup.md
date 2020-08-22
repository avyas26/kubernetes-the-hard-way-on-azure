# Cleaning Up

The following command will delete the `kubernetes` resource group and all related resources created during this tutorial.

```shell
az group delete --name kubernetes --yes
```

If you have used [Terraform](Terraform.md#provisioning-azure-infrastructure-using-terraform) to deploy the infrastructure, go to the Terraform folder created and run the below command.

```shell
terraform.exe destroy -var 'loc=southeastasia'
```
> Output

```shell
Plan: 0 to add, 0 to change, 24 to destroy.

Do you really want to destroy all resources?
  Terraform will destroy all your managed infrastructure, as shown above.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value: yes
  .
  .
  Destroy complete! Resources: 24 destroyed.
  
```
