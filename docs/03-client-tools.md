# Installing the Client Tools

In this lab we will use `master-1` server as our client machine to generate SSL certificates and kubeconfigs.
Get the public Ip and connect to server.

```shell
master1=`az vm show -d -g kubernetes --name master-1 --query publicIps -o tsv | tr -d [:space:]`
```
```shell
ssh kubeadmin@$master1
```
> output

```shell
kubeadmin@52.187.52.193's password:
X11 forwarding request failed on channel 0
[kubeadmin@master-1 ~]$
```
It should have OpenSSL installed by default. Verify if it's installed:

```shell
openssl version
```
> output

```shell
OpenSSL 1.0.2k-fips  26 Jan 2017
```
## Install kubectl

The `kubectl` command line utility is used to interact with the Kubernetes API Server. Download and install `kubectl` from the official release binaries:

```shell
{
curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
sudo mv kubectl /usr/local/bin/
sudo chmod +x /usr/local/bin/kubectl
}
```
### Verification

```shell
kubectl version --client
```
> output

```shell
Client Version: version.Info{Major:"1", Minor:"19", GitVersion:"v1.19.0", GitCommit:"e19964183377d0ec2052d1f1fa930c4d7575bd50", GitTreeState:"clean", BuildDate:"2020-08-26T14:30:33Z", GoVersion:"go1.15", Compiler:"gc", Platform:"linux/amd64"}
```

To quick check kubectl version, you can also use the following command : 

```shell
kubectl version --short
```

> output

```shell
Client Version: v1.19.0
The connection to the server localhost:8080 was refused - did you specify the right host or port?
```

Next: [Certificate Authority](04-certificate-authority.md)
