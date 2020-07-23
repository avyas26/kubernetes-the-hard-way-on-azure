# Configuring kubectl for Remote Access

Till now we have been using ```master-1``` as our administrative machine. Now that the cluster services are up and running we can query it using ```kubectl``` installed on local machine or laptop. Clik the link for steps to install [kubectl on Windows](https://kubernetes.io/docs/tasks/tools/install-kubectl/)

In order to access the cluster we will need to copy admin.kubeconfig file from ```master-1``` server to local machine or laptop.
Run the below steps on MobaXterm CLI to copy the file and replace the IP.

## The Admin Kubernetes Configuration File

```shell
mkdir kubeconfigs
master1ip=`az network public-ip show -g kubernetes -n master-1-pip --query "ipAddress" -otsv | tr -d '[:space:]'`
scp kubeadmin@${master1ip}:/home/kubeadmin/kubeconfigs/admin.kubeconfig ./kubeconfigs/
staticip=`az network public-ip show -g kubernetes -n kubernetes-pip --query ipAddress -otsv | tr -d '[:space:]'`
sed -i "s/127.0.0.1/$staticip/g" ./kubeconfigs/admin.kubeconfig
```

## Verification

Check the health of the remote Kubernetes cluster:

```shell
kubectl get componentstatuses --kubeconfig=./kubeconfigs/admin.kubeconfig
```

> output

```shell
NAME                 STATUS    MESSAGE             ERROR
scheduler            Healthy   ok
controller-manager   Healthy   ok
etcd-0               Healthy   {"health":"true"}
etcd-1               Healthy   {"health":"true"}
```

List the nodes in the remote Kubernetes cluster:

```shell
kubectl get nodes --kubeconfig=./kubeconfigs/admin.kubeconfig
```

> output

```shell
NAME       STATUS     ROLES    AGE   VERSION
worker-1   NotReady   <none>   40m   v1.18.6
worker-2   NotReady   <none>   39m   v1.18.6
```
Note: Worker nodes will move to `Ready` state after we deploy networking solution.

Next: [Provisioning Pod Network Routes](11-pod-network-routes.md)
