# Installing the Client Tools

In this lab we will use `master-1` server as our client machine to generate SSL certificates and kubeconfigs.
It should have OpenSSL installed by default. Verify if it's installed:

```shell
openssl version
```
> output

```shell
OpenSSL 1.1.1  11 Sep 2018
```
## Install kubectl

The `kubectl` command line utility is used to interact with the Kubernetes API Server. Download and install `kubectl` from the official release binaries:

```shell
curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
sudo mv kubectl /usr/local/bin/
sudo chmod +x /usr/local/bin/kubectl
```
### Verification

```shell
kubectl version --client
```
> output

```shell
Client Version: version.Info{Major:"1", Minor:"18", GitVersion:"v1.18.4", GitCommit:"c96aede7b5205121079932896c4ad89bb93260af", GitTreeState:"clean", BuildDate:"2020-06-17T11:41:22Z", GoVersion:"go1.13.9", Compiler:"gc", Platform:"linux/amd64"}
```

To quick check kubectl version, you can also use the following command : 

```shell
kubectl version --short
```

> output

```shell
Client Version: v1.18.4
```

Next: [Certificate Authority](04-certificate-authority.md)
