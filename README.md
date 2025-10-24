## Project summary — what this repo contains and what you did

This README has been trimmed to only describe the artifacts present in this repository and the actions you performed here.

What is in this repository
- `infra/` — Terraform configurations used in this project. Key files you created/used include:
  - `vpc.tf`, `subnets.tf`, `igw.tf`, `routes.tf`, `natgw.tf` — networking
  - `eks.tf` — EKS cluster resource and IAM role definitions (note: contains an `access_config` block in your copy; this is unsupported by the upstream provider and should be removed before apply)
  - `alb.tf`, `alb-role.tf` — ALB related resources and IAM role for the ingress controller
  - `providers.tf`, `locals.tf`, `user.tf`, `nodes_iamroles.tf`, `iam-policy.json`, `trust-policy.json` — provider and IAM pieces
  - `remote-backend/` — example S3/DynamoDB backend configuration for storing Terraform state remotely

- `k8s-manifest/` — Kubernetes manifests you included:
  - `ingress.yaml` — ALB ingress manifest
  - `viewer-cluster-role.yaml` and `viewer-cluster-role-binding.yaml` — example RBAC resources

What you did in this project (actions recorded here)
- Wrote Terraform configurations to provision VPC networking, subnets, NAT/IGW, and an EKS cluster.
- Created IAM roles and policies required for EKS and the ALB ingress controller (files in `infra/`).
- Included a remote backend example under `infra/remote-backend/` to store Terraform state in S3 with DynamoDB locking.
- Added Kubernetes manifests for an ALB ingress and example RBAC rules under `k8s-manifest/`.

Quick commands you used or will use (as part of this repo)
- Initialize Terraform (from `infra/`):

  ```bash
  cd infra
  terraform init
  terraform plan
  terraform apply
  ```

- After the EKS cluster exists, update kubeconfig (use the exact cluster name from your Terraform state):

  ```bash
  aws eks update-kubeconfig --region eu-west-2 --name <cluster-name>
  ```

- Deploy the manifests you added:

  ```bash
  kubectl create namespace retail-dev || true
  kubectl apply -n retail-dev -f k8s-manifest/
  ```

Important notes (directly relevant to what you have in the repo)
- The `access_config` block in `infra/eks.tf` (if present) is unsupported by the `aws_eks_cluster` resource and will cause Terraform to fail. Remove that block before running `terraform apply`.
- If `aws eks update-kubeconfig` reports "No cluster found for name", confirm the cluster name with:

  ```bash
  cd infra
  terraform state show aws_eks_cluster.eks
  # or list clusters
  aws eks list-clusters --region eu-west-2
  ```

Want this even shorter or in a different format?
- I can reduce this to a one-page checklist, convert it to a CHANGELOG-style summary of your steps, or add a small `Makefile` with the commands above. Tell me which and I'll add it.
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
