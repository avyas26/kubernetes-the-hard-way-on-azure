# Configuring kubectl for Remote Access

I have kubectl installed on my Windows laptop. In order to access the cluster `kubernetes-the-hard-way` from `cmd` edit the admin.kubeconfig file we copied to laptop during [Generating Kubernetes Configuration Files for Authentication](05-kubernetes-configuration-files.md) step under section `Distribute the Kubernetes Configuration Files`

## The Admin Kubernetes Configuration File

Retrieve the `kubernetes-the-hard-way` static IP address:

```shell
az network public-ip show -g kubernetes -n kubernetes-pip --query ipAddress -otsv
```
Edit the admin.kubeconfig file and replace the server with the static IP Address obtained from above command:

```shell
    server: https://<Public-IP-Address-here->:6443
```

## Verification

Check the health of the remote Kubernetes cluster:

```shell
kubectl get componentstatuses --kubeconfig=kubeconfigs\admin.kubeconfig
```

> output

```shell
NAME                 STATUS    MESSAGE              ERROR
controller-manager   Healthy   ok
scheduler            Healthy   ok
etcd-0               Healthy   {"health": "true"}
etcd-1               Healthy   {"health": "true"}
```

List the nodes in the remote Kubernetes cluster:

```shell
kubectl get nodes --kubeconfig=kubeconfigs\admin.kubeconfig
```

> output

```shell
NAME       STATUS     ROLES    AGE     VERSION
worker-1   NotReady   <none>   15m     v1.18.4
worker-2   NotReady   <none>   9m37s   v1.18.4
```
Note: Worker nodes will move to `Ready` state after we deploy networking solution.

Next: [Provisioning Pod Network Routes](11-pod-network-routes.md)
