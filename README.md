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
