# Installing the Client Tools

In this lab we will use `master-1` server as our client machine to generate SSL certificates and kubeconfigs.
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
Client Version: version.Info{Major:"1", Minor:"18", GitVersion:"v1.18.6", GitCommit:"dff82dc0de47299ab66c83c626e08b245ab19037", GitTreeState:"clean", BuildDate:"2020-07-15T16:58:53Z", GoVersion:"go1.13.9", Compiler:"gc", Platform:"linux/amd64"}
```

To quick check kubectl version, you can also use the following command : 

```shell
kubectl version --short
```

> output

```shell
Client Version: v1.18.6
```

Next: [Certificate Authority](04-certificate-authority.md)
