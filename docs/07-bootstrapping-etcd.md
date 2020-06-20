# Bootstrapping the etcd Cluster

Kubernetes components are stateless and store cluster state in [etcd](https://github.com/etcd-io/etcd). In this lab you will bootstrap a two node etcd cluster and configure it for high availability and secure remote access.

## Prerequisites

The commands in this lab must be run on each master node: `master-1` and `master-2`. Login to each master node using the `az` command to find its public IP and ssh to it. Example:

```shell
az network public-ip show -g kubernetes -n master-1-pip --query "ipAddress" -otsv

ssh -i id_rsa kubeadmin@<-Output-of-above-command->
```

## Bootstrapping an etcd Cluster Member

### Download and Install the etcd Binaries

Download the official etcd release binaries from the [etcd-io/etcd](https://github.com/etcd-io/etcd) GitHub project:

```shell
wget -q --show-progress --https-only --timestamping "https://github.com/etcd-io/etcd/releases/download/v3.4.9/etcd-v3.4.9-linux-amd64.tar.gz"
```

Extract and install the `etcd` server and the `etcdctl` command line utility:

```shell
{
  tar -xvf etcd-v3.4.9-linux-amd64.tar.gz
  sudo mv etcd-v3.4.9-linux-amd64/etcd* /usr/local/bin/
}
```

### Configure the etcd Server

```shell
{
  sudo mkdir -p /etc/etcd /var/lib/etcd
  sudo cp certs/ca.crt certs/kube-apiserver.crt certs/kube-apiserver.key /etc/etcd/
}
```

The instance internal IP address will be used to serve client requests and communicate with etcd cluster peers. Retrieve the internal IP address for the current compute instance:

```shell
INTERNAL_IP=$(ip addr show eth0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
```

Each etcd member must have a unique name within an etcd cluster. Set the etcd name to match the hostname of the current compute instance:

```shell
ETCD_NAME=$(hostname -s)
```

Create the `etcd.service` systemd unit file:

```shell
cat > etcd.service <<EOF
[Unit]
Description=etcd
Documentation=https://github.com/coreos

[Service]
ExecStart=/usr/local/bin/etcd \\
  --name ${ETCD_NAME} \\
  --cert-file=/etc/etcd/kube-apiserver.crt \\
  --key-file=/etc/etcd/kube-apiserver.key \\
  --peer-cert-file=/etc/etcd/kube-apiserver.crt \\
  --peer-key-file=/etc/etcd/kube-apiserver.key \\
  --trusted-ca-file=/etc/etcd/ca.crt \\
  --peer-trusted-ca-file=/etc/etcd/ca.crt \\
  --peer-client-cert-auth \\
  --client-cert-auth \\
  --initial-advertise-peer-urls https://${INTERNAL_IP}:2380 \\
  --listen-peer-urls https://${INTERNAL_IP}:2380 \\
  --listen-client-urls https://${INTERNAL_IP}:2379,http://127.0.0.1:2379 \\
  --advertise-client-urls https://${INTERNAL_IP}:2379 \\
  --initial-cluster-token etcd-cluster-0 \\
  --initial-cluster master-1=https://10.240.0.11:2380,master-2=https://10.240.0.12:2380 \\
  --initial-cluster-state new \\
  --data-dir=/var/lib/etcd
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
```

### Start the etcd Server

```shell
sudo mv etcd.service /etc/systemd/system/
```

```shell
{
  sudo systemctl daemon-reload
  sudo systemctl enable etcd
  sudo systemctl start etcd
}
```

> Remember to run the above commands on each master node: `master-1` and `master-2`.

## Verification

List the etcd cluster members:

```shell
sudo ETCDCTL_API=3 etcdctl member list \
  --endpoints=https://${INTERNAL_IP}:2379 \
  --cacert=/etc/etcd/ca.crt \
  --cert=/etc/etcd/kube-apiserver.crt \
  --key=/etc/etcd/kube-apiserver.key
```

> output

```shell
3a57933972cb5131, started, master-2, https://10.240.0.12:2380, https://10.240.0.12:2379, false
ffed16798470cab5, started, master-1, https://10.240.0.11:2380, https://10.240.0.11:2379, false
```

Next: [Bootstrapping the Kubernetes Control Plane](08-bootstrapping-kubernetes-controllers.md)
