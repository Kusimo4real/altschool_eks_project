# ############################
# # IAM Policy for ALB Controller
# ############################
# resource "aws_iam_policy" "alb_controller" {
#   name        = "AWSLoadBalancerControllerIAMPolicy"
#   description = "Policy for AWS Load Balancer Controller"
#   policy      = file("utils/aws-lb-controller/iam-policy.json")
# }

# ############################
# # IAM Role for ALB Controller
# ############################
# resource "aws_iam_role" "alb_controller_role" {
#   name = "alb-controller-role"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Effect = "Allow",
#         Principal = {
#           Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}"
#         },
#         Action = "sts:AssumeRoleWithWebIdentity",
#         Condition = {
#           StringEquals = {
#             "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:sub" = "system:serviceaccount:kube-system:aws-load-balancer-controller"
#           }
#         }
#       }
#     ]
#   })
# }

# ############################
# # Attach Policy to Role
# ############################
# resource "aws_iam_role_policy_attachment" "alb_controller_attach" {
#   role       = aws_iam_role.alb_controller_role.name
#   policy_arn = aws_iam_policy.alb_controller.arn
# }

# ############################
# # Service Account for ALB Controller
# ############################
# resource "kubernetes_service_account" "alb_controller_sa" {
#   metadata {
#     name      = "aws-load-balancer-controller"
#     namespace = "kube-system"
#     annotations = {
#       "eks.amazonaws.com/role-arn" = aws_iam_role.alb_controller_role.arn
#     }
#   }
# }

# ############################
# # Helm Release for ALB Controller
# ############################
# resource "helm_release" "aws_lb_controller" {
#   name       = "aws-load-balancer-controller"
#   repository = "https://aws.github.io/eks-charts"
#   chart      = "aws-load-balancer-controller"
#   namespace  = "kube-system"

#   values = [
#     yamlencode({
#       clusterName    = module.eks.cluster_name
#       region         = local.region
#       vpcId          = aws_vpc.altsch_vpc.id
#       serviceAccount = {
#         create = false
#         name   = kubernetes_service_account.alb_controller_sa.metadata[0].name
#       }
#     })
#   ]

#   depends_on = [
#     kubernetes_service_account.alb_controller_sa,
#     aws_iam_role_policy_attachment.alb_controller_attach
#   ]
# }

# ############################
# # Data Sources
# ############################
# data "aws_caller_identity" "current" {}



# MORE EXPLANATION
# Instead of module.vpc.vpc_id
# vpc_id = aws_vpc.my_vpc.id

# # Instead of module.eks.cluster_name
# cluster_name = aws_eks_cluster.my_cluster.name

# # Instead of module.eks.cluster_oidc_issuer_url
# provider_url = replace(aws_eks_cluster.my_cluster.identity[0].oidc[0].issuer, "https://", "")
