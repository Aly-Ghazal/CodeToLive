# CodeToLive

Created By: [Aly Ghazal](https://www.linkedin.com/in/aly-ghazal/)

The purpose of this task is to demonstrate my skills in provisioning infra in Azure and create a secure CI/CD pipeline via GitHub actions to deploy a flask app which is in this repo

https://github.com/Aly-Ghazal/Microservices

## Infra & Terraform Module Structure

![Full Infra](docs/images/1.jpg)

In this project we used Azure as a cloud provider and from the previous image we can conclude that our infrastructure components are:

- **Private Azure Kubernetes Service (AKS) Cluster**: API server not publicly exposed.
- **Dedicated Virtual Network (VNet) with Subnets**: For AKS, Azure Firewall, VM, and ACR private endpoints.
- **Network Security Groups (NSGs)**: Control traffic flow within subnets.
- **Azure Firewall**: Centralized outbound traffic control for AKS and VM. It also facilitates controlled inbound access to internal services via Destination Network Address Translation (DNAT) rules, forwarding external traffic from its public IP to specific internal Load Balancer endpoints within the VNet.
- **Internal Load Balancer**: Automatically provisioned by AKS, this component is responsible for exposing applications deployed within the AKS cluster to internal or DNAT-forwarded external traffic.
- **Azure VM**: Dedicated for running Git Actions pipelines and manage the cluster.
- **Azure Container Registry (ACR)**: Secured with a private endpoint for image storage.

Most of these infrastructure components are provisioned and managed using Terraform, ensuring a declarative, version-controlled, and automated deployment process.

and here are the commands the has done it

```
#To download necessary providers and needed modules
terraform init

#To review changes and observe expected results without excution
terraform plan

#To deploy the resources in Azure
terraform apply -auto-approve
```

except for the Internal LB which was deployed by the private AKS with credentials of "Network Contributor"

and the only thing was done manaully was creating the DNAT rule to forward the external traffic from firewall public ip and specific port to the internal LB private ip (which is in the same vnet with the firewall) and specific port

![DNAT rule](docs/images/2.png)

## APP Dockerization

![Multi-stage effect](docs/images/3.png)

## VM setup as GitHub action self-hosted runner and to access cluster

In the begining we need this VM to access other resources since all resources are private and only accessible with the VNet that host all those resources and using GitHub hosted runners won't be efficient since it can't access this infra to push new images in ACR or deploy apps in AKS.
From this needed we decided to use a Virual Machine as a self-hosted runner that come with other benefits like having all dependencies installed already and no need to wait for it to be up and running and many other benefits and also we can run multiple pipelines in the same VM so it is also cost efficient
Plus we can use it to access the cluster and debug it.
but How did we setup it?

1. we installed all the needed packages and tools that will be used by GitHub Actions pipeline and to access the cluster like: Git (obviously), Azure-cli, kubectl, docker, python, flake8, trivy.
2. we created a service Principal for the VM to have access on AKS and ACR (you will need to sign in with a privillaged account to create it)

```
az ad sp create-for-rbac --name "github-runner-sp" --query "{appId: appId, password: password, tenant: tenant}" --output json
```

after that we give it the needed credintials to access ACR and AKS

```
az role assignment create --assignee $SP_APP_ID --role "contributor" --scope $ACR_ID
az role assignment create --assignee $SP_APP_ID --role "contributor" --scope $AKS_ID
```

and then in the VM restore SP credinitials in ~/.bashrc (Not recommended at all and it's better to store it in Azure key vault)

```
export SP_APP_ID="xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
export SP_PASSWORD="xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
export SP_TENANT_ID="yyyyyyyy-yyyy-yyyy-yyyy-yyyyyyyyyyyy"
$ source ~/.bashrc
```

then login

```
az login --service-principal -u $SP_APP_ID -p $SP_PASSWORD --tenant $SP_TENANT_ID
```

then access ACR

```
az acr login --name $ACR_NAME
```

and finally access AKS by geting its creds (Kubeconfig)

```
az aks get-credentials --resource-group $RESOURCE_GROUP_NAME --name $AKS_NAME --overwrite-existing
```

Now to setup the VM to be a GitHub self-hosted runner

```
# Create a folder (Note: if you will use the same VM for Multiple Pipelines change the folder name)
$ mkdir actions-runner && cd actions-runner

# Download the latest runner package
$ curl -o actions-runner-linux-x64-2.326.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.326.0/actions-runner-linux-x64-2.326.0.tar.gz

# Optional: Validate the hash
$ echo "9c74af9b4352bbc99aecc7353b47bcdfcd1b2a0f6d15af54a99f54a0c14a1de8 actions-runner-linux-x64-2.326.0.tar.gz" | shasum -a 256 -c
# Extract the installer
$ tar xzf ./actions-runner-linux-x64-2.326.0.tar.gz

# Create the runner and start the configuration experience
$ ./config.sh --url $REPO-URL --token xxxxxxxxxxxxxxxxxxxxxxxxxx

# Last step, run it!
$ nohup ./run.sh &
```

and this is how the setup was done

## CI/CD pipeline using GitHub actions

## Cleanup

One of the benefits of using terraform or IaC in general is the ability to provision and destroy the entire infra with a single command and in this case we can cleanup the following infra by using a single command as following

```
terraform destroy
```

## Future work

- For CD pipeline instead of using GitHub actions it would be more efficient if we used **ArgoCD** not to only deploy application's new versions but also to keep track of the deployed K8s objects by making git as the single source of truth

- Use **HashiCorp packer** to create a machine image that includes all the needed tools and setup on the VM that is used as GitHub actions self-hosted runner and the needed tools in the pipeline

- finally we need to consider to use **Velero** as a solution for backing up and restoring Kubernetes cluster resources which include simplifying cluster migrations, consistent data snapshots, and ensuring business continuity for your Kubernetes workloads.
