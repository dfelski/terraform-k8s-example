## Simple Terraform Kubernetes example using minikube

Required software
- minikube: https://minikube.sigs.k8s.io/docs/start/
- terraform: https://www.terraform.io/

### Minikube setup
Install minikube depending on your OS and then start it (this may take a while for the first time)
```
minikube start
```

Enable ingress (must be done only once)
```
minikube addons enable ingress
```

### Let's go

Initiate terraform. Must be done only once and again if you change anything reagrding e.g. terraform provider setup. Ensure that the kubernetes provider config is correct.

```
terraform init
```

Create a deployment via terraform
```
terraform apply --auto-approve
```

Enable HTTP access for service `nginx` in namespace `bob`
```
minikube service -n bob nginx - url
```

Enjoy nginx ;)