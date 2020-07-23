# Smoke Test

In this lab you will complete a series of tasks to ensure your Kubernetes cluster is functioning correctly.

## Data Encryption

In this section you will verify the ability to [encrypt secret data at rest](https://kubernetes.io/docs/tasks/administer-cluster/encrypt-data/#verifying-that-data-is-encrypted).

Run below commands on ```master-1``` node

Create a generic secret:

```shell
kubectl create secret generic kubernetes-the-hard-way \
  --from-literal="mykey=mydata"
```

Print a hexdump of the `kubernetes-the-hard-way` secret stored in etcd:

```shell
ETCDCTL_API=3 etcdctl get /registry/secrets/default/kubernetes-the-hard-way | hexdump -C
```

> output

```shell
00000000  2f 72 65 67 69 73 74 72  79 2f 73 65 63 72 65 74  |/registry/secret|
00000010  73 2f 64 65 66 61 75 6c  74 2f 6b 75 62 65 72 6e  |s/default/kubern|
00000020  65 74 65 73 2d 74 68 65  2d 68 61 72 64 2d 77 61  |etes-the-hard-wa|
00000030  79 0a 6b 38 73 3a 65 6e  63 3a 61 65 73 63 62 63  |y.k8s:enc:aescbc|
00000040  3a 76 31 3a 6b 65 79 31  3a 90 5b ef e3 71 42 f5  |:v1:key1:.[..qB.|
00000050  d8 81 88 cb 2c 40 07 96  09 1f 39 03 91 92 47 bd  |....,@....9...G.|
00000060  24 b4 b8 5a c6 1c 71 5e  ef 5c 74 bf 9c df 8d da  |$..Z..q^.\t.....|
00000070  ca 98 ec bc d8 0c 1e b6  c5 f9 41 07 47 b7 6c 7a  |..........A.G.lz|
00000080  2d 04 f2 65 b7 15 d6 b9  9e ba c5 2b 57 2d be 52  |-..e.......+W-.R|
00000090  45 57 c6 bd 26 86 6f 18  43 73 33 13 55 b2 e6 64  |EW..&.o.Cs3.U..d|
000000a0  14 6f 2b 6a 8a 03 bd 27  40 9a 7d 59 9a 42 8c 9b  |.o+j...'@.}Y.B..|
000000b0  ab 0e 56 1b 6a d8 78 9c  48 70 08 94 3f 35 c1 7c  |..V.j.x.Hp..?5.||
000000c0  61 d8 71 5b 26 92 ba 2c  e3 ac d1 16 f2 a2 c7 84  |a.q[&..,........|
000000d0  29 2b 87 8f 47 46 74 c4  13 0a 12 e4 b7 e0 19 55  |)+..GFt........U|
000000e0  95 b7 d8 81 64 27 04 ec  b6 a5 2b 9a d8 9f 36 1e  |....d'....+...6.|
000000f0  b5 b8 6f 64 f2 32 18 40  e7 68 a3 14 5c de c5 92  |..od.2.@.h..\...|
00000100  1e 9a ed e9 f6 fc e1 82  c8 ca 00 76 8f 7e 10 f4  |...........v.~..|
00000110  e7 af 8b 73 19 16 12 87  e6 21 f3 8d d7 2c f1 e1  |...s.....!...,..|
00000120  9d bb ea 35 c8 fd e2 83  f1 15 c5 5c 1e cc 06 76  |...5.......\...v|
00000130  7e 97 7f 41 c4 ae 5c 41  b6 93 33 8b e3 f5 82 28  |~..A..\A..3....(|
00000140  7d 0d 7a e7 69 4b c4 31  4d 0a                    |}.z.iK.1M.|
0000014a
```

The etcd key should be prefixed with `k8s:enc:aescbc:v1:key1`, which indicates the `aescbc` provider was used to encrypt the data with the `key1` encryption key.

## Deployments

In this section you will verify the ability to create and manage [Deployments](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/).

Create a deployment for the [nginx](https://nginx.org/en/) web server:

```shell
kubectl create deployment nginx --image=nginx
```

List the pod created by the `nginx` deployment:

```shell
kubectl get pods
```

> output

```shell
NAME                    READY   STATUS    RESTARTS   AGE
busybox                 1/1     Running   0          7m18s
nginx-f89759699-fqc7f   1/1     Running   0          22s
```

### Port Forwarding

In this section you will verify the ability to access applications remotely using [port forwarding](https://kubernetes.io/docs/tasks/access-application-cluster/port-forward-access-application-cluster/).

Retrieve the full name of the `nginx` pod:

```shell
POD_NAME=$(kubectl get pods -l app=nginx -o jsonpath="{.items[0].metadata.name}")
```

Forward port `8080` on your local machine to port `80` of the `nginx` pod:

```shell
kubectl port-forward $POD_NAME 8080:80
```

> output

```shell
Forwarding from [::1]:8080 -> 80
```

In a new terminal make an HTTP request using the forwarding address:

```shell
curl --head http://127.0.0.1:8080
```

> output

```shell
HTTP/1.1 200 OK
Cache-Control: no-cache, private
Content-Type: application/json
Date: Thu, 23 Jul 2020 13:53:44 GMT
```

Switch back to the previous terminal and stop the port forwarding to the `nginx` pod:

```shell
Forwarding from 127.0.0.1:8080 -> 80
Forwarding from [::1]:8080 -> 80
Handling connection for 8080
^C
```

### Logs

In this section you will verify the ability to [retrieve container logs](https://kubernetes.io/docs/concepts/cluster-administration/logging/).

Print the `nginx` pod logs:

```shell
kubectl logs $POD_NAME
```

> output

```shell
127.0.0.1 - - [23/Feb/2020:12:15:34 +0000] "HEAD / HTTP/1.1" 200 0 "-" "curl/7.68.0" "-"
```

### Exec

In this section you will verify the ability to [execute commands in a container](https://kubernetes.io/docs/tasks/debug-application-cluster/get-shell-running-container/#running-individual-commands-in-a-container).

Print the nginx version by executing the `nginx -v` command in the `nginx` container:

```shell
kubectl exec -ti $POD_NAME -- nginx -v
```

> output

```shell
nginx version: nginx/1.19.1
```

## Services

In this section you will verify the ability to expose applications using a [Service](https://kubernetes.io/docs/concepts/services-networking/service/).

Expose the `nginx` deployment using a [NodePort](https://kubernetes.io/docs/concepts/services-networking/service/#nodeport) service:

```shell
kubectl expose pod $POD_NAME --port 80 --type NodePort
```

> The LoadBalancer service type can not be used because your cluster is not configured with [cloud provider integration](https://kubernetes.io/docs/concepts/cluster-administration/cloud-providers/#azure). Setting up cloud provider integration is out of scope for this tutorial.

Retrieve the node port assigned to the `nginx` service:

```shell
NODE_PORT=$(kubectl get svc nginx \
  --output=jsonpath='{range .spec.ports[0]}{.nodePort}')
```

Create a firewall rule that allows remote access to the `nginx` node port:

```shell
az network nsg rule create -g kubernetes \
  -n kubernetes-allow-nginx \
  --access allow \
  --destination-address-prefix '*' \
  --destination-port-range ${NODE_PORT} \
  --direction inbound \
  --nsg-name kubernetes-nsg \
  --protocol tcp \
  --source-address-prefix '*' \
  --source-port-range '*' \
  --priority 1002
```

Retrieve the external IP address of a worker instance:

```shell
EXTERNAL_IP=$(az network public-ip show -g kubernetes \
  -n worker-0-pip --query "ipAddress" -otsv)
```

Make an HTTP request using the external IP address and the `nginx` node port:

```shell
curl -I http://$EXTERNAL_IP:$NODE_PORT
```

> output

```shell
HTTP/1.1 200 OK
Server: nginx/1.17.8
Date: Sun, 23 Feb 2020 12:17:18 GMT
Content-Type: text/html
Content-Length: 612
Last-Modified: Tue, 21 Jan 2020 13:36:08 GMT
Connection: keep-alive
ETag: "5e26fe48-264"
Accept-Ranges: bytes
```

Next: [Dashboard Configuration](14-dashboard.md)
