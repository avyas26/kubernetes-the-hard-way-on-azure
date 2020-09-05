# Kubernetes The Hard Way on Azure

This tutorial walks you through setting up Kubernetes the hard way. This guide is not for people looking for a fully automated command to bring up a Kubernetes cluster. If that's you then check out [Azure Container Services](https://azure.microsoft.com/en-us/services/container-service), or the [Getting Started Guides](http://kubernetes.io/docs/getting-started-guides).

This tutorial uses [Microsoft Azure](https://azure.microsoft.com) and [Azure CLI 2.0](https://github.com/azure/azure-cli).
It is a fork from [Kubernetes The Hard Way on Azure](https://github.com/ivanfioravanti/kubernetes-the-hard-way-on-azure) and has references from [Kubernetes The Hard Way On VirtualBox](https://github.com/mmumshad/kubernetes-the-hard-way).

In this tutorial I have used [Docker](https://www.docker.com/) container run-time and [Weave](https://www.weave.works/docs/net/latest/kubernetes/kube-addon/) CNI which is different from the original one. 

Kubernetes The Hard Way is optimized for learning, which means taking the long route to ensure you understand each task required to bootstrap a Kubernetes cluster.

> The results of this tutorial should not be viewed as production ready, and may receive limited support from the community, but don't let that stop you from learning!

## Target Audience

The target audience for this tutorial is someone planning to support a production Kubernetes cluster and wants to understand how everything fits together.

## Cluster Details

Kubernetes The Hard Way guides you through bootstrapping a highly available Kubernetes cluster with end-to-end encryption between components and RBAC authentication.

* [Kubernetes](https://github.com/kubernetes/kubernetes) 1.19.0
* [Docker-CE](https://kubernetes.io/docs/setup/production-environment/container-runtimes/) 19.03.11
* [etcd](https://github.com/etcd-io/etcd/releases/tag/v3.4.9) v3.4.9
* [CoreDNS](https://coredns.io/)

## Labs

This tutorial assumes you have access to the [Microsoft Azure](https://azure.microsoft.com). While Azure is used for basic infrastructure requirements the lessons learned in this tutorial can be applied to other platforms.

* [Prerequisites](docs/01-prerequisites.md)
* [Provisioning Azure infrastructure using Terraform (Optional)](docs/Terraform.md)
* [Provisioning Compute Resources](docs/02-compute-resources.md)
* [Installing the Client Tools](docs/03-client-tools.md)
* [Provisioning the CA and Generating TLS Certificates](docs/04-certificate-authority.md)
* [Generating Kubernetes Configuration Files for Authentication](docs/05-kubernetes-configuration-files.md)
* [Generating the Data Encryption Config and Key](docs/06-data-encryption-keys.md)
* [Bootstrapping the etcd Cluster](docs/07-bootstrapping-etcd.md)
* [Bootstrapping the Kubernetes Control Plane](docs/08-bootstrapping-kubernetes-controllers.md)
* [Bootstrapping the Kubernetes Worker Nodes](docs/09-bootstrapping-kubernetes-workers.md)
* [Configuring kubectl for Remote Access](docs/10-configuring-kubectl.md)
* [Deploy Pod Networking Solution](docs/11-Deploy-networking-solution.md)
* [Deploying the DNS Cluster Add-on](docs/12-dns-addon.md)
* [Smoke Test](docs/13-smoke-test.md)
* [Kubernetes Dashboard (Optional)](docs/Dashboard.md)
* [Cleaning Up](docs/14-cleanup.md)
