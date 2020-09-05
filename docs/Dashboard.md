# Install kubernetes dashboard add-on

### Kubernetes Dashboard Installation

[Kubernetes Dashboard](https://github.com/kubernetes/dashboard#kubernetes-dashboard) is a general purpose, web-based UI for Kubernetes clusters. It allows users to manage applications running in the cluster and troubleshoot them, as well as manage the cluster itself.

On ```master-1``` node run the below command:

```shell
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.4/aio/deploy/recommended.yaml
```
> Output

```shell
namespace/kubernetes-dashboard created
serviceaccount/kubernetes-dashboard created
service/kubernetes-dashboard created
secret/kubernetes-dashboard-certs created
secret/kubernetes-dashboard-csrf created
secret/kubernetes-dashboard-key-holder created
configmap/kubernetes-dashboard-settings created
role.rbac.authorization.k8s.io/kubernetes-dashboard created
clusterrole.rbac.authorization.k8s.io/kubernetes-dashboard created
rolebinding.rbac.authorization.k8s.io/kubernetes-dashboard created
clusterrolebinding.rbac.authorization.k8s.io/kubernetes-dashboard created
deployment.apps/kubernetes-dashboard created
service/dashboard-metrics-scraper created
deployment.apps/dashboard-metrics-scraper created
```

### Create service account and role binding to access dashboard

On ```master-1``` node run the below commands:

```shell
cat > dashboard-adminuser.yaml <<EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-user
  namespace: kubernetes-dashboard
EOF
```

```shell
cat > dashboard-adminuser-rolebinding.yaml <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin-user
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: admin-user
  namespace: kubernetes-dashboard
EOF
```

```shell
kubectl apply -f dashboard-adminuser.yaml
kubectl apply -f dashboard-adminuser-rolebinding.yaml
```

> Output

```shell
serviceaccount/admin-user created
clusterrolebinding.rbac.authorization.k8s.io/admin-user created
```

### Edit the kubernetes-dashboard service

By default kubernetes-dashboard service is of type ```ClusterIP```. Edit and change it to ```NodePort```

```shell
kubectl edit -n kubernetes-dashboard service kubernetes-dashboard
```
> Output

```shell
......
  sessionAffinity: None
  type: NodePort
status:
  loadBalancer: {}
```

```shell
kubectl get svc -n kubernetes-dashboard
```
> Output

```shell
NAME                        TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)         AGE
dashboard-metrics-scraper   ClusterIP   10.96.0.14    <none>        8000/TCP        127m
kubernetes-dashboard        NodePort    10.96.0.247   <none>        443:32447/TCP   127m
```

### Get the node on which the pod is deployed and the port it is exposed on

```shell
kubectl get pods -l k8s-app=kubernetes-dashboard -n kubernetes-dashboard -o jsonpath="{.items[*].spec.nodeName}"
```
> Output:

```shell
worker-2
```

```shell
kubectl get svc -n kubernetes-dashboard -l k8s-app=kubernetes-dashboard -o jsonpath="{.items[*].spec.ports[*].nodePort}"
```
> Output:

```shell
32447
```

> In your cluster the node and port could be different from above output.

### Generate the Bearer Token for Login to UI. Run the below command on ```master-1``` node

```shell
kubectl -n kubernetes-dashboard describe secret $(kubectl -n kubernetes-dashboard get secret | grep admin-user | awk '{print $1}')
```
> Output:

```shell
Name:         admin-user-token-qjf57
Namespace:    kubernetes-dashboard
Labels:       <none>
Annotations:  kubernetes.io/service-account.name: admin-user
              kubernetes.io/service-account.uid: 8d59fdf1-a53f-430b-8c37-d4f33cffa2c4

Type:  kubernetes.io/service-account-token

Data
====
ca.crt:     989 bytes
namespace:  20 bytes
token:      eyJhbGciOiJSUzI1NiIsImtpZCI6IkRlVmJqV05ZY2QzaS1mWmJza1hzTzVUeE5kNnZJTnlPYlZuWEcyNDViazQifQ.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJrdWJlcm5ldGVzLWRhc2hib2FyZCIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VjcmV0Lm5hbWUiOiJhZG1pbi11c2VyLXRva2VuLXFqZjU3Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZXJ2aWNlLWFjY291bnQubmFtZSI6ImFkbWluLXVzZXIiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC51aWQiOiI4ZDU5ZmRmMS1hNTNmLTQzMGItOGMzNy1kNGYzM2NmZmEyYzQiLCJzdWIiOiJzeXN0ZW06c2VydmljZWFjY291bnQ6a3ViZXJuZXRlcy1kYXNoYm9hcmQ6YWRtaW4tdXNlciJ9.CsrokQieobeCSJj7fnSsSObGcMgp8yZyB9DJMirFYzVqBt9n0jTXIIHp4OEWQ7Lvp3oL5RyHxzi4HcnYBOM80UaSk2-SdktGPJZ-pYMqHz5k8BIo4HmELSg0hDvmC5nNlrKuF5AQwbg5mAfjNE_aTrIP5KWBi-lBWxsFF7mgNSMZeq0W3Dk8ivsROcWYfyzb2LDa0fiSqqaIGRsufHamKGASfLZMDxgn_foV1uRTB1qBPDm3SK76zIsp8_8C-CR1PFC94W0XRwiz_l6Zf6YIEO0r9YHE2mrE0A8LMYfuFCbMce-qO92W8wmXigATHrhY6vVLftTAONiNgferE4GMBg
```

Fetch the public IP for ```worker-2``` node as our pod is running on it

```shell
az vm show -d -g kubernetes --name worker-2 --query publicIps -o tsv
```

In the browser enter the IP address fetched from above command and NodePort fetched from the kubernetes-dashboard service.

> https://worker-2-public-IP:32447
  
You should see Login page as below. Enter the bearer token generated and and click on ```Sign in```

![Login Page](/config/login_page.PNG)

You should see the ```Dashboard```

![Dashboard](/config/welcome_page.PNG)

Next: [Cleaning Up](14-cleanup.md)
