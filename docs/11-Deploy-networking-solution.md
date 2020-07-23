# Deploy Pod Networking Solution

We will use flannel as our networking solution. Run the below command on ```master-1``` node.

```shell
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
```
> output:

```shell
podsecuritypolicy.policy/psp.flannel.unprivileged created
clusterrole.rbac.authorization.k8s.io/flannel created
clusterrolebinding.rbac.authorization.k8s.io/flannel created
serviceaccount/flannel created
configmap/kube-flannel-cfg created
daemonset.apps/kube-flannel-ds-amd64 created
daemonset.apps/kube-flannel-ds-arm64 created
daemonset.apps/kube-flannel-ds-arm created
daemonset.apps/kube-flannel-ds-ppc64le created
daemonset.apps/kube-flannel-ds-s390x created
```
## Verification

```shell
kubectl get pods -n kube-system
```
> output

```shell
NAME                          READY   STATUS    RESTARTS   AGE
kube-flannel-ds-amd64-m6v9x   1/1     Running   0          5m17s
kube-flannel-ds-amd64-rhfjt   1/1     Running   0          5m25s

```


Next: [Deploying the DNS Cluster Add-on](12-dns-addon.md)
