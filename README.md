## altschool_eks_project

Overview
--------
This repository contains Terraform infrastructure and Kubernetes manifests to provision and run a sample retail application on AWS EKS, fronted by an AWS Application Load Balancer (ALB). The infra is defined in `infra/` and the k8s manifests are in `k8s-manifest/`.

What you'll find
-----------------
- `infra/` - Terraform configs (VPC, subnets, NAT/IGW, EKS cluster, IAM roles, ALB-related resources and a remote backend)
- `infra/remote-backend/` - Terraform backend config for remote state (S3 + DynamoDB)
- `k8s-manifest/` - Kubernetes manifests (Ingress, RBAC, etc.) used to deploy the retail app

Quick summary
-------------
- Provision infrastructure with Terraform (S3 remote state supported)
- Create an EKS cluster and node IAM roles
- Deploy application manifests to the cluster and expose via ALB ingress

Prerequisites
-------------
- Terraform v1.0+ installed and configured
- AWS CLI v2 configured with credentials that have sufficient permissions
- kubectl installed
- An AWS account with permissions for EKS, EC2, IAM, S3, ACM, and ELB

Repository structure
--------------------
infra/
- `providers.tf` - provider and region configuration
- `vpc.tf`, `subnets.tf`, `igw.tf`, `routes.tf` - networking
- `eks.tf` - EKS cluster and IAM roles for the cluster
- `alb.tf`, `alb-role.tf` - ALB setup and IAM roles for ingress controller
- `remote-backend/` - backend configuration (S3/DynamoDB)

k8s-manifest/
- `ingress.yaml` - Ingress definition for ALB
- `viewer-cluster-role.yaml` / `viewer-cluster-role-binding.yaml` - example RBAC

How to use
----------
1. Configure your AWS credentials and region (example uses `eu-west-2`):

```bash
aws configure
# or use a named profile
aws configure --profile dev
```

2. Initialize Terraform (from `infra/`):

```bash
cd infra
terraform init
terraform plan
# review plan, then:
terraform apply
```

3. After Terraform creates the EKS cluster, update kubeconfig so kubectl can talk to it:

```bash
aws eks update-kubeconfig --region <region> --name <cluster-name>
# if you used a named profile:
aws eks update-kubeconfig --region <region> --name <cluster-name> --profile dev --alias dev-cluster
```

4. Deploy Kubernetes manifests:

```bash
kubectl apply -f ../k8s-manifest/ -n retail-dev
# create namespace first if needed
kubectl create namespace retail-dev || true
kubectl apply -f ../k8s-manifest/ -n retail-dev
```

Notes & known issues
--------------------
- Terraform remote state: this repo includes `infra/remote-backend/` with example S3/DynamoDB backend configuration. Ensure you have the S3 bucket and DynamoDB table (or let Terraform create them) and that your AWS credentials can access them.
- EKS `access_config` block: In some copies of `infra/eks.tf` there is an `access_config` block present. The AWS provider's `aws_eks_cluster` resource does not accept an `access_config` block — keeping it will cause Terraform apply to fail. If you see an `access_config` block in `infra/eks.tf`, remove it before running `terraform apply`.

Example: remove this unsupported block from `infra/eks.tf` if present:

```hcl
# access_config {
#   authentication_mode = "API"
#   bootstrap_cluster_creator_admin_permissions = true
# }
```

Troubleshooting
---------------
- Error updating kubeconfig ("No cluster found for name")
  - Confirm the cluster name: `terraform state show aws_eks_cluster.eks` or `aws eks list-clusters --region <region>`
  - Ensure you're in the correct AWS region
  - Confirm Terraform apply completed successfully and the `aws_eks_cluster` resource exists in state

- If ALB Ingress doesn't route traffic:
  - Check the AWS Load Balancer Controller is installed in the cluster
  - Confirm ingress annotations in `k8s-manifest/ingress.yaml` are correct and point to the right ACM certificate ARN (if using HTTPS)
  - Inspect ALB target groups health checks and security groups

Useful commands
---------------
- List clusters in a region:

```bash
aws eks list-clusters --region eu-west-2
```

- Show Terraform state for EKS resource (from `infra/`):

```bash
cd infra
terraform state show aws_eks_cluster.eks || true
```

- Update kubeconfig once you have cluster name and region:

```bash
aws eks update-kubeconfig --region eu-west-2 --name <cluster-name>
```

Where to look next
------------------
- Terraform files: `infra/` for infrastructure details
- Kubernetes manifests: `k8s-manifest/` for ingress and RBAC

Contributing
------------
- Open a PR with small, focused changes
- Run `terraform fmt` and `terraform validate` before opening a PR

License & contact
-----------------
This repo does not include an explicit license file. If you need one, add a LICENSE that fits your intended use.

If you want me to also:
- add a short Makefile wrapper for common terraform/kubectl commands
- add a GitHub Actions pipeline example for Terraform
I can create those in follow-up changes.

---

Generated README updated to reflect the repository layout and common commands.
# Technical Report: End-to-End Deployment of a Retail Application on AWS EKS with ALB Integration
[This is the link to my retail store at store.mijanscript.xyz](https://store.mijanscript.xyz/)
PS: If link does not work, the instance has likely been stopped to save cost

## Introduction
This report documents the complete process of deploying a containerized retail application to **Amazon Elastic Kubernetes Service (EKS)** using **Terraform for Infrastructure as Code (IaC)** and integrating it with the **AWS Application Load Balancer (ALB) Ingress Controller** for secure external access.  

The project showcases the following:
- Infrastructure provisioning with Terraform  
- EKS cluster setup and application deployment  
- Ingress routing with ALB and ACM-managed SSL certificates  
- CI/CD automation for Terraform using GitHub Actions  
- DNS integration with Namecheap for custom domain routing  

---

## 1. Infrastructure Provisioning with Terraform
Infrastructure was provisioned using **Terraform**, following a resource-based file structure instead of modules. Each AWS resource was defined in a dedicated file for clarity and maintainability:  

- **`vpc.tf`** → Defines the VPC and its CIDR block  
- **`subnets.tf`** → Creates public and private subnets across availability zones  
- **`igw.tf`** → Configures Internet Gateway for public subnet access  
- **`routes.tf`** → Sets up route tables and associations for traffic flow  
- **`eks.tf`** → Provisions the EKS cluster and worker node groups  
- **`providers.tf`** → Declares AWS provider configuration  
- **`locals.tf`** → Defines reusable variables and naming conventions  

Additionally, a **remote backend** was configured to store the Terraform state file securely. This ensured collaboration, state consistency, and disaster recovery capabilities.  

---

## 2. EKS Cluster Setup
The **Amazon EKS cluster** was created using the `eks.tf` definition. Key configurations included:  
- Worker node groups with auto-scaling  
- IAM roles and policies for EKS and worker nodes  
- Security groups for Kubernetes communication  

Once provisioned, the cluster configuration was updated locally with:  
```bash
aws eks update-kubeconfig --name <cluster-name> --region <region>
```

---

## 3. Application Deployment
The retail application (frontend `ui` and backend `api`) was containerized and deployed to the EKS cluster.  

### Kubernetes Manifests:
- **Namespace**: `retail-dev`  
- **Deployments**: Separate deployments for `ui` and `api` services  
- **Services**: Exposed via ClusterIP for internal communication  

---

## 4. Ingress and ALB Integration
The **AWS Load Balancer Controller** was installed to manage ingress traffic. The Ingress resource was annotated to:  
- Use an **internet-facing ALB**  
- Configure listeners on **HTTP (80)** and **HTTPS (443)**  
- Attach an **ACM-issued SSL certificate**  
- Define health check paths (`/health`)  

Example Ingress YAML snippet:
```yaml
annotations:
  kubernetes.io/ingress.class: alb
  alb.ingress.kubernetes.io/scheme: internet-facing
  alb.ingress.kubernetes.io/listen-ports: '[{"HTTP":80},{"HTTPS":443}]'
  alb.ingress.kubernetes.io/target-type: ip
  alb.ingress.kubernetes.io/certificate-arn: <certificate-arn>
```

---

## 5. SSL Certificate with ACM
A certificate for `store.mijanscript.xyz` was provisioned in **AWS Certificate Manager (ACM)**. Validation was completed via **CNAME DNS records** in Namecheap.  

Once validated, the certificate was attached to the ALB via Ingress annotations, enabling secure HTTPS access.  

---

## 6. DNS Configuration with Namecheap
Instead of Route 53, **Namecheap** was used for DNS management.  
- An **A record** was created for `store.mijanscript.xyz` pointing to the ALB’s DNS name.  
- DNS propagation ensured that both HTTP and HTTPS routes became accessible.  

---

## 7. CI/CD Pipeline for Terraform
A **GitHub Actions pipeline** was configured to automate Terraform operations. The workflow:  
1. On **push to a feature branch**:  
   - Runs `terraform fmt` to enforce code formatting  
   - Runs `terraform validate` to check syntax and indentation  
   - Executes `terraform plan` to detect changes  
2. On **merge to main**:  
   - Executes `terraform apply` to provision/update infrastructure  

This ensured safe, automated infrastructure deployments while maintaining high-quality Terraform code practices.  

---

## 8. Troubleshooting & Fixes
Several challenges were encountered and resolved:  
- **Ingress returning 404** → Fixed by ensuring correct service mapping and ALB reconciliation  
- **DNS not resolving** → Resolved by verifying Namecheap A records and propagation  
- **HTTPS not working** → Confirmed ALB Security Group allowed inbound traffic on port 443  

---

## Conclusion
This project successfully demonstrated the deployment of a retail application on AWS EKS using Terraform and GitHub Actions. Key achievements include:  
- Infrastructure as Code with Terraform using a file-per-resource approach  
- Secure, scalable application hosting on EKS  
- Automated CI/CD pipeline for infrastructure with GitHub Actions  
- Integration of Namecheap DNS with AWS ALB and ACM for SSL termination

### USER -ACCESS
- I provisioned an IAM user in AWS and integrated it with the Kubernetes cluster through RBAC (Role-Based Access Control). Using this setup, I bound the user’s AWS identity to a Kubernetes role, assigning permissions that allow the user to read, list, and describe cluster resources. This ensures secure, fine-grained access control while maintaining limited privilege.

#### User-Instructions
- 
- When you are in the aws console, you can create access to use in aws cli
-  On the user’s machine (or wherever they’ll use kubectl)
-  run "aws configure --profile dev-readonly and enter user access key and secret you created. region is eu-west-2
-  Set output format in json and this will store your credentials in ~/.aws/credentials
-  
##### Update Kubeconfig for your user
```
aws eks update-kubeconfig \
  --region eu-west-2 \
  --name your-cluster-name \
  --profile dev-readonly \
  --alias dev-readonly
```
  
- --profile dev-readonly tells AWS CLI to use the new IAM user.
- --alias adds a context name so you can easily switch in kubectl

  ##### Test Permissions
  ```
  kubectl get pods
  kubectl get pods --namespace retail-dev  #Add namespace as most of the services and deployments were deployed in retail-dev namespace
  ```
This deployment approach is production-ready and can be extended for scaling, monitoring, and further automation.  

---








# altschool_eks_project
