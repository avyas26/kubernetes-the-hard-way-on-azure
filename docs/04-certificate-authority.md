# Provisioning a CA and Generating TLS Certificates

In this lab we will provision a [PKI Infrastructure](https://en.wikipedia.org/wiki/Public_key_infrastructure) using OpenSSL, then use it to bootstrap a Certificate Authority, and generate TLS certificates for the following components: etcd, kube-apiserver, kubelet, and kube-proxy.

# Client Machine

We will be using master-1 virtual machine to generate the certificates and transfer them to other nodes as required.

```shell
ssh kubeadmin@<-Public-IP-of-Master-1->
kubeadmin@master-1:~$ mkdir certs
kubeadmin@master-1:~$ cd certs
```

## Certificate Authority

In this section you will provision a Certificate Authority that can be used to generate additional TLS certificates.
Modify the openssl.cnf file, Generate CA certificate and private key:

```shell
{
openssl genrsa -out ca.key 2048
openssl req -new -key ca.key -subj "/CN=KUBERNETES-CA" -out ca.csr
openssl x509 -req -in ca.csr -signkey ca.key -CAcreateserial  -out ca.crt -days 1000
}

ls
ca.crt  ca.csr  ca.key
```

## Client and Server Certificates

In this section you will generate client and server certificates for each Kubernetes component and a client certificate for the Kubernetes `admin` user.

### The Admin Client Certificate

Generate the `admin` client certificate and private key:

```shell
{
openssl genrsa -out admin.key 2048
openssl req -new -key admin.key -subj "/CN=admin/O=system:masters" -out admin.csr
openssl x509 -req -in admin.csr -CA ca.crt -CAkey ca.key -CAcreateserial  -out admin.crt -days 1000
}

ls admin.*
admin.crt  admin.csr  admin.key
```
### The Kubelet Client Certificates

Kubernetes uses a [special-purpose authorization mode](https://kubernetes.io/docs/admin/authorization/node/) called Node Authorizer, that specifically authorizes API requests made by [Kubelets](https://kubernetes.io/docs/concepts/overview/components/#kubelet). In order to be authorized by the Node Authorizer, Kubelets must use a credential that identifies them as being in the `system:nodes` group, with a username of `system:node:<nodeName>`. In this section you will create a certificate for each Kubernetes worker node that meets the Node Authorizer requirements.

Generate a certificate and private key for each Kubernetes worker node:

```shell
for i in 1 2; \
do \
cat > openssl-worker-$i.cnf <<EOF
[req]
req_extensions = v3_req
distinguished_name = req_distinguished_name
[req_distinguished_name]
[ v3_req ]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName = @alt_names
[alt_names]
DNS.1 = worker-$i
IP.1 = 10.240.0.2$i
EOF
done

for i in 1 2; \
do \
openssl genrsa -out worker-$i.key 2048

openssl req -new -key worker-$i.key -subj "/CN=system:node:worker-$i/O=system:nodes" \
-out worker-$i.csr -config openssl-worker-$i.cnf

openssl x509 -req -in worker-$i.csr -CA ca.crt -CAkey ca.key -CAcreateserial  \
-out worker-$i.crt -extensions v3_req -extfile openssl-worker-$i.cnf -days 1000; \
done

ls worker*

worker-1.crt  worker-1.csr  worker-1.key  worker-2.crt  worker-2.csr  worker-2.key
```

### The Controller Manager Client Certificate

Generate the `kube-controller-manager` client certificate and private key:

```shell
{
openssl genrsa -out kube-controller-manager.key 2048
openssl req -new -key kube-controller-manager.key -subj "/CN=system:kube-controller-manager" -out kube-controller-manager.csr
openssl x509 -req -in kube-controller-manager.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out kube-controller-manager.crt -days 1000
}

ls kube-controller*
kube-controller-manager.crt  kube-controller-manager.csr  kube-controller-manager.key
```

### The Kube Proxy Client Certificate

Generate the `kube-proxy` client certificate and private key:

```shell
{
openssl genrsa -out kube-proxy.key 2048
openssl req -new -key kube-proxy.key -subj "/CN=system:kube-proxy" -out kube-proxy.csr
openssl x509 -req -in kube-proxy.csr -CA ca.crt -CAkey ca.key -CAcreateserial  -out kube-proxy.crt -days 1000
}

ls kube-proxy*
kube-proxy.crt  kube-proxy.csr  kube-proxy.key
```

### The Scheduler Client Certificate

Generate the `kube-scheduler` client certificate and private key:

```shell
{
openssl genrsa -out kube-scheduler.key 2048
openssl req -new -key kube-scheduler.key -subj "/CN=system:kube-scheduler" -out kube-scheduler.csr
openssl x509 -req -in kube-scheduler.csr -CA ca.crt -CAkey ca.key -CAcreateserial  -out kube-scheduler.crt -days 1000
}

ls kube-scheduler*
kube-scheduler.crt  kube-scheduler.csr  kube-scheduler.key
```

### The Kubernetes API Server Certificate

The `kubernetes-the-hard-way` static IP address will be included in the list of subject alternative names for the Kubernetes API Server certificate. This will ensure the certificate can be validated by remote clients.

Retrieve the `kubernetes-the-hard-way` static IP address. We had created this in [Provisioning Compute Resources](02-compute-resources.md#Kubernetes-Public-IP-Address) lab.

```shell
az network public-ip show -g kubernetes -n kubernetes-pip --query "ipAddress" -otsv
```

Create the Kubernetes API Server conf file:

```shell
PIPADDR=<-Add-Public-IP-here->

cat > openssl-kubeapiserver.cnf <<EOF
[req]
req_extensions = v3_req
distinguished_name = req_distinguished_name
[req_distinguished_name]
[ v3_req ]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName = @alt_names
[alt_names]
DNS.1 = kubernetes
DNS.2 = kubernetes.default
DNS.3 = kubernetes.default.svc
DNS.4 = kubernetes.default.svc.cluster.local
IP.1 = 10.32.0.1
IP.2 = 10.240.0.11
IP.3 = 10.240.0.12
IP.4 = ${PIPADDR}
IP.5 = 127.0.0.1
EOF

```

Generate the Kubernetes API Server certificate and private key:

```shell
{
openssl genrsa -out kube-apiserver.key 2048

openssl req -new -key kube-apiserver.key -subj "/CN=kube-apiserver" \
-out kube-apiserver.csr -config openssl-kubeapiserver.cnf

openssl x509 -req -in kube-apiserver.csr -CA ca.crt -CAkey ca.key -CAcreateserial  \
-out kube-apiserver.crt -extensions v3_req -extfile openssl-kubeapiserver.cnf -days 1000
}

ls kube-api*
kube-apiserver.crt  kube-apiserver.csr  kube-apiserver.key
```

## The Service Account Key Pair

The Kubernetes Controller Manager leverages a key pair to generate and sign service account tokens as described in the [managing service accounts](https://kubernetes.io/docs/admin/service-accounts-admin/) documentation.

Generate the `service-account` certificate and private key:

```shell
{
openssl genrsa -out service-account.key 2048
openssl req -new -key service-account.key -subj "/CN=service-accounts" -out service-account.csr
openssl x509 -req -in service-account.csr -CA ca.crt -CAkey ca.key -CAcreateserial  -out service-account.crt -days 1000
}

ls service-*
service-account.crt  service-account.csr  service-account.key
```

## Distribute the Client and Server Certificates

There is no connectivity established between VMs so we will establish passwordless SSH.
Generate the keys on ```master-1``` server where we have created the certs.

```shell
ssh-keygen -b 2048 -t rsa -f ~/.ssh/id_rsa -q -N ""
```
Copy the key to establish passwordless connectivity

```shell
for srv in master-2 worker-1 worker-2; \
do \
ssh-copy-id ${srv}; \
done
```
> Validate the connectivity once done

```shell
for srv in master-2 worker-1 worker-2; \
do \
ssh ${srv} "hostname -s" ;\
done

output:
master-2
worker-1
worker-2
```
Copy ca.crt & worker* to respective worker nodes and ca.crt ca.key kube-apiserver.crt kube-apiserver.key service-account.crt service-account.key to second master node

```shell
{
for i in 1 2; \
do \
scp certs/ca.crt certs/worker-$i* kubeadmin@worker-$i:/home/kubeadmin/; \
done
scp certs/ca.* certs/kube-apiserver* certs/service-account* kubeadmin@master-2:/home/kubeadmin/
}
```

> The `kube-proxy`, `kube-controller-manager`, `kube-scheduler`, and `kubelet` client certificates will be used to generate client authentication configuration files in the next lab.

Next: [Generating Kubernetes Configuration Files for Authentication](05-kubernetes-configuration-files.md)
