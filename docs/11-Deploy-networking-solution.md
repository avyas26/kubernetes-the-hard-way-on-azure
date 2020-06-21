# Deploy Pod Networking Solution

We will use Weave as our networking solution. Download the CNI Weave plug-in on both `worker-1` and `worker-2` and extract it under `/opt/cni/bin` directory.

```shell
{
wget https://github.com/containernetworking/plugins/releases/download/v0.8.6/cni-plugins-linux-amd64-v0.8.6.tgz
sudo tar -xzvf cni-plugins-linux-amd64-v0.8.6.tgz --directory /opt/cni/bin/
}
```

## Deploy the Weave network solution by running it once on the `master` node

```shell
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"
```
> output:

```shell
serviceaccount/weave-net created
clusterrole.rbac.authorization.k8s.io/weave-net created
clusterrolebinding.rbac.authorization.k8s.io/weave-net created
role.rbac.authorization.k8s.io/weave-net created
rolebinding.rbac.authorization.k8s.io/weave-net created
daemonset.apps/weave-net created
```
## Verification

```shell
kubectl get pods -n kube-system
```
> output

```shell
NAME              READY   STATUS    RESTARTS   AGE
weave-net-62gjb   2/2     Running   0          35m
weave-net-hfs56   2/2     Running   0          35m
```


Next: [Deploying the DNS Cluster Add-on](12-dns-addon.md)
