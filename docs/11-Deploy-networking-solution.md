# Deploy Pod Networking Solution

We will use Weave as our networking solution. Run the below command on ```master-1``` node.

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
NAME                       READY   STATUS              RESTARTS   AGE
weave-net-kfsb9            2/2     Running             0          110s
weave-net-vsc25            2/2     Running             0          110s
```


Next: [Deploying the DNS Cluster Add-on](12-dns-addon.md)
