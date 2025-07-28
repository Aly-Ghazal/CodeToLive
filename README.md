# CodeToLive

Created By: [Aly Ghazal](https://www.linkedin.com/in/aly-ghazal/)

The purpose of this task is to demonstrate my skills in provisioning infra in Azure and create a secure CI/CD pipeline via GitHub actions to deploy a flask app which is in this repo

https://github.com/Aly-Ghazal/Microservices

## Infra & Terraform Module Structure

## VM setup as GitHub action self-hosted runner and to access cluster

## CI/CD pipeline using GitHub actions

## Cleanup

One of the benefits of using terraform or IaC in general is the ability to provision and destroy the entire infra with a single command and in this case we can cleanup the following infra by using a single command as following

```
terraform destroy
```

## Future work

- For CD pipeline instead of using GitHub actions it would be more efficient if we used ArgoCD not to only deploy application's new versions but also to keep track of the deployed K8s objects by making git as the single source of truth

- Use HashiCorp packer to create a machine image that includes all the needed tools and setup on the VM that is used as GitHub actions self-hosted runner and the needed tools in the pipeline

- finally we need to consider to use Velero as a solution for backing up and restoring Kubernetes cluster resources which include simplifying cluster migrations, consistent data snapshots, and ensuring business continuity for your Kubernetes workloads.
