# Provisioning Compute Resources

To install Kubernetes we will provision virtual machines which will host control plane and worker nodes. All the resources will be provisioned within a single [Resource Group](https://docs.microsoft.com/azure/azure-resource-manager/resource-group-overview#resource-groups) in a single [region](https://azure.microsoft.com/global-infrastructure/regions/)

We have already created ```kubernetes``` resource group in ```southeastasia``` region in the [Prerequisites](01-prerequisites.md#create-a-default-resource-group-in-a-region) lab.

## Networking

The Kubernetes [networking model](https://kubernetes.io/docs/concepts/cluster-administration/networking/#kubernetes-model) assumes a flat network in which containers and nodes can communicate with each other. In cases where this is not desired [network policies](https://kubernetes.io/docs/concepts/services-networking/network-policies/) can limit how groups of containers are allowed to communicate with each other and external network endpoints.

> Setting up network policies is out of scope for this tutorial.

### Virtual Network

In this section a dedicated [Virtual Network](https://docs.microsoft.com/azure/virtual-network/virtual-networks-overview) (VNet) network will be setup to host the Kubernetes cluster.

Create the `kubernetes-vnet` custom VNet network with a subnet `kubernetes-subnet` provisioned with an IP address range large enough to assign a private IP address to each node in the Kubernetes cluster.:

```shell
az network vnet create -g kubernetes -n kubernetes-vnet \
--address-prefix 10.240.0.0/24 --subnet-name kubernetes-subnet
```

> The `10.240.0.0/24` IP address range can host up to 254 compute instances.

### Firewall Rules
We won't be creating any firewall rules in this lab to keep it simple.

### Kubernetes Public IP Address

Allocate a static IP address that will be attached to the external load balancer fronting the Kubernetes API Servers:

```shell
az network lb create -g kubernetes -n kubernetes-lb --backend-pool-name kubernetes-lb-pool \
--public-ip-address kubernetes-pip --public-ip-address-allocation static
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

The compute instances in this lab will be provisioned using RHEL 7.8. Each compute instance will be provisioned with a fixed private IP address to simplify the Kubernetes bootstrapping process.

To select latest RHEL release run following command and replace RHEL variable below with latest row in the table. Change the --sku parameter to choose different RHEL version.

```shell
az vm image list --location southeastasia --publisher redhat --offer RHEL --sku 7.8 --all -o table
```

```shell
RHEL=RedHat:RHEL:7.8:7.8.2020050910
echo $RHEL
```
> output:
```shell
RedHat:RHEL:7.8:7.8.2020050910
```

### Kubernetes Controllers

Create two compute instances which will host the Kubernetes control plane in `master-as` [Availability Set](https://docs.microsoft.com/azure/virtual-machines/linux/tutorial-availability-sets#availability-set-overview):

```shell
az vm availability-set create -g kubernetes -n master-as
```
While creating virtual machines you can pass set of SSH keys which will then be used to login to servers. Azure currently supports SSH protocol 2 (SSH-2) RSA public-private key pairs with a minimum length of 2048 bits. Other key formats such as ED25519 and ECDSA are not supported.

In this lab we will be using passwords instead to keep it simple.

> Create public IPs

```shell
for i in 1 2; \
do \
az network public-ip create -n master-$i-pip -g kubernetes; \
done
```
> Create NIC

```shell
for i in 1 2; \
do \
az network nic create -g kubernetes -n master-$i-nic --private-ip-address 10.240.0.1$i --public-ip-address master-$i-pip \
--vnet kubernetes-vnet --subnet kubernetes-subnet --ip-forwarding --lb-name kubernetes-lb --lb-address-pools kubernetes-lb-pool; \
done
```
> Create virtual machines

```shell
for i in 1 2; \
do \
az vm create -g kubernetes -n master-$i --image $RHEL --nics master-$i-nic --availability-set master-as --nsg '' \
--admin-username "kubeadmin" --admin-password "kubeadmin@123"; \
done
```

### Kubernetes Workers

Create two compute instances which will host the Kubernetes worker nodes in `worker-as` Availability Set:

```shell
az vm availability-set create -g kubernetes -n worker-as
```
> Create public IPs

```shell
for i in 1 2; \
do \
az network public-ip create -n worker-$i-pip -g kubernetes; \
done
```
> Create NIC

```shell
for i in 1 2; \
do \
az network nic create -g kubernetes -n worker-$i-nic --private-ip-address 10.240.0.2$i \
--public-ip-address worker-$i-pip --vnet kubernetes-vnet --subnet kubernetes-subnet --ip-forwarding; \
done
```
> Create virtual machines

```shell
for i in 1 2; \
do \
az vm create -g kubernetes -n worker-$i --image $RHEL --nics worker-$i-nic --tags pod-cidr=10.200.${i}.0/24 \
--availability-set worker-as --nsg '' --admin-username "kubeadmin" --admin-password "kubeadmin@123"; \
done
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
SSH to the instances:

> Get the Public IPs

```shell
for i in 1 2; \
do \
az vm show -d -g kubernetes --name master-$i --query publicIps -o tsv | tr -d [:space:] >> ~/ips.txt; \
echo " " >> ~/ips.txt ;\
az vm show -d -g kubernetes --name worker-$i --query publicIps -o tsv | tr -d [:space:] >> ~/ips.txt; \
echo " " >> ~/ips.txt; \
done
```
> Login to server

```shell
for ip in `cat ~/ips.txt`; \
do \
ssh kubeadmin@$ip "hostname -s" ;\
done
```

> output

```shell
kubeadmin@xx.xxx.xxx.xx's password:
X11 forwarding request failed on channel 0
master-1
Warning: Permanently added 'xx.xxx.xxx.xx' (RSA) to the list of known hosts.
kubeadmin@xx.xxx.xxx.xx's password:
X11 forwarding request failed on channel 0
worker-1
Warning: Permanently added 'xx.xxx.xxx.xx' (RSA) to the list of known hosts.
kubeadmin@xx.xxx.xxx.xx's password:
X11 forwarding request failed on channel 0
master-2
Warning: Permanently added 'xx.xxx.xxx.xx' (RSA) to the list of known hosts.
kubeadmin@xx.xxx.xxx.xx's password:
X11 forwarding request failed on channel 0
worker-2
```

Next: [Installing the Client Tools](03-client-tools.md)
