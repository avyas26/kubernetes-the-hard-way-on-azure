# Generating Kubernetes Configuration Files for Authentication

In this lab we will generate [Kubernetes configuration files](https://kubernetes.io/docs/concepts/configuration/organize-cluster-access-kubeconfig/), also known as kubeconfigs, which enable Kubernetes clients to locate and authenticate to the Kubernetes API Servers.

## Client Authentication Configs

In this section we will generate kubeconfig files for the `controller manager`, `kubelet`, `kube-proxy`, and `scheduler` clients and the `admin` user.

### Kubernetes Public IP Address

Each kubeconfig requires a Kubernetes API Server to connect to. To support high availability the IP address assigned to the external load balancer fronting the Kubernetes API Servers will be used.

Retrieve the static IP address. We had created this in [Provisioning Compute Resources](02-compute-resources.md#Kubernetes-Public-IP-Address) lab.

```shell
az network public-ip show -g kubernetes -n kubernetes-pip --query "ipAddress" -otsv
```

### The kubelet Kubernetes Configuration File

When generating kubeconfig files for Kubelets the client certificate matching the Kubelet's node name must be used. This will ensure Kubelets are properly authorized by the Kubernetes [Node Authorizer](https://kubernetes.io/docs/admin/authorization/node/).

Generate a kubeconfig file for each worker node:

```shell

ssh kubeadmin@<Public-IP-of-Master-1->
{
KUBERNETES_PUBLIC_ADDRESS=<-Public-IP-Generated-from-above-command->
certs=/home/kubeadmin/certs

mkdir kubeconfigs
cd kubeconfigs

for instance in worker-1 worker-2; do
  kubectl config set-cluster kubernetes-the-hard-way \
    --certificate-authority=${certs}/ca.crt \
    --embed-certs=true \
    --server=https://${KUBERNETES_PUBLIC_ADDRESS}:6443 \
    --kubeconfig=${instance}.kubeconfig

  kubectl config set-credentials system:node:${instance} \
    --client-certificate=${certs}/${instance}.crt \
    --client-key=${certs}/${instance}.key \
    --embed-certs=true \
    --kubeconfig=${instance}.kubeconfig

  kubectl config set-context default \
    --cluster=kubernetes-the-hard-way \
    --user=system:node:${instance} \
    --kubeconfig=${instance}.kubeconfig

  kubectl config use-context default --kubeconfig=${instance}.kubeconfig
done
}

ls worker*
worker-1.kubeconfig  worker-2.kubeconfig
```

### The kube-proxy Kubernetes Configuration File

Generate a kubeconfig file for the `kube-proxy` service:

```shell
{
kubectl config set-cluster kubernetes-the-hard-way \
  --certificate-authority=${certs}/ca.crt \
  --embed-certs=true \
  --server=https://${KUBERNETES_PUBLIC_ADDRESS}:6443 \
  --kubeconfig=kube-proxy.kubeconfig

kubectl config set-credentials kube-proxy \
  --client-certificate=${certs}/kube-proxy.crt \
  --client-key=${certs}/kube-proxy.key \
  --embed-certs=true \
  --kubeconfig=kube-proxy.kubeconfig

kubectl config set-context default \
  --cluster=kubernetes-the-hard-way \
  --user=kube-proxy \
  --kubeconfig=kube-proxy.kubeconfig

kubectl config use-context default --kubeconfig=kube-proxy.kubeconfig
}

ls kube-proxy*
kube-proxy.kubeconfig
```

### The kube-controller-manager Kubernetes Configuration File

Generate a kubeconfig file for the `kube-controller-manager` service:

```shell
{
kubectl config set-cluster kubernetes-the-hard-way \
    --certificate-authority=${certs}/ca.crt \
    --embed-certs=true \
    --server=https://127.0.0.1:6443 \
    --kubeconfig=kube-controller-manager.kubeconfig

kubectl config set-credentials system:kube-controller-manager \
    --client-certificate=${certs}/kube-controller-manager.crt \
    --client-key=${certs}/kube-controller-manager.key \
    --embed-certs=true \
    --kubeconfig=kube-controller-manager.kubeconfig

kubectl config set-context default \
    --cluster=kubernetes-the-hard-way \
    --user=system:kube-controller-manager \
    --kubeconfig=kube-controller-manager.kubeconfig

kubectl config use-context default --kubeconfig=kube-controller-manager.kubeconfig
}

ls kube-contro*
kube-controller-manager.kubeconfig
```

### The kube-scheduler Kubernetes Configuration File

Generate a kubeconfig file for the `kube-scheduler` service:

```shell
{
  kubectl config set-cluster kubernetes-the-hard-way \
    --certificate-authority=${certs}/ca.crt \
    --embed-certs=true \
    --server=https://127.0.0.1:6443 \
    --kubeconfig=kube-scheduler.kubeconfig

  kubectl config set-credentials system:kube-scheduler \
    --client-certificate=${certs}/kube-scheduler.crt \
    --client-key=${certs}/kube-scheduler.key \
    --embed-certs=true \
    --kubeconfig=kube-scheduler.kubeconfig

  kubectl config set-context default \
    --cluster=kubernetes-the-hard-way \
    --user=system:kube-scheduler \
    --kubeconfig=kube-scheduler.kubeconfig

  kubectl config use-context default --kubeconfig=kube-scheduler.kubeconfig
}

ls kube-sc*
kube-scheduler.kubeconfig
```

### The admin Kubernetes Configuration File

Generate a kubeconfig file for the `admin` user:

```shell
{
  kubectl config set-cluster kubernetes-the-hard-way \
    --certificate-authority=${certs}/ca.crt \
    --embed-certs=true \
    --server=https://127.0.0.1:6443 \
    --kubeconfig=admin.kubeconfig

  kubectl config set-credentials admin \
    --client-certificate=${certs}/admin.crt \
    --client-key=${certs}/admin.key \
    --embed-certs=true \
    --kubeconfig=admin.kubeconfig

  kubectl config set-context default \
    --cluster=kubernetes-the-hard-way \
    --user=admin \
    --kubeconfig=admin.kubeconfig

  kubectl config use-context default --kubeconfig=admin.kubeconfig
}

ls admin*
admin.kubeconfig
```
## Distribute the Kubernetes Configuration Files

Copy the appropriate `kubelet` and `kube-proxy` kubeconfig files to respective worker nodes and `kube-controller-manager` `admin` and `kube-scheduler` kubeconfig files to master-2

```shell
{
for i in 1 2; \
do \
scp ~/kubeconfigs/worker-$i* ~/kubeconfigs/kube-proxy* worker-$i:/home/kubeadmin/; \
done

scp ~/kubeconfigs/kube-* ~/kubeconfigs/admin* master-2:/home/kubeadmin/
}
```

Next: [Generating the Data Encryption Config and Key](06-data-encryption-keys.md)
