# Provisioning Compute Resources

Kubernetes requires a set of machines to host the Kubernetes control plane and the worker nodes where containers are ultimately run. In this lab you will provision the compute resources required for running a secure and highly available Kubernetes cluster within a single [Resource Group](https://docs.microsoft.com/azure/azure-resource-manager/resource-group-overview#resource-groups) in a single [region](https://azure.microsoft.com/global-infrastructure/regions/)
Create a default Resource Group in a region
> Ensure a resource group has been created as described in the [Prerequisites](01-prerequisites.md#create-a-deafult-resource-group-in-a-region) lab.

## Networking

The Kubernetes [networking model](https://kubernetes.io/docs/concepts/cluster-administration/networking/#kubernetes-model) assumes a flat network in which containers and nodes can communicate with each other. In cases where this is not desired [network policies](https://kubernetes.io/docs/concepts/services-networking/network-policies/) can limit how groups of containers are allowed to communicate with each other and external network endpoints.

> Setting up network policies is out of scope for this tutorial.

### Virtual Network

In this section a dedicated [Virtual Network](https://docs.microsoft.com/azure/virtual-network/virtual-networks-overview) (VNet) network will be setup to host the Kubernetes cluster.

Create the `kubernetes-vnet` custom VNet network with a subnet `kubernetes` provisioned with an IP address range large enough to assign a private IP address to each node in the Kubernetes cluster.:

```shell
az network vnet create -g kubernetes -n kubernetes-vnet --address-prefix 10.240.0.0/24 --subnet-name kubernetes-subnet
```

> The `10.240.0.0/24` IP address range can host up to 254 compute instances.

### Firewall Rules

Create a firewall ([Network Security Group](https://docs.microsoft.com/azure/virtual-network/virtual-network-vnet-plan-design-arm#security)) and assign it to the subnet:

```shell
az network nsg create -g kubernetes -n kubernetes-nsg
```

```shell
az network vnet subnet update -g kubernetes -n kubernetes-subnet --vnet-name kubernetes-vnet --network-security-group kubernetes-nsg
```

Create a firewall rule that allows external SSH and HTTPS:

```shell
az network nsg rule create -g kubernetes -n kubernetes-allow-ssh --access allow --destination-address-prefix "*" --destination-port-range 22 --direction inbound --nsg-name kubernetes-nsg --protocol tcp --source-address-prefix "*" --source-port-range "*" --priority 1000
```

```shell
az network nsg rule create -g kubernetes -n kubernetes-allow-api-server --access allow --destination-address-prefix "*" --destination-port-range 6443 --direction inbound --nsg-name kubernetes-nsg --protocol tcp --source-address-prefix "*" --source-port-range "*" --priority 1001
```

> An [external load balancer](https://docs.microsoft.com/azure/load-balancer/load-balancer-overview) will be used to expose the Kubernetes API Servers to remote clients.

List the firewall rules in the `kubernetes-vnet` VNet network:

```shell
az network nsg rule list -g kubernetes --nsg-name kubernetes-nsg --query "[].{Name:name, Direction:direction, Priority:priority, Port:destinationPortRange}" -o table
```

> output

```shell
Name                         Direction      Priority    Port
---------------------------  -----------  ----------  ------
kubernetes-allow-ssh         Inbound            1000      22
kubernetes-allow-api-server  Inbound            1001    6443
```

### Kubernetes Public IP Address

Allocate a static IP address that will be attached to the external load balancer fronting the Kubernetes API Servers:

```shell
az network lb create -g kubernetes -n kubernetes-lb --backend-pool-name kubernetes-lb-pool --public-ip-address kubernetes-pip --public-ip-address-allocation static
```

Verify the `kubernetes-pip` static IP address was created correctly in the `kubernetes` Resource Group and chosen region:

```shell
az network public-ip list --query="[?name=='kubernetes-pip'].{ResourceGroup:resourceGroup, Region:location, Allocation:publicIpAllocationMethod, IP:ipAddress}" -o table
```

> output

```shell
ResourceGroup    Region         Allocation    IP
---------------  -------------  ------------  -------------
kubernetes       southeastasia  Static        xxx.xx.xxx.xx
```

## Virtual Machines

The compute instances in this lab will be provisioned using [Ubuntu Server](https://www.ubuntu.com/server) 18.04. Each compute instance will be provisioned with a fixed private IP address to simplify the Kubernetes bootstrapping process.

To select latest stable Ubuntu Server release run following command and replace UBUNTULTS variable below with latest row in the table.

```shell
az vm image list --location southeastasia --publisher Canonical --offer UbuntuServer --sku 18.04-LTS --all -o table
```

```shell
set UBUNTULTS="Canonical:UbuntuServer:18.04-LTS:18.04.202006101"

echo %UBUNTULTS%
"Canonical:UbuntuServer:18.04-LTS:18.04.202006101"

```

### Kubernetes Controllers

Create two compute instances which will host the Kubernetes control plane in `master-as` [Availability Set](https://docs.microsoft.com/azure/virtual-machines/linux/tutorial-availability-sets#availability-set-overview):

```shell
az vm availability-set create -g kubernetes -n master-as
```
While creating virtual machines you can pass your own set of SSH keys which will then be used to login to servers.
Azure currently supports SSH protocol 2 (SSH-2) RSA public-private key pairs with a minimum length of 2048 bits. Other key formats such as ED25519 and ECDSA are not supported. 

```shell

az network public-ip create -n master-1-pip -g kubernetes
az network public-ip create -n master-2-pip -g kubernetes

az network nic create -g kubernetes -n master-1-nic --private-ip-address 10.240.0.11 --public-ip-address master-1-pip --vnet kubernetes-vnet --subnet kubernetes-subnet --ip-forwarding --lb-name kubernetes-lb --lb-address-pools kubernetes-lb-pool
az network nic create -g kubernetes -n master-2-nic --private-ip-address 10.240.0.12 --public-ip-address master-2-pip --vnet kubernetes-vnet --subnet kubernetes-subnet --ip-forwarding --lb-name kubernetes-lb --lb-address-pools kubernetes-lb-pool

az vm create -g kubernetes -n master-1 --image %UBUNTULTS% --nics master-1-nic --availability-set master-as --admin-username "kubeadmin" --ssh-key-values <-Full-Path-To->\id_rsa.pub
az vm create -g kubernetes -n master-2 --image %UBUNTULTS% --nics master-2-nic --availability-set master-as --admin-username "kubeadmin" --ssh-key-values <-Full-Path-To->\id_rsa.pub

```

### Kubernetes Workers

Create two compute instances which will host the Kubernetes worker nodes in `worker-as` Availability Set:

```shell
az vm availability-set create -g kubernetes -n worker-as
```

```shell
az network public-ip create -n worker-1-pip -g kubernetes
az network public-ip create -n worker-2-pip -g kubernetes

az network nic create -g kubernetes -n worker-1-nic --private-ip-address 10.240.0.21 --public-ip-address worker-1-pip --vnet kubernetes-vnet --subnet kubernetes-subnet --ip-forwarding
az network nic create -g kubernetes -n worker-2-nic --private-ip-address 10.240.0.22 --public-ip-address worker-2-pip --vnet kubernetes-vnet --subnet kubernetes-subnet --ip-forwarding

az vm create -g kubernetes -n worker-1 --image %UBUNTULTS% --nics worker-1-nic --availability-set worker-as --admin-username "kubeadmin" --ssh-key-values <-Full-Path-To->\id_rsa.pub
az vm create -g kubernetes -n worker-2 --image %UBUNTULTS% --nics worker-2-nic --availability-set worker-as --admin-username "kubeadmin" --ssh-key-values <-Full-Path-To->\id_rsa.pub

```

### Verification

List the compute instances in your default compute zone:

```shell
az vm list -d -g kubernetes -o table
```

> output

```shell
Name      ResourceGroup    PowerState    PublicIps      Fqdns    Location       Zones
--------  ---------------  ------------  -------------  -------  -------------  -------
master-1  kubernetes       VM running    xx.xx.xx.xxx            southeastasia
master-2  kubernetes       VM running    xx.xx.xxx.xxx           southeastasia
worker-1  kubernetes       VM running    xx.xxx.xx.xx            southeastasia
worker-2  kubernetes       VM running    xx.xx.x.xxx             southeastasia
```
SSH to the instances using private key:

```shell
cd <-Full-Path-To-Private-Key->
ssh -i id_rsa kubeadmin@<-Public-IP-Listed-In-The-Table-Above->

```
> output

```shell

for ip in <-Public-IP-Master-1-> <-Public-IP-Master-2-> <-Public-IP-Worker-1-> <-Public-IP-Worker-2->
> do
> ssh -i id_rsa kubeadmin@$ip "hostname -s"
> done
master-1
master-2
worker-1
worker-2

```

Next: [Provisioning a CA and Generating TLS Certificates](04-certificate-authority.md)
